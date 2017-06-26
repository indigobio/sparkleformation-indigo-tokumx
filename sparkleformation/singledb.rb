ENV['volume_count']          ||= '8'
ENV['volume_size']           ||= '500'
ENV['sg']                    ||= 'private_sg'
ENV['chef_run_list']         ||= 'role[base],role[tokumx_single]'
ENV['notification_topic']    ||= "#{ENV['org']}_#{ENV['environment']}_deregister_chef_node"

SparkleFormation.new('singledb').load(:base, :chef_base, :trusty_ami, :ssh_key_pair, :snapshot_chooser, :git_rev_outputs).overrides do
  description <<"EOF"
Single TokuMX EC2 instance, configured by Chef.
EOF

  dynamic!(:iam_instance_profile, 'singledb',
           :chef_bucket => registry!(:my_s3_bucket, 'chef')
          )

  dynamic!(:chef_node, 'singledb',
           :chef_run_list => ENV['chef_run_list'],
           :restore_from_snapshot => ref!(:restore_from_snapshot),
           :volume_count => ENV['volume_count'],
           :volume_size => ENV['volume_size'],
           :security_group_ids => _array( registry!(:my_security_group_id) ),
           :subnet_id => registry!(:private_subnet_id, 0),
           :iam_instance_profile => 'SingledbIAMInstanceProfile',
           :iam_role => 'SingledbIAMRole'
          )
end
