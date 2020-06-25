FROM centos:7

COPY conf/DB_CONFIG /var/lib/ldap/DB_CONFIG

RUN yum update -y \
  && yum install -y openldap-clients openldap-servers \
  && yum clean all \
  && chown ldap. /var/lib/ldap/DB_CONFIG


#LDAP Database Files
VOLUME /var/lib/ldap

#LDAP Config Files
VOLUME /etc/openldap/slap.d

#Standard Port
EXPOSE 389/tcp
#EXPOSE 389/udp
#LDAPS
EXPOSE 636/tcp

CMD SLAPD_URLS="ldap:/// ldapi:///" \
  && SLAPD_OPTIONS= \
  && source /etc/sysconfig/slapd \
  && /usr/libexec/openldap/check-config.sh \
  && /usr/sbin/slapd -u ldap -d 0 -h "${SLAPD_URLS}" $SLAPD_OPTIONS
