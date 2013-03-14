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

bash download-artifact-from-nexus.sh -r snapshots -a se.r2m.stockmarket.market:stockmarket-market:LATEST -o /srv/builds/stockmarket-market.jar

# Updates slaves (dont edit)

puppet kick