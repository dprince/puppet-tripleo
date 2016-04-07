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
# == Class: tripleo::profile::base::neutron::ovs
#
# Neutron OVS Agent profile for tripleo
#
# === Parameters
#
# [*manage_service*]
#   (Optional) Whether to manage the Neutron OVS Agent service
#   Defaults to undef
#
# [*enabled*]
#   (Optional) Whether to enable the Neutron OVS Agent service
#   Defaults to undef
#
class tripleo::profile::base::neutron::ovs(
  $manage_service = undef,
  $enabled        = undef
) {
  include ::neutron::config
  if $step >= 4 {
    class { '::neutron::agents::ml2::ovs':
      manage_service => $manage_service,
      enabled        => $enabled
    }

    # Optional since manage_service may be false and neutron server may not be colocated.
    Service<| title == 'neutron-server' |> -> Service<| title == 'neutron-ovs-agent-service' |>
  }

}
