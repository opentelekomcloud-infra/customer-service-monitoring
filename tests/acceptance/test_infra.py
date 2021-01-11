#!/usr/bin/env python
import json
import logging
import os
import re
import subprocess
import unittest

from roles.build_infrastructure.files.get_key import Credential, acquire_temporary_ak_sk
from tests.utils import PROJECT_ROOT, project_path

INVENTORY_PATH = project_path('inventory', 'test-infra')

SCN_RE = re.compile(r'^([a-z-\d]+)_monitoring_(setup|destroy)\.ya?ml$')


def _playbook_path(*file_path) -> str:
    """Get playbook file absolute path for files located in resources dir"""
    return project_path('playbooks', *file_path)


def _collect_scenarios():
    collection = {}
    for path in os.listdir(_playbook_path()):
        playbook_name = os.path.basename(path)
        match = SCN_RE.fullmatch(playbook_name)
        if match is None:
            continue
        scenario, target = match.groups()
        mapping = collection.get(scenario, {})  # create new mapping if not exist
        mapping[target] = playbook_name  # record playbook for the target
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


DEBIAN_IMAGE = 'debian:buster'


class TestInfrastructure(unittest.TestCase):
    runner = ''
    scenarios: dict = None
    credential: Credential

    @classmethod
    def setUpClass(cls) -> None:
        cls.runner = _get_runner()
        cls.scenarios = _collect_scenarios()
        cls.credential = acquire_temporary_ak_sk()
        cls.run_playbook('setup_scenarios_controller.yml')

    @classmethod
    def run_playbook(cls, name, ignore_rc=False, **extra_vars):
        """Run playbook with given tool

        :param bool ignore_rc: Ignore process exit code
        :param str name: Name of playbook to be searched in `$PROJECT_ROOT/playbooks`
        :param extra_vars: Additional variables passed to ansible via `--extra-vars`
        :raises subprocess.CalledProcessError: exception for non-zero exit codes
        :return: None
        """

        try:
            subprocess.run([
                cls.runner,
                '--inventory', INVENTORY_PATH,
                '--extra-vars', json.dumps(extra_vars),
                _playbook_path(name)],
                check=not ignore_rc,
                stderr=subprocess.PIPE,
                stdout=subprocess.DEVNULL,
                env={
                    'ANSIBLE_NOCOLOR': '1',
                    'AWS_ACCESS_KEY_ID': cls.credential.access,
                    'AWS_SECRET_ACCESS_KEY': cls.credential.secret,
                    'AWS_SESSION_TOKEN': cls.credential.security_token,
                    'OS_CLOUD': os.getenv('OS_CLOUD'),
                },
                cwd=PROJECT_ROOT,
            )
            print("Playbook", name, "finished successfully")
        except subprocess.CalledProcessError as cpe:
            logging.error(cpe.stderr)
            raise

    def _test_scenario(self, playbooks: dict):
        self.assertIn('setup', playbooks)
        self.assertIn('destroy', playbooks)

        with self.subTest(action='setup'):
            self.run_playbook(playbooks['setup'])
        with self.subTest(action='destroy'):
            self.run_playbook(playbooks['destroy'])

    def test_scenarios(self):
        for k, playbooks in self.scenarios.items():
            print(k, playbooks)
            # with self.subTest(f'Run `{k}`', playbooks=playbooks):
            #     self._test_scenario(playbooks)

    @classmethod
    def tearDownClass(cls):
        cls.run_playbook('destroy_scenarios_controller.yml', ignore_rc=True)
        cls.run_playbook('destroy_scenarios_controller.yml', ignore_rc=True)
        cls.run_playbook('destroy_scenarios_controller.yml', ignore_rc=False)


if __name__ == '__main__':
    unittest.main()
