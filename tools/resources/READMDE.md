# Helm Chart Resource Calculator

## Overview

This Python script is designed to calculate the total resource requests and limits (CPU and memory) for Kubernetes Helm charts. It works by processing the Helm chart templates, extracting resource definitions from `deployment.yaml` files, and then summing up these resources across all containers in the charts.

## Features

- **Helm Chart Processing**: Automatically processes Helm chart templates to extract resource information.
- **Resource Aggregation**: Calculates the total CPU and memory requests and limits for all containers in the Helm charts.
- **Temporary Workspace**: Creates a unique temporary directory for processing, ensuring no interference with existing files.
- **Clean Up**: Automatically deletes the temporary directory after processing, leaving no residual data.

## Prerequisites

- Python 3.x
- Helm installed and configured
- Access to the Helm chart repositories

## Usage

1. **Clone or Download the Script**: Obtain the script from the provided source.

2. **Download pip Dependencies**: Use the command line to navigate to the script's directory and run the following command:

    ```bash
    python3 -m venv venv
    source venv/bin/activate
    pip install -r tools/resources/requirements.txt
    ```

    This command downloads the required dependencies for the script to run.

3. **Run the Script**: Use the command line to navigate to the script's directory and run it using Python. The script accepts two arguments:
    - `--repo`: The URL of the Helm chart repository (required).
    - `--version`: The version of the Helm chart (optional).

    Example command:

    ```bash
    python tools/resources/calc_chart_resources.py --repo "oci://registry-1.docker.io/organization/helm" --version "1.10.0"
    ```

    Replace `--version` with the version of the Helm chart you want to process. If you do not specify a version, the script processes the latest version of the chart.

4. **View the Output**: After successful execution, the script prints the total CPU and memory requests and limits in the format:

    ```json
    {'limits': {'cpu': X.XX, 'memory': 'XX.XXGi'}, 'requests': {'cpu': X.XX, 'memory': 'XX.XXGi'}}
    ```

    where `X.XX` represents the respective resource values.

## Important Notes

- The script creates a temporary directory for processing Helm chart templates and deletes this directory after completion. This ensures that no residual data is left on your system.
- Ensure that you have the necessary permissions to access the specified Helm chart repository.
- The resource calculations are based on the definitions found in the `deployment.yaml` files of the Helm charts. Make sure these files are properly formatted and contain the necessary resource definitions.

## Support

For any issues or queries regarding the script, please contact [Support Email/Contact Information].
