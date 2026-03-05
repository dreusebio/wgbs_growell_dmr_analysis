#!/usr/bin/env bash
set -euo pipefail

# ------------------------------------------------------------------------------
# scaffold_lab_template_orchestrator.sh
#
# Creates a Snakemake lab template that ORCHESTRATES:
#   WGBS: epigenerator (submodule)  -> Comethyl and/or DMRichR (R scripts)
#   snRNA: optional analysis module repo (submodule) via wrapper scripts
#   WGS: placeholder stub (you can extend later)
#
# You said: submodules preferred ✅
#
# Usage:
#   bash scaffold_lab_template_orchestrator.sh --repo lab-wgbs-snrna-wgs-template --project-id LAB_TEMPLATE
#
# Optional:
#   bash scaffold_lab_template_orchestrator.sh --repo X --project-id Y --force
#
# After scaffold:
#   cd <repo>
#   git submodule update --init --recursive
#   # edit config/config.yaml + config/samples.tsv + metadata/*
#   snakemake -n
#   snakemake --profile workflow/profiles/local
#   snakemake --profile workflow/profiles/slurm -j 100
# ------------------------------------------------------------------------------

REPO_DIR=""
PROJECT_ID="PROJECT_ID"
FORCE=0

# External repos (submodules)
EPIGENERATOR_URL="https://github.com/vhaghani26/epigenerator"
SNRNA_URL="https://github.com/osmansharifi/PCB_mouse_snRNAseq"

usage() {
  cat <<'USAGE'
Usage:
  bash scaffold_lab_template_orchestrator.sh --repo <dir> [--project-id <id>] [--force]

Options:
  --repo        Target directory to create (required)
  --project-id  Value to write into README/config (default: PROJECT_ID)
  --force       Overwrite existing files if present
USAGE
}

die() { echo "ERROR: $*" >&2; exit 1; }

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)        REPO_DIR="${2:-}"; shift 2 ;;
    --project-id)  PROJECT_ID="${2:-}"; shift 2 ;;
    --force)       FORCE=1; shift 1 ;;
    -h|--help)     usage; exit 0 ;;
    *) die "Unknown argument: $1" ;;
  esac
done

[[ -z "$REPO_DIR" ]] && { usage; die "--repo is required"; }

write_file() {
  local path="$1"
  local content="$2"
  if [[ -e "$path" && "$FORCE" -ne 1 ]]; then
    die "File exists: $path (use --force to overwrite)"
  fi
  mkdir -p "$(dirname "$path")"
  printf "%s" "$content" > "$path"
}

mkdir -p "$REPO_DIR"
cd "$REPO_DIR"

# --------------------------
# Directory skeleton
# --------------------------
mkdir -p \
  .github/workflows \
  .github/ISSUE_TEMPLATE \
  config/schema \
  metadata/provenance \
  resources \
  external \
  workflow/rules \
  workflow/scripts/wgbs \
  workflow/scripts/snrna \
  workflow/scripts/wgs \
  workflow/envs \
  workflow/profiles/local \
  workflow/profiles/slurm \
  analysis/notebooks \
  results \
  logs

# --------------------------
# Root files
# --------------------------
write_file ".editorconfig" \
"root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
indent_style = space
indent_size = 2
trim_trailing_whitespace = true

[*.py]
indent_size = 4

[*.{smk,Snakemake}]
indent_size = 2
"

write_file ".gitignore" \
"# Generated outputs
results/**
logs/**
tmp/**
.cache/**
.snakemake/**
benchmark/**
reports/**

# Keep placeholders
!results/.gitkeep
!logs/.gitkeep

# External submodules: keep tracked by git, but don't accidentally add large outputs
external/**/results/**
external/**/logs/**
external/**/.snakemake/**

# Large bioinformatics files
*.bam
*.bai
*.cram
*.crai
*.fastq
*.fastq.gz
*.fq.gz
*.vcf
*.vcf.gz
*.tbi
*.csi
*.bed.gz
*.bw
*.bigWig
*.bigBed

# R / Python
.Rhistory
.RData
.Rproj.user/
*.pyc
__pycache__/

# Jupyter
.ipynb_checkpoints/

# OS
.DS_Store
"

write_file "CHANGELOG.md" \
"# Changelog

## Unreleased
- Initial scaffold (Snakemake orchestrator + submodules)
"

write_file "LICENSE" \
"MIT License

Copyright (c) $(date +%Y)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the \"Software\"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
"

write_file "CITATION.cff" \
"cff-version: 1.2.0
message: \"If you use this software, please cite it.\"
title: \"${PROJECT_ID}\"
type: software
authors:
  - family-names: \"Lab\"
    given-names: \"Your\"
    affiliation: \"Your Institution\"
"

write_file "README.md" \
"# ${PROJECT_ID}

Lab-standard **Snakemake orchestrator** template.

## What this template does

### WGBS (recommended path)
1) **epigenerator** (submodule) for preprocessing / cytosine reports
2) downstream analysis:
   - **Comethyl** (R script wrapper)
   - **DMRichR** (R script wrapper)

### snRNA
- Optional: pinned analysis repo as a **submodule** + wrapper rule(s)

### WGS
- Placeholder stub (extend as your lab standardizes a WGS pipeline)

## Setup

Clone a project created from this template, then initialize submodules:
\`\`\`bash
git submodule update --init --recursive
\`\`\`

## Configure
- \`config/config.yaml\`
- \`config/samples.tsv\`
- metadata lives in \`metadata/\`

## Run
Dry-run:
\`\`\`bash
snakemake -n
\`\`\`

Local:
\`\`\`bash
snakemake --profile workflow/profiles/local
\`\`\`

Slurm:
\`\`\`bash
snakemake --profile workflow/profiles/slurm -j 100
\`\`\`

## Conventions
- Generated outputs: \`results/\` (not committed)
- Logs: \`logs/\` (not committed)
- Human metadata + provenance: \`metadata/\` (committed)
"

write_file "results/.gitkeep" ""
write_file "logs/.gitkeep" ""
write_file "analysis/notebooks/.gitkeep" ""

# --------------------------
# GitHub templates + CI
# --------------------------
write_file ".github/PULL_REQUEST_TEMPLATE.md" \
"## Summary
Describe the change.

## Checklist
- [ ] Updated README/docs as needed
- [ ] Updated config defaults if needed
- [ ] Snakemake dry-run passes
"

write_file ".github/ISSUE_TEMPLATE/bug_report.md" \
"---
name: Bug report
about: Report a bug in the pipeline/template
---

## What happened?

## Expected behavior

## How to reproduce
Commands + config used.

## Environment
- OS:
- Snakemake version:
- Profile (local/slurm):
"

write_file ".github/workflows/ci.yml" \
"name: ci

on:
  push:
  pull_request:

jobs:
  dryrun:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.11'
      - name: Install minimal deps
        run: |
          python -m pip install --upgrade pip
          pip install snakemake pandas
      - name: Snakemake dry-run (orchestrator)
        run: |
          snakemake -n --configfile config/config.yaml
"

# --------------------------
# config/
# --------------------------
write_file "config/config.yaml" \
"project:
  id: \"${PROJECT_ID}\"
  assay: \"wgbs\"   # wgbs | snrna | wgs
  genome_build: \"hg38\"

paths:
  samplesheet: \"config/samples.tsv\"
  units: \"config/units.tsv\"       # optional
  outdir: \"results\"
  logdir: \"logs\"

external:
  epigenerator_dir: \"external/epigenerator\"
  snrna_repo_dir: \"external/PCB_mouse_snRNAseq\"

resources:
  default_threads: 4
  default_mem_mb: 16000
  default_time_min: 240

wgbs:
  preprocess:
    engine: \"epigenerator\"        # currently only epigenerator supported
    profile: \"workflow/profiles/slurm\"
    jobs: 100
    # Where epigenerator outputs should be copied/synced into:
    standardized_outdir: \"results/wgbs/epigenerator\"

  downstream:
    run_comethyl: true
    run_dmrichr: false

  # Inputs to downstream analysis
  coldata_xlsx: \"metadata/coldata.xlsx\"  # create this per project

comethyl:
  # Where to write results
  outdir: \"results/wgbs/comethyl\"
  params:
    covMin: 4
    methSD: 0.08

dmrichr:
  outdir: \"results/wgbs/dmrichr\"
  params:
    maxPerms: 100

snrna:
  run_external_module: false
  outdir: \"results/snrna\"

wgs:
  outdir: \"results/wgs\"
"

write_file "config/samples.tsv" \
"sample_id\tsubject_id\tassay\tfastq_r1\tfastq_r2\tsex\tbatch
S1\tP1\twgbs\t/path/S1_R1.fastq.gz\t/path/S1_R2.fastq.gz\tM\t1
S2\tP2\twgbs\t/path/S2_R1.fastq.gz\t/path/S2_R2.fastq.gz\tF\t1
"

write_file "config/units.tsv" \
"sample_id\tlibrary_id\tlane\tfastq_r1\tfastq_r2
S1\tL1\t1\t/path/S1_L001_R1.fastq.gz\t/path/S1_L001_R2.fastq.gz
S1\tL1\t2\t/path/S1_L002_R1.fastq.gz\t/path/S1_L002_R2.fastq.gz
"

write_file "config/schema/config.schema.yaml" \
"type: object
required:
  - project
  - paths
  - external
  - wgbs
properties:
  project:
    type: object
    required: [id, assay, genome_build]
  wgbs:
    type: object
"

# --------------------------
# metadata/
# --------------------------
write_file "metadata/README.md" \
"# metadata/

Version-controlled project metadata (NOT raw data).

Recommended:
- coldata.xlsx (sample-level traits; rownames = sample_id)
- data dictionaries / codebooks
- provenance notes (sample exclusions, references, pipeline versions)
"

write_file "metadata/provenance/pipeline_versions.md" \
"# Pipeline versions (fill in per project)

## Submodules
- epigenerator: (git submodule commit SHA)
- PCB_mouse_snRNAseq: (git submodule commit SHA)

## References
- genome build:
- fasta path + checksum:
- gtf path + checksum:
"

# (placeholder for user to create)
write_file "metadata/coldata.xlsx.placeholder.txt" \
"Create metadata/coldata.xlsx with rownames = sample_id. (Placeholder file.)"

# --------------------------
# resources/
# --------------------------
write_file "resources/references.md" \
"# References

Record exact reference versions and checksums here (or in metadata/provenance).
"

write_file "resources/manifest.tsv" \
"resource\tpath_or_url\tversion\tchecksum_sha256\tnotes
reference_fasta\t/path/to/reference.fa\t\t\t
annotation_gtf\t/path/to/annotation.gtf\t\t\t
"

# --------------------------
# workflow: orchestrator Snakefile + rules
# --------------------------
write_file "workflow/Snakefile" \
"configfile: \"config/config.yaml\"

ASSAY = config[\"project\"][\"assay\"]

include: \"workflow/rules/common.smk\"

if ASSAY == \"wgbs\":
    include: \"workflow/rules/wgbs_orchestrator.smk\"
elif ASSAY == \"snrna\":
    include: \"workflow/rules/snrna_orchestrator.smk\"
elif ASSAY == \"wgs\":
    include: \"workflow/rules/wgs_orchestrator.smk\"
else:
    raise ValueError(f\"Unknown assay: {ASSAY}. Must be wgbs|snrna|wgs\")

rule all:
    input:
        f\"{config['paths']['outdir']}/{ASSAY}/_SUCCESS\"
"

write_file "workflow/rules/common.smk" \
"import pandas as pd
from pathlib import Path

SAMPLESHEET = config[\"paths\"][\"samplesheet\"]
samples_df = pd.read_csv(SAMPLESHEET, sep=\"\\t\", dtype=str)

def outdir():
    return config[\"paths\"][\"outdir\"]

def logdir():
    return config[\"paths\"][\"logdir\"]

def assay():
    return config[\"project\"][\"assay\"]

def apath(*parts):
    return str(Path(outdir()) / assay() / Path(*parts))

rule make_dirs:
    output:
        touch(apath(\"_DIRS_CREATED\"))
    shell:
        r\"
        mkdir -p {config[paths][outdir]}/{config[project][assay]}
        mkdir -p {config[paths][logdir]}/{config[project][assay]}
        touch {output}
        \"
"

# ---- WGBS orchestrator rules ----
write_file "workflow/rules/wgbs_orchestrator.smk" \
"from pathlib import Path

WGBS_SUCCESS = Path(config['paths']['outdir']) / 'wgbs' / '_SUCCESS'

EPIGEN_DIR = config['external']['epigenerator_dir']
EPIGEN_PROFILE = config['wgbs']['preprocess']['profile']
EPIGEN_JOBS = int(config['wgbs']['preprocess']['jobs'])
EPIGEN_STD_OUT = config['wgbs']['preprocess']['standardized_outdir']

COMETHYL_ON = bool(config['wgbs']['downstream']['run_comethyl'])
DMRICHR_ON = bool(config['wgbs']['downstream']['run_dmrichr'])

COMETHYL_OUT = config['comethyl']['outdir']
DMRICHR_OUT = config['dmrichr']['outdir']

rule wgbs_epigenerator:
    input:
        rules.make_dirs.output
    output:
        touch(\"results/wgbs/epigenerator/_SUCCESS\")
    resources:
        time_min=1440,
        mem_mb=64000,
        threads=8
    shell:
        r\"
        set -euo pipefail
        # Run epigenerator pipeline (expects user to configure epigenerator itself)
        # NOTE: You must init submodules first:
        #   git submodule update --init --recursive
        test -d {EPIGEN_DIR} || (echo 'Missing submodule: {EPIGEN_DIR}' && exit 1)

        # If epigenerator has its own working dir/config, you can either:
        #  (A) configure epigenerator to write directly into {EPIGEN_STD_OUT}
        #  (B) run it in-place then rsync outputs into {EPIGEN_STD_OUT}
        #
        # This template uses (B) as the safe default.
        mkdir -p {EPIGEN_STD_OUT}

        (cd {EPIGEN_DIR} && snakemake --profile ../../{EPIGEN_PROFILE} -j {EPIGEN_JOBS})

        # TODO: Adjust this rsync once you standardize epigenerator output paths in your lab.
        # Example:
        # rsync -av {EPIGEN_DIR}/CpG_Me2/output/ {EPIGEN_STD_OUT}/
        echo 'NOTE: configure rsync path from epigenerator outputs -> standardized results dir.'
        touch {output}
        \"

rule wgbs_comethyl:
    input:
        rules.wgbs_epigenerator.output
    output:
        touch(\"results/wgbs/comethyl/_SUCCESS\")
    conda:
        \"workflow/envs/r_comethyl.yaml\"
    shell:
        r\"
        set -euo pipefail
        Rscript workflow/scripts/wgbs/run_comethyl.R \\
          --epigenerator_dir '{EPIGEN_STD_OUT}' \\
          --coldata_xlsx '{config[wgbs][coldata_xlsx]}' \\
          --outdir '{COMETHYL_OUT}' \\
          --covMin '{config[comethyl][params][covMin]}' \\
          --methSD '{config[comethyl][params][methSD]}'
        touch {output}
        \"

rule wgbs_dmrichr:
    input:
        rules.wgbs_epigenerator.output
    output:
        touch(\"results/wgbs/dmrichr/_SUCCESS\")
    conda:
        \"workflow/envs/r_dmrichr.yaml\"
    shell:
        r\"
        set -euo pipefail
        Rscript workflow/scripts/wgbs/run_dmrichr.R \\
          --epigenerator_dir '{EPIGEN_STD_OUT}' \\
          --coldata_xlsx '{config[wgbs][coldata_xlsx]}' \\
          --outdir '{DMRICHR_OUT}' \\
          --maxPerms '{config[dmrichr][params][maxPerms]}'
        touch {output}
        \"

rule wgbs_finalize:
    input:
        rules.make_dirs.output,
        rules.wgbs_epigenerator.output,
        # Conditionally include downstream sentinels
        *( [\"results/wgbs/comethyl/_SUCCESS\"] if COMETHYL_ON else [] ),
        *( [\"results/wgbs/dmrichr/_SUCCESS\"] if DMRICHR_ON else [] )
    output:
        touch(str(WGBS_SUCCESS))
    shell:
        r\"
        touch {output}
        \"
"

# ---- snRNA orchestrator rules ----
write_file "workflow/rules/snrna_orchestrator.smk" \
"from pathlib import Path

SNRNA_SUCCESS = Path(config['paths']['outdir']) / 'snrna' / '_SUCCESS'
SNRNA_REPO = config['external']['snrna_repo_dir']
RUN_EXT = bool(config['snrna']['run_external_module'])

rule snrna_external_module:
    input:
        rules.make_dirs.output
    output:
        touch(\"results/snrna/external_module/_SUCCESS\")
    shell:
        r\"
        set -euo pipefail
        if [ \"{RUN_EXT}\" != \"True\" ]; then
          echo 'snRNA external module disabled (snrna.run_external_module=false).'
          touch {output}
          exit 0
        fi

        test -d {SNRNA_REPO} || (echo 'Missing submodule: {SNRNA_REPO}' && exit 1)

        # This is intentionally a placeholder because Osman’s repo is script-driven.
        # Your lab can standardize a single entrypoint script and call it here.
        echo 'TODO: add a standardized entrypoint for snRNA external module.'
        touch {output}
        \"

rule snrna_finalize:
    input:
        rules.make_dirs.output,
        \"results/snrna/external_module/_SUCCESS\"
    output:
        touch(str(SNRNA_SUCCESS))
    shell:
        r\"touch {output}\"
"

# ---- WGS orchestrator rules ----
write_file "workflow/rules/wgs_orchestrator.smk" \
"from pathlib import Path
WGS_SUCCESS = Path(config['paths']['outdir']) / 'wgs' / '_SUCCESS'

rule wgs_stub:
    input:
        rules.make_dirs.output
    output:
        touch(\"results/wgs/_SUCCESS\")
    shell:
        r\"
        echo 'WGS stub. Implement lab-standard WGS pipeline here.'
        touch {output}
        \"
"

# --------------------------
# workflow scripts (R wrappers)
# --------------------------
write_file "workflow/scripts/wgbs/run_comethyl.R" \
"#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(optparse)
})

option_list <- list(
  make_option(c(\"--epigenerator_dir\"), type=\"character\", help=\"Standardized epigenerator outputs dir\"),
  make_option(c(\"--coldata_xlsx\"), type=\"character\", help=\"metadata/coldata.xlsx\"),
  make_option(c(\"--outdir\"), type=\"character\", help=\"Output directory\"),
  make_option(c(\"--covMin\"), type=\"double\", default=4),
  make_option(c(\"--methSD\"), type=\"double\", default=0.08)
)

opt <- parse_args(OptionParser(option_list=option_list))

dir.create(opt$outdir, recursive=TRUE, showWarnings=FALSE)

cat(\"[Comethyl wrapper]\\n\")
cat(\"epigenerator_dir:\", opt$epigenerator_dir, \"\\n\")
cat(\"coldata_xlsx:\", opt$coldata_xlsx, \"\\n\")
cat(\"outdir:\", opt$outdir, \"\\n\")
cat(\"covMin:\", opt$covMin, \" methSD:\", opt$methSD, \"\\n\")

# TODO:
# 1) Decide what exact file(s) from epigenerator outputs you treat as the input to Comethyl.
# 2) Implement:
#    - reading Bismark cytosine reports / CpG matrices
#    - constructing BSseq (or required object)
#    - CpG clustering + module detection
#    - saving key outputs into opt$outdir
#
# Tip: keep this script as the single lab-standard entrypoint for Comethyl runs.

writeLines(\"PLACEHOLDER: Comethyl run not yet implemented.\", file.path(opt$outdir, \"README_RUN_PLACEHOLDER.txt\"))
"

write_file "workflow/scripts/wgbs/run_dmrichr.R" \
"#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(optparse)
})

option_list <- list(
  make_option(c(\"--epigenerator_dir\"), type=\"character\", help=\"Standardized epigenerator outputs dir\"),
  make_option(c(\"--coldata_xlsx\"), type=\"character\", help=\"metadata/coldata.xlsx\"),
  make_option(c(\"--outdir\"), type=\"character\", help=\"Output directory\"),
  make_option(c(\"--maxPerms\"), type=\"integer\", default=100)
)

opt <- parse_args(OptionParser(option_list=option_list))

dir.create(opt$outdir, recursive=TRUE, showWarnings=FALSE)

cat(\"[DMRichR wrapper]\\n\")
cat(\"epigenerator_dir:\", opt$epigenerator_dir, \"\\n\")
cat(\"coldata_xlsx:\", opt$coldata_xlsx, \"\\n\")
cat(\"outdir:\", opt$outdir, \"\\n\")
cat(\"maxPerms:\", opt$maxPerms, \"\\n\")

# TODO:
# Implement lab-standard DMRichR entrypoint using epigenerator cytosine reports.
# Keep all DMRichR parameters explicit and config-driven.

writeLines(\"PLACEHOLDER: DMRichR run not yet implemented.\", file.path(opt$outdir, \"README_RUN_PLACEHOLDER.txt\"))
"

chmod +x workflow/scripts/wgbs/run_comethyl.R || true
chmod +x workflow/scripts/wgbs/run_dmrichr.R || true

# --------------------------
# Conda envs (minimal; pin later with conda-lock if you want)
# --------------------------
write_file "workflow/envs/common.yaml" \
"name: lab_common
channels: [conda-forge, bioconda]
dependencies:
  - python=3.11
  - pandas
  - snakemake
"

# Comethyl wrapper env (placeholder)
write_file "workflow/envs/r_comethyl.yaml" \
"name: lab_r_comethyl
channels: [conda-forge, bioconda]
dependencies:
  - r-base=4.3
  - r-optparse
  - r-remotes
  - r-devtools
  # install comethyl inside env as needed (e.g., via remotes::install_github or CRAN/Bioc)
"

# DMRichR wrapper env (placeholder; you may need to pin R/Bioc to match DMRichR constraints)
write_file "workflow/envs/r_dmrichr.yaml" \
"name: lab_r_dmrichr
channels: [conda-forge, bioconda]
dependencies:
  - r-base=4.2
  - r-optparse
  - r-remotes
  - r-devtools
  # install DMRichR + Bioconductor deps inside env as needed
"

# --------------------------
# Profiles (local + Slurm)
# --------------------------
write_file "workflow/profiles/local/config.yaml" \
"jobs: 4
printshellcmds: true
rerun-incomplete: true
keep-going: true
"

write_file "workflow/profiles/slurm/config.yaml" \
"executor: slurm
jobs: 100
latency-wait: 60
rerun-incomplete: true
keep-going: true
printshellcmds: true

default-resources:
  - threads=4
  - mem_mb=16000
  - time_min=240
  - partition=production
  - qos=normal

slurm:
  extra: \"--parsable\"
  time: \"{resources.time_min}\"
  mem_mb: \"{resources.mem_mb}\"
  partition: \"{resources.partition}\"
  qos: \"{resources.qos}\"
  cpus-per-task: \"{threads}\"
"

write_file "workflow/profiles/slurm/slurm-status.py" \
"#!/usr/bin/env python3
import subprocess, sys
jobid = sys.argv[1]
try:
    out = subprocess.check_output([\"sacct\",\"-j\",jobid,\"--format=State\",\"--noheader\"], text=True)
    state = out.strip().split()[0] if out.strip() else \"UNKNOWN\"
except Exception:
    state = \"UNKNOWN\"

if state in (\"COMPLETED\",):
    print(\"success\")
elif state in (\"FAILED\",\"CANCELLED\",\"TIMEOUT\",\"NODE_FAIL\",\"OUT_OF_MEMORY\"):
    print(\"failed\")
else:
    print(\"running\")
"
chmod +x workflow/profiles/slurm/slurm-status.py || true

# --------------------------
# analysis/
# --------------------------
write_file "analysis/README.md" \
"# analysis/

Downstream stats/figures live here.
Recommended: use renv for R reproducibility.
"
write_file "analysis/renv.lock" "{}"
mkdir -p analysis/renv

# --------------------------
# Initialize git + add submodules
# --------------------------
if command -v git >/dev/null 2>&1; then
  if [[ ! -d ".git" ]]; then
    git init >/dev/null
  fi

  # Add submodules (only if not already present or if --force)
  if [[ ! -d "external/epigenerator" || "$FORCE" -eq 1 ]]; then
    # If force and directory exists, remove it before re-adding
    if [[ -d "external/epigenerator" && "$FORCE" -eq 1 ]]; then
      rm -rf external/epigenerator
    fi
    git submodule add "$EPIGENERATOR_URL" external/epigenerator || true
  fi

  if [[ ! -d "external/PCB_mouse_snRNAseq" || "$FORCE" -eq 1 ]]; then
    if [[ -d "external/PCB_mouse_snRNAseq" && "$FORCE" -eq 1 ]]; then
      rm -rf external/PCB_mouse_snRNAseq
    fi
    git submodule add "$SNRNA_URL" external/PCB_mouse_snRNAseq || true
  fi

  # Make an initial commit if possible
  git add -A || true
  git commit -m "Initial scaffold: Snakemake orchestrator + submodules" >/dev/null 2>&1 || true
fi

echo "✅ Scaffold created at: $(pwd)"
echo
echo "Next steps:"
echo "  1) git submodule update --init --recursive"
echo "  2) edit config/config.yaml + config/samples.tsv + metadata/coldata.xlsx"
echo "  3) IMPORTANT: set the epigenerator output sync path inside workflow/rules/wgbs_orchestrator.smk"
echo "  4) snakemake -n"
echo "  5) snakemake --profile workflow/profiles/local"
echo "  6) snakemake --profile workflow/profiles/slurm -j 100"
