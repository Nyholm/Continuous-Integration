# This puppet definition uses the downloadFromNexus script to deploy artifacts to puppet clients.
# Make sure that the downloadFromNexus is installed and executeable.
# 
# Example usage:
# tomcat::deployment { "some_name":
#		repository => "snapshots",
#		groupId => "se.company.application.service",
#		artifactId => "my_bundle",
#		version => "LATEST",
#		warname => "great-service",
#	}
#
#
# Repository might be: snapshots, testing or release etc
# groupId is se.company.application.service
# artifactId is the name of the artifact
# $version may be a number, LATEST, RELEASE or "1.0-SNAPSHOT"
# warname is the name of the link in topcat webapps folder, if excluded we use the artifactId (warname should not include ".war")
# onlyon specifies a hostname that this artifact should be restricted to
define tomcat::deployment($repository, $groupId, $artifactId, $version, $warname=false,$onlyon=false) {
	
	#set instance dir
	$instancedir = "/opt/data/instances/$instancename"
	
	#set the warname to the artifact id if empty
	if ( $warname == false ){
		$warname = $artifactId
	}

	if ( $onlyon == $::hostname ) or ( $onlyon == false ){
		#download form nexus
		exec { "bash downloadFromNexus -r $repository -n http://$nexus_host -a $groupId:$artifactId:$version -o $instancedir/war/$warname.war":
			creates => "$instancedir/war/$warname",
			require => File[$instancedir]
		}
		
		#make sure we create a symlink to webapps
			file { "$instancedir/webapps/$warname.war":
				ensure => link,
				target => "$instancedir/war/$warname.war",
				require => Exec["bash downloadFromNexus -r $repository -n http://$nexus_host -a $groupId:$artifactId:$version -o $instancedir/war/$warname.war"],
			}
		}
	}
}

