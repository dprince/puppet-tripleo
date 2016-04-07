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
# == Class: tripleo::profile::base::neutron::metadata
#
# Neutron Metadata Agent profile for tripleo
#
# === Parameters
#
# [*enabled*]
#   (Optional) Whether to enable the Neutron Metadata Agent service
#   Defaults to undef
#
# [*manage_service*]
#   (Optional) Whether to manage the Neutron Metadata Agent service
#   Defaults to undef
#
class tripleo::profile::base::neutron::metadata (
  $enabled              = undef,
  $manage_service       = undef,
) {
  if $step >= 4 {
    include ::neutron::config
    class { '::neutron::agents::metadata':
      manage_service => $manage_service,
      enabled        => $enabled
    }

    Service<| title == 'neutron-server' |> -> Service<| title == 'neutron-metadata' |>
  }
}
