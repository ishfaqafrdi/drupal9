#!/bin/bash


echo "Checking website status..."
vendor/bin/drush status bootstrap | grep -q Successful
if [ $? -eq 0 ] 
then
  # Update database if required.
  echo "Updating database..."
  vendor/bin/drush updb --yes
	
	# The website is set up already. Import the config.
	echo "The website has been installed already. Importing changes..."
	vendor/bin/drush config-import --yes
	
	# Clear the cache so we get new javascript and CSS files.
	echo "Rebuilding cache..."
	vendor/bin/drush cache-rebuild
else
	# The website has not been set up. Install it.
	echo "The website has not been installed. Installing..."
	chmod 557 web/sites/default/settings.php

	# install Drupal
    vendor/bin/drush site:install custom_profile -y --existing-config
	
	# Clear the cache so we get new javascript and CSS files.
	echo "Rebuilding cache..."
	vendor/bin/drush cache-rebuild

    # Set admin user's password
    vendor/bin/drush upwd admin "admin82"

fi

# install Drupal
# vendor/bin/drush site:install existing_config -y --existing-config

# Set admin user's password
# vendor/bin/drush upwd admin "admin82"

# Start apache
apachectl -D FOREGROUND
