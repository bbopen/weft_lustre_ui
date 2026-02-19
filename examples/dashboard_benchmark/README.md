# Dashboard Benchmark

Tracked benchmark app for `dashboard-01`, `sidebar-03`, and `sidebar-07` parity validation.

## Canonical Parity Workflow

```sh
bash scripts/start-parity-servers.sh
```

This starts persistent background servers and writes PID/log artifacts under:

- `/Users/brettbonner/code/work/weft_lustre_ui/examples/dashboard_benchmark/visual-artifacts`
- benchmark: `http://127.0.0.1:4175/index.html`
- real shadcn reference: `http://127.0.0.1:4180/dashboard`

Run parity and gates from `/Users/brettbonner/code/work/weft_lustre_ui`:

```sh
bash scripts/start-parity-servers.sh
bash scripts/check-reference-signature.sh
npx --yes --package=playwright@1.54.1 node scripts/check-parity.mjs
bash scripts/check-reference-visual.sh
bash scripts/check-visual.sh
bash scripts/check.sh
```

`check.sh` treats `check-reference-visual.sh` as advisory by default. To make it blocking, run with:

```sh
WEFT_LUSTRE_UI_REQUIRE_REFERENCE_VISUAL=1 bash scripts/check.sh
```

Refresh visual baselines only when intentional UI changes are approved:

```sh
bash scripts/check-visual.sh --update-baseline
```
