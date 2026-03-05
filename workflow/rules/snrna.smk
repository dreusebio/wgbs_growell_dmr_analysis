rule snrna_stub:
    input: rules.make_dirs.output
    output: touch(outpath("_SUCCESS"))
    shell:
        r"echo 'snRNA stub: implement pipeline here' && touch {output}"
