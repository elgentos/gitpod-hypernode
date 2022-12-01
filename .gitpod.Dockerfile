ARG PHP_VERSION=8.1
ARG PHP_VERSION_WITHOUT_DOT=81
ARG MYSQL_VERSION_WITHOUT_DOT=80
FROM docker.hypernode.com/byteinternet/hypernode-buster-docker-php${PHP_VERSION_WITHOUT_DOT}-mysql${MYSQL_VERSION_WITHOUT_DOT}:latest
MAINTAINER Peter Jaap Blaakmeer <peterjaap@elgentos.nl>

# Magento Config
ENV INSTALL_MAGENTO YES
ENV MAGENTO_VERSION 2.4.5-p1
ENV MAGENTO_ADMIN_EMAIL admin@magento.com
ENV MAGENTO_ADMIN_PASSWORD password1
ENV MAGENTO_ADMIN_USERNAME admin
ENV MAGENTO_COMPOSER_AUTH_USER 64229a8ef905329a184da4f174597d25
ENV MAGENTO_COMPOSER_AUTH_PASS a0df0bec06011c7f1e8ea8833ca7661e

RUN php -v

# Add public key
#ADD gitlab-ci.pub /tmp/key.pub
#RUN cat /tmp/key.pub > /root/.ssh/authorized_keys
#RUN cat /tmp/key.pub > /data/web/.ssh/authorized_keys
#RUN rm -f /tmp/deployment.pub

# Disable password login
#RUN sed -i 's/PasswordAuthentication\ yes/PasswordAuthentication\ no/g' /etc/ssh/sshd_config

# Enable passwordless sudo for app user (see https://github.com/ByteInternet/hypernode-docker/issues/6)
#RUN echo "app     ALL = (ALL) NOPASSWD: ALL" >> /etc/sudoers

# Enable basic auth
#RUN echo "elgentos:\$apr1\$w3qy86vS\$0bK4seHyfv8/0N38ie1NO0" > /data/web/htpasswd
#ADD server.basicauth /data/web/nginx/server.basicauth

# Allow Lets Encrypt challenges
#RUN printf '\nlocation ^~ /.well-known/acme-challenge/ {\n\tauth_basic off;\n}\n' >> /data/web/nginx/server.basicauth
# Remove default *.hypernode.local certificate to avoid nginx errors when using LE
RUN rm -rf /etc/nginx/ssl

# Install gcloud
RUN export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" && \
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    apt-get update -y && apt-get install google-cloud-sdk -y

# Install awscli
RUN apt-get install -y libpython-dev python-dev libyaml-dev python-pip
RUN pip install awscli --upgrade --user
RUN echo "export PATH=~/.local/bin:$PATH" >> ~/.bash_profile

# Install kubectl
#RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/v1.10.5/bin/linux/amd64/kubectl
#RUN curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
#RUN chmod +x ./kubectl && mv ./kubectl /usr/bin/kubectl

# Install doctl
#RUN curl -sL https://github.com/digitalocean/doctl/releases/download/v1.12.0/doctl-1.12.0-linux-amd64.tar.gz | tar -xzv
#RUN mv doctl /usr/local/bin/doctl

RUN apt-get install apt-transport-https

# Install yarn repo
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Install nodejs 10.x repo
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -

# Install yarn, npm and node
RUN apt-get update
RUN apt-get install -y nodejs
RUN apt-get install -y yarn

# Install requirejs for r.js optimization
RUN npm install -g requirejs

# Install n & gulp-cli
RUN yarn global add n gulp-cli

# Update node to 13.8
RUN n 14

# Update composer
RUN wget https://getcomposer.org/composer-1.phar
RUN sudo mv composer-1.phar /usr/local/bin/composer
RUN wget https://getcomposer.org/composer-stable.phar
RUN sudo mv composer-stable.phar /usr/local/bin/composer2
RUN chmod +x /usr/local/bin/composer
RUN chmod +x /usr/local/bin/composer2
RUN composer --version
RUN composer2 --version

# Download Deployer 6
#RUN wget --no-check-certificate https://deployer.org/releases/v6.9.0/deployer.phar
#RUN mv deployer.phar /usr/local/bin/dep
#RUN chmod +x /usr/local/bin/dep
#RUN dep --version

# Download Deployer 7 RC
#RUN wget --no-check-certificate https://github.com/deployphp/deployer/releases/download/v7.0.2/deployer.phar
#RUN mv deployer.phar /usr/local/bin/dep7
#RUN chmod +x /usr/local/bin/dep7

# Install latest magerun2
RUN wget https://files.magerun.net/n98-magerun2.phar
RUN sudo mv n98-magerun2.phar /usr/local/bin/magerun2
RUN chmod +x /usr/local/bin/magerun2

# Install nvm
RUN wget -qO- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
RUN export NVM_DIR="$([ -z "${XDG_CONFIG_HOME-}" ] && printf %s "${HOME}/.nvm" || printf %s "${XDG_CONFIG_HOME}/nvm")"
RUN sh "${HOME}/.nvm/nvm.sh"

# Change PHP version inside Hypernode container
#RUN jq ".php.version=${PHP_VERSION}" /etc/hypernode/magweb.json > /tmp/magweb.json
#RUN mv /tmp/magweb.json /etc/hypernode/magweb.json
#RUN update-alternatives --set php $(which php${PHP_VERSION})
#RUN bash /etc/my_init.d/60_restart_services.sh

# Echo out PHP version
#RUN php -v
