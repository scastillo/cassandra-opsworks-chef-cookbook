default[:cassandra] = {
  :cluster_name => "Test Cluster",
  :initial_token => "",
  :version => '2.0.0',
  :user => "cassandra",
  :jvm  => {
    :xms => 32,
    :xmx => 512,
    :xss => "228k"
  },
  :limits => {
    :memlock => 'unlimited',
    :nofile  => 48000
  },
  :installation_dir => "/usr/local/cassandra",
  :bin_dir          => "/usr/local/cassandra/bin",
  :lib_dir          => "/usr/local/cassandra/lib",
  :conf_dir         => "/etc/cassandra/",
  # commit log, data directory, saved caches and so on are all stored under the data root. MK.
  :data_root_dir    => "/var/lib/cassandra/",
  :commitlog_dir    => "/var/lib/cassandra/",
  :log_dir          => "/var/log/cassandra/",
  :listen_address   => node[:ipaddress],
  :rpc_address      => node[:ipaddress],
  :max_heap_size    => nil,
  :heap_new_size    => nil,
  :vnodes           => 64,
  :seeds            => [],
  :concurrent_reads => 32,
  :concurrent_writes => 32,
  :snitch           => 'EC2Snitch',
  :authenticator    => 'org.apache.cassandra.auth.PasswordAuthenticator',
  :authorizer       => 'org.apache.cassandra.auth.CassandraAuthorizer',
  :native_transport => {
    :start       => true,
    :port        => 9042,
    :max_threads => 128
  }
}

# Java version specifics
default[:java] = {
  :install_flavor => 'oracle',
  :jdk_version => '8',
  :oracle => {
    :accept_oracle_download_terms => true
  },
  'jdk' => {
    '8' => {
      'x86_64' => {
        'url' => 'https://s3.amazonaws.com/setup-dependencies-repo/jre-8u66-linux-x64.tar.gz',
        'checksum' => '88f31f3d642c3287134297b8c10e61bf'
      }
    }
  }
}

# Set the OpsWorks specifics here

puts "Configured Snitch is #{node["cassandra"]["snitch"]}"

seed_array = []

# Add this node as the first seed
# If using the multi-region snitch, we must use the public IP address
if node["cassandra"]["snitch"] == "Ec2MultiRegionSnitch"
  seed_array << node["opsworks"]["instance"]["ip"]
else
  seed_array << node["opsworks"]["instance"]["private_ip"]
end


node["opsworks"]["layers"]["cassandra"]["instances"].each do |instance_name, values|
  # If using the multi-region snitch, we must use the public IP address
  if node["cassandra"]["snitch"] == "Ec2MultiRegionSnitch"
    seed_array << values["ip"]
  else
    seed_array << values["private_ip"]
  end
end
  
set[:cassandra][:seeds] = seed_array
