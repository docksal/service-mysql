FROM mysql:5.7.24

# MySQL settings
COPY default.cnf /etc/mysql/conf.d/10-default.cnf

# Add support for init script run under root user at startup
# Scripts should be placed in the /docker-entrypoint.d/ folder
COPY docker-entrypoint.d.sh /usr/local/bin/docker-entrypoint.d.sh
RUN set -xe; \
	sed -i '/\$(id -u)/ r /usr/local/bin/docker-entrypoint.d.sh' /usr/local/bin/docker-entrypoint.sh
# Init scripts run under root
COPY docker-entrypoint.d /docker-entrypoint.d
COPY healthcheck.sh /opt/healthcheck.sh

# Health check script
HEALTHCHECK --interval=5s --timeout=1s --retries=12 CMD ["/opt/healthcheck.sh"]
