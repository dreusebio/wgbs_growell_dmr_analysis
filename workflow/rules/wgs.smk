rule wgs_stub:
    input: rules.make_dirs.output
    output: touch(outpath("_SUCCESS"))
    shell:
        r"echo 'WGS stub: implement pipeline here' && touch {output}"
