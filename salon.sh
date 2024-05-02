#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ Salon Appointment Scheduler ~~~~~\n"

MAIN_MENU () {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  SERVICES=$($PSQL "SELECT * FROM services ORDER BY service_id;")
  echo -e "\nWhat service would you like to appoint?"
  echo "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED
  case $SERVICE_ID_SELECTED in
    1) CREATE_APPOINTMENT 1 ;;
    2) CREATE_APPOINTMENT 2 ;;
    3) CREATE_APPOINTMENT 3 ;;
    *) MAIN_MENU "Not valid service selected. Please use only the number of service." ;;
  esac
}

CREATE_APPOINTMENT() {
  #get phone number
  echo -e "\nPlease enter your phone number:"
  read CUSTOMER_PHONE
  #find customer_id
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
  #if not found
  if [[ -z $CUSTOMER_ID ]]
  then
    #get customer name
    echo -e "\nPlease enter your name:"
    read CUSTOMER_NAME
    #insert customer
    CUSTOMER_INSERT_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")
    #get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
  fi
  #get time
  echo -e "\nPlease enter appointment time:"
  read SERVICE_TIME
  #insert appointment
  APPOINTMENT_INSERT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $1, '$SERVICE_TIME');")
  #get appointment info
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID;" | sed 's/^ *//')
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$1;" | sed 's/^ *//')
  echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
}

MAIN_MENU