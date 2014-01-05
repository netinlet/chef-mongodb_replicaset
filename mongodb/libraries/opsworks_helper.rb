
require 'chef/node'

class Chef::ResourceDefinitionList::OpsWorksHelper

  # true if we're on opsworks, false otherwise
  def self.opsworks?(node)
    node['opsworks'] != nil
  end

  # return Chef Nodes for this replicaset / layer
  def self.replicaset_members(node)
    members = []
    # FIXME -> this is bad, we're assuming replicaset instances use a single layer
    replicaset_layer_slug_name = node['opsworks']['instance']['layers'].first
    instances = node['opsworks']['layers'][replicaset_layer_slug_name]['instances']
    instances.each do |name, instance|
      if instance['status'] == 'online'
        member = Chef::Node.new
        member.name(name)
        member.default['fqdn'] = instance['private_dns_name']
        member.default['ipaddress'] = instance['private_ip']
        member.default['hostname'] = name
        mongodb_attributes = {
          # here we could support a map of instances to custom replicaset options in the custom json
          'port' => node['mongodb']['port'],
          'replica_arbiter_only' => false,
          'replica_build_indexes' => true,
          'replica_hidden' => false,
          'replica_slave_delay' => 0,
          'replica_priority' => 1,
          'replica_tags' => {}, # to_hash is called on this
          'replica_votes' => 1
        }
        member.default['mongodb'] = mongodb_attributes
        members << member
      end
    end
    members
  end

end