import os
import glob
import pandas as pd

# Load config
configfile: "config.yaml"

# Input/output paths
INPUT_DIR = config["MITOFINDER_OUTPUT_DIR"]
OUTPUT_DIR = config["RENAMED_MTDNA_DIR"]
METADATA_FILE = config["METADATA_FILE"]
SUMMARY_FILE = os.path.join(OUTPUT_DIR, "renaming_summary.tsv")
MISSING_FILE = os.path.join(OUTPUT_DIR, "missing_samples.tsv")

os.makedirs(OUTPUT_DIR, exist_ok=True)

# Load metadata
metadata = pd.read_csv(METADATA_FILE, sep="\t")
expected_samples = set(metadata["old_name"])

rule all:
    input:
        os.path.join(OUTPUT_DIR, "renamed.done")

rule rename_mtDNA:
    output:
        summary=SUMMARY_FILE,
        missing=MISSING_FILE
    run:
        with open(SUMMARY_FILE, "w") as summary_fh, open(MISSING_FILE, "w") as missing_fh:
            summary_fh.write("plot_name\tpopulation\told_name\trenamed_files\n")
            
            for idx, row in metadata.iterrows():
                old_name = row["old_name"]
                new_name = row["new_name"]
                population = row["population"]
                plot_name = row["plot_names"]

                folder_candidates = glob.glob(os.path.join(INPUT_DIR, f"{old_name}_MitoFinder*"))
                folder = folder_candidates[0] if folder_candidates else None

                if folder:
                    new_folder = os.path.join(OUTPUT_DIR, plot_name)
                    os.makedirs(new_folder, exist_ok=True)
                    renamed_paths = []

                    for suffix in ["mtDNA_contig.fasta", "final_genes_AA.fasta", "final_genes_NT.fasta"]:
                        pattern = os.path.join(folder, f"*_{suffix}")
                        files = glob.glob(pattern)
                        if files:
                            original_file = files[0]
                            new_file = os.path.join(new_folder, f"{plot_name}_{suffix}")
                            with open(original_file) as infile, open(new_file, "w") as outfile:
                                for line in infile:
                                    outfile.write(line.replace(old_name, plot_name))
                            renamed_paths.append(new_file)

                    os.chdir(new_folder)
                    os.system("""md5sum *.fasta > md5sums.txt""")

                    summary_fh.write(f"{plot_name}\t{population}\t{old_name}\t{';'.join(renamed_paths)}\n")
                else:
                    missing_fh.write(f"{old_name}\n")

            for dirpath in glob.glob(os.path.join(INPUT_DIR, "*_MitoFinder*")):
                sample_base = os.path.basename(dirpath).split("_MitoFinder")[0]
                if sample_base not in expected_samples:
                    missing_fh.write(f"{sample_base}\n")

rule mark_rename_done:
    input:
        SUMMARY_FILE
    output:
        os.path.join(OUTPUT_DIR, "renamed.done")
    shell: """
        touch {output}
    """
