#!/usr/bin/env bash
set -eu

init_nginx() {
  local _config_file
  _config_file='/etc/nginx/conf.d/default.conf'

  if [[ -f "${_config_file}" ]]; then
    return
  fi

  echo "[INIT] Configuring nginx"

  echo "[INIT]     /etc/nginx/nginx.conf"
  cp -f /docker-entrypoint.d/nginx/nginx.conf /etc/nginx/nginx.conf

  echo "[INIT]     ${_config_file}"
  cp /docker-entrypoint.d/nginx/default.conf "${_config_file}"
}

init_openldap() {
  local _openldap_db
  _openldap_db="$(ls -A /var/lib/openldap/openldap-data)"

  # shellcheck disable=SC2154
  if [[ -n "${_openldap_db}" ]] && [[ -f "${LDAPCONF}" ]]; then
    return
  fi

  echo "[INIT] Configuring OpenLDAP"

  if [[ ! -f "${LDAPCONF}" ]]; then
    echo "[INIT]     Creating ${LDAPCONF}"
    envsubst <"/docker-entrypoint.d/openldap/slapd.template.conf" >"${LDAPCONF}"
  fi

  if [[ -z "${_openldap_db}" ]]; then
    echo "[INIT]     OpenLDAP database not found, initializing"

    trap 'rm -rf /var/lib/openldap/openldap-data/*' EXIT

    echo "[INIT]     Creating DB_CONFIG"
    cp /docker-entrypoint.d/openldap/DB_CONFIG /var/lib/openldap/openldap-data/DB_CONFIG

    echo "[INIT]     Initializing empty OpenLDAP database"
    # shellcheck disable=SC2154
    slapadd -f "${LDAPCONF}" -F "${LDAP_CONF_DIR}" -l /dev/null

    echo "[INIT]     Generating initial LDIF files"
    for ldif_file in /docker-entrypoint.d/openldap/*.template.ldif; do
      _target="$(basename "${ldif_file}" | sed 's/\.template//')"
      echo "[INIT]      + ${_target}"
      # shellcheck disable=SC2154
      envsubst <"${ldif_file}" >"${LDAP_INIT_DIR}/${_target}"
    done

    echo "[INIT]     Applying LDIF files"
    for ldif_file in "${LDAP_INIT_DIR}/"*".ldif"; do
      echo "[INIT]      + $(basename "${ldif_file}")"
      slapadd -f "${LDAPCONF}" -F "${LDAP_CONF_DIR}" -l "${ldif_file}"
    done

    echo "[INIT]     Verifying OpenLDAP server configuration"
    slaptest -f "${LDAPCONF}" -F "${LDAP_CONF_DIR}" -d 256

    trap - EXIT
  fi

}

init_php_fpm() {
  local _config_file
  _config_file='/usr/local/etc/php-fpm.d/docker.conf'

  if [[ -f "${_config_file}" ]]; then
    return
  fi

  echo "[INIT] Configuring PHP-FPM"

  echo "[INIT]     ${_config_file}"
  cp /docker-entrypoint.d/php/docker.conf "${_config_file}"
}

init_phpldapadmin() {
  local _config_file
  _config_file='/etc/phpldapadmin/config.php'

  if [[ -f "${_config_file}" ]]; then
    return
  fi

  echo "[INIT] Configuring phpLDAPadmin"

  trap 'rm -f "${_config_file}"' EXIT

  echo "[INIT]     ${_config_file}"
  # shellcheck disable=SC2016
  export servers='$servers'
  envsubst <"/docker-entrypoint.d/phpldapadmin/config.template.php" >"${_config_file}"
  unset servers

  echo "[INIT]     Fix the issue with ampersand in passwords"
  # https://github.com/leenooks/phpLDAPadmin/issues/104
  patch /usr/share/webapps/phpldapadmin/htdocs/login.php /docker-entrypoint.d/phpldapadmin/login.patch

  trap - EXIT
}


# shellcheck disable=SC2154
readonly LDAP_DN="dc=${DOMAIN_NAME//\./,dc=}"
# shellcheck disable=SC2154
readonly LDAP_ROOTDN="cn=${LDAP_ROOT_USERNAME},${LDAP_DN}"
# shellcheck disable=SC2154
readonly LDAP_ROOTPW="${LDAP_ROOT_PASSWORD}"
export LDAP_DN
export LDAP_ROOTDN
export LDAP_ROOTPW

init_nginx
init_openldap
init_php_fpm
init_phpldapadmin


_COMMAND=(
  "slapd -f \"${LDAPCONF}\" -F \"${LDAP_CONF_DIR}\" -u root -g root -d ${LDAP_LOG_LEVEL}"
)

if [[ -z "${DISABLE_PHPLDAPADMIN:-""}" ]]; then
  _COMMAND+=("nginx -g 'daemon off;'")
  _COMMAND+=('php-fpm')
fi

exec multirun "${_COMMAND[@]}"
