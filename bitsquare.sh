#!/bin/sh
echo "#################################################"
echo "# Bitsquare auto install on Raspberry PI.       #"
echo "# +metabit (June 11 2016)                       #"
echo "# https://github.com/metabit                    #"
echo "# Donations: 1MetabitMKKGcYZy8YieDHenjjoMxHNAgW #"
echo "#################################################"
echo

# Bounty: https://forum.bitsquare.io/t/1-btc-bounty-for-bitsquare-on-raspberry-pi/209"

# Prerequisites - Raspbian installation:
#   1. Get Raspbian Jessie image from https://www.raspberrypi.org/downloads/raspbian/
#   2. Follow https://www.raspberrypi.org/documentation/installation/installing-images/README.md

# Sanity check - raspbery pi hardware?
uname -m | grep -v arm > /dev/null && echo "This is not a Raspberry PI. Aborting ..." && exit 1

# Let's work at home
cd

# Check if it an update or a first install
if [ -d ~/bitsquare ]; then
echo "Running update for bitsquare ..."
echo "Updating bitsquare code"
cd bitsquare
git pull
mvn clean package -DskipTests
echo "Update done."
else
echo "Installing bitsquare ..."
echo "Update and upgrade repository"
sudo apt-get -y update
sudo apt-get -y upgrade
echo "Install mvn"
sudo apt-get -y install maven

echo "Get oracle JDK"
wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jdk/8u92-b14/jdk-8u92-linux-arm32-vfp-hflt.tar.gz

echo "Install oracle JDK"
sudo tar zxvf jdk-8u92-linux-arm32-vfp-hflt.tar.gz -C /opt
sudo update-alternatives --install /usr/bin/javac javac /opt/jdk1.8.0_92/bin/javac 3200
sudo update-alternatives --install /usr/bin/java java /opt/jdk1.8.0_92/bin/java 3200

echo "Enable unlimited Strength for cryptographic keys"
wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" http://download.oracle.com/otn-pub/java/jce/8/jce_policy-8.zip
unzip jce_policy-8.zip
sudo cp UnlimitedJCEPolicyJDK8/US_export_policy.jar /opt/jdk1.8.0_92/jre/lib/security/US_export_policy.jar
sudo cp UnlimitedJCEPolicyJDK8/local_policy.jar /opt/jdk1.8.0_92/jre/lib/security/local_policy.jar

echo "Getting openjfx overlay"
wget http://chriswhocodes.com/downloads/openjfx-8u60-sdk-overlay-linux-armv6hf.zip
sudo unzip openjfx-8u60-sdk-overlay-linux-armv6hf.zip -d /opt/jdk1.8.0_92

echo "Install bitcoinj"
git clone -b FixBloomFilters https://github.com/bitsquare/bitcoinj.git
cd bitcoinj
mvn clean install -DskipTests -Dmaven.javadoc.skip=true
cd -

echo "Getting bitsquare code"
git clone https://github.com/bitsquare/bitsquare.git
cd bitsquare
echo "Build bitsquare"
mvn clean package -DskipTests
cd -

echo "Copy the BountyCastle provider jar file"
sudo cp /home/pi/.m2/repository/org/bouncycastle/bcprov-jdk15on/1.53/bcprov-jdk15on-1.53.jar /opt/jdk1.8.0_92/jre/lib/ext/bcprov-jdk15on-1.53.jar

echo "Update java.security file to add BouncyCastleProvider"
sudo chmod 666 /opt/jdk1.8.0_92/jre/lib/security/java.security
sudo echo "security.provider.11=org.bouncycastle.jce.provider.BouncyCastleProvider" >> /opt/jdk1.8.0_92/jre/lib/security/java.security
sudo chmod 644 /opt/jdk1.8.0_92/jre/lib/security/java.security

fi

# Done
echo
echo "Usage: java -jar ~/bitsquare/gui/target/shaded.jar"

