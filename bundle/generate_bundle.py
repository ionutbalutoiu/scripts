#!/usr/bin/python
import argparse
import yaml

parser = argparse.ArgumentParser()
parser.add_argument("--bundle-path", dest="bundle_path", type=str, default="ci_bundle.yaml", help="Path of the generated yaml bundle")
parser.add_argument("--nr-ad-units", dest="nr_ad_units", type=int, default=0, help="Number of AD units to be deployed")
parser.add_argument("--nr-devstack-units", dest="nr_devstack_units", type=int, default=1, help="Number of DevStack units to be deployed")
parser.add_argument("--nr-hyperv-units", dest="nr_hyper_v_units", type=int, default=1, help="Number of Hyper-V units to be deployed")
parser.add_argument("--zuul-branch", dest="zuul_branch", type=str, default="master", help="Zuul branch")
parser.add_argument("--zuul-change", dest="zuul_change", type=str, required=True, help="Zuul change")
parser.add_argument("--zuul-project", dest="zuul_project", type=str, required=True, help="Zuul project")
parser.add_argument("--zuul-ref", dest="zuul_ref", type=str, required=True, help="Zuul ref")
parser.add_argument("--zuul-uuid", dest="zuul_uuid", type=str, required=True, help="Zuul uuid")
parser.add_argument("--zuul-url", dest="zuul_url", type=str, required=True, help="Zuul url")
parser.add_argument("--data-ports", dest="data_ports", type=str, required=True, help="Data ports")
parser.add_argument("--external-ports", dest="external_ports", type=str, required=True, help="External ports")
parser.add_argument("--ad-domain-name", dest="ad_domain_name", type=str, default="cloudbase.local", help="AD domain name")
parser.add_argument("--ad-admin-password", dest="ad_admin_password", type=str, help="AD administrator password")
parser.add_argument("--hyper-v-extra-python-packages", dest="hyper_v_extra_python_packages", type=str, default='""', help="Hyper-V extra python packages")
parser.add_argument("--vlan-range", dest="vlan_range", type=str, required=True, help="VLAN range")
parser.add_argument("--devstack-extra-packages", dest="devstack_extra_packages", type=str, default='""', help="DevStack extra packages")
parser.add_argument("--devstack-extra-python-packages", dest="devstack_extra_python_packages", type=str, default='""', help="DevStack extra python packages")
parser.add_argument("--devstack-enabled-services", dest="devstack_enabled_services", type=str, default='""', help="DevStack enabled services")
parser.add_argument("--devstack-disabled-services", dest="devstack_disabled_services", type=str, default='""', help="DevStack disabled services")
parser.add_argument("--devstack-enabled-plugins", dest="devstack_enabled_plugins", type=str, default='""', help="DevStack enabled plugins")
options = parser.parse_args()

if options.nr_ad_units > 0 and options.ad_admin_password is None:
    parser.error("Parameter --ad-admin-password is mandatory if AD units are deployed.")

hyper_v_charm_name = 'hyper-v-ci-%s' % options.zuul_uuid
devstack_charm_name = 'devstack-%s' % options.zuul_uuid
bundle_content = {
 'maas': {'overrides': {'data-port': options.data_ports,
                        'external-port': options.external_ports,
                        'zuul-branch': options.zuul_branch,
                        'zuul-change': options.zuul_change,
                        'zuul-project': options.zuul_project,
                        'zuul-ref': options.zuul_ref,
                        'zuul-url': options.zuul_url},
          'relations': [[devstack_charm_name, hyper_v_charm_name]],
          'services': {devstack_charm_name: {'branch': 'https://github.com/cloudbase/devstack-charm.git',
                                             'charm': 'local:trusty/devstack',
                                             'num_units': options.nr_devstack_units,
                                             'options': {'disabled-services': options.devstack_disabled_services,
                                                         'enable-plugin': options.devstack_enabled_plugins,
                                                         'enabled-services': options.devstack_enabled_services,
                                                         'extra-packages': options.devstack_extra_packages,
                                                         'extra-python-packages': options.devstack_extra_python_packages,
                                                         'heat-image-url': 'http://10.255.251.230/Fedora.vhdx',
                                                         'test-image-url': 'http://10.255.251.230/cirros.vhdx',
                                                         'vlan-range': options.vlan_range}},
                       hyper_v_charm_name: {'branch': 'https://github.com/cloudbase/hyperv-compute-ci.git',
                                            'charm': 'local:win2012hvr2/hyper-v-ci',
                                            'num_units': options.nr_hyper_v_units,
                                            'options': {'download-mirror': 'http://64.119.130.115/bin',
                                                        'extra-python-packages': options.hyper_v_extra_python_packages,
                                                        'git-user-email': 'hyper-v_ci@microsoft.com',
                                                        'git-user-name': 'Hyper-V CI',
                                                        'wheel-mirror': 'http://64.119.130.115/wheels'}}}}}
if options.nr_ad_units > 0:
    ad_charm = {'active-directory': {'branch': 'https://github.com/cloudbase/active-directory.git',
                                     'charm': 'local:win2012r2/active-directory',
                                     'num_units': options.nr_ad_units,
                                     'options': {'domain-name': options.ad_domain_name,
                                                 'password': options.ad_admin_password}}}
    bundle_content['maas']['relations'].append([hyper_v_charm_name, 'active-directory'])
    bundle_content['maas']['services'].update(ad_charm)

with open(options.bundle_path, 'w') as yaml_file:
    yaml_file.write( yaml.dump(bundle_content, default_flow_style=False))