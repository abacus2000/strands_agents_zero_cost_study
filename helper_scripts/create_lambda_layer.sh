#!/bin/bash

set -e

# Script to create AWS Lambda layers for Python packages
# Usage: ./create-lambda-layer.sh <package_names> <python_version> [layer_name] [region]
# Example: ./create-lambda-layer.sh pandas 3.9
# Example: ./create-lambda-layer.sh "pandas pyarrow" 3.9
# Example: ./create-lambda-layer.sh "pandas==2.0.3 pyarrow==12.0.0" 3.9 my-data-layer us-west-2

# Check if required arguments are provided
if [ $# -lt 2 ]; then
    echo "Usage: $0 <package_names> <python_version> [layer_name] [region]"
    echo ""
    echo "Arguments:"
    echo "  package_names   : Python package(s) to install (space-separated for multiple)"
    echo "                    Single: pandas"
    echo "                    Multiple: 'pandas pyarrow'"
    echo "                    With versions: 'pandas==2.0.3 pyarrow==12.0.0'"
    echo "  python_version  : Python version for Lambda (e.g., 3.9, 3.10, 3.11, 3.12)"
    echo "  layer_name      : Optional. Name for the Lambda layer (default: <package>-layer)"
    echo "  region          : Optional. AWS region (default: us-east-1)"
    echo ""
    echo "Examples:"
    echo "  $0 pandas 3.9"
    echo "  $0 'pandas pyarrow' 3.9"
    echo "  $0 'requests urllib3' 3.11 http-layer us-west-2"
    exit 1
fi

# Parse arguments
PACKAGE_NAMES="$1"
PYTHON_VERSION="$2"

# Extract first package name for default layer name
FIRST_PACKAGE=$(echo "$PACKAGE_NAMES" | awk '{print $1}' | sed 's/[=<>].*//')

LAYER_NAME="${3:-${FIRST_PACKAGE}-layer}"
REGION="${4:-us-east-1}"

# Determine Python runtime string
RUNTIME="python${PYTHON_VERSION}"

# Create work directory
WORK_DIR="lambda-layer-build-$$"
mkdir -p "$WORK_DIR/python"

echo "========================================="
echo "Lambda Layer Builder"
echo "========================================="
echo "Packages:       $PACKAGE_NAMES"
echo "Python Version: $PYTHON_VERSION"
echo "Layer Name:     $LAYER_NAME"
echo "Region:         $REGION"
echo "Runtime:        $RUNTIME"
echo "========================================="
echo ""

# Install packages with Lambda-compatible platform
echo "Installing packages for Lambda x86_64 platform..."
pip3 install \
    --platform manylinux2014_x86_64 \
    --target="$WORK_DIR/python" \
    --implementation cp \
    --python-version "$PYTHON_VERSION" \
    --only-binary=:all: \
    --upgrade \
    $PACKAGE_NAMES

if [ $? -ne 0 ]; then
    echo "Error: Failed to install package"
    rm -rf "$WORK_DIR"
    exit 1
fi

# Create zip file
echo ""
echo "Creating layer zip file..."
cd "$WORK_DIR"
ZIP_FILE="${LAYER_NAME}.zip"
zip -r "$ZIP_FILE" python/ -q

if [ $? -ne 0 ]; then
    echo "Error: Failed to create zip file"
    cd ..
    rm -rf "$WORK_DIR"
    exit 1
fi

# Show zip file size
ZIP_SIZE=$(du -h "$ZIP_FILE" | cut -f1)
echo "Layer zip created: $ZIP_FILE (Size: $ZIP_SIZE)"

# Move zip to parent directory
mv "$ZIP_FILE" ../"$ZIP_FILE"
cd ..

# publish layer to AWS Lambda
echo ""
echo "Publishing layer to AWS Lambda..."
LAYER_ARN=$(aws lambda publish-layer-version \
    --layer-name "$LAYER_NAME" \
    --description "Lambda layer for $PACKAGE_NAMES (Python $PYTHON_VERSION, x86_64)" \
    --zip-file "fileb://$ZIP_FILE" \
    --compatible-runtimes "$RUNTIME" \
    --region "$REGION" \
    --query 'LayerVersionArn' \
    --output text)

if [ $? -ne 0 ]; then
    echo "Error: Failed to publish layer"
    rm -rf "$WORK_DIR"
    exit 1
fi

echo ""
echo "Cleaning up temporary files..."
rm -rf "$WORK_DIR"

echo ""
echo "========================================="
echo "SUCCESS!"
echo "========================================="
echo "Layer ARN: $LAYER_ARN"
echo ""
echo "To use this layer in your Lambda function, run:"
echo "aws lambda update-function-configuration \\"
echo "  --function-name YOUR_FUNCTION_NAME \\"
echo "  --layers $LAYER_ARN \\"
echo "  --region $REGION"
echo ""
echo "Or add to your Lambda function configuration."
echo "========================================="
