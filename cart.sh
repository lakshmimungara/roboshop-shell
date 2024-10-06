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


dnf module disable nodejs -y &>>$LOGFILE

VALIDATE $? "disable nodejs"

dnf module enable nodejs:20 -y &>>$LOGFILE

VALIDATE $? "enable nodejs"

dnf install nodejs -y &>>$LOGFILE

VALIDATE $? "Installing NodeJS"

#once the user is created, if you run this script 2nd time
# this command will defnitely fail
# IMPROVEMENT: first check the user already exist or not, if not exist then create
useradd roboshop &>>$LOGFILE

#write a condition to check directory already exist or not
mkdir /app &>>$LOGFILE

curl -L -o /tmp/cart.zip https://roboshop-artifacts.s3.amazonaws.com/cart-v3.zip &>>$LOGFILE

VALIDATE $? "downloading cart artifact"

cd /app &>>$LOGFILE

VALIDATE $? "Moving into app directory"

unzip /tmp/cart.zip &>>$LOGFILE

VALIDATE $? "unzipping cart"

npm install &>>$LOGFILE

VALIDATE $? "Installing dependencies"

# give full path of cart.service because we are inside /app
cp /home/ec2-user/roboshop_shell/cart.service /etc/systemd/system/cart.service &>>$LOGFILE

VALIDATE $? "copying cart.service"

systemctl daemon-reload &>>$LOGFILE

VALIDATE $? "daemon reload"

systemctl enable cart &>>$LOGFILE

VALIDATE $? "Enabling cart"

systemctl start cart &>>$LOGFILE

VALIDATE $? "Starting cart"