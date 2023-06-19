# ldap

## Install LDAP
* set secrets in `secret.yml`

* kubectl apply -f namespace.yml -f secret.yml -f claim.yml

To initialize the ldap server run
* kubectl apply -f setup.yml

After Job Completion run the Server
* kubectl apply -f ldap.yml
