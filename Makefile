.PHONY: venv

# Recreates your virtualenv from scratch, assuming you have python3 installed
venv:
ifneq ($(wildcard ./venv/.*),)
	@echo "venv already exists"
else
	python3 -m virtualenv venv
	venv/bin/python3 -m pip install --no-deps -r airflow.requirements.txt
	venv/bin/python3 -m pip install -r local.requirements.txt
endif

# Lints all python files
lint: venv
	venv/bin/python3 -m black dags plugins tests --check
	venv/bin/python3 -m pylint dags --load-plugins=pylint_airflow
	venv/bin/python3 -m pylint plugins
	venv/bin/python3 -m pylint tests

# Runs all tests
test: venv
	@( \
		export AIRFLOW_HOME=${PWD}; \
		source venv/bin/activate; \
		pytest tests --log-cli-level=info --disable-warnings; \
	)

# Gets rid of junk from running pytest locally
clean-pytest:
	rm -rf *.cfg airflow.db logs .pytest_cache

# Cleans your virtualenv, run make venv to recreate it
clean-venv:
	rm -rf venv plugins.egg-info

# Cleans everything
clean-all: clean-pytest clean-venv reset-airflow
	rm .env

set-fernet-key: venv
	@venv/bin/python3 scripts/set_fernet_key.py

# starts Postgres
start-db:
	@docker-compose up -d postgres

# starts Airflow
start-airflow: set-fernet-key start-db
	@docker-compose up 

# stops Airflow
airflow-down:
	@docker-compose down 

# Resets local Airflow, removes all docker-volumes
reset-airflow:
	@docker-compose down -v