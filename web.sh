#!/bin/bash

ID=$(id -u)

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script started and executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){

    if [ $1 -ne 0 ]
    then
        echo -e "$2...$R FAILED $N"
    else
        echo -e "$2...$G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1
else
    echo -e "$G You are the root user $N"
fi

dnf install nginx -y

VALIDATE $? "installing nginx"

systemctl enable nginx

VALIDATE $? "enabling nginx"

systemctl start nginx

VALIDATE $? "starting nginx"

rm -rf /usr/share/nginx/html/*

VALIDATE $? "removed default website"

curl -o /tmp/web.zip https://roboshop-builds.s3.amazonaws.com/web.zip

VALIDATE $? "downloaded web application"

cd /usr/share/nginx/html

VALIDATE $? "moving nginx html directory"

unzip -o /tmp/web.zip

VALIDATE $? "unzipping web"

cp /home/centos/Roboshop-shellscript/roboshop.conf /etc/nginx/default.d/roboshop.conf 

VALIDATE $? "copied roboshop reverse proxy config"

systemctl restart nginx 

VALIDATE $? "Restarted nginx"