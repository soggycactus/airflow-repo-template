""" Plugin Validation Tests to be performed on every CI/CD run. """
import inspect
import logging
import unittest

from airflow.plugins_manager import AirflowPlugin, is_valid_plugin

import plugins


def isplugin(x):
    """
    Identifies whether an object is a custom Airflow plugin

    :param x: object to evaluate
    :type x: Class
    :return: Boolean, whether the object inherits from AirflowPlugin
    """
    if inspect.isclass(x):
        return (
            issubclass(x, AirflowPlugin) and x.__name__ != "AirflowPlugin"
        )  # ignore the AirflowPlugin object itself
    return False


def islocalmodule(x):
    """
    This is a hacky safeguard to prevent our test from recursing the entire virtualenv

    :param x: object to evaluate
    :type x: Module
    :return: Boolean, whether the module is a local module inside 'plugins'
    """
    if inspect.ismodule(x):
        return plugins.__name__ in x.__name__

    return False


def get_all_plugins(module, plugins=[]):  # pylint: disable=redefined-outer-name
    """
    Retrieves all custom Airflow plugins from a specified module, using recursion

    :param module: module to crawl for Airflow plugins
    :type module: Module
    :param plugins: recursive parameter, existing plugins to include
    :type plugins: list of AirflowPlugin objects
    :return: list of tuples (str: name, AirflowPlugin)
    """
    inspection = inspect.getmembers(module, isplugin)
    if inspection:
        plugins.extend(inspection)
    modules = [x[1] for x in inspect.getmembers(module, islocalmodule)]

    while modules:
        for module in modules:  # pylint: disable=redefined-argument-from-local
            get_all_plugins(module, plugins)
            modules.remove(module)

    return plugins


class TestPlugins(unittest.TestCase):
    """
    Tests each custom plugin to ensure it integrates with Airflow
    """

    @classmethod
    def setUpClass(cls):
        cls.plugins = get_all_plugins(module=plugins)

    def test_plugin_validity(self):
        """
        Tests that all plugins are able to be installed by Airflow
        """
        for name, plugin in self.plugins:
            logging.info("Validating %s", name)

            # is_valid_plugin is used by Airflow internally to validate plugins before installation
            # it accepts an argument of existing plugins to prevent duplicate installs
            # because we're testing validity, not installing, we pass an empty list
            self.assertTrue(is_valid_plugin(plugin, []))
