# Master Snakefile

# Load config
configfile: "config.yaml"

# -----------------------------
# Conditionally include modules
# -----------------------------
if config["RUN_MODULES"]["extract_mitogenomes"]:
    include: "01-extract_mitogenomes.smk"

if config["RUN_MODULES"]["rename_extracted_mitogenomes"]:
    include: "02-rename_extracted_mitogenomes.smk"

if config["RUN_MODULES"]["mitogenome_phylogeny"]:
    include: "03-mitogenome_phylogeny.smk"

# -----------------------------
# Master 'all' rule
# -----------------------------
done_files = []
if config["RUN_MODULES"]["extract_mitogenomes"]:
    done_files.append(os.path.join(config["FINAL_OUTPUT_DIRECTORY"], "extracted.done"))

if config["RUN_MODULES"]["rename_extracted_mitogenomes"]:
    done_files.append(os.path.join(config["RENAMED_MTDNA_DIR"], "renamed.done"))

if config["RUN_MODULES"]["mitogenome_phylogeny"]:
    done_files.append(os.path.join(config["ALIGNMENT_DIR"], "phylogeny.done"))

rule all:
    input:
        done_files
