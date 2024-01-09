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

dnf module disable mysql -y &>> $LOGFILE

VALIDATE $? "Disable current mysql version"

cp mysql.repo /etc/yum.repos.d/mysql.repo &>> $LOGFILE

VALIDATE $? "copied mysql repo"

dnf install mysql-community-server -y &>> $LOGFILE

VALIDATE $? "installing mysql server"

systemctl enable mysqld &>> $LOGFILE

VALIDATE $? "enabling mysql server"

systemctl start mysqld &>> $LOGFILE

VALIDATE $? "starting mysql server"

mysql_secure_installation --set-root-pass RoboShop@1 &>> $LOGFILE

VALIDATE $? "setting mysql root password"









