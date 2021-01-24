FROM php:7.4-fpm-alpine

RUN apk add --no-cache \
    multirun \
    # docker-entrypoint.sh
    bash gettext openldap-clients patch \
    # Web server
    nginx phpldapadmin \
    # OpenLDAP
    openldap openldap-back-mdb \
    # ldap.h for PHP 'ldap' package
    openldap-dev \
    # bindtextdomain() for PHP 'gettext'
    musl-libintl \
 && docker-php-ext-install -j "$(nproc)" gettext ldap \
 && rm -rf /var/cache/apk/*


WORKDIR /docker-entrypoint.d/
COPY ./docker/ /


# OpenLDAP
ENV DOMAIN_NAME="local"
ENV LDAPCONF=/etc/openldap/slapd.conf
ENV LDAP_CONF_DIR=/etc/openldap/slapd.d
ENV LDAP_INIT_DIR=/var/lib/openldap/openldap-init
ENV LDAP_LOG_LEVEL="1024"
ENV LDAP_ROOT_PASSWORD="changeme"
ENV LDAP_ROOT_USERNAME="root"

RUN mkdir -p "$LDAP_CONF_DIR" \
 && mv /var/lib/openldap/openldap-data/DB_CONFIG.example /docker-entrypoint.d/openldap/DB_CONFIG \
 && rm -f "$LDAPCONF"

VOLUME /var/lib/openldap/openldap-data
VOLUME /var/lib/openldap/openldap-init

EXPOSE 389/tcp


# Nginx, PHP, phpLDAPadmin
RUN rm -rf /etc/nginx/conf.d/default.conf /usr/local/etc/php-fpm.d/*

EXPOSE 80/udp


# Entrypoint
ENV DISABLE_PHPLDAPADMIN=""

WORKDIR /

CMD ["/docker-entrypoint.sh"]
