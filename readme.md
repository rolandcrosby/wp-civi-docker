# Dockerized CiviCRM on WordPress

Problem I'm trying to solve: I want to run CiviCRM on WordPress on a virtual machine somewhere, on a domain I already own.

Solution so far: Get a free-tier EC2 VM, deploy everything into Docker containers, do as little on the host as possible besides data storage.

What's in this repo:

- `docker-compose.yml`: Docker Compose file to run MariaDB, WordPress, and CiviCRM
  - also runs an Nginx reverse proxy that automatically handles SSL termination via Let's Encrypt
  - assumes that data is stored in `/data` and this repo is at `/data/build`
  - update the wordpress section with the domain(s) and admin email you're using
- `docker-compose.override.yml`: Overrides for local development on my Mac (don't bind to port 80, use Docker volumes instead of a local folder for persistence)
- `secrets.sample.env`: copy this to `secrets.env` and populate with a MySQL root password
- `setup_host.sh`: commands to set up docker, docker compose, and these services on a debian host
- `systemd`: systemd unit files to run docker-compose at startup
- `nginx.tmpl`: config file needed by the config generator for the encryption proxy
- `wordpress-civicrm`: Dockerfile and entrypoint script based on the Docker Library [wordpress:4.9.7-php7.1-apache][wpdocker] image.

## How I've been running this so far

### get a machine on the internet

- create a new hosted zone in AWS Route53 and point my subdomain's DNS to it
- create an elastic IP for my virtual machine
- create an A record in Route53 pointing the domain I want to use to the elastic IP
- start an Ubuntu 16.04 LTS VM in AWS EC2 and assign it the elastic IP
  - actually let's use debian - commands now target debian
- expose port 80 and 443 in the EC2 settings

Lightsail appears to provide a nice interface to do all of the above. (update: lightsail works great for vm/networking/storage; i'm just updating the DNS manually in Hover in production)

### get the machine ready to run mysql/wordpress/civicrm/letsencrypt

- SSH to the new VM and [install Docker CE][dockerinstall] and [docker-compose][dockercompose]
- copy this repo to `/data/build` on the VM
- if you're using existing data volumes for mariadb or wordpress, put it in `/data/mysql` or `/data/wordpress`
- set up a `secrets.env` file in `/data/build`
- create a docker network
- edit the wordpress section of `docker-compose.yml` with the domain and admin email address you're using

### turn everything on

- `docker-compose up --force-recreate -d`
- install the systemd files to /etc/systemd/system, make them run at startup, and start them

note that this will now automatically take care of SSL via Let's Encrypt (implementation is heavily based on [this tutorial][letsencrypt])

commands to execute all of the above are in `setup_host.sh` which is not something you should run

### post install

- go to the website in a browser
- run the WordPress and CiviCRM installers
- set up SMTP settings for CiviCRM (I'm using AWS Simple Email Service)
  - make sure AWS actually enables outgoing mail from your domain - you'll need to put in a support ticket
  - for now, I hardcoded outgoing email settings in a single-file plugin based on [this][wp-smtp-plugin]
  - civicrm has separate outgoing mail settings that you should also set up


## todo

- get cron working/run civicrm's scheduled tasks sometime
  - set a machine user for civicrm to run tasks
  - cron as that CMS user and as www-data linux user
  - use a timer on the host?
- automatically send/rotate log files
- automatically back up data and files
- configure apache correctly (ServerName)
  - get this from the VIRTUAL_HOST env variable?
  - does this matter?
- automatically install wordpress and civicrm? or push a config file?
- figure out a better way to do secret management
- wordpress caching/best practices
- basic wordpress tweaks - any apache dependencies?
- decide what should be done in docker and what should be split out into wordpress customizations versioned and deployed some other way




[wpdocker]: https://github.com/docker-library/wordpress/blob/b7198b18d92c016411c4bc3cdb31711065305605/php7.1/apache/Dockerfile
[dockerinstall]: https://docs.docker.com/install/linux/docker-ce/ubuntu/
[dockercompose]: https://github.com/docker/compose/releases
[wp-smtp-plugin]: https://gist.github.com/butlerblog/7e4dbafcbc61b15505ee8ca90510f1e7#file-functions-php
[letsencrypt]: https://blog.ssdnodes.com/blog/tutorial-extending-docker-nginx-host-multiple-websites-ssl/