rule wgbs_stub:
    input: rules.make_dirs.output
    output: touch(outpath("_SUCCESS"))
    shell:
        r"echo 'WGBS stub: implement pipeline here' && touch {output}"
