# PROJECT_NAME

Reproducible bioinformatics analysis for **[short project description]**.

**Data type(s):** [WGBS / snRNA-seq / WGS / multi-omics]  
**Study / cohort:** [name]  
**Genome build:** [hg38/hg19/etc]  
**Primary outputs:** [DMRs/DEGs/modules/figures/etc]

---

## Quick start

### Clone
```bash
git clone https://github.com/[ORG_OR_USER]/[REPO].git
cd [REPO]
```

### Submodules (if used)
```bash
git submodule update --init --recursive
```

---

## Configuration

- `config/config.yaml` (single source of truth)
- `config/samples.tsv` (sample sheet)
- optional: `config/units.tsv`

Human-curated metadata + provenance:
- `metadata/`

Reference versions/checksums:
- `resources/manifest.tsv`

---

## Run the analysis

### Option A — Snakemake (if used)

Dry-run:
```bash
snakemake -n
```

Local:
```bash
snakemake --profile workflow/profiles/local
```

SLURM:
```bash
snakemake --profile workflow/profiles/slurm -j 100
```

### Option B — SLURM submit scripts (no Snakemake required)

```bash
sbatch scripts/slurm/submit_rscript.sbatch
```

### Option C — Direct scripts

```bash
bash scripts/run_local.sh
```

---

## Repository structure

- `config/` — configuration + sample sheets
- `metadata/` — codebooks, data dictionaries, provenance notes (**committed**)
- `resources/` — reference versions + checksums (**committed**)
- `workflow/` — orchestration workflows (**optional**)
- `scripts/` — entrypoints + SLURM submit scripts
- `analysis/` — downstream statistics/figures (optionally `renv`)
- `docs/` — methods + workflow documentation
- `results/` — generated outputs (**not committed**)
- `logs/` — generated logs (**not committed**)

---

## Reproducibility standard

See `docs/lab_reproducibility_standard.md`.

---

## License

MIT License (see `LICENSE`)
