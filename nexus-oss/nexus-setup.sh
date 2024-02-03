#!/bin/bash
set -euxo pipefail
nexus_domain=$(hostname --fqdn)
config_authentication='nexus'
apt-get install -y openjdk-8-jre-headless
apt-get install -y gnupg

# add the nexus user.
groupadd --system nexus
adduser \
    --system \
    --disabled-login \
    --no-create-home \
    --gecos '' \
    --ingroup nexus \
    --home /opt/nexus \
    nexus
install -d -o root -g nexus -m 750 /opt/nexus

# download and install nexus.
pushd /opt/nexus
nexus_version=3.58.1-02
nexus_home=/opt/nexus/nexus-$nexus_version
nexus_tarball=nexus-$nexus_version-unix.tar.gz
nexus_download_url=https://download.sonatype.com/nexus/3/$nexus_tarball
nexus_download_sha1=99d0cb82471f2b39a6060369e77868dd1462b243
wget -q $nexus_download_url
if [ "$(sha1sum $nexus_tarball | awk '{print $1}')" != "$nexus_download_sha1" ]; then
    echo "downloaded $nexus_download_url failed the checksum verification"
    exit 1
fi
tar xf $nexus_tarball # NB this creates the $nexus_home (e.g. nexus-3.58.1-02) and sonatype-work directories.
rm $nexus_tarball
install -d -o nexus -g nexus -m 700 .java # java preferences are saved here (the default java.util.prefs.userRoot preference).
install -d -o nexus -g nexus -m 700 sonatype-work/nexus3/etc
chown -R nexus:nexus sonatype-work
grep -v -E '\s*##.*' $nexus_home/etc/nexus-default.properties >sonatype-work/nexus3/etc/nexus.properties
sed -i -E 's,(application-host=).+,\1127.0.0.1,g' sonatype-work/nexus3/etc/nexus.properties
sed -i -E 's,nexus-pro-,nexus-oss-,g' sonatype-work/nexus3/etc/nexus.properties
cat >>sonatype-work/nexus3/etc/nexus.properties <<'EOF'
# disable the wizard.
nexus.onboarding.enabled=false

# disable generating a random password for the admin user.
nexus.security.randompassword=false

# allow the use of groovy scripts because we use them to configure nexus.
# see https://issues.sonatype.org/browse/NEXUS-23205
# see Scripting Nexus Repository Manager 3 at https://support.sonatype.com/hc/en-us/articles/360045220393
nexus.scripts.allowCreation=true
EOF
diff -u $nexus_home/etc/nexus-default.properties sonatype-work/nexus3/etc/nexus.properties || true
popd

if [ "$config_authentication" = 'ldap' ]; then
echo '192.168.56.2 dc.example.com' >>/etc/hosts
openssl x509 -inform der -in /vagrant/shared/ExampleEnterpriseRootCA.der -out /usr/local/share/ca-certificates/ExampleEnterpriseRootCA.crt
update-ca-certificates -v
fi