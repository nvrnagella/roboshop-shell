source  common.sh

print_head "setup redis repo"
yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>>${LOG}
status_check

print_head "enable Redis 6.2 dnf module"
dnf module enable redis:remi-6.2 -y &>>${LOG}
status_check

print_head "installing redis "
yum install redis -y &>>${LOG}
status_check

print_head "updating redis listening IP"
sed -i -e 's/127.0.0.1/0.0.0.0/' /etc/redis.conf &>>${LOG}
status_check

print_head "enabling redis "
systemctl enable redis &>>${LOG}
status_check

print_head "restarting redis"
systemctl restart redis &>>${LOG}
status_check