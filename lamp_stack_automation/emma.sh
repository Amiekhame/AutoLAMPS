#!/bin/bash

# Check if the script is being run as root.
if [[ "${UID}" -ne 0 ]]
then
  sudo -E "${0}" "${@}"
  exit
fi


# Define variables
GIT_REPO="https://github.com/laravel/laravel.git"
DB_ROOT_PASSWORD=$(openssl rand -base64 32)

# Update and Upgrade server
apt-get update && apt-get upgrade -y

# Add important package repositories
apt-get install -y software-properties-common
add-apt-repository -y ppa:ondrej/php

# Install AP stack and important extensions
apt-get install -y apache2
apt-get install -y php8.2 php8.2-mysql php8.2-curl php8.2-gd php8.2-intl php8.2-mbstring php8.2-soap php8.2-xml php8.2-xmlrpc php8.2-zip php8.2-bcmath php8.2-common php8.2-cli php8.2-tokenizer libapache2-mod-php8.2 curl git unzip zip


# Start and enable apache
systemctl start apache2
systemctl enable apache2

# configure php.ini
sed -i "s/;cgi.fix_pathinfo=1/cgi.fix_pathinfo=0/" /etc/php/8.2/apache2/php.ini

# Install Composer
export COMPOSER_ALLOW_SUPERUSER=1
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer



# Configure Apache
cat <<EOF > /etc/apache2/sites-available/laravel.conf
<VirtualHost *:80>
    ServerName 192.168.56.31
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html/laravel/public

    <Directory /var/www/html/laravel>
        AllowOverride All
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# Enable the laravel.conf site
a2enmod rewrite
a2ensite laravel.conf
a2enmod php8.2

# Set root user and password for MySQL
debconf-set-selections <<< "mysql-server mysql-server/root_password password ${DB_ROOT_PASSWORD}"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password ${DB_ROOT_PASSWORD}"
apt-get install -y mysql-server

# Navigate into the web directory
cd /var/www/html || exit

# Clone the git repository
git clone $GIT_REPO

# Navigate to the laravel directory
cd /var/www/html/laravel || exit

# Install dependencies
composer install --no-dev --optimize-autoloader --no-interaction

# Set permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html/laravel
chmod -R 755 /var/www/html/laravel/storage
chmod -R 755 /var/www/html/laravel/bootstrap/cache

# Copy the .env.example file to .env
cp .env.example .env

# Generate the application key
php artisan key:generate


# Database setup
mysql -u root -p"${DB_ROOT_PASSWORD}" <<EOF
CREATE DATABASE laravel;
GRANT ALL PRIVILEGES ON laravel.* TO 'root'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

# update the .env file with database credentials
sed -i "s/DB_PASSWORD=.*/DB_PASSWORD=$DB_ROOT_PASSWORD/g" .env

# Cache the config
php artisan config:cache

# Migrate the database
php artisan migrate --force

# restart apache
systemctl restart apache2
