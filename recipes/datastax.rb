#
# Cookbook Name:: cassandra-opsworks
# Recipe:: datastax
#
# Copyright 2011-2012, Michael S Klishin & Travis CI Development Team
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

# This recipe relies on a PPA package and is Ubuntu/Debian specific. Please
# keep this in mind.

apt_repository "datastax" do
  uri          "http://debian.datastax.com/community"
  distribution "stable"
  components   ["main"]
  key          "http://debian.datastax.com/debian/repo_key"

  action :add
end

# Insall Java from cookbook
#   (by default use oracle 8. See attributes)

include_recipe 'java'

# DataStax Server Community Edition package will not install w/o this
# one installed. MK.
package "python-cql" do
  action :install
end

package "libjna-java" do
  version "3.2.7-4"
  action :install
end

package "cassandra" do
  version "2.0.17"
  action :install
end

package "dsc20" do
  version "2.0.17-1"
  action :install
end

# Provide some monitoring capabilities when logged in
package "htop" do
  action :install
end

# If we have requested opscenter installation, install that also
#if node[:cassandra][:install_opscenter]
#  package "opscenter-free" do
#    action :install
#  end
#end

service "cassandra" do
  supports :restart => true, :status => true
  action [:enable, :start]
end
