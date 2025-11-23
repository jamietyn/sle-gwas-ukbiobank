# REGENIE Genome-Wide Association Study

This document describes the REGENIE analysis conducted on UK Biobank whole-exome sequencing data to test for association between genetic variants and systemic lupus erythematosus (SLE).

## Overview

REGENIE is a two-step procedure for genome-wide association studies that:
1. **Step 1**: Builds a whole-genome polygenic risk score using array genotype data
2. **Step 2**: Tests association between WES variants and phenotype, using Step 1 predictions as covariates to control for population structure and cryptic relatedness

## Analysis Platform

- **Platform**: UK Biobank Research Analysis Platform (RAP)
- **Application**: REGENIE 2.1.1 (Swiss Army Knife app)
- **Instance**: mem3_ssd1_v2_x16
- **Execution**: GUI-based workflow (no command-line scripting)

## Input Data

### Step 1: Array Genotypes
- **Format**: PLINK binary (.bed/.bim/.fam)
- **Data**: `ukb_GRCh38_1_22` (autosomal chromosomes 1-22)
- **Source**: UK Biobank genotype array data (lifted over to GRCh38)
- **Quality Control**: Pre-QCed by UK Biobank (MAF > 0.01, missingness < 0.1, HWE p > 1e-6)
- **Samples**: QC-passed samples from phenotype QC step

### Step 2: Whole-Exome Sequencing
- **Format**: BGEN v1.3 (.bgen + .sample)
- **Data**: 22 chromosome files + X chromosome
- **Variants**: QC-passed WES variants from variant QC pipeline
- **Source**: UK Biobank WES data (OQFE final release, GRCh38)

### Phenotype File
- **Format**: Tab-separated text file
- **Phenotype**: `has_sle_icd10` (binary: 1 = SLE case, 0 = control)
- **Source**: Derived from ICD-10 diagnosis codes (phenotype QC pipeline)

### Covariates
- **Demographic**: Sex, age
- **Ancestry**: Ethnic group (restricted to white British, ethnic_group = 1, to reduce population stratification effects)
- **Population structure**: Principal components 1-10 (PC1-PC10)

## REGENIE Parameters

### Step 1: Whole-Genome Prediction

| Parameter | Value | Description |
|-----------|-------|-------------|
| Genotype files | `ukb_GRCh38_1_22.bed/bim/fam` | Array genotype data |
| Phenotype | `has_sle_icd10` | Binary SLE phenotype |
| Covariates | `sex,age,ethnic_group,pc1-pc10` | Demographic and ancestry covariates |
| Quantitative trait | `False` | Binary trait (case/control) |
| Block size | `1000` | Number of SNPs per block for ridge regression |
| First allele as reference | `True` | Reference allele specification |
| Genome-wide PRS mode | `False` | Standard LOCO (leave-one-chromosome-out) prediction |
| Output prefix | `WES_GWAS` | Prefix for output files |

### Step 2: Association Testing

| Parameter | Value | Description |
|-----------|-------|-------------|
| Genotype files | 22 WES BGEN files (chr1-22) | Whole-exome sequencing data |
| Genotype BGI index files | 22 corresponding .bgi files | BGEN index files |
| Sample files | 22 corresponding .sample files | Sample metadata |
| Variant IDs to extract | `final_WES_snps_GRCh38_qc_pass.snplist` | QC-passed variants only |
| Block size | `200` | Number of variants tested per block |
| P-value threshold | `0.05` | Significance threshold for reporting |
| Firth approximation | `True` | Apply Firth correction for rare variants/low case counts |
| Test type | `additive` | Additive genetic model |
| Minimum MAC | `3` | Minimum minor allele count |
| First allele as reference | `True` | Reference allele specification |

## Statistical Model

### Binary Phenotype Model (Step 2)
```
logit(P(Y=1|X)) = β₀ + βₐX + Σβⱼcovⱼ + γPRS
```

Where:
- **Y**: SLE case/control status
- **X**: Genotype dosage at tested variant (0, 1, or 2 copies of effect allele)
- **cov**: Covariates (sex, age, ethnic_group, PC1-PC10)
- **PRS**: Polygenic risk score from Step 1 (LOCO prediction)
- **βₐ**: Effect size (log odds ratio) for variant being tested

### Firth Correction

Firth's penalised likelihood approach is applied to:
- Reduce bias in effect size estimates for low minor allele count variants
- Improve calibration of p-values in the presence of case-control imbalance
- Handle complete or quasi-complete separation (when genotypes nearly perfectly predict case/control status, causing standard logistic regression to fail)

## Output Files

REGENIE produces the following outputs:

- **Step 1 predictions** (`.loco.gz`): Polygenic risk scores for each sample and chromosome
- **Step 2 association results** (`.regenie.gz`): Summary statistics for all tested variants
  - Columns: CHROM, GENPOS, ID, ALLELE0, ALLELE1, A1FREQ, INFO, N, TEST, BETA, SE, CHISQ, LOG10P, EXTRA

## Next Steps

After completing the REGENIE analysis, the output summary statistics can be used for downstream visualisation and interpretation:

- **Manhattan plots**: Visualise genome-wide association signals across all chromosomes using tools such as LocusZoom (available on UK Biobank RAP) or qqman R package
- **QQ plots**: Examine genomic inflation factor (λ) and assess test statistic inflation to evaluate population stratification and overall GWAS quality
- **Regional association plots**: Generate locus-specific plots for significant variants to examine local LD structure and identify potential causal variants
- **Annotation**: Annotate significant variants with functional information (e.g., gene annotations, regulatory elements, eQTL data)

## References

1. Mbatchou J, Barnard L, Backman J, et al. Computationally efficient whole-genome regression for quantitative and binary traits. *Nat Genet*. 2021;53(7):1097-1103.
2. REGENIE documentation: https://rgcgithub.github.io/regenie/