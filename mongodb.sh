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


cp /home/ec2-user/roboshop_shell/mongo.repo /etc/yum.repos.d/mongo.repo &>> $LOGFILE
VALIDATE $? "Copied MongoDB repo into yum.repos.d"

dnf install mongodb-org -y  &>> $LOGFILE
VALIDATE $? "Installation of MongoDB"

systemctl enable mongod &>> $LOGFILE
VALIDATE $? "Enabling MongoDB"

systemctl start mongod &>> $LOGFILE
VALIDATE $? "Starting MongoDB"

sed -i 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>> $LOGFILE
VALIDATE $? "Edited MongoDB conf"

systemctl restart mongod &>> $LOGFILE
VALIDATE $? "Restarting MonogoDB"