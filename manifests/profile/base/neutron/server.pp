# Copyright 2014 Red Hat, Inc.
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
# == Class: tripleo::profile::base::neutron::server
#
# Neutron server profile for tripleo
#
# === Parameters
#
# [*sync_db*]
#   (Optional) Whether to run Neutron DB sync operations
#   Defaults to undef
#
# [*manage_service*]
#   (Optional) Whether to manage the Neutron Server service
#   Defaults to undef
#
# [*enabled*]
#   (Optional) Whether to enable the Neutron Server service
#   Defaults to undef
#
class tripleo::profile::base::neutron::server (
  $sync_db          = undef,
  $manage_service   = undef,
  $enabled          = undef
) {
  include ::neutron::config
  include ::neutron::server::notifications

  class { '::neutron::server':
    sync_db        => $sync_db,
    manage_service => $manage_service,
    enabled        => $enabled
  }
}
