FROM centos:7


RUN [ -n "$ADMIN_PASSWORD" ] \
  && yum update -y \
  && yum install -y openldap-servers openldap-clients \
  && yum clean all

COPY conf/DB_CONFIG /var/lib/ldap/DB_CONFIG

RUN chown ldap. /var/lib/ldap/DB_CONFIG \
  && slappasswd -s $ADMIN_PASSWORD

#how to use entrypoint?

