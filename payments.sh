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

dnf install python36 gcc python3-devel -y &>> $LOGFILE

VALIDATE $? "" 

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

curl -L -o /tmp/payment.zip https://roboshop-builds.s3.amazonaws.com/payment.zip

VALIDATE $? "Downloading payment"

cd /app 

unzip -o /tmp/payment.zip

VALIDATE $? "unzipping payment"

pip3.6 install -r requirements.txt

VALIDATE $? "installing dependencies"

cp /home/centos/Roboshop-shellscript/payment.service /etc/systemd/system/payment.service &>> $LOGFILE

VALIDATE $? "copying payment service"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "daemon reload"

systemctl enable payment &>> $LOGFILE

VALIDATE $? "enable payment"

systemctl start payment &>> $LOGFILE

VALIDATE $? "start payment"









