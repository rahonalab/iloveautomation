#!/bin/sh
# Original from David Fox:
# https://gist.github.com/dfox/1677405
#
# Script to bind a CNAME to our HOST_NAME in ZONE

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
echo "This script must be run as root" 1>&2
exit 1
fi

# Defaults
TTL=60
HTTP=youriphere
ZONE=$1

# Export access key ID and secret for cli53
export AWS_ACCESS_KEY_ID='undisclosed'
export AWS_SECRET_ACCESS_KEY='undisclosed'

# Create hosted zone

aws route53 create-hosted-zone --name $ZONE --caller-reference 2014-04-01-18:47 --hosted-zone-config Comment="hosted zone for $ZONE"

# Add DNS entry
