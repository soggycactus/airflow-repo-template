""" Locally install custom Airflow plugins as extensions """
from setuptools import setup

setup(
    name="plugins",
    entry_points={
        "airflow.plugins": ["example_plugin = plugins.example_plugin:ExamplePlugin",]
    },
)
