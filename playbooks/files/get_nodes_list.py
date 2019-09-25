import json
import os
from collections import defaultdict
from argparse import ArgumentParser

version = '0.1'

def parse_params():
    parser = ArgumentParser('OpenTelekomCloud Terraform inventory')
    parser.add_argument('--list', action='store_true', default=True, help='List Terraform hosts')
    parser.add_argument('--scenarioname', '-s', action='store', dest='scenarioname',
                        help='Terraform scenario name in which directory search terraform.tfstate', default='scenario1')
    parser.add_argument('--version', '-v', action='store_true', help='Show version')
    args = parser.parse_args()
    return args


def get_tfstate(scenario_name):
    # filename = os.getcwd() + "/" + scenario_name + "/.terraform/terraform.tfstate"
    filename = "C:\\Users\\asidelni\\PycharmProjects\\OTC\\csm-sandbox\\scenarios\\scenario1\\.terraform\\" \
               "terraform.tfstate"
    return json.load(open(filename))


def parse_state(tf_source, prefix, sep='.'):
    for key, value in list(tf_source.items()):
        try:
            curprefix, rest = key.split(sep, 1)
        except ValueError:
            continue
        if curprefix != prefix or rest == '#':
            continue

        yield rest, value


def parse_list(tf_source, prefix, sep='.'):
    return [value for _, value in parse_state(tf_source, prefix, sep)]


class TerraformInventory:
    def __init__(self):
        self.args = parse_params()
        if self.args.version:
            print(version)
        elif self.args.list:
            print(self.list_all())

    def list_all(self):
        hosts_vars = {}
        attributes = {}
        groups = {}
        groups_json = {}
        inv_output = {}
        group_hosts = defaultdict(list)
        for name, attributes, groups in self.get_tf_instances():
            hosts_vars[name] = attributes
            for group in list(groups):
                group_hosts[group].append(name)

        for group in group_hosts:
            inv_output[group] = {'hosts': group_hosts[group]}
        inv_output["_meta"] = {'hostvars': hosts_vars}
        return json.dumps(inv_output, indent=2)

    def get_tf_instances(self):
        tfstate = get_tfstate(self.args.scenarioname)
        for resource in tfstate['resources']:

            if resource['type'] == 'opentelekomcloud_compute_instance_v2':
                tf_attrib = resource['instances'][0]['attributes']
                # print(tf_attrib)
                if tf_attrib['name'] != 'bastion':
                    name = tf_attrib['name']
                    group = []

                    attributes = {
                        'id': tf_attrib['id'],
                        'image': tf_attrib['image_name'],
                        'ipv4_address': tf_attrib['access_ip_v4'],
                        'region': tf_attrib['region'],
                        'public_ipv4': tf_attrib['network'][0]['floating_ip'],
                        'private_ipv4': tf_attrib['network'][0]['fixed_ip_v4'],
                        'ansible_host': tf_attrib['access_ip_v4'],
                        'ansible_ssh_user': 'linux',
                        'tags': parse_list(tf_attrib, 'tags'),
                    }
                    if 'user_metadata' in tf_attrib:
                        attributes['metadata'] = tf_attrib['user_metadata']

                    for value in list(attributes["tags"]):
                        try:
                            curprefix, rest = value.split(":", 1)
                        except ValueError:
                            continue
                        if curprefix != "group":
                            continue
                        group.append(rest)

                    yield name, attributes, group

                else:
                    continue


if __name__ == '__main__':
    TerraformInventory()
