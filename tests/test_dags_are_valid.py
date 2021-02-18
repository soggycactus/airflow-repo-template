""" DAG Validation Tests to be performed on every CI/CD run. """
import logging
import os
import subprocess
import unittest

from airflow.models import Connection, DagBag
from airflow.settings import Session
from cryptography.fernet import Fernet


class TestDagIntegrity(unittest.TestCase):
    """
    Tests each DAG definition file's integrity by checking for standard configuration & formatting
    """

    @classmethod
    def setUpClass(cls):
        """
        Before tests are run, we instantiate the airflow db, create connections, & import DAGs.
        This ensures DAGs are 100% guaranteed to integrate with our Airflow environment.
        """

        # we run resetdb instead of initdb here to ensure idempotency for Fernet key
        subprocess.run(["airflow", "db", "reset", "-y"], check=False)

        # must set a Fernet key to store connections in the db
        # read more here: https://airflow.readthedocs.io/en/stable/howto/secure-connections.html
        key = Fernet.generate_key().decode()
        os.environ["AIRFLOW__CORE__FERNET_KEY"] = key

        # add all of the connections to the database before loading DAGs
        cls.session = Session()

        for connection in cls.get_connections():

            cls.session.add(connection)
            cls.session.commit()

        # load the DAGs
        cls.dagbag = DagBag(dag_folder="dags", include_examples=False)
        cls.dag_ids = list(cls.dagbag.dags.keys())

    def test_import_dags(self):
        """
        Tests that all DAGs found by Airflow are able to be imported.
        """
        logging.info("DAGs to import: \n%s", "\n".join(self.dag_ids))

        self.assertFalse(
            len(self.dagbag.import_errors),
            f"DAG import failures. Errors: {self.dagbag.import_errors}",
        )

    @classmethod
    def get_connections(cls):
        """
        This method is meant to instantiate connections we need before running our tests.
        This ensures DAGs using custom connections are able to be imported for testing.
        When you create a new connection to use in a DAG, be sure to add it here.
        DO NOT ADD SENSITIVE INFORMATION HERE.
        """

        return [
            Connection(conn_id="example-connection", conn_type="http"),
        ]
