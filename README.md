# This is mono workspace for my learning journey as DevOps / Cloud / Software Engineering.

**The Projects have (or to have) a detailed README explaining guidance how to implement**

## Projects

[Github Actions](./.github/workflows/): Demonstration of calling wanted service's CI or CD workflow depending on the file changed in the pushed commit.

[AWS](./aws/):

- [EKS](./aws/eks/): Terraform manifests for deploying Kubernetes cluster on AWS.

- [ELC](./aws/rds/): Terraform manifests for deploying EC2 instance with ELC on AWS.

[GCP](./gcp/):

- [GKE](./gcp/gke/): Terraform manifests for deploying production ready(!!!) Kubernetes cluster on GCP.

[helm](./helm/): Demonstration of microservices structure with parent helm chart and subchart per microservice.

[scripts](./scripts/):

- [utils](./scripts/bash_utils.sh): Utils bash file to store functions to be imported in needed files

- [formatter](./scripts/format_all.sh): Format the repository's code according to my standard

- [linter](./scripts/format_all.sh): Lint the repository's code to reduce bad code

- [test_args](./scripts/test_args.sh): Test args function imported from utils

[tools](./tools/):

- [slack_alert](./tools/slack_alert/): To use on CI/CD to be alerted on certain statuses in slack

- [tavisod](./tools/tavisod/): Python package to simplify fetching a secret from google's secret manager

- [google_sql_migrator](./tools/google_sql_migrator/): Tool to migrate data between Google Cloud SQL instances.

## My other Projects

[BookishSWAdventure](https://github.com/justmike1/bookish-sw-adventure) (_WIP_)

[MarketWatcher](https://github.com/justmike1/MarketWatcher) (_My favorite_)

[resolve-and-ping](https://github.com/justmike1/resolve-and-ping)

[CryptoTradingTools](https://github.com/justmike1/CryptoTradingTools)

[AutomationScripts](https://github.com/justmike1/AutomationScripts)

[WorldOfGames-DOE](https://github.com/justmike1/WorldOfGames-DOE)
