# Investigating Causal Variant Candidates of Systemic Lupus Erythematosus Using UK Biobank Sequencing Data

## Project Overview

This repository contains analysis pipelines for identifying genetic variants associated with systemic lupus erythematosus (SLE) using UK Biobank whole-exome and whole-genome sequencing data (~500,000 samples). The project comprises two main analyses:

1. **Genome-wide association study (GWAS)** on whole-exome sequencing (WES) data using REGENIE
2. **Targeted association analysis of the IRF5 locus** using whole-genome sequencing (WGS) data

### **Data Sources**

- **UK Biobank WGS Data**: DRAGEN population-level WGS variants (500k release)
- **Phenotype Data**: UK Biobank primary care and hospital episode statistics (ICD-10 codes)
- **Genomic Coordinates**: GRCh38/hg38 reference genome

## **Workflow Overview**

### **1. Sample & Phenotype QC** (`01_sample_phenotype_qc/`)
- Filter samples passing WGS QC
- Define SLE cases and controls using ICD-10 codes
- Prepare covariate files (age, sex, ethnicity, PCs)

### **2. Variant QC** (`02_variant_qc/`)
- Apply variant-level quality control filters
- Generate lists of QC-passed variants per chromosome

### **3. Genome-Wide Association Study** (`03_gwas/`)
- Perform GWAS on WES variants using REGENIE
- Test for association between genetic variants and SLE across the genome

### **4. IRF5 Region Analysis** (`04_irf5_analysis/`)
- Extract WGS variants in IRF5 gene region (chr7:128,937,032-128,950,038 ± 1Mb)
- Test for association with SLE using logistic regression (PLINK2)
- Annotate top variants with rsIDs and nearest genes

**Software**: Python 3.12, PySpark, PLINK2, REGENIE, dxCompiler, Ensembl REST API

## Repository Structure
```
SLE-GWAS-UKBIOBANK/
│
├── 01_sample_phenotype_qc/
│   └── sample_phenotype_qc.ipynb          # Sample QC and phenotype preparation
│
├── 02_variant_qc/
│   ├── count_variants.sh                   # Count variants per chromosome
│   ├── generate_wes_qc_json.ipynb          # Generate WES QC configuration
│   └── run_wes_qc.sh                       # Run variant QC pipeline
│
├── 03_gwas/
│   └── regenie_gwas.md                     # GWAS analysis using REGENIE
│
├── 04_irf5_analysis/
│   └── irf5_sle_association_analysis.ipynb # IRF5 region association analysis
│
└── README.md                               # This file
```

## Data Confidentiality & Repository Management
**This repository follows UK Biobank Repository Management Best Practices for Sensitive Data.**
Sensitive data files (participant data/identifiers, genetic data files) are not included in this repository due to UK Biobank data access restrictions. All data files are stored outside the repository directory on the UK Biobank Research Analysis Platform, and all analysis was conducted on the Platform under approved project access. Generated results and outputs are also excluded (see `.gitignore`).

**Reference:** [UK Biobank Repository Management Best Practices](https://community.ukbiobank.ac.uk/hc/en-gb/articles/31205342500253)
## Usage

All notebooks should be run in JupyterLab on the UK Biobank Research Analysis Platform, and all scripts can be run via command line connected to UK Biobank RAP.

**Note**: These analyses require access to UK Biobank data via the Research Analysis Platform and cannot be reproduced without appropriate data access agreements. 

## Acknowledgements
- WES variant QC workflow adapted from DNAnexus UKB_RAP repository ([GitHub](https://github.com/dnanexus/UKB_RAP/tree/main/end_to_end_gwas_phewas/bgens_qc))
- WES GWAS workflow adapted from UK Biobank RAP GWAS tutorial ([DNAnexus GitBook](https://dnanexus.gitbook.io/uk-biobank-rap/science-corner/gwas-using-alzheimers-disease))
- Analysis conducted on UK Biobank Research Analysis Platform
- This research has been conducted using the UK Biobank Resource