#!/bin/bash

LOGS_FOLDER="/var/log/expense"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
mkdir -p $LOGS_FOLDER

USERID=$(id -u)
#echo "user ID is: $USERID"
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"

CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then    
        echo -e "$R Please run this script with root privileges $N" | tee -a $LOG_FILE
        exit 1
    fi 
}
VALIDATE(){
    if [ $1 -ne 0 ]
    then 
        echo -e "$2 is $R failed $N" | tee -a $LOG_FILE
        exit 1 
    else 
        echo -e "$2 is $G success $N" | tee -a $LOG_FILE
    fi
}

echo "script started executing at: $(date)" | tee -a $LOG_FILE

CHECK_ROOT

dnf install python3 gcc python3-devel -y &>>$LOGFILE
VALIDATE $? "Installing python"

useradd roboshop &>>$LOGFILE

mkdir /app  &>>$LOGFILE

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip  &>>$LOGFILE
VALIDATE $? "Downloading artifact"

cd /app &>>$LOGFILE
VALIDATE $? "Moving to app directory"

unzip /tmp/payment.zip &>>$LOGFILE
VALIDATE $? "unzip artifact"

pip3 install -r requirements.txt &>>$LOGFILE
VALIDATE $? "Installing dependencies"

cp /home/ec2-user/roboshop_shell/payment.service /etc/systemd/system/payment.service &>>$LOGFILE
VALIDATE $? "copying payment service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "daemon-reload"

systemctl enable payment  &>>$LOGFILE
VALIDATE $? "enable payment"

systemctl start payment &>>$LOGFILE
VALIDATE $? "starting payment"