log_message () {
	logger -t "install_script" "\"message\":\"$1\""
}

log_message "Checking website status..."
drush status bootstrap | grep -q Successful
if [ $? -eq 0 ] 
then
  # Update database if required.
  echo "Updating database..."
  drush updb --yes
	
	# The website is set up already. Import the config.
	log_message "The website has been installed already. Importing changes..."
	drush config-import --yes

	# Set the site ID.
	log_message "Setting site ID to ${WEBSITE_ID}..."
	drush cset system.site uuid ${WEBSITE_ID} --yes
	
	# Clear the cache so we get new javascript and CSS files.
	log_message "Rebuilding cache..."
	drush cache-rebuild
else
	# The website has not been set up. Install it.
	log_message "The website has not been installed. Installing..."
	chmod 557 /app/web/sites/default/settings.php

	# Install site using a minimal profile.
	log_message "Installing site using a minimal profile..."
	drush site:install minimal --yes

	# Change the profile from minimal to standard.
	log_message "Changing the profile from minimal to standard..."
	drush en profile_switcher --yes
	drush --include="modules/contrib/profile_switcher" switch-profile standard --yes
	
	# Sync the Site UUID.
	log_message "Setting site ID to ${WEBSITE_ID}..."
	drush config:set system.site uuid ${WEBSITE_ID} --yes
	
	# Import config.
	log_message "Importing configuration..."
	drush config:import --source=/app/config/sync --yes
	
	# Clear the cache so we get new javascript and CSS files.
	log_message "Rebuilding cache..."
	drush cache-rebuild

	if [ ! $? -eq 0 ]
	then
		# An error occurred. We need to exit straight away. Supervisord should try again
		# a number of times, in case the DB isn't available yet.
		log_message "Error returned from drush site install. Exiting..."

		# Sleep for 5 seconds before exiting, in case it's a timing issue.
		sleep 5
		exit 1
	fi
fi

# Set the admin password.
log_message "Resetting password..."
drush upwd admin "${DRUPAL_PASSWORD}"

# Make sure that Drupal has access to the files we need.
log_message "Setting file permissions..."
chmod 555 /app/web/sites/default/settings.php
chmod 555 /app/web/.htaccess

# Finally, start Apache so we can start receiving traffic.
log_message "Finished install. Starting web server..."
supervisorctl start apache2
