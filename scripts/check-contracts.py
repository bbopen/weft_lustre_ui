#!/usr/bin/env python3
"""
Package-interface contract verification for headless/styled module pairs.

Reads the Gleam package-interface JSON and verifies:
  1. Every headless public function exists in its styled counterpart
  2. Parameter labels follow the mirror contract:
     styled params == headless params  (config constructors, pipeline helpers)
     styled params == ["theme"] + headless params  (render functions)
  3. Types exported by headless appear in styled (re-export check)

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

# Intentional label deviations: styled functions that deliberately differ
# from the standard mirror contract. Each entry documents the reason.
LABEL_EXCEPTIONS = {
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
        if (styled_mod, fn_name) in LABEL_EXCEPTIONS:
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
