import os
from argparse import ArgumentParser

import json
import yaml

version = '0.1'


def parse_params():
    parser = ArgumentParser('OpenTelekomCloud Terraform inventory')
    parser.add_argument('--scenario', '-s', action='store', dest='scenario',
                        help='Terraform scenario name in which directory search terraform.tfstate', default='scenario1')
    parser.add_argument('--version', '-v', action='store_true', help='Show version')
    args = parser.parse_args()
    return args


def get_tfstate(scenario_name):
    filename = os.getcwd() + "/" + scenario_name + "/.terraform/terraform.tfstate"
    return json.load(open(filename))


class TerraformInventory:
    def __init__(self):
        self.hosts_vars = {}
        self.inv_output = {}
        self.hosts = {}
        self.group = {}

        self.args = parse_params()
        if self.args.version:
            print(version)
        else:
            self.list_all()

    def list_all(self):
        for name, attributes, self.group in self.get_tf_instances():
            self.hosts_vars[name] = attributes
            self.hosts[name] = ''
        self.inv_output["all"] = {
            'hosts': self.hosts_vars,
            'children': {
                self.group['group']: {
                    "hosts": self.hosts
                }
            }
        }
        path = (os.path.pardir + "/inventory/prod/{}.yml".format(self.args.scenario))
        f = open(path, "w+")
        for i in yaml.dump(self.inv_output, default_flow_style=False):
            f.write(i)
        f.close()
        return print("File written to: {}".format(path))

    def get_tf_instances(self):
        tfstate = get_tfstate(self.args.scenario)
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

                else:
                    continue


if __name__ == '__main__':
    TerraformInventory()
