FROM centos:7

RUN yum update -y \
  && yum install -y openldap-servers openldap-clients \
  && yum clean all

#LDAP Database Files
VOLUME /var/lib/ldap

#LDAP Config Files
VOLUME /etc/openldap/slap.d

EXPOSE 389/tcp
EXPOSE 389/udp

CMD SLAPD_URLS="ldap:/// ldapi:///" \
  && SLAPD_OPTIONS= \
  && source /etc/sysconfig/slapd \
  && /usr/libexec/openldap/check-config.sh \
  && /usr/sbin/slapd -u ldap -d 0 -h "${SLAPD_URLS}" $SLAPD_OPTIONS
