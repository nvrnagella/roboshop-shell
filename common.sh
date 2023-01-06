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