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
# == Class: tripleo::profile::pacemaker::neutron::server
#
# Neutron Server Pacemaker profile for tripleo
#
# === Parameters
#
# [*pacemaker_master*]
#   (Optional) The hostname of the pacemaker master
#   Defaults to hiera('bootstrap_nodeid')
#
class tripleo::profile::pacemaker::neutron::server (
  $pacemaker_master = hiera('bootstrap_nodeid'),
) {
  class { '::tripleo::profile::base::neutron::server':
    sync_db        => ($::hostname == downcase($pacemaker_master)),
    manage_service => false,
    enabled        => false,
  }

  pacemaker::constraint::base { 'keystone-to-neutron-server-constraint':
    constraint_type => 'order',
    first_resource  => 'openstack-core-clone',
    second_resource => "${::neutron::params::server_service}-clone",
    first_action    => 'start',
    second_action   => 'start',
    require         => [Pacemaker::Resource::Ocf['openstack-core'],
                        Pacemaker::Resource::Service[$::neutron::params::server_service]],
  }
}
