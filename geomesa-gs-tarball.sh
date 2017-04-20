#!/usr/bin/env sh

# Tweak these settings to change version of jars we build the extension tarball from
SCALA_VERSION=2.11
GEOMESA_VERSION=1.3.1
CASSANDRA_VERSION=3.0.10
CASSANDRA_DRIVER_VERSION=3.0.0

mkdir temp
cd temp
curl https://repo.locationtech.org/content/groups/geomesa/org/locationtech/geomesa/geomesa-cassandra-gs-plugin_${SCALA_VERSION}/${GEOMESA_VERSION}/geomesa-cassandra-gs-plugin_${SCALA_VERSION}-${GEOMESA_VERSION}-install.tar.gz  | tar xvz

install_dir=$(cd "`dirname "$0"`"; pwd)

NL=$'\n'
BASE_URL='http://search.maven.org/remotecontent?filepath='

CASSANDRA_VERSION=3.0.10
CASSANDRA_DRIVER_VERSION=3.0.0

# Setup download URLs
declare -a urls=(
"${BASE_URL}org/apache/cassandra/cassandra-all/${CASSANDRA_VERSION}/cassandra-all-${CASSANDRA_VERSION}.jar"
"${BASE_URL}com/datastax/cassandra/cassandra-driver-core/${CASSANDRA_DRIVER_VERSION}/cassandra-driver-core-${CASSANDRA_DRIVER_VERSION}.jar"
"${BASE_URL}com/datastax/cassandra/cassandra-driver-mapping/${CASSANDRA_DRIVER_VERSION}/cassandra-driver-mapping-${CASSANDRA_DRIVER_VERSION}.jar"
"${BASE_URL}io/netty/netty-all/4.0.33.Final/netty-all-4.0.33.Final.jar"
"${BASE_URL}io/dropwizard/metrics/metrics-core/3.1.2/metrics-core-3.1.2.jar"
)

# Download dependencies
for x in "${urls[@]}"; do
fname=$(basename "$x");
echo "fetching ${x}";
wget -O "${install_dir}/${fname}" "$x" || { rm -f "${install_dir}/${fname}"; echo "Error downloading dependency: ${fname}"; \
errorList="${errorList[@]} ${x} ${NL}"; };
done
if [[ -n "${errorList}" ]]; then
echo "Failed to download: ${NL} ${errorList[@]}";
fi

tar cfv ../geomesa-cassandra-gs-plugin-${GEOMESA_VERSION}-${CASSANDRA_VERSION}.tar.gz .
cd ..
rm -fr ${install_dir}
