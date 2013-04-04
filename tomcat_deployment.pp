# This puppet definition uses the downloadFromNexus script to deploy artifacts to puppet clients.
# Make sure that the downloadFromNexus is installed and executeable.
# 
# Example usage:
# tomcat::deployment { "some_name":
#		repository => "snapshots",
#		groupId => "se.company.application.service",
#		artifactId => "my_bundle",
#		version => "LATEST",
#		intancename => "great-service",
#	}
# A war file will be place in /opt/data/instances/great-service/war/great-service.war
#
#
# Repository might be: snapshots, testing or release etc
# groupId is se.company.application.service
# artifactId is the name of the artifact
# $version may be a number, LATEST, RELEASE or "1.0-SNAPSHOT"
# $instancename is the name of the folder that we put the war in
# warname is the name of the link in topcat webapps folder, if excluded we use the artifactId (warname should not include ".war")
# onlyon specifies a hostname that this artifact should be restricted to
define tomcat::deployment($repository, $groupId, $artifactId, $version, $instancename=false, $warname=false, $onlyon=false) {
	
	#set the instancename to the artifact id if empty
	if ( $instancename == false ){
		$instancename = $artifactId
	}
	
	#set the warname to the instancename if empty
	if ( $warname == false ){
		$warname = $instancename
	}
	
	#set instance dir
	$instancedir = "/opt/data/instances/$instancename"
	

	if ( $onlyon == $::hostname ) or ( $onlyon == false ){
		#download form nexus
		exec { "bash downloadFromNexus -r $repository -n http://$nexus_host -a $groupId:$artifactId:$version -o $instancedir/war/$warname.war":
			creates => "$instancedir/war/$warname",
			require => File[$instancedir],
			before => File["$instancedir/webapps/$warname.war"]
		}
		
		#make sure we create a symlink to webapps
		file { "$instancedir/webapps/$warname.war":
			ensure => link,
			target => "$instancedir/war/$warname.war"
		}
	}
}

