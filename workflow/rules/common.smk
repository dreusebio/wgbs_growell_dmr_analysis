import pandas as pd

SAMPLESHEET = config["paths"]["samplesheet"]
samples_df = pd.read_csv(SAMPLESHEET, sep="\t", dtype=str)
SAMPLES = samples_df["sample_id"].tolist()

def outpath(*parts):
    return "/".join([config["paths"]["outdir"], config["project"]["assay"], *parts])

rule make_dirs:
    output:
        touch(outpath("_DIRS_CREATED"))
    shell:
        r"
        mkdir -p {config[paths][outdir]}/{config[project][assay]}
        mkdir -p {config[paths][logdir]}/{config[project][assay]}
        touch {output}
        "
