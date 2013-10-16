ec2_ip_modifier
===============


  ***Please install "VM::EC2" for the first time.***
	   $>perl -MCPAN -e "install VM::EC2"
	   
	   During installation.There will be a prompt to enter "access_key" and "secret_key".
	   Please press enter to skip it.

	Reference : http://search.cpan.org/~lds/VM-EC2-1.23/lib/VM/EC2/SecurityGroup.pm

	
	e.g >perl ec2_updater.pl  --access_key="AKIAIFTWUCTKHN32JOEA" 
							  --secret_key="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" 
							  --security_group_name=default_saran2
							  -region=us-east-1
							  --old_ip_address=192.188.2.1/24
							  --new_ip_address=192.111.2.1/24 


D:\saran\perl>perl ec2_updater.pl --help

        	Please install "VM::EC2" for the first time.
	        $>perl -MCPAN -e "install VM::EC2"



        Reference : http://search.cpan.org/~lds/VM-EC2-1.23/lib/VM/EC2/SecurityG
roup.pm

        HELP
        perl ec2_updater.pl [OPTIONS]
        Options:
        access_key                              Access Key for Amazon Ec2 Instan
ce
        secret_key                              Secret Key
        security_group_name             specify security group name
        region                                  region
        old_ip_address                  Ip address to modify
        new_ip_address                  New IP address
        debug                                   Optional
        help                                    Optional

        e.g >perl ec2_updater.pl  --access_key="AKIAIFTWUCTKHN32JOEA"
                                                          --secret_key="bfZ0fS0v
rcg1i6dORTJ8uEasdxtXVxbAMkWD3Qj0"
                                                          --security_group_name=
default_saran2
                                                          -region=us-east-1
                                                          --old_ip_address=192.1
88.2.1/24
                                                          --new_ip_address=192.1
11.2.1/24



D:\saran\perl>perl ec2_updater.pl  --access_key="AKIAIFTWUCTKHN32JOEA" --secret_
key="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" --security_group_name=default_sar
an1 --old_ip_address=192.168.2.0/24 --new_ip_address=192.143.2.1/32 --region=us-
east-1
IP Range Found 192.168.2.0/24 : SUCCESS
Group [ default_saran1 ] deletion : SUCCESS
Group [ default_saran1 ] recreation : SUCCESS
Group name [ default_saran1 ] verification : SUCCESS
Ip Range[192.168.2.0/24 --> 192.143.2.1/32 ]:SUCCESS
OVERALL SUCCESS


Debug mode

D:\saran\perl>perl ec2_updater.pl  --access_key="AKIAIFTWUCTKHN32JOEA" --secret_
key="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" --security_group_name=default_sar
an1 --old_ip_address=111.111.111.111/11 --new_ip_address=200.200.200.200/32 --re
gion=us-east-1 --debug
Group [ default_saran1 ] found

1[192.168.2.0/32] ipRanges found in rule [ icmp(-1..-1) FROM CIDR 192.168.2.0/32
 ] and security_group [ default_saran1 ]

Ranges : 192.168.2.0/32

1[111.111.111.111/11] ipRanges found in rule [ tcp(22..22) FROM CIDR 111.111.111
.111/11 ] and security_group [ default_saran1 ]

IP Range[200.200.200.200/32] Found 111.111.111.111/11 and modified with 200.200.
200.200/32

Ranges : 200.200.200.200/32

1[111.111.111.111/11] ipRanges found in rule [ tcp(993..993) FROM CIDR 111.111.1
11.111/11 ] and security_group [ default_saran1 ]

IP Range[200.200.200.200/32] Found 111.111.111.111/11 and modified with 200.200.
200.200/32

Ranges : 200.200.200.200/32

1[192.143.5.1/24] ipRanges found in rule [ tcp(143..143) FROM CIDR 192.143.5.1/2
4 ] and security_group [ default_saran1 ]

Ranges : 192.143.5.1/24

IP Range Found 111.111.111.111/11 : SUCCESS
Delete status : 1

Group [ default_saran1 ] deletion : SUCCESS
create status [ default_saran1 ] : sg-2d2a5a46

Group [ default_saran1 ] recreation : SUCCESS
Group name [ default_saran1 ] verification : SUCCESS
1[192.143.5.1/24] ipRanges found in rule [ tcp(143..143) FROM CIDR 192.143.5.1/2
4 ] and security_group [ default_saran1 ]

Ranges : 192.143.5.1/24

1[192.168.2.0/32] ipRanges found in rule [ icmp(-1..-1) FROM CIDR 192.168.2.0/32
 ] and security_group [ default_saran1 ]

Ranges : 192.168.2.0/32

1[200.200.200.200/32] ipRanges found in rule [ tcp(22..22) FROM CIDR 200.200.200
.200/32 ] and security_group [ default_saran1 ]

IP Range[200.200.200.200/32] Found 200.200.200.200/32 and modified with 200.200.
200.200/32

Ranges : 200.200.200.200/32

1[200.200.200.200/32] ipRanges found in rule [ tcp(993..993) FROM CIDR 200.200.2
00.200/32 ] and security_group [ default_saran1 ]

IP Range[200.200.200.200/32] Found 200.200.200.200/32 and modified with 200.200.
200.200/32

Ranges : 200.200.200.200/32

Ip Range[111.111.111.111/11 --> 200.200.200.200/32 ]:SUCCESS
Complete Data:{
  'default_saran1' => {
    'tcp(993..993) FROM CIDR 200.200.200.200/32' => {
      'toPort' => '993',
      'range' => [
        '200.200.200.200/32'
      ],
      'groups' => undef,
      'ipProtocol' => 'tcp',
      'fromPort' => '993'
    },
    'tcp(22..22) FROM CIDR 200.200.200.200/32' => {
      'ipProtocol' => 'tcp',
      'fromPort' => '22',
      'groups' => undef,
      'range' => [
        '200.200.200.200/32'
      ],
      'toPort' => '22'
    },
    'description' => 'default group',
    'icmp(-1..-1) FROM CIDR 192.168.2.0/32' => {
      'range' => [
        '192.168.2.0/32'
      ],
      'toPort' => '-1',
      'fromPort' => '-1',
      'ipProtocol' => 'icmp',
      'groups' => undef
    },
    'tcp(143..143) FROM CIDR 192.143.5.1/24' => {
      'range' => [
        '192.143.5.1/24'
      ],
      'toPort' => '143',
      'ipProtocol' => 'tcp',
      'fromPort' => '143',
      'groups' => undef
    },
    'vpcId' => undef,
    'groupId' => 'sg-2d2a5a46'
  }
}

OVERALL SUCCESS

