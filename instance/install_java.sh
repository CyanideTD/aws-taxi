#!/bin/bash

VERSION=8

JAVA_RPM_URL=http://download.oracle.com/otn-pub/java/jdk/8u131-b11/d54c1d3a095b4ff2b6607d096fa80163/jdk-8u131-linux-x64.rpm;

set -e
set -x

wget --no-cookies --header "Cookie:http://www.oracle.com; oraclelicense=accept-securebackup-cookie" $JAVA_RPM_URL -O jdk-$VERSION-linux-x64.rpm

rpm -Uvh jdk-$VERSION-linux-x64.rpm

alternatives --install /usr/bin/java java /usr/java/latest/bin/java 2

rm -rf jdk-$VERSION-linux-x64.rpm

