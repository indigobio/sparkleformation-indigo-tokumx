## sparkleformation-indigo-tokumx
This repository contains a SparkleFormation template that creates a 
three-member TokuMX replicaset.

Additionally, the template creates private Route53 (DNS) CNAME records:
mongo01-03.`ENV['private_domain']`.

### Dependencies

The template requires external Sparkle Pack gems, which are noted in
the Gemfile and the .sfn file.  These gems interact with AWS through the
`aws-sdk-core` gem to identify or create  availability zones, subnets, and 
security groups.

### Parameters

When launching the compiled CloudFormation template, you will be prompted for
some stack parameters:

| Parameter | Default Value | Purpose |
|-----------|---------------|---------|
| ChefServer | https://api.opscode.com/organizations/product_dev | No need to change |
| ChefValidationClientName | product_dev-validator | No need to change |
| ChefVersion | 12.4.0 | No need to change |
| RestorableId | latest | You can choose a set of snapshots to restore from, based on 'backup_id' resource tags |
| RestoreFromSnapshots | true | If true, CloudFormation will create EBS volumes from snapshot.  Otherwise, it will create blank volumes. |
| SshKeyPair | indigo-bootstrap | No need to change |
| Tokumx01AssociatePublicIpAddress | false | No need to change |
| Tokumx01ChefrunList | role[base],role[tokumx_server] | The Chef run list to run on tokumx01 |
| Tokumx01DeleteEbsVolumesOnTermination | true | Set to false if you want the EBS volumes to persist when the instance is terminated |
| Tokumx01EbsOptimized| false | Enable EBS optimization for certain [instance types](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSOptimized.html#ebs-optimization-support) |
| Tokumx01EbsProvisionedIops| 300 | Number of provisioned IOPS to request for io1 EBS volumes |
| Tokumx01EbsVolumeSize | 10 | Size (in GB) of additional EBS volumes |
| Tokumx01EbsVolumeType | gp2 | EBS volume type (gp2, or general purpose, or io1, provisioned IOPS).  Provisioned IOPS volumes incur additional expense. |
| Tokumx01InstanceMonitoring | false | Set to true to enable detailed cloudwatch monitoring (additional costs incurred) |
| Tokumx01InstanceType | t2.small | Increase the instance size for more network throughput |
| Tokumx01RootVolumeSize | 12 | Size of the root EBS volume, in GB |

Note that the same parameters apply to the other two TokuMX servers.  You can
change the run list for one of the servers and make it an Arbiter, which is 
a reduced capacity member that simply votes (does not hold data).
