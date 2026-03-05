# wgbs_growell_dmr_analysis

This repository contains the analysis pipeline for identifying differentially methylated regions (DMRs) from whole-genome bisulfite sequencing (WGBS) data generated in the GROWell study. The workflow processes methylation data from dried blood spot samples and performs region-level differential methylation analysis using DMRichR, integrating covariates and phenotype metadata to investigate associations between DNA methylation patterns and pregnancy-related outcomes. The pipeline includes steps for data preprocessing, CpG filtering, DMR detection, annotation, and downstream visualization to support reproducible epigenomic analysis within the GROWell cohort.

**Data type(s):** WGBS and lipidomics  
**Study/cohort:** GROWELL
**Genome build:** hg38
**Primary outputs:** DMRs

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
