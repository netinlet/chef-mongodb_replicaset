include_recipe "deploy"

node[:deploy].each do |application, deploy|
  deploy = node[:deploy][application]

  execute "restart Rails app #{application}" do
    cwd deploy[:current_path]
    command node[:opsworks][:rails_stack][:restart_command]
    action :nothing
  end

  node.default[:deploy][application][:database][:adapter] = OpsWorks::RailsConfiguration.determine_database_adapter(application, node[:deploy][application], "#{node[:deploy][application][:deploy_to]}/current", :force => node[:force_database_adapter_detection])
  deploy = node[:deploy][application]

  template "#{deploy[:deploy_to]}/shared/config/mongoid.yml" do
    source "mongoid.yml.erb"
    cookbook 'rails_mongoid'
    mode "0660"
    group deploy[:group]
    owner deploy[:user]

    #replicaset_name = node['mongodb']['replicaset_name']
    #replicaset_instances = node['opsworks']['layers'][replicaset_name]['instances'].keys.map{|name| "#{name}:27017"}

    replicaset_instances = node["opsworks"]["layers"]["mongodb"]["instances"].keys.map{|server| "#{node["opsworks"]["layers"]["mongodb"]["instances"][server]["private_ip"]}:27017" }
    variables(
      :environment => deploy[:rails_env],
      :replicaset_instances => replicaset_instances
    )

    notifies :run, "execute[restart Rails app #{application}]"

    only_if do
      File.exists?("#{deploy[:deploy_to]}") && File.exists?("#{deploy[:deploy_to]}/shared/config/")
    end
  end

  #template "#{deploy[:deploy_to]}/shared/config/database.yml" do
    #source "database.yml.erb"
    #cookbook 'rails'
    #mode "0660"
    #group deploy[:group]
    #owner deploy[:user]
    #variables(:database => deploy[:database], :environment => deploy[:rails_env])

    #notifies :run, "execute[restart Rails app #{application}]"

    #only_if do
      #File.exists?("#{deploy[:deploy_to]}") && File.exists?("#{deploy[:deploy_to]}/shared/config/")
    #end
  #end

end
