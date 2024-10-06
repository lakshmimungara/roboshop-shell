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

dnf install maven -y &>>$LOGFILE
VALIDATE $? "Installing Maven"

useradd roboshop &>>$LOGFILE

mkdir /app &>>$LOGFILE

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip  &>>$LOGFILE
VALIDATE $? "Downloading shipping artifact"

cd /app &>>$LOGFILE
VALIDATE $? "Moving to app directory"
 
unzip /tmp/shipping.zip &>>$LOGFILE
VALIDATE $? "Unzipping shipping"

cd /app &>>$LOGFILE
VALIDATE $? "Moving to app directory"

mvn clean package &>>$LOGFILE
VALIDATE $? "packaging shipping app"

mv target/shipping-1.0.jar shipping.jar &>>$LOGFILE
VALIDATE $? "renaming shipping jar"

cp /home/ec2-user/roboshop_shell/shipping.service /etc/systemd/system/shipping.service &>>$LOGFILE
VALIDATE $? "copying shipping service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "daemon-reload"

systemctl enable shipping  &>>$LOGFILE
VALIDATE $? "Enabling shipping"

systemctl start shipping &>>$LOGFILE
VALIDATE $? "Starting shipping"


dnf install mysql -y  &>>$LOGFILE
VALIDATE $? "Installing MySQL client"

mysql -h mysql.daws81s.fun -uroot -pRoboShop@1 < /app/db/shipping.sql  &>>$LOGFILE
VALIDATE $? "Loaded countries and cities info"

# mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pRoboShop@1 < /app/db/app-user.sql &>>$LOGFILE

# mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -pRoboShop@1 < /app/db/master-data.sql &>>$LOGFILE
systemctl restart shipping &>>$LOGFILE
VALIDATE $? "Restarting shipping"