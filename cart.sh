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

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "Disabling current Nodejs" 

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "Enabling current Nodejs:18" 

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "Installing Nodejs:18" 

id roboshop    #to avoid error while executing second time in creation of user
if [ $? -ne 0 ]
then
    useradd roboshop
    VALIDATE $? "roboshop user creation"
else
    echo -e "roboshop user already exist $Y SKIPPING $N"
fi

#useradd roboshop &>> $LOGFILE

VALIDATE $? "creating roboshop user" 

mkdir -p /app &>> $LOGFILE  #it will check and if dir avaialbe it will not create and if not available it will create

VALIDATE $? "creating app directory" 

curl -L -o /tmp/cart.zip https://roboshop-builds.s3.amazonaws.com/cart.zip &>> $LOGFILE

VALIDATE $? "Downloading cart application" 

cd /app &>> $LOGFILE

unzip -o /tmp/cart.zip &>> $LOGFILE #here -o is to overwrite if we run second time

VALIDATE $? "unzipping cart" 

npm install &>> $LOGFILE

VALIDATE $? "installing dependencies" 

cp /home/centos/Roboshop-shellscript/cart.service /etc/systemd/system/cart.service &>> $LOGFILE

VALIDATE $? "copying cart service file" 

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "Cart daemon reload" 

systemctl enable cart &>> $LOGFILE

VALIDATE $? "Enabling Cart" 

systemctl start cart &>> $LOGFILE

VALIDATE $? "starting Cart" 

