#!/bin/bash
sleep 12;
mysql -e 'CREATE DATABASE IF NOT EXISTS magento;' &&
pass=$(cat /data/web/.my.cnf  | grep pass | awk '{print$3}') && 
url=$(gp url | awk -F"//" {'print $2'}) && url+="/" && 
url="https://80-"$url && 
if [ "${INSTALL_MAGENTO}" = "YES" ]; then php bin/magento setup:install --db-name='magento' --db-user='app' --db-password=$pass --base-url=$url --backend-frontname='admin' --admin-user=$MAGENTO_ADMIN_USERNAME --admin-password=$MAGENTO_ADMIN_PASSWORD --admin-email=$GITPOD_GIT_USER_EMAIL --admin-firstname='Admin' --admin-lastname='User' --use-rewrites='1' --use-secure='1' --base-url-secure=$url --use-secure-admin='1' --language='en_US' --db-host='127.0.0.1' --cleanup-database --timezone='Europe/Amsterdam' --currency='EUR' --session-save='redis'; fi &&

magerun2 module:disable Magento_Csp &&
magerun2 module:disable Magento_TwoFactorAuth &&
magerun2 setup:upgrade &&

yes | php bin/magento setup:config:set --session-save=redis --session-save-redis-host=127.0.0.1 --session-save-redis-log-level=3 --session-save-redis-db=0 --session-save-redis-port=6379;
yes | php bin/magento setup:config:set --cache-backend=redis --cache-backend-redis-server=127.0.0.1 --cache-backend-redis-db=1;
yes | php bin/magento setup:config:set --page-cache=redis --page-cache-redis-server=127.0.0.1 --page-cache-redis-db=2;

php bin/magento config:set web/cookie/cookie_path "/" &&
php bin/magento config:set web/cookie/cookie_domain ".gitpod.io" &&

magerun2 cache:flush &&
redis-cli flushall &&

touch $GITPOD_REPO_ROOT/gitpod/db-installed.flag &&

ln -s /workspace/gitpod-hypernode/ /data/web/current  &&
ln -s /data/web/current/pub /data/web/public
