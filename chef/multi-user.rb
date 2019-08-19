# Ideally we have a range of UIDs that are unique to system user accounts.
# This will matter if we are using things like NFS and need to ensure system
# user accounts access a mount point with the same level of access without using
# NIS etc

# multiple user
# Create an array of users
userlist  = ['user0', 'user01', 'user02']
groupname = "testgroup"

group "#{groupname}" do
  action :create
end

userlist.each do |username|
  user "#{username}" do
    gid "#{groupname}"
    home "/home/#{username}"
    actino :create
  end

  directory "/home/#{username}" do
    owner "#{username}"
    group "#{groupname}"
    mode '0700'
    action :create
  end
  
  # Set the account to never expire
  bash 'fixUserPassword' do
    user 'root'
    code <<-EOH
    chage --maxdays -1 "#{username}"
    EOH
  end
end
