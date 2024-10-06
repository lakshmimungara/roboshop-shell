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

dnf module disable nginx -y &>>$LOGFILE
VALIDATE $? "disabling Nginx"

dnf module enable nginx:1.24 -y &>>$LOGFILE
VALIDATE $? "enabling Nginx:1.24"

dnf install nginx -y &>>$LOGFILE
VALIDATE $? "Installing Nginx"

systemctl enable nginx &>>$LOGFILE
VALIDATE $? "Enabling Nginx"

systemctl start nginx &>>$LOGFILE
VALIDATE $? "Starting Nginx"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
VALIDATE $? "Removing default index html files"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip &>>$LOGFILE
VALIDATE $? "Downloading web artifact"

cd /usr/share/nginx/html &>>$LOGFILE
VALIDATE $? "Moving to default HTML directory"

unzip /tmp/frontend.zip &>>$LOGFILE
VALIDATE $? "unzipping frontend.zip"

cp /home/ec2-user/roboshop_shell/nginx.conf /etc/nginx/nginx.conf  &>>$LOGFILE
VALIDATE $? "copying roboshop config"

systemctl restart nginx  &>>$LOGFILE
VALIDATE $? "Restarting Nginx"