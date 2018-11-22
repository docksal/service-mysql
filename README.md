# Database Docker images for Docksal

Docksal MySQL images are derived from the stock `mysql` images from Docker Hub.  
We include extra settings (see `default.cnf`) and enable user defined overrides via a settings file. 

This image(s) is part of the [Docksal](http://docksal.io) image library.

## Versions

- `mysql-5.5`
- `mysql-5.6`
- `mysql-5.7`, `latest`
- `mysql-8.0`

## Settings overrides

User defined MySQL settings are expected in `/var/www/.docksal/etc/mysql/my.cnf` in the container.

When used with Docksal, this is taken care of for you. Just place your custom settings in `.docksal/etc/mysql/my.cnf` 
in your project's repo.
