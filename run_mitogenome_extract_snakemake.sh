#!/bin/bash
#
#$ -S /bin/bash
#$ -cwd
#$ -j n
#$ -M T.Oriowo@leibniz-lib.de
#$ -e /home/toriowo/Snakemake_projects/mitogenome-extraction-workflow/workflow/logs
#$ -o /home/toriowo/Snakemake_projects/mitogenome-extraction-workflow/workflow/logs
#$ -q medium.q,large.q
#$ -pe smp 16
#$ -m n
#$ -N mitogenome_extract

module load miniforge/24.7.1-0


# #Extract tar files first before running snakemake
# TAR_FILE="/share/pool/CompGenomVert/RawData/Novogene_Phoxinus_20240610/X208SC24022985-Z01-F002.tar"
# NEW_DIR="/share/pool/toriowo/Resources/madlen_vienna_mitogenomes/extracted"

# # Create the new directory if it doesn't exist
# mkdir -p "$NEW_DIR"

# # Untar the file into the new directory
# tar -xvf "$TAR_FILE" -C "$NEW_DIR"

# Navigate to the workflow directory
cd /home/toriowo/SNAKEMAKE/MitoExtractor_run

# Activate Snakemake Conda Environment
conda activate /home/toriowo/.conda/envs/snakemake


SMK_FILE="/home/toriowo/Snakemake_projects/mitogenome-extraction-workflow/workflow/rules/extract-mitogenomes.smk"
CONFIG="/home/toriowo/Snakemake_projects/mitogenome-extraction-workflow/config/config.yaml"

# Running Snakemake with the single config file
echo "Running Snakemake with the following config:"
echo "${CONFIG}"


# Launch Snakemake pipeline
snakemake --cores 15 \
          --use-envmodules \
          --printshellcmds \
          --verbose \
          --reason \
          --snakefile ${SMK_FILE} \
          --configfile ${CONFIG} \
          --latency-wait 300
          #--use-conda 
          #--conda-create-envs-only \

# Check for Snakemake success
if [ $? -ne 0 ]; then
    echo "Snakemake failed. Exiting."
    conda deactivate
    exit 1
fi

# Deactivate Conda environment
conda deactivate
