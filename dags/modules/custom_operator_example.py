""" Example Airflow Plugin """
import logging

from airflow.models import BaseOperator
from airflow.utils.decorators import apply_defaults


class ExamplePluginOperator(BaseOperator):
    """
    Example Operator to print a message
    """

    @apply_defaults
    def __init__(
        self,
        message: str,
        *args,
        **kwargs,
    ):
        super().__init__(*args, **kwargs)
        self.message = message

    def execute(self, context):
        logging.info("Returning the message: %s", self.message)
        return self.message
