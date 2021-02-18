PYTHON_VERSION := 3.8
AIRFLOW_VERSION := 2.0.0
# Must be comma-separated, no spaces
AIRFLOW_EXTRAS := postgres
CONSTRAINT := https://raw.githubusercontent.com/apache/airflow/constraints-${AIRFLOW_VERSION}/constraints-${PYTHON_VERSION}.txt

# Recreates your virtualenv from scratch, assuming you have python3 installed
.PHONY: venv
venv:
ifneq ($(wildcard ./venv/.*),)
	@echo "venv already exists"
else
	python3 -m virtualenv venv
	venv/bin/python3 -m pip install --upgrade pip
	venv/bin/python3 -m pip install --trusted-host pypi.python.org "apache-airflow[${AIRFLOW_EXTRAS}]==${AIRFLOW_VERSION}" --constraint ${CONSTRAINT}  --use-deprecated legacy-resolver
	venv/bin/python3 -m pip install -r airflow.requirements.txt --use-deprecated legacy-resolver
	venv/bin/python3 -m pip install -r local.requirements.txt --use-deprecated legacy-resolver
endif

# Lints all python files
.PHONY: lint
lint: venv
	venv/bin/python3 -m black dags plugins tests --check
	venv/bin/python3 -m pylint dags --load-plugins=pylint_airflow
	venv/bin/python3 -m pylint dags/modules --load-plugins=pylint_airflow
	venv/bin/python3 -m pylint plugins
	venv/bin/python3 -m pylint tests

lint-docker:
	@docker-compose up lint

# Runs all tests
.PHONY: test
test: venv
	@( \
		export AIRFLOW_HOME=${PWD}; \
		source venv/bin/activate; \
		pytest tests --log-cli-level=info --disable-warnings; \
	)

test-docker:
	@docker-compose up test

# Gets rid of junk from running pytest locally
clean-pytest:
	rm -rf *.cfg airflow.db logs .pytest_cache

# Cleans your virtualenv, run make venv to recreate it
clean-venv:
	rm -rf venv plugins.egg-info

# Cleans everything
clean-all: clean-pytest clean-venv reset-airflow

# starts Postgres
start-db:
	@docker-compose up -d postgres
	@docker-compose up initdb

# starts Airflow
start-airflow: start-db
	@docker-compose up webserver scheduler

# stops Airflow
stop-airflow:
	@docker-compose down 

# Resets local Airflow, removes all docker volumes and stopped containers
reset-airflow:
	@docker-compose down -v || true
	@docker-compose rm -f
	rm -f webserver_config.py

# Rebuilds all docker-compose images 
rebuild-airflow:
	@docker-compose build

### DO NOT RUN THESE STEPS BY HAND
### The below steps are used inside the Dockerfile and/or docker-compose, they are not meant to be run locally
internal-install-airflow:
	pip install --trusted-host pypi.python.org "apache-airflow[${AIRFLOW_EXTRAS}]==${AIRFLOW_VERSION}" --constraint ${CONSTRAINT}  --use-deprecated legacy-resolver

internal-install-deps: 
	pip install -r airflow.requirements.txt --use-deprecated legacy-resolver

internal-install-local-deps:
	pip install -r local.requirements.txt --use-deprecated legacy-resolver

internal-test: internal-install-local-deps
	pytest tests --log-cli-level=info --disable-warnings

internal-lint: internal-install-local-deps
	black dags plugins tests --check
	pylint dags --load-plugins=pylint_airflow
	pylint dags/modules --load-plugins=pylint_airflow
	pylint plugins
	pylint tests