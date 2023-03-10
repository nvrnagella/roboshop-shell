script_location=$(pwd)
LOG=/tmp/roboshop.log
status_check() {
  if [ $? -eq 0 ]
  then
    echo -e "\e[1;32m SUCCESS \e[0m"
  else
    echo -e "\e[1;31m FAILURE \e[0m"
    echo "refer log file for more information LOG - ${LOG}"
  exit
  fi
}

print_head() {
  echo -e "\e[1m $1 \e[0m"
}

APP_PREREQ (){

  print_head "add application user"
  id roboshop &>>${LOG}
  if [ $? -ne 0 ]; then
    useradd roboshop &>>${LOG}
  fi
  status_check

  mkdir -p /app &>>${LOG}

  print_head "downloading app contents"
  curl -L -o /tmp/${component}.zip https://roboshop-artifacts.s3.amazonaws.com/${component}.zip &>>${LOG}
  status_check

  print_head "clean old app contents"
  rm -rf /app/* &>>${LOG}
  status_check

  cd /app
  print_head "extracting app data"
  unzip /tmp/${component}.zip &>>${LOG}
  status_check
}

SYSTEMD_SETUP (){

  print_head "configuring ${component} service"
  cp ${script_location}/files/${component}.service /etc/systemd/system/${component}.service &>>${LOG}
  status_check

  print_head "reloading daemon"
  systemctl daemon-reload &>>${LOG}
  status_check

  print_head "enabling ${component}"
  systemctl enable ${component} &>>${LOG}
  status_check

  print_head "starting ${component}"
  systemctl start ${component} &>>${LOG}
  status_check
}

LOAD_SCHEMA (){

  if [ ${schema_load} == "true" ]; then
    if [ ${schema_type} == "mongo" ]; then
      print_head "copying mongo repo"
      cp ${script_location}/files/mongodb.repo /etc/yum.repos.d/mongo.repo &>>${LOG}
      status_check

      print_head "installing mongo client"
      yum install mongodb-org-shell -y &>>${LOG}
      status_check

      print_head "loading database schema"
      mongo --host mongodb-dev.nvrnagella.online </app/schema/${component}.js &>>${LOG}
      status_check
    fi
    if [ ${schema_type} == "mysql" ]; then

      print_head "installing mysql client"
      yum install mysql -y &>>${LOG}
      status_check

      print_head "loading database schema"
      mysql -h mysql-dev.nvrnagella.online -uroot -p${root_mysql_password} < /app/schema/shipping.sql  &>>${LOG}
      status_check
    fi
  fi

}

NODEJS (){
  print_head "configuring nodejs application"
  curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>>${LOG}
  status_check

  print_head "installing nodejs"
  yum install nodejs -y &>>${LOG}
  status_check

  APP_PREREQ

  cd /app
  print_head "installing nodejs dependencies"
  npm install &>>${LOG}
  status_check

  SYSTEMD_SETUP


}

MAVEN (){

  print_head "installing MAVEN"
  yum install maven -y &>>${LOG}
  status_check

  APP_PREREQ

  print_head "build a package"
  mvn clean package &>>${LOG}
  status_check

  print_head "copy app file to app location"
  mv target/${component}-1.0.jar ${component}.jar
  status_check

  SYSTEMD_SETUP

  LOAD_SCHEMA
}