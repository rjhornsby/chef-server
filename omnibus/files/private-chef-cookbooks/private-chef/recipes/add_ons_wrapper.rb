#
# Author:: Douglas Triggs (<doug@chef.io>)
# Copyright:: 2014-2018 Chef Software, Inc.
# License:: Apache License, Version 2.0
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'chef/handler'

class AddonInstallHandler < Chef::Handler
  def initialize
    @packages = []
  end

  def add(pkg)
    @packages.push(pkg)
  end

  def report
    @packages.each do |pkg|
      puts "-- Installed Add-On Package: #{pkg}"
    end
  end
end

addon_handler = AddonInstallHandler.new

# We notify whether or not the run was successful:
Chef::Config[:report_handlers].reject! { |i| i.is_a?(AddonInstallHandler) }
Chef::Config[:report_handlers] << addon_handler
Chef::Config[:exception_handlers].reject! { |i| i.is_a?(AddonInstallHandler) }
Chef::Config[:exception_handlers] << addon_handler

# No way to pass params via notifications, so we just make a resource to notify for
# every package we intend to install
node['private_chef']['addons']['packages'].each do |pkg|
  ruby_block "addon_install_notification_#{pkg}" do
    block do
      addon_handler.add(pkg)
    end
    action :nothing
  end
end

# if remotely installing add-ons we'll first fetch all required packaies
if OmnibusHelper.new(node).remote_install_addons?
  addon_path = Chef::Config[:file_cache_path]

  require 'mixlib/install'

  node['private_chef']['addons']['packages'].each do |pkg|
    artifact_info = Mixlib::Install.new(
      channel: :stable,
      product_name: pkg.split(/(chef-|opscode-)(.*)/).last,
      product_version: :latest,
      platform_version_compatibility_mode: true
    ).detect_platform.artifact_info

    pkg_file = File.join(addon_path, File.basename(artifact_info.url))

    remote_file pkg_file do
      source artifact_info.url
      checksum artifact_info.sha256
    end
  end
else
  addon_path = node['private_chef']['addons']['path']
end

# install each add-on from the local cache
node['private_chef']['addons']['packages'].each do |pkg|
  pkg_file = nil

  # We wrap this in a `ruby_block` so our directory globbing is evaluated
  # after the `remote_file` above has run.
  ruby_block "locate_addon_package_#{pkg}" do
    block do
      pkg_file = if ::File.directory?(addon_path)
                   # find the newest package of each name if 'addon_path' is a directory
                   Dir["#{addon_path}/#{pkg}*.#{OmnibusHelper.new(node).platform_package_suffix}"].sort_by { |f| File.mtime(f) }.last
                 else
                   # use the full path to the package
                   addon_path
                 end
    end
  end

  package pkg do
    provider value_for_platform_family(
      ['debian'] => Chef::Provider::Package::Dpkg,
      %w(rhel suse) => Chef::Provider::Package::Rpm
    )
    source lazy { pkg_file }
    notifies :run, "ruby_block[addon_install_notification_#{pkg}]", :immediately
  end
end
