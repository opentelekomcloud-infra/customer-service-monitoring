import json
import os
from argparse import ArgumentParser

import yaml

version = '0.3'


def parse_params():
    parser = ArgumentParser('OpenTelekomCloud Terraform inventory')
    parser.add_argument('state', help='Terraform state file')
    parser.add_argument('--name', default=None)
    parser.add_argument('--version', '-v', action='store_true', help='Show version')
    args = parser.parse_args()
    if args.name is None:
        args.name = args.state
    return args


def get_tfstate(state_file):
    return json.load(open(state_file))


def main():
    args = parse_params()
    if args.version:
        print(version)
    else:
        list_all(args)


def list_all(args):
    inv_output = {
        'all': {
            'hosts': {},
            'children': {}
        }
    }
    hosts = inv_output['all']['hosts']
    children = inv_output['all']['children']
    for name, attributes in get_tf_instances(args.state):
        tag: dict = attributes.pop('tag', None) or {}
        hosts[name] = attributes
        if 'group' in tag:
            grp_name = tag['group']
            if grp_name not in children:
                children[grp_name] = {'hosts': {}}
            children[grp_name]['hosts'][name] = ''
    if hosts:
        root_path = os.path.abspath(f'{os.path.dirname(__file__)}/../..')
        path = f'{root_path}/inventory/prod/{args.name}.yml'
        with open(path, 'w+') as file:
            file.write(yaml.safe_dump(inv_output, default_flow_style=False))
        print('File written to: {}'.format(path))
    else:
        print('Nothing to write')


def get_tf_instances(tfstate):
    tfstate = get_tfstate(tfstate)
    for resource in tfstate['resources']:

        if resource['type'] == 'opentelekomcloud_compute_instance_v2' and resource['name'] != 'bastion':
            for instance in resource['instances']:
                tf_attrib = instance['attributes']

                _name = tf_attrib['name']
                _attributes = {
                    'id': tf_attrib['id'],
                    'image': tf_attrib['image_name'],
                    'region': tf_attrib['region'],
                    'public_ipv4': tf_attrib['network'][0]['floating_ip'],
                    'ansible_host': tf_attrib['access_ip_v4'],
                    'ansible_ssh_user': 'linux',
                    'tag': tf_attrib['tag'],
                }

                yield _name, _attributes


if __name__ == '__main__':
    main()
