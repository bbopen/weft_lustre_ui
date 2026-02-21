#!/usr/bin/env python3
"""
Package-interface contract verification for headless/styled module pairs.

Reads the Gleam package-interface JSON and verifies:
  1. Every headless public function exists in its styled counterpart
  2. Parameter labels follow the mirror contract:
     styled params == headless params  (config constructors, pipeline helpers)
     styled params == ["theme"] + headless params  (render functions)
  3. Return types match between headless and styled functions
  4. Parameter types match (positionally aligned, skipping the theme param)
  5. Types exported by headless appear in styled (re-export check)

The package-interface naturally excludes @internal functions, so only
the documented public API is checked.

Usage:
  gleam export package-interface --out build/interface.json
  python3 scripts/check-contracts.py build/interface.json
"""

import json
import sys

PACKAGE_PREFIX = "weft_lustre_ui"
HEADLESS_PREFIX = PACKAGE_PREFIX + "/headless/"

# Intentional contract deviations: styled functions that deliberately differ
# from the standard mirror contract. Skips label, return type, and parameter
# type checks. Each entry documents the reason.
CONTRACT_EXCEPTIONS = {
    # Styled button/link use "label" instead of headless "child" for clarity.
    (PACKAGE_PREFIX + "/button", "button"): "label rename: child -> label",
    (PACKAGE_PREFIX + "/link", "link"): "label rename: child -> label",
    # Styled alert_description adds a variant parameter for variant-specific styling.
    (PACKAGE_PREFIX + "/alert", "alert_description"): "extra variant param for styling",
}


def load_interface(path):
    with open(path) as f:
        return json.load(f)


def get_labels(params):
    """Extract parameter labels from a function's parameter list."""
    return [p.get("label", "") or "" for p in params]


def normalize_type(type_repr):
    """Normalize a type representation by collapsing headless module paths.

    Strips '/headless/' from module paths so that
    'weft_lustre_ui/headless/toggle' becomes 'weft_lustre_ui/toggle',
    making structurally identical types compare equal.
    """
    if not isinstance(type_repr, dict):
        return type_repr
    kind = type_repr.get("kind")
    if kind == "named":
        module = type_repr.get("module", "")
        normalized_module = module.replace("/headless/", "/")
        return {
            **type_repr,
            "module": normalized_module,
            "parameters": [normalize_type(p) for p in type_repr.get("parameters", [])],
        }
    if kind == "variable":
        return type_repr
    if kind == "tuple":
        return {
            **type_repr,
            "elements": [normalize_type(e) for e in type_repr.get("elements", [])],
        }
    if kind == "fn":
        return {
            **type_repr,
            "parameters": [normalize_type(p) for p in type_repr.get("parameters", [])],
            "return": normalize_type(type_repr.get("return", {})),
        }
    return type_repr


def format_type(type_repr):
    """Format a type representation as a human-readable Gleam-style string."""
    if not isinstance(type_repr, dict):
        return str(type_repr)
    kind = type_repr.get("kind")
    if kind == "named":
        name = type_repr.get("name", "?")
        params = type_repr.get("parameters", [])
        if params:
            return "%s(%s)" % (name, ", ".join(format_type(p) for p in params))
        return name
    if kind == "variable":
        return "var_%s" % type_repr.get("id", "?")
    if kind == "tuple":
        elems = type_repr.get("elements", [])
        return "#(%s)" % ", ".join(format_type(e) for e in elems)
    if kind == "fn":
        params = type_repr.get("parameters", [])
        ret = type_repr.get("return", {})
        return "fn(%s) -> %s" % (
            ", ".join(format_type(p) for p in params),
            format_type(ret),
        )
    return str(type_repr)


def check_function_existence(headless_fns, styled_fns, headless_mod, styled_mod):
    """Check that every headless function exists in styled."""
    violations = []
    for fn_name in headless_fns:
        if fn_name not in styled_fns:
            violations.append(
                "%s is missing function '%s' from %s"
                % (styled_mod, fn_name, headless_mod)
            )
    return violations


def check_parameter_labels(headless_fns, styled_fns, styled_mod):
    """Check parameter labels follow the mirror contract."""
    violations = []
    for fn_name, fn_data in headless_fns.items():
        if fn_name not in styled_fns:
            continue  # already reported by existence check

        # Skip functions with documented intentional deviations
        if (styled_mod, fn_name) in CONTRACT_EXCEPTIONS:
            continue

        h_labels = get_labels(fn_data.get("parameters", []))
        s_labels = get_labels(styled_fns[fn_name].get("parameters", []))

        # Valid patterns:
        #   1. Exact match (config constructors, pipeline helpers)
        #   2. Theme prefix (render functions): styled = ["theme"] + headless
        if s_labels == h_labels:
            continue
        if s_labels == ["theme"] + h_labels:
            continue

        violations.append(
            "%s.%s label mismatch:\n"
            "      expected: %s or ['theme'] + %s\n"
            "      actual:   %s"
            % (styled_mod, fn_name, h_labels, h_labels, s_labels)
        )
    return violations


def check_return_types(headless_fns, styled_fns, styled_mod):
    """Check that return types match between headless and styled functions."""
    violations = []
    for fn_name, fn_data in headless_fns.items():
        if fn_name not in styled_fns:
            continue
        if (styled_mod, fn_name) in CONTRACT_EXCEPTIONS:
            continue

        h_return = normalize_type(fn_data.get("return", {}))
        s_return = normalize_type(styled_fns[fn_name].get("return", {}))

        if h_return != s_return:
            violations.append(
                "%s.%s return type mismatch:\n"
                "      headless: %s\n"
                "      styled:   %s"
                % (styled_mod, fn_name, format_type(h_return), format_type(s_return))
            )
    return violations


def check_parameter_types(headless_fns, styled_fns, styled_mod):
    """Check that parameter types match between headless and styled functions.

    Aligns parameters positionally: if styled has a leading 'theme' param,
    it is skipped before comparison.
    """
    violations = []
    for fn_name, fn_data in headless_fns.items():
        if fn_name not in styled_fns:
            continue
        if (styled_mod, fn_name) in CONTRACT_EXCEPTIONS:
            continue

        h_params = fn_data.get("parameters", [])
        s_params = styled_fns[fn_name].get("parameters", [])

        h_labels = get_labels(h_params)
        s_labels = get_labels(s_params)

        # Determine alignment: exact match or theme-prefixed
        if s_labels == h_labels:
            aligned_s_params = s_params
        elif s_labels == ["theme"] + h_labels:
            aligned_s_params = s_params[1:]
        else:
            # Labels don't match either pattern — label check already reports it
            continue

        for i, (h_p, s_p) in enumerate(zip(h_params, aligned_s_params)):
            h_type = normalize_type(h_p.get("type", {}))
            s_type = normalize_type(s_p.get("type", {}))
            if h_type != s_type:
                label = h_p.get("label", "?")
                violations.append(
                    "%s.%s param '%s' type mismatch:\n"
                    "      headless: %s\n"
                    "      styled:   %s"
                    % (styled_mod, fn_name, label,
                       format_type(h_type), format_type(s_type))
                )
    return violations


def check_type_reexports(headless_types, styled_types, headless_mod, styled_mod):
    """Check that types defined in headless are re-exported by styled."""
    violations = []
    for type_name in headless_types:
        if type_name not in styled_types:
            violations.append(
                "%s is missing type '%s' from %s"
                % (styled_mod, type_name, headless_mod)
            )
    return violations


def verify_contracts(interface):
    modules = interface.get("modules", {})
    violations = []

    headless_modules = {
        name: data
        for name, data in modules.items()
        if name.startswith(HEADLESS_PREFIX)
    }

    for headless_mod, headless_data in sorted(headless_modules.items()):
        component = headless_mod[len(HEADLESS_PREFIX):]
        styled_mod = PACKAGE_PREFIX + "/" + component

        if styled_mod not in modules:
            violations.append(
                "%s has no styled counterpart '%s'" % (headless_mod, styled_mod)
            )
            continue

        styled_data = modules[styled_mod]

        headless_fns = headless_data.get("functions", {})
        styled_fns = styled_data.get("functions", {})
        headless_types = headless_data.get("type-aliases", {})
        headless_types.update(headless_data.get("types", {}))
        styled_types = styled_data.get("type-aliases", {})
        styled_types.update(styled_data.get("types", {}))

        violations.extend(
            check_function_existence(
                headless_fns, styled_fns, headless_mod, styled_mod
            )
        )
        violations.extend(
            check_parameter_labels(headless_fns, styled_fns, styled_mod)
        )
        violations.extend(
            check_return_types(headless_fns, styled_fns, styled_mod)
        )
        violations.extend(
            check_parameter_types(headless_fns, styled_fns, styled_mod)
        )
        violations.extend(
            check_type_reexports(
                headless_types, styled_types, headless_mod, styled_mod
            )
        )

    return violations


def main():
    if len(sys.argv) != 2:
        print("Usage: %s <package-interface.json>" % sys.argv[0], file=sys.stderr)
        sys.exit(2)

    interface = load_interface(sys.argv[1])
    violations = verify_contracts(interface)

    if violations:
        for v in violations:
            print("FAIL: " + v, file=sys.stderr)
        print(
            "\n%d contract violation(s) found." % len(violations),
            file=sys.stderr,
        )
        sys.exit(1)
    else:
        print("OK: contract verification passed (%d module pairs checked)"
              % len([m for m in interface.get("modules", {})
                     if m.startswith(HEADLESS_PREFIX)]),
              file=sys.stderr)


if __name__ == "__main__":
    main()
