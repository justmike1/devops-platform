import os
import glob
import yaml
import json
import subprocess
import argparse
import uuid
import shutil
import tempfile


class HelmChart:
    def __init__(self, repo, version, output_dir):
        self.repo = repo
        self.version = version
        self.output_dir = output_dir

    def helm_template(self):
        """
        Run helm template command and return the output
        """
        cmd = f"helm template {self.repo} --output-dir {self.output_dir}"
        if self.version:
            cmd += f" --version {self.version}"
        return subprocess.check_output(
            cmd, shell=True, text=True, stderr=subprocess.DEVNULL
        )


# Define and parse command-line arguments
parser = argparse.ArgumentParser(description="Process helm charts")
parser.add_argument("--repo", required=True, help="Repository URL")
parser.add_argument("--version", help="Chart version")
args = parser.parse_args()

# Create a unique temporary directory
unique_id = str(uuid.uuid4())
output_dir = tempfile.mkdtemp(prefix=f"calc_helm_resources_{unique_id}")

try:
    # Create HelmChart instance and run helm template
    helm_chart = HelmChart(args.repo, args.version, output_dir)
    helm_chart.helm_template()

    def extract_resources(file_path):
      with open(file_path, "r") as file:
          data = yaml.safe_load(file)

      # Default to 1 replica if not specified
      replicas = data.get("spec", {}).get("replicas", 1)

      containers = data["spec"]["template"]["spec"]["containers"]
      resources = {}

      for container in containers:
          container_name = container["name"]
          container_resources = container.get("resources", {})
          resources[container_name] = container_resources

      return resources, replicas

    def process_charts_directory(base_path):
        all_resources = {}

        # Iterate over each subdirectory in the base_path
        for sub_dir in glob.glob(os.path.join(base_path, "*/")):
            deployment_file = os.path.join(sub_dir, "templates/deployment.yaml")

            # Check if deployment.yaml exists in this subdirectory
            if os.path.exists(deployment_file):
                chart_name = os.path.basename(os.path.dirname(sub_dir))
                resources, replicas = extract_resources(deployment_file)

                # Structure: Include replicas and resources under the chart
                all_resources[chart_name] = {
                    "replicas": replicas,
                    "resources": resources
                }

        return all_resources 
    base_path = output_dir + "/suite/charts"
    chart_resources = process_charts_directory(base_path)

    total = json.dumps(chart_resources, indent=4)
    print(total)
    # Convert JSON string back to dictionary
    data = json.loads(total)

    # Function to convert CPU to millicores and then to cores
    def convert_cpu_to_cores(value, replicas):
        if value.endswith("m"):
            return float(value[:-1]) / 1000 * replicas
        return float(value) * replicas

    # Function to convert memory to MiB and then to GiB
    def convert_memory_to_gib(value, replicas):
        if value.endswith("Mi"):
            return float(value[:-2]) / 1024 * replicas
        elif value.endswith("Gi"):
            return float(value[:-2]) * replicas
        elif value.endswith("Ki"):
            return float(value[:-2]) / (1024 * 1024) * replicas
        else:  # Assuming value in bytes
            return float(value) / (1024 * 1024 * 1024) * replicas

    # Initialize accumulators
    total_limits = {"cpu": 0, "memory": 0}
    total_requests = {"cpu": 0, "memory": 0}

    # Iterate over the data to accumulate resources
    for chart, chart_data in chart_resources.items():
        replicas = chart_data.get("replicas", 1)
        containers = chart_data.get("resources", {})
        for container, resources in containers.items():
            if "limits" in resources:
                total_limits["cpu"] += (
                    convert_cpu_to_cores(resources["limits"].get("cpu", "0"), replicas)
                )
                total_limits["memory"] += (
                    convert_memory_to_gib(resources["limits"].get("memory", "0Gi"), replicas)
                )
            if "requests" in resources:
                total_requests["cpu"] += (
                    convert_cpu_to_cores(resources["requests"].get("cpu", "0"), replicas)
                )
                total_requests["memory"] += (
                    convert_memory_to_gib(resources["requests"].get("memory", "0Gi"), replicas)
                )


    # Formatting the output
    total_limits["cpu"] = round(total_limits["cpu"], 2)
    total_limits["memory"] = str(round(total_limits["memory"], 2)) + "Gi"
    total_requests["cpu"] = round(total_requests["cpu"], 2)
    total_requests["memory"] = str(round(total_requests["memory"], 2)) + "Gi"

    print({"limits": total_limits, "requests": total_requests})
finally:
    # Clean up: Delete the temporary directory
    shutil.rmtree(output_dir)
