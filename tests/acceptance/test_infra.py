#!/usr/bin/env python
import glob
import os
import re
import subprocess
import unittest

__BASE_PROJECT_PATH = os.path.abspath(f'{os.path.dirname(__file__)}/..')

PLAYBOOKS_PATH = os.path.join(__BASE_PROJECT_PATH, 'playbooks')
INVENTORY_PATH = os.path.join(__BASE_PROJECT_PATH, 'inventory', 'test-infra')

SCN_RE = re.compile(r'^([a-z-\d]+)_monitoring_(setup|destroy)\.ya?ml$')


def _collect_scenarios():
    collection = {}
    playbooks = glob.glob(os.path.join(PLAYBOOKS_PATH, '*.yml'))
    for playbook in playbooks:
        name = os.path.basename(playbook)
        match = SCN_RE.fullmatch(name)
        if match is None:
            continue
        scenario, target = match.groups()
        mapping = collection.get(scenario, {})  # create new mapping if not exist
        mapping[target] = name  # record playbook for the target
        collection[scenario] = mapping
    return collection


def _get_runner():
    """Get `ansible-playbook` absolute path"""

    prc = subprocess.run(
        ['/usr/bin/which', 'ansible-playbook'],
        check=True,
        stdout=subprocess.PIPE
    )
    return str(prc.stdout.strip(), 'utf-8')


class TestInfrastructure(unittest.TestCase):
    runner = ""
    scenarios = None

    @classmethod
    def setUpClass(cls) -> None:
        cls.runner = _get_runner()
        cls.scenarios = _collect_scenarios()
        cls.run_playbook('setup_scenarios_controller.yml')

    @classmethod
    def run_playbook(cls, name):
        """Run playbook with given tool

        :param str name: Name of playbook
        :raises subprocess.CalledProcessError: exception for non-zero exit codes
        :return: None
        """
        subprocess.run(
            [cls.runner, '-i', INVENTORY_PATH, f'{PLAYBOOKS_PATH}/{name}'],
            check=True,
            stderr=subprocess.PIPE,
        )

    def _test_scenario(self, playbooks: dict):
        self.assertIn('setup', playbooks)
        self.assertIn('destroy', playbooks)

        with self.subTest(action='setup'):
            self.run_playbook(playbooks['setup'])
        with self.subTest(action='destroy'):
            self.run_playbook(playbooks['destroy'])

    def test_scenarios(self):
        for k, playbooks in self.scenarios.items():
            with self.subTest(f'Run `{k}`', playbooks=playbooks):
                self._test_scenario(playbooks)

    @classmethod
    def tearDownClass(cls):
        cls.run_playbook(f'{PLAYBOOKS_PATH}/destroy_scenarios_controller.yml')


if __name__ == '__main__':
    unittest.main()
