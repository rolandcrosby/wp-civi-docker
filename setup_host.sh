# set up a debian host to run all this stuff.
# i don't think this is really a shell script,
# more just a series of commands to run.
# do your own error checking!

# install docker
apt-get update
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common

curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -

echo "fingerprint ending in '0EBF CD88' should be here:"
apt-key fingerprint 0EBFCD88

add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"

apt-get update
apt-get install -y docker-ce

# install docker compose
COMPOSE_RELEASE=$(curl -Ls -o /dev/null -w '%{url_effective}' https://github.com/docker/compose/releases/latest | sed -e 's/tag/download/')
curl -fSL $COMPOSE_RELEASE/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# fetch this repo
mkdir -p /data
git clone https://github.com/rolandcrosby/wp-civi-docker.git /data/build

# start the docker compose service
systemctl enable docker-compose docker-compose-reload.timer
systemctl start docker-compose
systemctl start docker-compose-reload.timer