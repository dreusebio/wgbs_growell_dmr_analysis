.PHONY: help dryrun run-local run-slurm

help:
\t@echo "Targets:"
\t@echo "  make dryrun     # snakemake dry-run (if workflow exists)"
\t@echo "  make run-local   # run local (snakemake profile or scripts/run_local.sh)"
\t@echo "  make run-slurm   # run slurm (snakemake profile or sbatch script)"

dryrun:
\t@command -v snakemake >/dev/null 2>&1 && snakemake -n || echo "snakemake not found; skipping"

run-local:
\t@if command -v snakemake >/dev/null 2>&1; then \
\t\tsnakemake --profile workflow/profiles/local; \
\telse \
\t\tbash scripts/run_local.sh; \
\tfi

run-slurm:
\t@if command -v snakemake >/dev/null 2>&1; then \
\t\tsnakemake --profile workflow/profiles/slurm -j 100; \
\telse \
\t\tsbatch scripts/slurm/submit_rscript.sbatch; \
\tfi
