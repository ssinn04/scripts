username = "user"
groupname = "group"

directory "/home/#{username}/.ssh" do
  owner "#{username}"
  group "#{groupname}"
  mode  '0700'
  action :create
end

node.default['sshconfig'] = [
  [ 'authorized_keys', '0640' ],
  [ 'config', '0644' ]
]

node.default['sshconfig'].each do |filename, filemode|
  cookbook_file "/home/#{username}/.ssh/#{filename}" do
    source "#{filename}"
    owner "#{username}"
    group "#{groupname}"
    mode  "#{filemode}"
    action :create_if_missing
  end
end

node.default['sshfile'] = [
  ['id_rsa_user.pub', 'id_rsa_user.pub', '0644']
]

node.default['sshfile_priv'] = [
  ['id_rsa_user', 'id_rsa_user', '0600']
]

ssh_pub = data_bag_item('user_secure', 'user_public')
node.default['sshfile'].each do |source, target, permissions|
  template "/home/#{username}/.ssh/#{target}" do
    source "ssh_pub.erb"
    owner "#{username}"
    group "#{groupname}"
    mode  permissions
      variables ({
      :ssh_value => ssh_pub[source]
      })
  end
  # Update authorized_keys if the public key is missing
  template "/home/#{username}/.ssh/authorized_keys" do
    source "authorized_keys.erb"
    owner  "#{username}"
    group  "#{groupname}"
    mode   "0640"
      variables ({
      :ssh_value => ssh_pub[source]
      })
    action :create
  end
end
  
if File.exist?("#{node['user_secure']}")
  ssh_secret = Chef::EncryptedDataBagItem.load_secret("#{node['user_secure']}")
  ssh_cred  =  Chef::EncryptedDataBagItem.load('user_secure', 'user_private', ssh_secret)
  node.default['sshfile_priv'].each do |source, target, permissions|
    template "/home/#{username}/.ssh/#{target}" do
      source "ssh_prv.erb"
      owner "#{username}"
      group "#{groupname}"
      mode  permissions
        variables ({
        :ssh_value => ssh_cred[source]
        })
    end
  end
end
