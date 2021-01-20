#!/usr/bin/env python
import os
import random
import re
import string
import subprocess
import unittest
from queue import Queue
from threading import Thread

from ansible_runner import run as run_playbook

from roles.build_infrastructure.files.get_key import Credential, acquire_temporary_ak_sk
from tests.utils import PROJECT_ROOT, project_path

INVENTORY_PATH = project_path('inventory', 'test-infra')

SCN_RE = re.compile(r'^([a-z-_\d]+)_monitoring_(setup|destroy)\.ya?ml$')
TEST_TIMEOUT = 60 * 60 * 60  # 1hr
LOG_PATH = os.path.join(PROJECT_ROOT, 'log')


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

EXCLUDE_SCENARIOS = {
    # 'dns',
    # 'rds',
    # 'rds_backup',
    # 'as',
    'sfs',
    # 'hdd',
    # 'lb',
    # 'lb_down',
    # 'iscsi',
}


def _random_tmp_path(base='/tmp'):
    rand_part = ''.join(random.choice(string.ascii_letters) for _ in range(10))
    path = os.path.join(base, rand_part)
    os.makedirs(path, exist_ok=True)
    return path


class TestInfrastructure(unittest.TestCase):
    runner = ''
    scenarios: dict = None
    credential: Credential
    scenario_queue: Queue

    @classmethod
    def setUpClass(cls) -> None:
        cls.runner = _get_runner()
        cls.scenarios = _collect_scenarios()
        cls.scenario_queue = Queue(len(cls.scenarios))

        cls.credential = acquire_temporary_ak_sk()
        runner = cls.run_playbook('bastion_setup.yaml')
        if runner.rc != 0:
            cls.tearDownClass()
            raise RuntimeError('Failed to prepare scenario controller')

    @classmethod
    def run_playbook(cls, name, **extra_vars):
        """Run playbook with given tool

        :param str name: Name of playbook to be searched in `$PROJECT_ROOT/playbooks`
        :param extra_vars: Additional variables passed to ansible via `extra-vars`
        :raises subprocess.CalledProcessError: exception for non-zero exit codes
        :return: None
        """

        project_tmp = _random_tmp_path()

        extra_vars = extra_vars.copy()
        extra_vars.update({
            'os_cloud_config_file': '/tmp/csm-test/clouds.yaml',  # FIXME: temporary
            'tmp_dir': os.path.join(project_tmp, "tmp"),
        })

        os.makedirs(extra_vars['tmp_dir'], exist_ok=True)
        os.makedirs(LOG_PATH, exist_ok=True)

        print("Starting playbook", name)
        runner = run_playbook(
            inventory=INVENTORY_PATH,
            extravars=extra_vars,
            playbook=_playbook_path(name),
            envvars={
                'ANSIBLE_NOCOLOR': '1',
                'ANSIBLE_LOG_PATH': os.path.join(LOG_PATH, f'{name}.log'),
                'AWS_ACCESS_KEY_ID': cls.credential.access,
                'AWS_SECRET_ACCESS_KEY': cls.credential.secret,
                'AWS_SESSION_TOKEN': cls.credential.security_token,
            },
            private_data_dir=project_tmp,
        )
        if runner.rc == 0:
            print("Playbook", name, "finished successfully")
        else:
            print("Playbook", name, "failed with code", runner.rc)
        return runner

    def __skip_excluded(self, name):
        if name in EXCLUDE_SCENARIOS:
            self.skipTest(f'Scenario {name} is excluded')

    def __process_scenario(self):
        name, playbooks = self.scenario_queue.get()

        self.assertIn('setup', playbooks)
        self.assertIn('destroy', playbooks)

        with self.subTest(scenario=name, action='setup'):
            self.__skip_excluded(name)
            prc_s = self.run_playbook(playbooks['setup'])
            self.assertEqual(prc_s.rc, 0, f'Setup failed with exit code {prc_s.rc}')

        with self.subTest(scenario=name, action='destroy'):
            self.__skip_excluded(name)
            prc_d = self.run_playbook(playbooks['destroy'])
            self.assertEqual(prc_d.rc, 0, f'Destroy failed with exit code {prc_d.rc}')

        self.scenario_queue.task_done()

    def _test_scenarios(self):
        while not self.scenario_queue.empty():
            Thread(target=self.__process_scenario).start()
        self.scenario_queue.join()

    def test_scenarios(self):
        for item in self.scenarios.items():
            self.scenario_queue.put(item)
        self._test_scenarios()
        self.scenario_queue.join()

    @classmethod
    def tearDownClass(cls):
        cls.run_playbook('bastion_destroy.yaml')


if __name__ == '__main__':
    unittest.main()
