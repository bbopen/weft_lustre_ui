# Test Audit: Potentially "Fishy" / Low-Signal Tests

This pass focuses on tests that look like they may have been written to keep green status rather than to strongly verify behavior.


## Current status (post-rewrite follow-up)

- ✅ Addressed in tests: `navigation_menu`, `resizable`, `menubar`, `item`, `form`, `input_otp`, and `direction` now include behavior-oriented assertions that replaced the original low-signal round-trips.
- ✅ Addressed in this follow-up: `carousel` now checks `carousel-content` and `carousel-previous` slots in both headless and styled render paths, adds a negative orientation assertion (`horizontal` absent when `vertical` is configured), and tightens disabled checks to explicit boolean attribute rendering.
- ✅ Addressed in this follow-up: `textarea` disabled assertion is now precise (`disabled=""`) instead of a broad `"disabled"` token check.
- 🔄 Remaining long-term improvement opportunities (not blocking this audit close-out): replace broad string assertions with attribute extraction/parsing helpers where practical.

## Heuristics used

- **Self-fulfilling round-trips**: setter + getter + predicate all from same module, no independent oracle.
- **Wrapper-equals-wrapper tests**: compares façade output to canonical helper output but never validates user-observable behavior.
- **Weak markup checks**: only checks `string.contains` for a broad token (`data-slot=...`) that may pass even if behavior regresses.
- **"Function exists" checks**: assertions like `helper() != []` that only prove non-empty output, not correctness.

## Head-scratcher list

1. `test/navigation_menu_test.gleam`
   - `trigger style helper remains available` (headless + styled) only checks non-empty style list (`... != []`), which is weak and likely to pass through regressions.
   - `viewport-enabled flag round-trips through config helpers` (headless + styled) is setter/getter self-validation with no render/event consequence check.
   - Rendering tests only assert a few `data-slot` markers and do not verify viewport toggling behavior when disabled.

2. `test/carousel_test.gleam`
   - `orientation helpers round-trip...` (headless + styled) uses module-local setter/getter/predicate chain; high risk of tautological pass.
   - Rendering assertions only check 3 slot markers (`carousel`, `carousel-item`, `carousel-next`), missing prev state/disabled semantics/orientation-specific rendering effects.

3. `test/resizable_test.gleam`
   - Orientation and handle tests are mostly helper round-trips with little externally validated behavior.
   - Render test expects `aria-orientation="vertical"` but does not explicitly set orientation in test setup, coupling to defaults and making intent brittle.

4. `test/item_test.gleam`
   - Styled mutator tests are round-trips through same API (`item_variant` -> `item_config_variant` -> `item_variant_is_*`) with no independent expected value check.
   - Render tests only verify slot-marker presence and not semantic behavior.

5. `test/menubar_test.gleam`
   - `root config key mutators keep menubar renderable` (headless + styled) checks only that rendering still includes `data-slot="menubar"`; this can pass even if callbacks are ignored.
   - Item variant/inset tests are helper round-trips with no UI consequence assertions.

6. `test/form_test.gleam`
   - Façade-forwarding tests compare rendered strings from two related APIs; useful for aliasing checks but weak for product behavior.
   - `styled form root renders semantic form container` only checks `<form` token, not form attrs/submit wiring/accessibility semantics.

7. `test/textarea_test.gleam`
   - Façade-forwarding equivalence test (`styled/textarea` vs `styled/input`) is mostly alias verification and may allow both paths to be wrong in same way.
   - Rows assertion is useful but still string-level only; no parser/attribute extraction.

8. `test/input_otp_test.gleam`
   - Config mutator tests check for `data-disabled` and index marker via substring; does not verify length-specific behavior robustly (e.g., exact slot count).
   - Rendering checks for slot markers only; no event/interaction semantics tested.

9. `test/direction_test.gleam`
   - Styled helper test includes a direction helper round-trip before render check; that round-trip is low-signal by itself.
   - Render check is a single `dir="rtl"` contains assertion, with no nested/override behavior verification.

## Recommended rewrite priorities

1. **High priority**: navigation_menu, carousel, resizable (behavior-rich widgets with currently low-signal tests).
2. **Medium priority**: menubar, input_otp, item.
3. **Lower priority**: form/textarea façade tests (still useful, but should be complemented by behavior tests).

## Rewrite pattern suggestions

- Prefer **attribute extraction / structural assertions** over broad substring checks.
- Add **negative assertions** (e.g., disabled viewport means viewport absent).
- Verify **event wiring effects** by invoking handlers where possible.
- For config helpers, include an **independent oracle** (expected literal, alternate construction path, or public behavior change).
- Keep façade parity tests, but add at least one **behavior test per façade** to avoid mirrored failures.
