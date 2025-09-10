import os

# Load config
configfile: "config.yaml"

INPUT_DIR = config["RENAMED_MTDNA_DIR"]
WORKING_DIR = config["ALIGNMENT_DIR"]
GENES = config["MITO_GENES"]
AMAS_PATH = config["AMAS_PATH"]

rule all:
    input:
        os.path.join(WORKING_DIR, "phylogeny.done")

rule prepare_gene_fastas:
    input:
        expand(os.path.join(INPUT_DIR, "{sample}", "{sample}_final_genes_NT.fasta"),
               sample=[d for d in os.listdir(INPUT_DIR) if os.path.isdir(os.path.join(INPUT_DIR, d))])
    output:
        expand(os.path.join(WORKING_DIR, "gene_alignments", "{gene}.fasta"), gene=GENES)
    run:
        os.makedirs(os.path.join(WORKING_DIR, "gene_alignments"), exist_ok=True)
        for infile in input:
            sample = os.path.basename(infile).split("_")[0]
            with open(infile) as fh:
                contents = fh.read().split(">")
            for gene in GENES:
                with open(os.path.join(WORKING_DIR, "gene_alignments", f"{gene}.fasta"), "a") as out_fh:
                    for entry in contents:
                        if gene in entry:
                            seq = "\n".join(entry.splitlines()[1:])
                            out_fh.write(f">{sample}\n{seq}\n")

rule align_genes:
    input:
        os.path.join(WORKING_DIR, "gene_alignments", "{gene}.fasta")
    output:
        os.path.join(WORKING_DIR, "gene_alignments", "{gene}_aligned.fasta")
    shell: """
        mafft --localpair --maxiterate 1000 {input} > {output}
    """

rule build_supermatrix:
    input:
        expand(os.path.join(WORKING_DIR, "gene_alignments", "{gene}_aligned.fasta"), gene=GENES)
    output:
        supermatrix=os.path.join(WORKING_DIR, "gene_alignments", "supermatrix.phy"),
        partitions=os.path.join(WORKING_DIR, "gene_alignments", "partitions_iqtree.txt")
    shell: """
        {AMAS_PATH} concat -i {input} -f fasta -d dna -u phylip -t {output.supermatrix} -p partitions.txt
        sed 's/^\(p[0-9]*_[^ ]*\)_aligned[ ]*= */DNA, \\1 = /' partitions.txt > {output.partitions}
    """

rule run_iqtree:
    input:
        supermatrix=os.path.join(WORKING_DIR, "gene_alignments", "supermatrix.phy"),
        partitions=os.path.join(WORKING_DIR, "gene_ali
