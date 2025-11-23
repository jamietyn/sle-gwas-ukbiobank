#!/bin/bash
# WES Variant QC Workflow for SLE GWAS
# Automates variant quality control for UK Biobank whole exome sequencing data
#
# Prerequisites:
# 1. Linux environment 
# 2. Completed phenotype QC step (sle_pqc_gwas.phe uploaded to /02.Phenotype_SampleQC/)
# 3. Generated bgens_qc_input.json (uploaded to /03.Variant_QC/)
#
# Usage:
# 1. Make executable: chmod +x run_wes_qc.sh
# 2. Run: ./run_wes_qc.sh
# 3. Enter UK Biobank project ID when prompted
#
# The script will:
# - Check and auto-install all required dependencies (Python3, pip3, dxpy, Java, wget)
# - Download dxCompiler 2.13.0
# - Download the WDL workflow file from DNAnexus GitHub
# - Compile the workflow
# - Submit the analysis to UK Biobank RAP
#
# Expected outputs in /03.Variant_QC/ upon completion:
# - bgen_qc (Applet): Per-chromosome QC processing
# - bgens_qc (Workflow): Main workflow orchestrator
# - bgens_qc_common (Applet): Shared workflow components
# - bgens_qc_outputs (Applet): Results aggregator
# - concat_qc_pass_files (Applet): Concatenates QC results across chromosomes
# - final_WES_snps_GRCh38_qc_pass.snplist: List of variants passing QC

set -e  # Exit immediately if any command fails

echo "=== WES Variant QC Workflow ==="
echo ""

# Helper function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1  # Check if command is in PATH, suppress output
}

echo "Checking dependencies..."
echo ""

# Install Python3 if missing
if ! command_exists python3; then
    echo "Installing Python3..."
    sudo apt update && sudo apt install -y python3  # Update package list and install Python3
fi
echo "Python3: OK"

# Install pip3 if missing
if ! command_exists pip3; then
    echo "Installing pip3..."
    sudo apt update && sudo apt install -y python3-pip  # Install Python package manager
fi
echo "pip3: OK"

# Install DNAnexus CLI if missing
if ! command_exists dx; then
    echo "Installing DNAnexus CLI..."
    pip3 install --user dxpy --break-system-packages  # Install DNAnexus Python SDK for user only
    export PATH="$HOME/.local/bin:$PATH"  # Add local bin directory to PATH for current session
    if ! command_exists dx; then  # Verify installation succeeded
        echo "Error: DNAnexus CLI installation failed"
        echo "Manual installation: pip3 install dxpy --break-system-packages"
        exit 1
    fi
fi
echo "DNAnexus CLI: OK"

# Install Java 17 (compatible with dxCompiler 2.13.0)
if ! command_exists java; then
    echo "Installing Java 17 (LTS)..."
    sudo apt update && sudo apt install -y openjdk-17-jre  # Install Java Runtime Environment
fi
echo "Java: OK"

# Install wget if missing
if ! command_exists wget; then
    echo "Installing wget..."
    sudo apt update && sudo apt install -y wget  # Install file download utility
fi
echo "wget: OK"

echo ""

# Verify DNAnexus login status
if ! dx whoami >/dev/null 2>&1; then  # Check if logged into DNAnexus
    echo "DNAnexus login required:"
    dx login  # Prompt for DNAnexus credentials
fi

echo "Logged in as: $(dx whoami)"  # Display current DNAnexus username
echo ""

# Prompt user for project ID
read -p "Enter UK Biobank project ID: " PROJECT_ID  # Get project ID from user input

# Validate project ID format
if [[ ! $PROJECT_ID =~ ^project- ]]; then  # Check if ID starts with 'project-'
    echo "Error: Invalid project ID format (must start with 'project-')"
    exit 1
fi

echo "Project: $PROJECT_ID"
echo ""

# Use stable dxCompiler version (compatible with Java 17)
echo "Using dxCompiler 2.13.0..."
DXCOMPILER_VERSION="2.13.0"  # Set version number
DXCOMPILER_FILE="dxCompiler-${DXCOMPILER_VERSION}.jar"  # Construct JAR filename
echo ""

# Download dxCompiler JAR file
echo "[1/5] Downloading dxCompiler 2.13.0..."
if [ ! -f "${DXCOMPILER_FILE}" ]; then  # Check if file already exists
    wget -q "https://github.com/dnanexus/dxCompiler/releases/download/${DXCOMPILER_VERSION}/dxCompiler-${DXCOMPILER_VERSION}.jar"  # Download silently
fi

# Download WDL workflow file from GitHub
echo "[2/5] Downloading WDL workflow..."
if [ ! -f "bgens_qc.wdl" ]; then  # Check if workflow file already exists
    wget -q https://raw.githubusercontent.com/dnanexus/UKB_RAP/main/end_to_end_gwas_phewas/bgens_qc/bgens_qc.wdl  # Download WDL workflow definition
fi

# Download input JSON from RAP project
echo "[3/5] Downloading input configuration..."
dx download /03.Variant_QC/bgens_qc_input.json --overwrite  # Download JSON config from project, overwrite if exists

# Compile WDL into DNAnexus native workflow
echo "[4/5] Compiling WDL workflow..."
java -jar ${DXCOMPILER_FILE} compile bgens_qc.wdl \
  -project ${PROJECT_ID} \              # Specify target project
  -inputs bgens_qc_input.json \         # Provide input configuration
  -archive \                            # Archive previous workflow versions
  -folder /03.Variant_QC/               # Set output folder location

# Submit workflow to RAP
echo "[5/5] Submitting workflow..."
ANALYSIS_ID=$(dx run /03.Variant_QC/bgens_qc -f bgens_qc_input.dx.json --brief)  # Execute workflow and capture analysis ID

echo ""
echo "Workflow submitted successfully"
echo "Analysis ID: ${ANALYSIS_ID}"  # Display analysis ID for monitoring
echo ""
echo "Monitor status: dx describe ${ANALYSIS_ID}"  # Show command to check workflow status
echo ""
echo "Optional: Upload workflow files to RAP for documentation:"
echo "  dx upload run_wes_qc.sh --path /03.Variant_QC/"
echo "  dx upload bgens_qc.wdl --path /03.Variant_QC/"