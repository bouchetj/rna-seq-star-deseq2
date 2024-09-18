rule GSVA:
    input:
        "results/deseq2/normcounts.tsv"
    output:
        report("results/pathway/hallmark_GSVA.csv", "../report/gsva.rst"),
        report("results/pathway/hallmark_GSVA.svg", "../report/heatmap.rst"),
    log:
        "logs/pathway/gsva.log",
    conda:
        "../envs/pathway.yaml"
    script:
        "../scripts/pathway.R"