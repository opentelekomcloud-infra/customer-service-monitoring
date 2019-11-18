#!/usr/bin/env python3
import json
import os
import sys
from argparse import ArgumentParser

import yaml

__version__ = '0.4'


def parse_params():
    parser = ArgumentParser(description='Create Ansible inventory from Terraform state for OpenTelekomCloud')
    parser.add_argument('state', help='Terraform state file')
    parser.add_argument('--name')
    parser.add_argument('--version', '-v', action='store_true', help='Show version')
    args = parser.parse_args()
    if args.name is None:
        args.name = args.state
    return args


def read_state(state_file) -> dict:
    """Load Terraform state from tfstate file to dict"""
    with open(state_file) as s_file:
        return json.load(s_file)


def main():
    args = parse_params()
    if args.version:
        print(__version__)
        sys.exit(0)
    generate_inventory(args)


def generate_inventory(args):
    inv_output = {
        'all': {
            'hosts': {},
            'children': {}
        }
    }
    hosts = inv_output['all']['hosts']
    children = inv_output['all']['children']
    for name, attributes in get_ecs_instances(args.state):
        tags: dict = attributes.pop('tag', None) or {}
        hosts[name] = attributes
        if 'group' in tags:
            grp_name = tags['group']
            if grp_name not in children:
                children[grp_name] = {'hosts': {}}
            children[grp_name]['hosts'][name] = ''
    if hosts:
        root_path = os.path.abspath(f'{os.path.dirname(__file__)}/../..')
        path = f'{root_path}/inventory/prod/{args.name}.yml'
        with open(path, 'w+') as file:
            file.write(yaml.safe_dump(inv_output, default_flow_style=False))
        print(f'File written to: {path}')
    else:
        print('Nothing to write')


def get_ecs_instances(tf_state_file):
    tf_state = read_state(tf_state_file)
    for resource in tf_state['resources']:

        if resource['type'] == 'opentelekomcloud_compute_instance_v2' and resource['name'] != 'bastion':
            for instance in resource['instances']:
                tf_attrib = instance['attributes']

                name = tf_attrib['name']
                attributes = {
                    'id': tf_attrib['id'],
                    'image': tf_attrib['image_name'],
                    'region': tf_attrib['region'],
                    'public_ipv4': tf_attrib['network'][0]['floating_ip'],
                    'ansible_host': tf_attrib['access_ip_v4'],
                    'ansible_ssh_user': 'linux',
                    'tag': tf_attrib['tag'],
                }

                yield name, attributes


if __name__ == '__main__':
    main()
