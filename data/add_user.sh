#!/bin/bash
TASKD=../../src/taskd
ROOT=$PWD/root
ROOT_CA=../../pki/ca.cert.pem

#read username and org from comandline
read -p "Username?`echo $'\n> '`" USER
read -p "Org?`echo $'\n> '`" ORG

#create org if nessersary
$TASKD add --data $ROOT org $ORG >&2>/dev/null

#create user
$TASKD add --data $ROOT user --quiet $ORG $USER 1> user.key

#find configs
$TASKD config --data $ROOT |grep  '^server ' >server

(cd ../../pki && ./generate.client $ORG$USER)
cd $PWD
cp ../../pki/$ORG$USER.cert.pem $USER.cert
#cat `$TASKD config --data $ROOT |grep  '^client.cert '| sed -e 's/client.cert//'`>client.cert

#if user-config already exists remove it
FILENAME=data/$USER.$ORG.taskdconfig
rm -rf $FILENAME

#Write to user-conf file
echo "username: "$USER>>$FILENAME
echo "org: "$ORG>>$FILENAME
cat user.key| sed 's/New user key:/user key:/g'>>$FILENAME
echo "server: "`cat server| sed 's/^server//g'|sed 's/^[ \t]*//'`>>$FILENAME
echo "Client.cert:">>$FILENAME
cat $USER.cert>>$FILENAME
echo "ca.cert:">>$FILENAME
cat $ROOT_CA>>$FILENAME

#remove temp-files
rm -rf user.key server $USER.cert
rm -f ../../pki/$ORG$USER.cert.pem

echo 
echo "You're ready!"
echo "Copy the "$FILENAME" to your device and don't forget to start the server:"
echo "./run"
