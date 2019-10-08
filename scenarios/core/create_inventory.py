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
    hosts_vars = {}
    inv_output = {}
    hosts = {}
    group = {}

    def get_tf_instances():
        tfstate = get_tfstate(args.state)
        for resource in tfstate['resources']:

            if resource['type'] == 'opentelekomcloud_compute_instance_v2' and resource['name'] != 'bastion':
                for instance in resource['instances']:
                    tf_attrib = instance['attributes']

                    name = tf_attrib['name']
                    group = {}
                    attributes = {
                        'id': tf_attrib['id'],
                        'image': tf_attrib['image_name'],
                        'region': tf_attrib['region'],
                        'public_ipv4': tf_attrib['network'][0]['floating_ip'],
                        'ansible_host': tf_attrib['access_ip_v4'],
                        'ansible_ssh_user': 'linux',
                        'tag': tf_attrib['tag'],
                    }
                    group.update(attributes['tag'])

                    yield name, attributes, group

    for name, attributes, group in get_tf_instances():
        hosts_vars[name] = attributes
        hosts[name] = ''
    inv_output['all'] = {
        'hosts': hosts_vars,
        'children': {
            group['group']: {
                'hosts': hosts
            }
        }
    }
    path = '{}/inventory/prod/{}.yml'.format(
        os.path.abspath("{}/../..".format(os.path.dirname(__file__))), args.name)
    with open(path, 'w+') as file:
        file.write(yaml.safe_dump(inv_output, default_flow_style=False))
    return print('File written to: {}'.format(path))


if __name__ == '__main__':
    main()
