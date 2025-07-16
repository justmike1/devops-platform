# TODO: pytest
from tavisod import tavisod

_tavisod = tavisod.gSM(
    project_id="project-contains-secret", version="latest", check_env=False
)
print(_tavisod.get(secret_id="DB_PASSWORD"))
