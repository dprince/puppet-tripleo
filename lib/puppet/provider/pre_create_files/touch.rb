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

require 'fileutils'

class File
  def File.open(*args)
    file_dir = File.dirname(args[0])

    # pre-create all directories for access files
    # This is required for custom providers which
    # may have hard coded paths in their implementations
    # and thus don't show up in the catalog below (neutron_config..., etc.)
    if not Dir.exists?(file_dir) then
      FileUtils.mkdir_p(file_dir)
    end

    f = new(*args)
    if block_given?
      begin
        yield(f)
      ensure
        f.close
      end
    else
      f
    end
  end
end


Puppet::Type.type(:pre_create_files).provide(:touch) do

  desc "Precreate files and directories"

  def create_user(r)
    begin
      if r[:owner] and r[:owner].class == String then
        `getent passwd | grep #{r[:owner]} || useradd #{r[:owner]}`
      end
    rescue
    end
  end

  def create_group(r)
    begin
      if r[:group] and r[:group].class == String then
        `getent group | grep #{r[:group]} || groupadd -f #{r[:group]}`
      end
    rescue
    end
  end

  def pre_create_files
    resource.catalog.resources.each do |r|
      if [:file,:file_line,:concat].include?(r.type)
        # files may be assign an owner and group so we create those first
        create_user(r)
        create_group(r)

        path = r[:path]
        path = r.name if path.nil? # File path defaults to name
        if r[:ensure] == :directory then
          FileUtils.mkdir_p(path)
        else
          FileUtils.mkdir_p(File.dirname(path))
          FileUtils.touch(path)
          if r[:ensure] == :link then
            FileUtils.mkdir_p(File.dirname(r[:target]))
            FileUtils.ln_sf(r[:target], path)
          end
        end
      end

      # exec resources require fake binaries to exist
      if r.type == :exec then
        command = r[:command]
        command = r.name if command.nil? # Command defaults to name
        binary = command.gsub(/\s.+/, '')
        FileUtils.touch(binary)
        FileUtils.chmod(0755, binary)
      end
    end
  end

  def exists?
    false
  end

  def create
    pre_create_files()
    true
  end

  def destroy
    true
  end

end
