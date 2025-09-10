MitoExtractor Snakemake Workflow

Author: Temitope Oriowo
Email: t.oriowo@leibniz-lib.de

A Snakemake workflow to extract and annotate mitochondrial genomes from raw Illumina paired-end sequencing data using MitoFinder. This workflow supports recursive detection of FASTQ files in subdirectories and organizes outputs by sample.

Table of Contents

Project Overview

Directory Structure

Requirements

Configuration

Running the Workflow

Output

Tips and Notes

Project Overview

This workflow automates:

Discovery of paired-end FASTQ files in subdirectories.

Extraction of mitochondrial genomes using MitoFinder.

Organization of outputs into per-sample directories.

Cleanup of temporary working files.

It is designed to run on HPC clusters (SGE/SLURM) or locally, supports multiple cores, and can leverage conda environments or module systems.

Directory Structure
mitogenome-extraction-workflow/
├── config/
│   └── config.yaml           # Workflow configuration
├── workflow/
│   ├── rules/
│   │   └── extract-mitogenomes.smk  # Snakemake rules
│   └── logs/                 # Logs for job submissions
├── results/                  # Final outputs (configured in config.yaml)
├── envs/                     # Optional conda environments
└── README.md

Requirements

Software:

MitoFinder
 (path added to $PATH)

Java JRE 1.8+

Snakemake 7+

Python Packages (via conda):

glob, os (standard)

Cluster Modules (optional):

module load java/jre1.8.0_231

Configuration

Edit config/config.yaml to set:

reference: "/path/to/reference.gb"
source_directory: "/path/to/raw_fastq"
temp_directory: "/path/to/temp"
final_output_directory: "/path/to/results"
threads: 7


source_directory: Root directory containing subdirectories of samples.

temp_directory: Working directory for MitoFinder intermediate files.

final_output_directory: Where final mitochondrial genome results are stored.

threads: Number of threads per sample.

Running the Workflow
Dry Run (Cold Run)
snakemake --snakefile workflow/rules/extract-mitogenomes.smk \
          --configfile config/config.yaml \
          --cores 1 \
          --printshellcmds \
          --reason \
          -n


Checks all samples and commands without executing them.

Full Run (Local)
snakemake --snakefile workflow/rules/extract-mitogenomes.smk \
          --configfile config/config.yaml \
          --cores 16 \
          --printshellcmds \
          --reason

Cluster Execution (SGE)
qsub run_mitofinder.sh


Where run_mitofinder.sh contains your Snakemake command with environment setup and cores.

Output

For each sample, the final output directory is:

<final_output_directory>/<sample>/<sample>_MitoFinder_megahit_mitfi_Final_Results/


Contains:

Assembled mitochondrial genome (.fasta)

Annotation files (.gb, .tbl, .gff)

Logs of MitoFinder runs

Temporary working directories are automatically removed after successful completion.

Tips and Notes

Ensure MitoFinder path and Java module are correctly loaded in your shell or Snakemake shell commands.

Sample names are automatically derived from subdirectory names.

_1 and _2 FASTQs must be paired and located in the same subdirectory.

Use dry-run first to verify your setup before large-scale execution.

Adjust threads in config.yaml according to available resources.