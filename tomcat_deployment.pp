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
		$instancename_fact=$artifactId
	}
	else{
		$instancename_fact= $instancename
	}
	
	#set the warname to the instancename if empty
	if ( $warname == false ){
		$warname_fact = $instancename_fact
	}
	else{
		$warname_fact = $warname
	}
	
	$instancedir = "/opt/data/instances/$instancename_fact"
	
	#set instance dir
	file { instancedir:
		path => "$instancedir",
	    ensure => "directory",
	}
	
	file { instancedir_war:
		path => "$instancedir/war",
	    ensure => "directory",
		require => File["instancedir"],
	}
	
	file { instancedir_webapps:
		path => "$instancedir/webapps",
	    ensure => "directory",
		require => File["instancedir"],
	}
	

	if ( $onlyon == $::hostname ) or ( $onlyon == false ){
		#download form nexus
		exec { download_war:
			command => "/bin/bash downloadFromNexus -r $repository -n http://$nexus_host -a $groupId:$artifactId:$version -o $instancedir/war/$warname_fact.war",
			creates => "$instancedir/war/$warname_fact",
			require => File["instancedir_war"],
			before => File["link_to_war"]
		}
		
		#make sure we create a symlink to webapps
		file { link_to_war:
			path => "$instancedir/webapps/$warname_fact.war",
			ensure => link,
			target => "$instancedir/war/$warname_fact.war",
			require => File["instancedir_webapps"],
		}
	}

}

