# Database migrator

## Instructions

**IMPORTANT connect to gcloud sdk `gcloud auth application-default login`**

- Setup python
    ```bash
    brew install python@3.8
    python3.8 -m venv venv
    source venv/bin/activate
    ```
- Install requirements
    ```bash
    pip install -r tools/google_sql_migrator/requirements.txt
    ```

### Running the migrator

> The script has multiple argumets:

- --ex_project: source google cloud project
- --im_project: destination google cloud project
- --bucket: s3 bucket that stores the files | **(default: gs://import_export_db/python/)**
- --ex_databases: which databases to export? | **(default: all)**
- --ex_sql: export source google cloud sql id | **required**
- --im_sql: import destination google cloud sql id | **if not included the script will only export/backup to requested bucket**

```bash
python google_sql_migrator/migrate.py --ex_sql <SOURCE_DB> --im_sql <DEST_DB>
```

### Running the localhost migrator

**make sure you have installed postgresql via brew**

```bash
brew install postgresql@14 # or 13
```

- run the migrator with the desired database to migrate

```bash
./tools/google_sql_migrator/init.sh <DB_1> <DB_2>

# I.E:
./tools/google_sql_migrator/init.sh emr
```

### Test

> To check if the migration worked

- connect to the database via ssh tunneling (if migrated between google SQLs)

```bash
psql postgres://postgres:<SQL_PASS>@localhost:5432/
\list
```

- if migrated to localhost then

```bash
psql postgres://postgres:password@localhost:5432/
\list
```

### Run as a Docker

> the docker run should have the google credential file as volume and as environment variable

- GOOGLE_APPLICATION_CREDENTIALS

```bash
docker run -e GOOGLE_APPLICATION_CREDENTIALS=/adc.json \
    -v ~/.config/gcloud/legacy_credentials/<EMAIL>/adc.json:/adc.json \
    google_sql_migrator --ex_sql=<SOURCE> --im_sql=<TARGET>
```

### if one of the SQL instances is new, need to add service account permissions

- take the service account of the SQL instance from GCP --> SQL

`gsutil iam ch serviceAccount:<user email>:objectCreator,roles/storage.objectViewer gs://import_export_db`
