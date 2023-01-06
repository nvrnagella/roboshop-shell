source common.sh

echo -e "\e[31m configuring nodejs repo \e[0m"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG}
status_check
echo -e "\e[31m installing nodejs \e[0m"
yum install nodejs -y &>>${LOG}
status_check
echo -e "\e[31m add application user \e[0m"
useradd roboshop &>>${LOG}
status_check
mkdir -p /app &>>${LOG}
status_check
echo -e "\e[31m downloading app content \e[0m"
curl -L -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip &>>${LOG}
status_check
echo -e "\e[31m cleaned old app content \e[0m"
rm -rf /app/* &>>${LOG}
status_check
cd /app
echo -e "\e[31m extracting app data \e[0m"
unzip /tmp/catalogue.zip &>>${LOG}
status_check
cd /app
echo -e "\e[31m installing npm \e[0m"
npm install &>>${LOG}
status_check
echo -e "\e[31m configuring catalogue service \e[0m"
cp ${script_location}/files/catalogue.service /etc/systemd/system/catalogue.service &>>${LOG}
status_check
echo -e "\e[31m reloading daemon \e[0m"
systemctl daemon-reload &>>${LOG}
status_check
echo -e "\e[31m enabling catalogue \e[0m"
systemctl enable catalogue &>>${LOG}
status_check
echo -e "\e[31m starting catalogue \e[0m"
systemctl start catalogue &>>${LOG}
status_check
echo -e "\e[31m copying mongo repo \e[0m"
cp ${script_location}/files/mongodb.repo /etc/yum.repos.d/mongo.repo &>>${LOG}
status_check
echo -e "\e[31m installing mongo client \e[0m"
yum install mongodb-org-shell -y &>>${LOG}
status_check
echo -e "\e[31m loading database schema \e[0m"
mongo --host mongodb-dev.nvrnagella.online </app/schema/catalogue.js &>>${LOG}
status_check
