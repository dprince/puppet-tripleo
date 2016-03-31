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
# == Class: tripleo::profile::pacemaker::neutron
#
# Neutron server profile for tripleo
#
# === Parameters
#
# [*pacemaker_master*]
#   (Optional) The hostname of the pacemaker master
#   Defaults to hiera('bootstrap_nodeid')
#
# [*step*]
#   (Optional) The step in the deployment
#   Defaults to hiera('step')
#
# [*enable_l3*]
#   (Optional) Whether to include the Neutron L3 agent pacemaker profile
#   Defaults to hiera('neutron::enable_l3_agent', true)
#
# [*enable_dhcp*]
#   (Optional) Whether to include the Neutron DHCP agent pacemaker profile
#   Defaults to hiera('neutron::enable_dhcp_agent', true)
#
# [*enable_metadata*]
#   (Optional) Whether to include the Neutron Metadata agent pacemaker profile
#   Defaults to hiera('neutron::enable_metadata_agent', true)
#
# [*enable_ovs*]
#   (Optional) Whether to include the Neutron OVS agent pacemaker profile
#   Defaults to hiera('neutron::enable_ovs_agent', true)
#
class tripleo::profile::pacemaker::neutron (
  $pacemaker_master = hiera('bootstrap_nodeid'),
  $step             = hiera('step'),
  $enable_l3        = hiera('neutron::enable_l3_agent', true),
  $enable_dhcp      = hiera('neutron::enable_dhcp_agent', true),
  $enable_metadata  = hiera('neutron::enable_metadata_agent', true),
  $enable_ovs       = hiera('neutron::enable_ovs_agent', true),
) {
  if $step >= 4 {
    class { '::tripleo::profile::base::neutron':
      driver_classname => 'pacemaker',
    }

    neutron_config {
      'DEFAULT/notification_driver': value => 'messaging';
    }

    if $enable_l3 {
      include ::tripleo::profile::pacemaker::neutron::l3
    }

    if $enable_dhcp {
      include ::tripleo::profile::pacemaker::neutron::dhcp
    }

    if $enable_metadata {
      include ::tripleo::profile::pacemaker::neutron::metadata
    }

    if $enable_ovs {
      include ::tripleo::profile::pacemaker::neutron::ovs
    }
  }

  if $step >= 5 {
    if $step == 5 {
      # Neutron
      # NOTE(gfidente): Neutron will try to populate the database with some data
      # as soon as neutron-server is started; to avoid races we want to make this
      # happen only on one node, before normal Pacemaker initialization
      # https://bugzilla.redhat.com/show_bug.cgi?id=1233061
      # NOTE(emilien): we need to run this Exec only at Step 4 otherwise this exec
      # will try to start the service while it's already started by Pacemaker
      # It would result to a deployment failure since systemd would return 1 to Puppet
      # and the overcloud would fail to deploy (6 would be returned).
      # This conditional prevents from a race condition during the deployment.
      # https://bugzilla.redhat.com/show_bug.cgi?id=1290582
      exec { 'neutron-server-systemd-start-sleep' :
        command => 'systemctl start neutron-server && /usr/bin/sleep 5',
        path    => '/usr/bin',
        unless  => '/sbin/pcs resource show neutron-server',
      } ->
      pacemaker::resource::service { $::neutron::params::server_service:
        clone_params => 'interleave=true',
        require      => Pacemaker::Resource::Ocf['openstack-core']
      }
    } else {
      pacemaker::resource::service { $::neutron::params::server_service:
        clone_params => 'interleave=true',
        require      => Pacemaker::Resource::Ocf['openstack-core']
      }
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

    if $enable_ovs {
      pacemaker::constraint::base { 'neutron-openvswitch-agent-to-dhcp-agent-constraint':
        constraint_type => 'order',
        first_resource  => "${::neutron::params::ovs_agent_service}-clone",
        second_resource => "${::neutron::params::dhcp_agent_service}-clone",
        first_action    => 'start',
        second_action   => 'start',
        require         => [Pacemaker::Resource::Service[$::neutron::params::ovs_agent_service],
                            Pacemaker::Resource::Service[$::neutron::params::dhcp_agent_service]],
      }
    }

    if $enable_dhcp and $enable_ovs {
      pacemaker::constraint::base { 'neutron-server-to-openvswitch-agent-constraint':
        constraint_type => 'order',
        first_resource  => "${::neutron::params::server_service}-clone",
        second_resource => "${::neutron::params::ovs_agent_service}-clone",
        first_action    => 'start',
        second_action   => 'start',
        require         => [Pacemaker::Resource::Service[$::neutron::params::server_service],
                            Pacemaker::Resource::Service[$::neutron::params::ovs_agent_service]],
      }

      pacemaker::constraint::colocation { 'neutron-openvswitch-agent-to-dhcp-agent-colocation':
        source  => "${::neutron::params::dhcp_agent_service}-clone",
        target  => "${::neutron::params::ovs_agent_service}-clone",
        score   => 'INFINITY',
        require => [Pacemaker::Resource::Service[$::neutron::params::ovs_agent_service],
                    Pacemaker::Resource::Service[$::neutron::params::dhcp_agent_service]],
      }
    }

    if $enable_dhcp and $enable_l3 {
      pacemaker::constraint::base { 'neutron-dhcp-agent-to-l3-agent-constraint':
        constraint_type => 'order',
        first_resource  => "${::neutron::params::dhcp_agent_service}-clone",
        second_resource => "${::neutron::params::l3_agent_service}-clone",
        first_action    => 'start',
        second_action   => 'start',
        require         => [Pacemaker::Resource::Service[$::neutron::params::dhcp_agent_service],
                            Pacemaker::Resource::Service[$::neutron::params::l3_agent_service]]
      }

      pacemaker::constraint::colocation { 'neutron-dhcp-agent-to-l3-agent-colocation':
        source  => "${::neutron::params::l3_agent_service}-clone",
        target  => "${::neutron::params::dhcp_agent_service}-clone",
        score   => 'INFINITY',
        require => [Pacemaker::Resource::Service[$::neutron::params::dhcp_agent_service],
                    Pacemaker::Resource::Service[$::neutron::params::l3_agent_service]]
      }
    }

    if $enable_l3 and $enable_metadata {
      pacemaker::constraint::base { 'neutron-l3-agent-to-metadata-agent-constraint':
        constraint_type => 'order',
        first_resource  => "${::neutron::params::l3_agent_service}-clone",
        second_resource => "${::neutron::params::metadata_agent_service}-clone",
        first_action    => 'start',
        second_action   => 'start',
        require         => [Pacemaker::Resource::Service[$::neutron::params::l3_agent_service],
                            Pacemaker::Resource::Service[$::neutron::params::metadata_agent_service]]
      }
      pacemaker::constraint::colocation { 'neutron-l3-agent-to-metadata-agent-colocation':
        source  => "${::neutron::params::metadata_agent_service}-clone",
        target  => "${::neutron::params::l3_agent_service}-clone",
        score   => 'INFINITY',
        require => [Pacemaker::Resource::Service[$::neutron::params::l3_agent_service],
                    Pacemaker::Resource::Service[$::neutron::params::metadata_agent_service]]
      }
    }
  }
}
