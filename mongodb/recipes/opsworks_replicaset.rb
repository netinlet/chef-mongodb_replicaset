#
# Cookbook Name:: mongodb
# Recipe:: replicaset
#
# Copyright 2011, edelight GmbH
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

include_recipe "mongodb"
include_recipe "mongodb::mongo_gem"

::Chef::Recipe.send(:include, MongoDB::OpsWorksHelper)

Chef::Log.info "Configuring replicaset with OPSWORKS REPLICASET"

# if we are configuring a shard as a replicaset we do nothing in this recipe
if !node.recipe?("mongodb::shard")

  # assuming for the moment only one layer for the replicaset instances
  replicaset_layer_slug_name = node['opsworks']['instance']['layers'].first
  replicaset_layer_instances = node['opsworks']['layers'][replicaset_layer_slug_name]['instances']

  Chef::ResourceDefinitionList::MongoDB.configure_replicaset(node, replicaset_layer_slug_name, replicaset_members(node, replicaset_layer_instances))
end

  # mongodb_instance node['mongodb']['instance_name'] do
  #   mongodb_type "mongod"
  #   port         node['mongodb']['port']
  #   logpath      node['mongodb']['logpath']
  #   dbpath       node['mongodb']['dbpath']
  #   replicaset   node
  #   enable_rest  node['mongodb']['enable_rest']
  #   smallfiles   node['mongodb']['smallfiles']
  # end
