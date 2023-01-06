source common.sh

print_head "configuring nodejs application"
curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG}
status_check
print_head "installing nodejs"
yum install nodejs -y &>>${LOG}
status_check
print_head "add application user"
useradd roboshop &>>${LOG}
status_check
mkdir -p /app &>>${LOG}
status_check
print_head "downloading app contents"
curl -L -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue.zip &>>${LOG}
status_check
print_head "clean old app contents"
rm -rf /app/* &>>${LOG}
status_check
cd /app
print_head "extracting app data"
unzip /tmp/catalogue.zip &>>${LOG}
status_check
cd /app
print_head "installing npm"
npm install &>>${LOG}
status_check
print_head "configuring catalogue service"
cp ${script_location}/files/catalogue.service /etc/systemd/system/catalogue.service &>>${LOG}
status_check
print_head "reloading daemon"
systemctl daemon-reload &>>${LOG}
status_check
print_head "enabling catalogue"
systemctl enable catalogue &>>${LOG}
status_check
print_head "starting catalogue"
systemctl start catalogue &>>${LOG}
status_check
print_head "copying mongo repo"
cp ${script_location}/files/mongodb.repo /etc/yum.repos.d/mongo.repo &>>${LOG}
status_check
print_head "installing mongo client"
yum install mongodb-org-shell -y &>>${LOG}
status_check
print_head "loading database schema"
mongo --host mongodb-dev.nvrnagella.online </app/schema/catalogue.js &>>${LOG}
status_check
