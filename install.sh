#!/bin/bash

echo -n "Installing UniAPR Maven Plugin..."
mvn install:install-file -Dfile=jars/uniapr-plugin-1.0-SNAPSHOT.jar -DgroupId=org.uniapr -DartifactId=uniapr-plugin -Dversion=1.0-SNAPSHOT -Dpackaging=jar > /dev/null 2>&1
echo " DONE"
