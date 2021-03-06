ENV['volume_count']          ||= '8'
ENV['volume_size']           ||= '500'
ENV['sg']                    ||= 'private_sg'
ENV['chef_run_list']         ||= 'role[base],role[tokumx_server]'
ENV['arbiter_run_list']      ||= 'role[base],role[tokumx_arbiter]'
ENV['notification_topic']    ||= "#{ENV['org']}_#{ENV['environment']}_deregister_chef_node"

SparkleFormation.new('tokumx').load(:base, :chef_base, :trusty_ami, :ssh_key_pair, :snapshot_chooser, :git_rev_outputs).overrides do
  description <<"EOF"
TokuMX EC2 instances, configured by Chef.  Route53 records: mongo0[1,2,3].#{ENV['private_domain']}.
EOF

  dynamic!(:iam_instance_profile, 'tokumx',
           :policy_statements => [ :modify_route53 ],
           :chef_bucket => registry!(:my_s3_bucket, 'chef')
          )

  dynamic!(:chef_node, 'tokumx01',
           :chef_run_list => ENV['chef_run_list'],
           :restore_from_snapshot => ref!(:restore_from_snapshot),
           :volume_count => ENV['volume_count'],
           :volume_size => ENV['volume_size'],
           :security_group_ids => _array( registry!(:my_security_group_id) ),
           :subnet_id => registry!(:private_subnet_id, 0),
           :iam_instance_profile => 'TokumxIAMInstanceProfile',
           :iam_role => 'TokumxIAMRole'
          )

  dynamic!(:chef_node, 'tokumx02',
           :chef_run_list => ENV['chef_run_list'],
           :restore_from_snapshot => ref!(:restore_from_snapshot),
           :volume_count => ENV['volume_count'],
           :volume_size => ENV['volume_size'],
           :security_group_ids => _array( registry!(:my_security_group_id) ),
           :subnet_id => registry!(:private_subnet_id, 1),
           :iam_instance_profile => 'TokumxIAMInstanceProfile',
           :iam_role => 'TokumxIAMRole',
           :depends_on => 'Tokumx01Ec2Instance'
          )

  dynamic!(:chef_node, 'tokumx03',
           :chef_run_list => ENV['chef_run_list'],
           :restore_from_snapshot => ref!(:restore_from_snapshot),
           :volume_count => ENV['volume_count'],
           :volume_size => ENV['volume_size'],
           :security_group_ids => _array( registry!(:my_security_group_id) ),
           :subnet_id => registry!(:private_subnet_id, 2),
           :iam_instance_profile => 'TokumxIAMInstanceProfile',
           :iam_role => 'TokumxIAMRole',
           :depends_on => 'Tokumx02Ec2Instance'
  )

end
