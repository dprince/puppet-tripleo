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
# == Class: tripleo::profile::base::neutron
#
# Neutron server profile for tripleo
#
# === Parameters
#
# [*core_plugin*]
#   (Optional) Then name of the neutron core plugin to be used
#   Defaults to hiera('neutron::core_plugin')
#
# [*driver_classname*]
#   (Optional) Name of the profile class directory to be included
#   Defaults to 'base'
#
# [*step*]
#   (Optional) The current step of the deployment
#   Defaults to hiera('step')
#
class tripleo::profile::base::neutron (
  $core_plugin      = hiera('neutron::core_plugin'),
  $driver_classname = 'base',
  $step             = hiera('step'),
) {
  if $step >= 4 {
    include "::tripleo::profile::${driver_classname}::neutron::server"

    case $core_plugin {
      'midonet.neutron.plugin_v1.MidonetPluginV2': {
        include "::tripleo::profile::${driver_classname}::neutron::midonet"
      }

      'neutron.plugins.nuage.plugin.NuagePlugin': {
        include ::neutron
        include ::neutron::plugins::nuage
      }

      'neutron_plugin_contrail.plugins.opencontrail.contrail_plugin.NeutronPluginContrailCoreV2': {
        include ::neutron
        include ::neutron::plugins::opencontrail
      }

      # ML2 plugin
      default: {
        include ::neutron
        include "::tripleo::profile::${driver_classname}::neutron::ml2"
      }
    }
  }
}
