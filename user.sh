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

curl -L -o /tmp/user.zip https://roboshop-builds.s3.amazonaws.com/user.zip

VALIDATE $? "downloading user application" 

cd /app 

unzip -o /tmp/user.zip &>> $LOGFILE 

VALIDATE $? "unzipping user" 

npm install &>> $LOGFILE 

VALIDATE $? "installing dependencies" 

cp /home/centos/Roboshop-shellscript/user.service /etc/systemd/system/user.service

VALIDATE $? "copying user service file"

systemctl daemon-reload &>> $LOGFILE 

VALIDATE $? "user daemon reload"

systemctl enable user &>> $LOGFILE

VALIDATE $? "enabling user"

systemctl start user &>> $LOGFILE

VALIDATE $? "starting user"

cp /home/centos/Roboshop-shellscript/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE 

VALIDATE $? "copying mongodb repo"

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "Installing mongodb client"

mongo --host 172.31.44.166 </app/schema/user.js &>> $LOGFILE

VALIDATE $? "Loading user data into mongodb"




