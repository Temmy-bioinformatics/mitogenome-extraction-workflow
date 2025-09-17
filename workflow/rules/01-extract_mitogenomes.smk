import os
import glob

# -----------------------------
# Build sample list from subdirectories
# -----------------------------
fastq_paths = glob.glob(os.path.join(config["SOURCE_DIRECTORY"], "**/*_1.fq.gz"), recursive=True) \
             + glob.glob(os.path.join(config["SOURCE_DIRECTORY"], "**/*_1.fastq.gz"), recursive=True)

SAMPLES = sorted(list({os.path.basename(os.path.dirname(fq)) for fq in fastq_paths}))

# Map sample name -> fq1 and fq2 paths (keep only the first lane)
SAMPLE_FASTQS = {}
for fq in fastq_paths:
    sample = os.path.basename(os.path.dirname(fq))
    fq2 = fq.replace("_1.fq.gz", "_2.fq.gz").replace("_1.fastq.gz", "_2.fastq.gz")
    # Only store the first occurrence for each sample
    if sample not in SAMPLE_FASTQS:
        SAMPLE_FASTQS[sample] = {"fq1": fq, "fq2": fq2}

# -----------------------------
# Run MitoFinder
# -----------------------------
rule mitofinder:
    input:
        fq1=lambda wc: SAMPLE_FASTQS[wc.sample]["fq1"],
        fq2=lambda wc: SAMPLE_FASTQS[wc.sample]["fq2"],
        reference=config["REFERENCE"]
    output:
        directory(os.path.join(
            config["FINAL_OUTPUT_DIRECTORY"], "{sample}", "{sample}_MitoFinder_megahit_mitfi_Final_Results"
        ))
    threads: config["THREADS"]
    shell: """
        export PATH=$PATH:/home/toriowo/Tools/Mitofinder/MitoFinder
        module load java/jre1.8.0_231

        mkdir -p {config[TEMP_DIRECTORY]}/{wildcards.sample}
        cd {config[TEMP_DIRECTORY]}/{wildcards.sample}

        mitofinder -j {wildcards.sample} \
                   -1 {input.fq1} \
                   -2 {input.fq2} \
                   -r {input.reference} \
                   --max-contig 1 \
                   -o 2 \
                   -p {threads}

        if [ -d {config[TEMP_DIRECTORY]}/{wildcards.sample}/{wildcards.sample}_MitoFinder_megahit_mitfi_Final_Results ]; then
            mkdir -p {config[FINAL_OUTPUT_DIRECTORY]}/{wildcards.sample}
            mv {config[TEMP_DIRECTORY]}/{wildcards.sample}/{wildcards.sample}_MitoFinder_megahit_mitfi_Final_Results \
               {config[FINAL_OUTPUT_DIRECTORY]}/{wildcards.sample}/
        fi

        rm -rf {config[TEMP_DIRECTORY]}/{wildcards.sample}
    """

# -----------------------------
# Sentinel marker
# -----------------------------
rule mark_extract_done:
    input:
        expand(os.path.join(config["FINAL_OUTPUT_DIRECTORY"], "{sample}", "{sample}_MitoFinder_megahit_mitfi_Final_Results"),
               sample=SAMPLES)
    output:
        os.path.join(config["FINAL_OUTPUT_DIRECTORY"], "extracted.done")
    shell:
        "touch {output}"
