# Dockerized CiviCRM on WordPress

Problem I'm trying to solve: I want to run CiviCRM on WordPress on a virtual machine somewhere, on a domain I already own.

Solution so far: Get a free-tier EC2 VM, deploy everything into Docker containers, do as little on the host as possible besides data storage.

What's in this repo:

- `docker-compose.yml`: Docker Compose file to run MariaDB, WordPress, and CiviCRM; data is stored in `/data`
- `docker-compose.override.yml`: Overrides for local development on my Mac (don't bind to port 80, use Docker volumes instead of a local folder for persistence)
- `secrets.sample.env`: copy this to `secrets.env` and populate with your MySQL root password
- `wordpress-civicrm`: Dockerfile and entrypoint script based on the Docker Library [wordpress:4.9.7-php7.1-apache][wpdocker] image.

How I've been running this so far:

- create a new hosted zone in AWS Route53 and point my domain's DNS to it
- create an elastic IP for my virtual machine
- create an A record in Route53 pointing the domain I want to use to the elastic IP
- start an Ubuntu 16.04 LTS VM in AWS EC2 and assign it the elastic IP
- expose port 80 in the EC2 settings
- SSH to the new VM and [install Docker CE][dockerinstall] and `docker-compose`
- copy this repo to the VM and run `docker-compose up`

todo:
- automatically start docker-compose at startup (systemd service)
- actually finish configuring civicrm (mail/SES, cron, etc.)
- figure out SSL (let's encrypt)
- automatically send/rotate log files
- automatically back up data and files
- configure apache correctly (ServerName)
  - maybe configure this via a docker env variable?
- automatically install wordpress and civicrm? or push a config file?

[wpdocker]: https://github.com/docker-library/wordpress/blob/b7198b18d92c016411c4bc3cdb31711065305605/php7.1/apache/Dockerfile
[dockerinstall]: https://docs.docker.com/install/linux/docker-ce/ubuntu/