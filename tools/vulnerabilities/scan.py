import argparse
import logging
import os
import re
import subprocess
from concurrent.futures import ThreadPoolExecutor, as_completed
import time

import pdfkit


class VulnerabilityScanner:
    MAX_RETRIES = 3
    RETRY_DELAY = 5

    @staticmethod
    def get_all_images(repo, version):
        # Helper function to run the helm template command
        def run_helm_command(saas_enabled):
            helm_template_cmd = ["helm", "template", repo]
            if saas_enabled:
                helm_template_cmd += ["--set", "global.saas.enabled=true"]
            if version:
                helm_template_cmd.append(f"--version {version}")
            helm_template_cmd += [
                "| grep 'image:' | sed 's/ //g' | sed 's/\"//g' | sed \"s/'//g\" | sort | uniq",
            ]
            full_cmd = " ".join(helm_template_cmd)

            try:
                result = subprocess.run(
                    full_cmd,
                    shell=True,
                    capture_output=True,
                    check=True,
                    text=True,
                )
                return result.stdout
            except subprocess.CalledProcessError as e:
                logging.error(f"Error running Helm command with {'SaaS enabled' if saas_enabled else 'SaaS disabled'}: {e.stderr}")
                return ""

        # Run commands with SaaS enabled and disabled
        output_saas_enabled = run_helm_command(True)
        output_saas_disabled = run_helm_command(False)

        # Extract unique images from both outputs
        images_saas_enabled = set(re.findall(r"image:([^\s]+)", output_saas_enabled))
        images_saas_disabled = set(re.findall(r"image:([^\s]+)", output_saas_disabled))

        # Combine and return unique images
        return images_saas_enabled.union(images_saas_disabled)

    def __init__(self, repo, version=None):
        self.images = self.get_all_images(repo, version)
        self.html_files = []

    def run_trivy_scan(self, image):
        html_file_name = f"{image.replace('/', '_').replace(':', '_')}.html"
        html_file_path = os.path.join(
            os.path.abspath(os.path.dirname(__file__)), html_file_name
        )
        self.html_files.append(html_file_path)

        trivy_cmd = [
            "trivy",
            "image",
            "-q",
            "--severity",
            "LOW,MEDIUM,HIGH,CRITICAL",
            "-f",
            "template",
            "--template",
            f"@{os.path.abspath(os.path.dirname(__file__))}/html.tpl",
            "-o",
            html_file_path,
            "--scanners",
            "vuln",
            image,
        ]

        retries = 0
        while retries < self.MAX_RETRIES:
            logging.debug("Running command: %s", " ".join(trivy_cmd))
            result = subprocess.run(trivy_cmd, capture_output=True, text=True)
            
            if result.returncode == 0:
                logging.info(f"Trivy scan completed for image {image}")
                return html_file_path
            elif "TOOMANYREQUESTS" in result.stderr:
                retries += 1
                logging.warning(
                    f"Rate limit error for image {image}. Retrying {retries}/{self.MAX_RETRIES} after {self.RETRY_DELAY} seconds."
                )
                time.sleep(self.RETRY_DELAY)
            else:
                logging.error(f"Error running Trivy for image {image}: {result.stderr}")
                return None

        logging.error(f"Trivy scan failed after {self.MAX_RETRIES} retries for image {image}")
        return None

    def scan(self):
        with ThreadPoolExecutor() as executor:
            futures = {executor.submit(self.run_trivy_scan, image): image for image in self.images if "postgresql" not in image}
            for future in as_completed(futures):
                image = futures[future]
                try:
                    future.result()
                except Exception as exc:
                    logging.error(f"Image {image} generated an exception: {exc}")

        # Combine all HTML files
        combined_html_file_path = os.path.join(
            os.path.abspath(os.path.dirname(__file__)), "combined.html"
        )
        with open(combined_html_file_path, "w") as outfile:
            for html_file in self.html_files:
                with open(html_file) as infile:
                    outfile.write(infile.read())

        # Convert combined HTML to PDF
        pdf_options = {"page-size": "A3", "debug-javascript": ""}
        pdf_output_file_path = os.path.join(
            os.path.abspath(os.path.dirname(__file__)), "report.pdf"
        )
        pdfkit.from_file(
            combined_html_file_path, pdf_output_file_path, options=pdf_options
        )

        # Remove temporary files
        os.remove(combined_html_file_path)
        for html_file in self.html_files:
            os.remove(html_file)

        logging.info(
            f"Vulnerability scanning complete. Report saved as {pdf_output_file_path}"
        )


def main():
    parser = argparse.ArgumentParser(
        description="Scan a Helm chart for vulnerabilities."
    )
    parser.add_argument("--repo", type=str, help="The Helm chart repository to scan.")
    parser.add_argument(
        "--version", type=str, help="The version of the Helm chart to scan.", default=None
    )
    parser.add_argument(
        "--log-level",
        type=str,
        default="INFO",
        choices=["DEBUG", "INFO", "WARNING", "ERROR"],
        help="The log level.",
    )
    args = parser.parse_args()

    # Configure logging
    logging.basicConfig(level=args.log_level, format="[%(levelname)s] %(message)s")

    # Create a handler for stdout if it doesn't already exist
    stdout_handler = logging.StreamHandler()
    stdout_handler.setLevel(args.log_level)
    logger = logging.getLogger()
    if not logger.handlers:
        logger.addHandler(stdout_handler)

    if not args.repo:
        parser.error("--repo argument is required.")

    scanner = VulnerabilityScanner(args.repo, args.version)
    scanner.scan()


if __name__ == "__main__":
    main()