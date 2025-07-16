# Setup

```bash
pip install tavisod
```

# Usage

- [See test file for example usage](../../tests/test_tavisod.py)
    > replace project_id to your relevant one

| argument   | required            |
| ---------- | ------------------- |
| project_id | yes                 |
| secret_id  | yes                 |
| version    | no (default=latest) |
| check_env  | no (default=False)  |

## Build project

**make sure you are in project's dir**

```bash
python setup.py sdist
```

## Upload to pypi

```bash
pip install twine
```

```bash
twine upload --repository-url https://upload.pypi.org/legacy/ dist/*
```

### TODO: add all provider's secret managers
