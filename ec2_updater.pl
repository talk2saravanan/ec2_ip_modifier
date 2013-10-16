#!/usr/bin/perl
################################################################################# 
# 16/10/2013 Saran -> talk2saravanan@yahoo.co.in
# 
#ec2_updater.pl -> Modify the security rules of Amazon Ec2
################################################################################# 

sub help {

		
	print <<EOF;
	
	Please install "VM::EC2" for the first time.
	$>perl -MCPAN -e "install VM::EC2"


	Reference : http://search.cpan.org/~lds/VM-EC2-1.23/lib/VM/EC2/SecurityGroup.pm

	HELP 
	perl ec2_updater.pl [OPTIONS]
	Options:
	access_key				Access Key for Amazon Ec2 Instance
	secret_key				Secret Key
	security_group_name		specify security group name
	region					region
	old_ip_address			Ip address to modify
	new_ip_address			New IP address
	debug					Optional
	help					Optional

	e.g >perl ec2_updater.pl  --access_key="AKIAIFTWUCTKHN32JOEA" 
							  --secret_key="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" 
							  --security_group_name=default_saran2
							  -region=us-east-1
							  --old_ip_address=192.188.2.1/24
							  --new_ip_address=192.111.2.1/24 

EOF
exit;
}





use VM::EC2;
use Data::Dumper;
use Getopt::Long;



my $default_access_key = 'AKIAIFTWUCTKHN32JOEA';
my $default_secret_key = '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';
my $default_security_group_name = 'default';

my $endpoint = 'http://ec2.amazonaws.com';
my $default_region = 'us-east-1';

sub printd ;


my ($access_key,$secret_key,$security_group_name,$region,$old_ip,$new_ip,$debug,$help);
GetOptions(
    'access_key=s' => \$access_key,
	'secret_key=s' => \$secret_key,
	'security_group_name=s' => \$security_group_name,
	'region=s' => \$region,
	'old_ip_address=s' => \$old_ip,
	'new_ip_address=s' => \$new_ip,

	'debug!' => \$debug,
    'help!'     => \$help
) or die "Incorrect usage!\n".help();

$access_key = $access_key || $default_access_key;
$secret_key = $secret_key || $default_secret_key;
$security_group_name = $security_group_name || $default_security_group_name;
$region = $region || $default_region;

die "Please provide access_key as a command line argument".help() unless($access_key);
die "Please provide secret_key as a command line argument".help() unless($secret_key);
die "Please provide security_group_name as a command line argument".help() unless($security_group_name);
die "Please provide region as a command line argument".help() unless($region);
die "Please provide old_ip_address as a command line argument".help() unless($old_ip);
die "Please provide new_ip_address as a command line argument".help() unless($new_ip);

help() if($help);


#Creating object
my $ec2 = VM::EC2->new(-access_key => $access_key,
                        -secret_key => $secret_key,
                        -endpoint   => $endpoint,
						-region     => $region,
						) or die "Cant connect to Ec2:$!\n";

# Check if your security_group exist
if(check_group($ec2,$security_group_name)) {
	printd "Group [ $security_group_name ] found \n";
}
else {
	print "Group [ $security_group_name ] not found in $region region\n";
	exit;
}



my ($found,$ranges) = filter_ipranges($ec2,$security_group_name,$old_ip,$new_ip);
if($found) {
		print "IP Range Found $old_ip : SUCCESS \n";
		foreach my $security_group (keys(%$ranges)) {
			if(delete_group($ec2,$security_group)) { #delete_security_group
				print "Group [ $security_group ] deletion : SUCCESS \n";
				if(create_group($ec2,$security_group,$ranges)) {#recreating group
					print "Group [ $security_group ] recreation : SUCCESS \n";
					if(check_group($ec2,$security_group)) { # check if recreated group exist
						print "Group name [ $security_group ] verification : SUCCESS \n";
						my ($success,$new_ranges) = filter_ipranges($ec2,$security_group_name,$new_ip,$new_ip); #this is for verifying the modified changes after recreating
						if($success) {
							print "Ip Range[$old_ip --> $new_ip ]:SUCCESS\n";
							printd "Complete Data:".Dumper($new_ranges);
							print "OVERALL SUCCESS\n";
						}
						else {
							printd "Complete Data:".Dumper($new_ranges);
							print "May take some time to refresh  \n";
						}
					}
					else {
						print "Cant find group name [ $security_group ] after recreation.\n";
					}
				}
				else {
					print "Cant create group [ $security_group ] .Check Permission \n";
				}
			}
			else {
				print "Cant delete security group [$security_group].Check Permissions \n";
				exit;
			}
      }
}
else {
	print "IP Range [ $old_ip ] not found in security group [ $security_group_name ]\n";
}








#------------------------------------------------------------------------- 
# filter_ipranges() -> check for ipranges with old ip and replace with new_ip and store all its relavant information in hash variable
#------------------------------------------------------------------------- 

sub filter_ipranges {
	
	my ($ec,$security_group_name,$old_ip,$new_ip) = @_;

	my $sg = $ec->describe_security_groups(-name=>$security_group_name) or die $ec->error_str."Group name $security_group_name not found.Invalid Group Name : $!\n";

	my @rules = $sg->ipPermissions;
	my ( $modified_ranges , $found );
	
	if(scalar(@rules) == 0) {
		printd "No rules found in security_group [ $security_group_name ] \n";
		return(0);
	}
	  
	foreach my $rule (@rules) {
		my @ranges = $rule->ipRanges;

		if(scalar(@ranges) eq 0) {
			printd scalar(@ranges)." ipRanges found in rule [ $rule ] and security_group [ $security_group_name ] \n";
			next;
		}
		printd scalar(@ranges)."[@ranges] ipRanges found in rule [ $rule ] and security_group [ $security_group_name ] \n";
		my @modified_ranges;
		foreach my $range (@ranges) {
			my $old_ip_rx = qr/$old_ip/;
			if($range =~s/$old_ip_rx/$new_ip/gi) {
				printd "IP Range[$range] Found $old_ip and modified with $range \n";
				$found = 1;
			}

		
			push(@modified_ranges,$range);
		}
		
			printd "Ranges : @modified_ranges \n";
			$modified_ranges->{$security_group_name}->{$rule}->{range} = \@modified_ranges;
			$modified_ranges->{$security_group_name}->{$rule}->{ipProtocol} = $rule->ipProtocol;
			$modified_ranges->{$security_group_name}->{$rule}->{fromPort} = $rule->fromPort;
			$modified_ranges->{$security_group_name}->{$rule}->{toPort} = $rule->toPort;
			$modified_ranges->{$security_group_name}->{$rule}->{groups} = $rule->groups;
		

	}	
	if($found) {
		$modified_ranges->{$security_group_name}->{description} = $sg->groupDescription;
		$modified_ranges->{$security_group_name}->{groupId} = $sg->groupId;
		$modified_ranges->{$security_group_name}->{vpcId} = $sg->vpcId;
	}
	else {
		return(0);
	}
	

	return($found,$modified_ranges);
}
#------------------------------------------------------------------------- 
#delete_group() --> Delete the given security_group
#------------------------------------------------------------------------- 

sub delete_group {
		my ($ec,$security_group_name) = @_;
		
		my $delete_status = $ec->delete_security_group(-group_name=>$security_group_name) or die $ec->error_str."Cant delete Group name $security_group_name .Check Permisson/Group Name : $!\n";
		printd "Delete status : $delete_status \n";

		return($delete_status);


}

#------------------------------------------------------------------------- 
#create_group() --> create the given security_group and update all its attributes
#------------------------------------------------------------------------- 
sub create_group {
		my ($ec,$security_group_name,$modified_ranges) = @_;
			
		my $group = $ec->create_security_group(-group_name=>$security_group_name, -group_description=>$modified_ranges->{$security_group_name}->{description} , -vpc_id=>$modified_ranges->{$security_group_name}->{vpcId}) or die $ec->error_str."Cant create Group name $security_group_name .Check Permisson/Group Name : $!\n";
		printd "create status [ $security_group_name ] : $group \n";


		foreach my $rule (keys(%{$modified_ranges->{$security_group_name}})){
													
					next unless($modified_ranges->{$security_group_name}->{$rule}->{ipProtocol} || $modified_ranges->{$security_group_name}->{$rule}->{range} );
					$group->authorize_incoming(
												-protocol  => $modified_ranges->{$security_group_name}->{$rule}->{ipProtocol},
												-port      => $modified_ranges->{$security_group_name}->{$rule}->{fromPort},
												-source_ip => $modified_ranges->{$security_group_name}->{$rule}->{range},
											  );

					$group->authorize_outgoing(
												-protocol  => $modified_ranges->{$security_group_name}->{$rule}->{ipProtocol},
												-port      => $modified_ranges->{$security_group_name}->{$rule}->{toPort},
												-source_ip => $modified_ranges->{$security_group_name}->{$rule}->{range}
											  );
		
					
		}
		$group->update();

		return(1);
}
#------------------------------------------------------------------------- 
#check_group() --> check if given group exist in the ec2 region
#------------------------------------------------------------------------- 

sub check_group {

	my($ec,$security_group_name) = @_;
	
	my @all_sg =  $ec->describe_security_groups();

	foreach my $sg (@all_sg) {
		my $group_name = $sg->groupName;
		if($group_name =~/$security_group_name/si) {
			return(1);
		}
	}

	return(0);


}


sub display_group {

	my($ec) = @_;
	
	my @all_sg =  $ec->describe_security_groups();

	foreach my $sg (@all_sg) {
		my $group_name = $sg->groupName;
		printd "Groupid [  $sg ] --> $group_name \n";
	}

	return(1);


}



sub printd {
    
        print "@_"."\n" if ($debug);
}
