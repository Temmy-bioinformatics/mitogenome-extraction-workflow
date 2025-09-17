---

# 🧬 MitoExtractor Snakemake Workflow

**Author:** Temitope Oriowo  
**Email:** t.oriowo@leibniz-lib.de  

A Snakemake workflow to extract and annotate mitochondrial genomes from raw Illumina paired-end sequencing data using **MitoFinder**. It supports recursive detection of FASTQ files in subdirectories and organizes outputs by sample.

---

## 📚 Table of Contents

- [📚 Table of Contents](#-table-of-contents)
- [🚀 Project Overview](#-project-overview)
- [🗂️ Directory Structure](#️-directory-structure)
- [⚙️ Requirements](#️-requirements)
- [🛠️ Configuration](#️-configuration)
- [🧪 Running the Workflow](#-running-the-workflow)
  - [🔍 Dry Run (Preview)](#-dry-run-preview)
  - [🚀 Full Run (Local)](#-full-run-local)
  - [☁️ Cluster Execution (SGE)](#️-cluster-execution-sge)
- [📦 Output](#-output)
- [💡 Tips and Notes](#-tips-and-notes)
- [📖 Citation](#-citation)

---

## 🚀 Project Overview

This workflow automates:

- Discovery of paired-end FASTQ files in subdirectories  
- Extraction of mitochondrial genomes using **MitoFinder**  
- Organization of outputs into per-sample directories  
- Cleanup of temporary working files  

It’s designed for HPC clusters (SGE/SLURM) or local execution, supports multi-threading, and can use conda environments or module systems.

---

## 🗂️ Directory Structure

```
mitogenome-extraction-workflow/
├── config/
│   └── config.yaml              # Workflow configuration
├── workflow/
│   ├── rules/
│   │   └── extract-mitogenomes.smk  # Snakemake rules
│   └── logs/                    # Logs for job submissions
├── results/                     # Final outputs (configured in config.yaml)
├── envs/                        # Optional conda environments
└── README.md
```

---

## ⚙️ Requirements

**Software:**

- [MitoFinder](https://github.com/RemiAllio/MitoFinder) (added to `$PATH`)  
- Java JRE 1.8+  
- Snakemake 7+

**Python Packages (via conda):**

- `glob`, `os` (standard library)

**Cluster Modules (optional):**

```bash
module load java/jre1.8.0_231
```

---

## 🛠️ Configuration

Edit `config/config.yaml`:

```yaml
reference: "/path/to/reference.gb"
source_directory: "/path/to/raw_fastq"
temp_directory: "/path/to/temp"
final_output_directory: "/path/to/results"
threads: 7
```

- `source_directory`: Root folder with sample subdirectories  
- `temp_directory`: Scratch space for intermediate files  
- `final_output_directory`: Where results are stored  
- `threads`: Number of threads per sample

---

## 🧪 Running the Workflow

### 🔍 Dry Run (Preview)

```bash
snakemake --snakefile workflow/rules/extract-mitogenomes.smk \
          --configfile config/config.yaml \
          --cores 1 \
          --printshellcmds \
          --reason \
          -n
```

### 🚀 Full Run (Local)

```bash
snakemake --snakefile workflow/rules/extract-mitogenomes.smk \
          --configfile config/config.yaml \
          --cores 16 \
          --printshellcmds \
          --reason
```

### ☁️ Cluster Execution (SGE)

Submit your job script:

```bash
qsub run_mitofinder.sh
```

Where `run_mitofinder.sh` contains your Snakemake command and environment setup.

---

## 📦 Output

For each sample, results are stored in:

```
<final_output_directory>/<sample>/<sample>_MitoFinder_megahit_mitfi_Final_Results/
```

Contents include:

- Assembled mitochondrial genome (`.fasta`)  
- Annotation files (`.gb`, `.tbl`, `.gff`)  
- MitoFinder logs  

Temporary directories are removed after successful completion.

---

## 💡 Tips and Notes

- Ensure MitoFinder and Java are correctly loaded in your shell or Snakemake shell commands  
- Sample names are derived from subdirectory names  
- `_1` and `_2` FASTQs must be paired and in the same folder  
- Always run a dry-run first to verify setup  
- Adjust `threads` in `config.yaml` based on available resources

---

## 📖 Citation

The reference for Mitofinder, please cite:

> Allio, R., Schomaker-Bastos, A., Romiguier, J., Prosdocimi, F., Nabholz, B., & Delsuc, F. (2020). MitoFinder: Efficient automated large-scale extraction of mitogenomic data in target enrichment phylogenomics. *Molecular Ecology Resources*, 20(4), 892–905.  
> [https://doi.org/10.1111/1755-0998.13160](https://doi.org/10.1111/1755-0998.13160)

---
