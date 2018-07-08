# Dockerized CiviCRM on WordPress

Problem I'm trying to solve: I want to run CiviCRM on WordPress on a virtual machine somewhere, on a domain I already own.

Solution so far: Get a free-tier EC2 VM, deploy everything into Docker containers, do as little on the host as possible besides data storage.

What's in this repo:

- `docker-compose.yml`: Docker Compose file to run MariaDB, WordPress, and CiviCRM; data is stored in `/data`
- `docker-compose.override.yml`: Overrides for local development on my Mac (don't bind to port 80, use Docker volumes instead of a local folder for persistence)
- `secrets.sample.env`: copy this to `secrets.env` and populate with your MySQL root password
- `wordpress-civicrm`: Dockerfile and entrypoint script based on the Docker Library [wordpress:4.9.7-php7.1-apache][wpdocker] image.
- `systemd`: systemd unit files for docker-compose

How I've been running this so far:

- create a new hosted zone in AWS Route53 and point my domain's DNS to it
- create an elastic IP for my virtual machine
- create an A record in Route53 pointing the domain I want to use to the elastic IP
- start an Ubuntu 16.04 LTS VM in AWS EC2 and assign it the elastic IP
- expose port 80 in the EC2 settings
- SSH to the new VM and [install Docker CE][dockerinstall] and [docker-compose][dockercompose]
- copy this repo to `/data/build` on the VM
- install the systemd files to /etc/systemd/system, make them run at startup, and start them:
    ```
    systemctl enable docker-compose docker-compose-reload
    systemctl start docker-compose
    systemctl start docker-compose-reload
    ```
- go to the website in a browser
- run the WordPress and CiviCRM installers
- set up SMTP settings for CiviCRM (I'm using AWS Simple Email Service)

todo:
- get cron working
  - set up a machine user for civicrm by default
  - cron as that CMS user and as www-data linux user
- figure out how to handle wordpress SMTP configuration
- figure out SSL (let's encrypt)
- automatically send/rotate log files
- automatically back up data and files
- configure apache correctly (ServerName)
  - maybe configure this via a docker env variable?
- automatically install wordpress and civicrm? or push a config file?
- figure out a better way to do secret management
- wordpress caching/best practices
- basic wordpress tweaks - any apache dependencies?
- decide what should be done in docker and what should be split out into wordpress customizations versioned and deployed some other way

[wpdocker]: https://github.com/docker-library/wordpress/blob/b7198b18d92c016411c4bc3cdb31711065305605/php7.1/apache/Dockerfile
[dockerinstall]: https://docs.docker.com/install/linux/docker-ce/ubuntu/
[dockercompose]: https://github.com/docker/compose/releases