source  common.sh
print_head "configuring mongo repo"
cp ${script_location}/files/mongodb.repo /etc/yum.repos.d/mongo.repo &>>${LOG}
status_check
print_head "installing mongodb "
yum install mongodb-org -y &>>${LOG}
status_check
print_head "updating mongodb listening IP"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/mongod.conf &>>${LOG}
status_check
print_head "enabling mongodb "
systemctl enable mongod &>>${LOG}
status_check
print_head "restarting mongodb"
systemctl restart mongod &>>${LOG}
status_check