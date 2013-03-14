#!/bin/bash

# Downloads the needed artifacts
# Updates all the puppet slaves

##############################################################
#### EXAMPLE :
####
#### bash puppetUpdateSlaves.sh 
#### 
####
##############################################################

# Download artifacts

bash downloadFromNexus.sh -r snapshots -a se.r2m.stockmarket.market:stockmarket-market:LATEST -o /srv/builds/stockmarket-market.war

# Updates slaves (dont edit)

#puppet kick --all
puppet apply /etc/puppet/manifests/site.pp
