FROM php:apache
MAINTAINER Johan Smits

# Enable Apache rewrite module
RUN a2enmod rewrite

# Copy the necessary files
COPY email-autodiscover/.htaccess /var/www/html/
COPY email-autodiscover/autodiscover.xml.php /var/www/html/
COPY email-autodiscover/mail /var/www/html/mail
COPY settings.json /var/www/html/settings.json

# Override the default command and set configure the environment
COPY start.sh /usr/local/bin

# Run the server
CMD ["start.sh"]
