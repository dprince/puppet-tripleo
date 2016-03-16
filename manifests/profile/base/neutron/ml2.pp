# Copyright 2016 Red Hat, Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.
#
# == Class: tripleo::profile::base::neutron::ml2
#
# Neutron ML2 driver profile for tripleo
#
# === Parameters
#
# [*mechanism_drivers*]
#   (Optional) The mechanism drivers to use with the Ml2 plugin
#   Defaults to hiera('neutron::plugins::ml2::mechanism_drivers')
#
# [*include_ovs*]
#   (Optional) Whether to include the Neutron OVS Agent profile
#   Defaults to true
#
# [*include_l3*]
#   (Optional) Whether to include the Neutron L3 Agent profile
#   Defaults to true
#
# [*include_dhcp*]
#   (Optional) Whether to include the Neutron DHCP Agent profile
#   Defaults to true
#
# [*include_metadata*]
#   (Optional) Whether to include the Neutron Metadata Agent profile
#   Defaults to true
#
class tripleo::profile::base::neutron::ml2 (
  $mechanism_drivers  = hiera('neutron::plugins::ml2::mechanism_drivers'),
  $include_ovs        = true,
  $include_l3         = true,
  $include_dhcp       = true,
  $include_metadata   = true,
) {
  include ::neutron::plugins::ml2

  if $include_ovs {
    include ::profile::base::neutron::ovs
  }

  if $include_l3 {
    include ::tripleo::profile::base::neutron::l3
  }

  if $include_dhcp {
    include ::tripleo::profile::base::neutron::dhcp
  }

  if $include_metadata {
    include ::tripleo::profile::base::neutron::metadata
  }

  if 'cisco_n1kv' in $mechanism_drivers {
    include ::tripleo::profile::base::neutron::n1k
  }

  if 'cisco_ucsm' in $mechanism_drivers {
    include ::neutron::plugins::ml2::cisco::ucsm
  }

  if 'cisco_nexus'  in $mechanism_drivers {
    include ::neutron::plugins::ml2::cisco::nexus
    include ::neutron::plugins::ml2::cisco::type_nexus_vxlan
  }

  if 'bsn_ml2' in $mechanism_drivers {
    include ::neutron::plugins::ml2::bigswitch::restproxy
    include ::neutron::agents::bigswitch
  }
}
