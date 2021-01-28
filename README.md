[![QA Build Status](https://github.com/danie1k/homelab-ldap/workflows/Lint/badge.svg)](https://github.com/danie1k/homelab-ldap/actions?query=workflow%3ALint)
[![Docker Hub Build Status](https://img.shields.io/docker/cloud/build/danie1k/homelab-ldap)](https://hub.docker.com/repository/docker/danie1k/homelab-ldap)
[![Docker Image Version](https://img.shields.io/docker/v/danie1k/homelab-ldap)](https://hub.docker.com/repository/docker/danie1k/homelab-ldap)
[![MIT License](https://img.shields.io/github/license/danie1k/homelab-ldap)](https://github.com/danie1k/homelab-ldap/blob/master/LICENSE)

# OpenLDAP server with built-in phpLDAPadmin

This container is far from perfect and set only the minimum needed settings (especially when it comes to [OpenLDAP] server),
but does its job and can be a great base for building much more complex solution.

Based on:
- https://github.com/docker-library/php/blob/master/7.4/alpine3.13/fpm/Dockerfile
- https://github.com/nextcloud/docker/blob/master/20.0/apache/Dockerfile

## Included services
- [nginx]
- [OpenLDAP]
- [phpLDAPadmin]


## Environment Variables you should set

- `DOMAIN_NAME` -- Domain name for LDAP suffix (i.e.: `example.com`)
- `DOMAIN_NAME_DC` -- [DomainComponent] for LDAP database (single word, no dots, i.e.: `example`)
- `LDAP_ROOT_USERNAME` -- root/admin user name for [OpenLDAP]
- `LDAP_ROOT_PASSWORD` -- password for [OpenLDAP] root/admin user \*

\* Plain-text password is possible, but not recommended! To generate password hash,
   use the [`slappasswd`] command and set this environment variable to value returned by [`slappasswd`].  
   If you don't want to install this command, use:

   ```shell
   $ docker run --rm -it alpine:latest sh -c 'apk add openldap 2>/dev/null; slappasswd'
   ```

*nginx, php & phpLDAPadmin can be disabled altogether by setting `DISABLE_PHPLDAPADMIN="1"` environment variable.*


## Exposed Ports

- `80` (tcp) -- [phpLDAPadmin] via [nginx]
- `389` (tcp) -- [OpenLDAP]


## Volumes

- `/var/lib/openldap/openldap-data` -- [OpenLDAP] database
- `/var/lib/openldap/openldap-init` -- custom [LDIF] config files for [OpenLDAP]


## Useful commands

- Test LDAP root login:
  ```shell
  ldapsearch -D 'cn=root,dc=example,dc=com' -W '(objectclass=*)' -b 'dc=example,dc=com'
  ```


## Useful links

### LDAP/OpenLDAP (`slapd`) documentation

- https://wiki.archlinux.org/index.php/OpenLDAP
- https://linux.die.net/man/5/slapd.conf
- https://ldapwiki.com/wiki/
- [log levels](ttp://www.openldap.org/doc/admin24/slapdconf2.html)

### phpLDAPadmin documentation

- https://wiki.archlinux.org/index.php/PhpLDAPadmin
- http://phpldapadmin.sourceforge.net/wiki/index.php/LDAP_server_definitions


## License 

MIT


[DomainComponent]: https://ldapwiki.com/wiki/DomainComponent
[LDIF]: https://www.openldap.org/software//man.cgi?query=LDIF&sektion=5&apropos=0&manpath=OpenLDAP+2.4-Release
[OpenLDAP]: https://www.openldap.org/
[nginx]: https://www.nginx.com/
[phpLDAPadmin]: http://phpldapadmin.sourceforge.net/
[`slappasswd`]: https://command-not-found.com/slappasswd
