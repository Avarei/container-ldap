FROM centos:7

ARG ADMIN_PASSWORD
ARG DOMAIN

ARG CONF_PATH=/ldap/conf
ARG TEMPLATE_PATH=$CONF_PATH/template

RUN [ -n "$ADMIN_PASSWORD" ] \
  && yum update -y \
  && yum install -y openldap-servers openldap-clients \
  && yum clean all \
  && mkdir -p $CONF_PATH $TEMPLATE_PATH

COPY conf/DB_CONFIG /var/lib/ldap/DB_CONFIG
COPY conf/chrootpw.ldif $TEMPLATE_PATH/chrootpw.ldif
COPY conf/chdomain.ldif $TEMPLATE_PATH/chdomain.ldif
COPY conf/basedomain.ldif $TEMPLATE_PATH/basedomain.ldif

RUN chown ldap. /var/lib/ldap/DB_CONFIG \
  && ADMIN_PASSWORD_SHA=$(slappasswd -s $ADMIN_PASSWORD) \
  && DOMAIN_DC="dc=$(echo $DOMAIN | sed -E -e 's/\.(\w+)/,dc=\1/g')" \
  && sed "s/ADMIN_PASSWORD_SHA/$ADMIN_PASSWORD_SHA/g" < $TEMPLATE_PATH/chrootpw.ldif > $CONF_PATH/chrootpw.ldif \
  && sed -i -e "s/ADMIN_PASSWORD_SHA/$ADMIN_PASSWORD_SHA" \
    -e "s/DOMAIN_DC/$DOMAIN_DC/g"
    < $TEMPLATE_PATH/chdomain.ldif \
    > $CONF_PATH/chdomain.ldif \
  && sed -i -e "s/DOMAIN_DC/$DOMAIN_DC/g"
  && SLAPD_URLS="ldap:/// ldapi:///" \
  && SLAPD_OPTIONS= \
  && source /etc/sysconfig/slapd \
  && /usr/libexec/openldap/check-config.sh \
  && /usr/sbin/slapd -u ldap -h "${SLAPD_URLS}" $SLAPD_OPTIONS \
  && ldapadd -Y EXTERNAL -H ldapi:/// -f $CONF_PATH/chrootpw.ldif \
  && ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/cosine.ldif \
  && ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/nis.ldif \
  && ldapadd -Y EXTERNAL -H ldapi:/// -f /etc/openldap/schema/inetorgperson.ldif \
  && ldapmodify -Y EXTERNAL -H ldapi:/// -f $CONF_PATH/chdomain.ldif \
  && sed -E -e 's/\.(\w+)/,dc=\1/g' \
  && ldapadd -x -D cn=Manager,$DOMAIN_DC -W -f basedomain.ldif
#TODO more...
#TODO maybe put this into init script...


#TODO double check if this is true!
#LDAP Database Files
VOLUME /var/lib/ldap

#LDAP Config Files
VOLUME /etc/openldap/slap.d


#TEMP FOR DEBUGGING
ENV ADMIN_PASSWORD=$ADMIN_PASSWORD

EXPOSE 389/tcp
EXPOSE 389/udp

CMD SLAPD_URLS="ldap:/// ldapi:///" \
  && SLAPD_OPTIONS= \
  && source /etc/sysconfig/slapd \
  && /usr/libexec/openldap/check-config.sh \
  && /usr/sbin/slapd -u ldap -d 0 -h "${SLAPD_URLS}" $SLAPD_OPTIONS
