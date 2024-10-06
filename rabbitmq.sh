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

cp /home/ec2-user/roboshop_shell/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo &>>$LOGFILE

dnf install rabbitmq-server -y  &>>$LOGFILE

systemctl enable rabbitmq-server  &>>$LOGFILE

systemctl start rabbitmq-server  &>>$LOGFILE

rabbitmqctl add_user roboshop roboshop123 &>>$LOGFILE

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOGFILE