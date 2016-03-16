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
# == Class: tripleo::profile::pacemaker::neutron::l3
#
# Neutron L3 Agent server profile for tripleo
#
class tripleo::profile::pacemaker::neutron::l3 (
) {
  class { '::tripleo::profile::base::neutron::l3':
    manage_service => false,
    enabled        => false,
  }

  pacemaker::resource::service { $::neutron::params::l3_agent_service:
    clone_params => 'interleave=true',
  }

}
