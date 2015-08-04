# Copyright 2015 Red Hat, Inc.
# All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may
# not use this file except in compliance with the License. You may obtain
# a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations
# under the License.

# == Class: tripleo::noop
#
# Enable noop mode for various Puppet resource types via collectors.
#
# === Parameters:
# [*package*]
#  Whether Package resources should be noop.
#  Defaults to true
#
# [*file*]
#  Whether File resources should be noop.
#  Defaults to true
#
# [*service*]
#  Whether Service resources should be noop.
#  Defaults to true
#
# [*exec*]
#  Whether Exec resources should be noop.
#  Defaults to true
#
# [*user*]
#  Whether User resources should be noop.
#  Defaults to true
#
# [*group*]
#  Whether Group resources should be noop.
#  Defaults to true
#
# [*cron*]
#  Whether Cron resources should be noop.
#  Defaults to true
#
# [*file_line*]
#  Whether File_line resources should be noop.
#  Defaults to true
#
# [*concat*]
#  Whether Concat resources should be noop.
#  Defaults to true
#
# [*staging_file*]
#  Whether Staging::File resources should be noop.
#  Defaults to true
#
# [*vs_bridge*]
#  Whether Vs_bridge resources should be noop.
#  Defaults to true
#
# [*mongodb_conn_validator*]
#  Whether Mongodb_conn_validator resources should be noop.
#  Defaults to true
#
# [*mongodb_replset*]
#  Whether Mongodb_replset resources should be noop.
#  Defaults to true
#
# [*rabbitmq_plugin*]
#  Whether Rabbitmq_plugin resources should be noop.
#  Defaults to true
#
# [*mysql_user*]
#  Whether Mysql_user resources should be noop.
#  Defaults to true
#
# [*mysql_database*]
#  Whether Mysql_database resources should be noop.
#  Defaults to true
#
# [*mysql_grant*]
#  Whether Mysql_grant resources should be noop.
#  Defaults to true
#
#
class tripleo::noop (
  $package                = true,
  $file                   = true,
  $service                = true,
  $exec                   = true,
  $user                   = true,
  $group                  = true,
  $cron                   = true,
  $file_line              = true,
  $concat                 = true,
  $staging_file           = true,
  $vs_bridge              = true,
  $mongodb_conn_validator = true,
  $mongodb_replset        = true,
  $rabbitmq_plugin        = true,
  $mysql_user             = true,
  $mysql_database         = true,
  $mysql_grant            = true,
) {

  Package <| |> { noop => $package}
  File <| |> { noop => $file}
  Service <| |> { noop => $service}
  Exec <| |> { noop => $exec}
  User <| |> { noop => $user}
  Group <| |> { noop => $group}
  Cron <| |> { noop => $cron}

  File_line <| |> { noop => $file_line }
  Concat <| |> { noop => $concat }
  Staging::File<| |> { noop => $staging_file}
  Mongodb_conn_validator<| |> { noop => $mongodb_conn_validator }

  # custom noop providers
  if $vs_bridge {
    Vs_bridge <| |> { provider => noop }
  }
  if $mongodb_replset {
    Mongodb_replset<| |> { provider => noop }
  }
  if $rabbitmq_plugin {
    Rabbitmq_plugin<| |> { provider => noop }
  }
  if $mysql_user {
    Mysql_user<| |> { provider => noop }
  }
  if $mysql_database {
    Mysql_database<| |> { provider => noop }
  }
  if $mysql_grant {
    Mysql_grant<| |> { provider => noop }
  }
}
