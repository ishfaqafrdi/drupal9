FROM osiolabs/drupaldevwithdocker-php:7.4
WORKDIR /var/www
Copy docroot /var/www

Copy scripts/install-script.sh scripts

COPY scripts/wait-for-it.sh /usr/wait-for-it.sh

COPY scripts/docker-entrypoint.sh /usr/docker-entrypoint.sh

RUN apt-get update && apt-get install wget
RUN wget -O drush.phar https://github.com/drush-ops/drush-launcher/releases/download/0.6.0/drush.phar && \
    chmod +x drush.phar && mv drush.phar /usr/local/bin/drush

RUN chmod +x /usr/wait-for-it.sh
RUN chmod +x /usr/docker-entrypoint.sh

ENTRYPOINT ["/usr/docker-entrypoint.sh"]

CMD ./scripts/install-script.sh
