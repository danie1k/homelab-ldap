<?php

$servers = new Datastore();
$servers->newServer('ldap_pla');
$servers->setValue('server', 'name', 'OpenLDAP');
$servers->setValue('server', 'host', '127.0.0.1');
$servers->setValue('server', 'base', ['${LDAP_DN}']);
$servers->setValue('login', 'bind_id', '${LDAP_ROOTDN}');
