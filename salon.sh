#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~ MY SALON ~~~~\n"
echo -e "\nWelcome, what can we do for you today?\n"

MAIN_MENU(){
    if [[ $1 ]]
    then
    echo -e "\n$1"
    fi
   # present service options
 SERVICES=$($PSQL "SELECT service_id, name FROM services")
    echo "$SERVICES" | while read SERVICE_ID BAR NAME
    do       
      echo "$SERVICE_ID) $NAME"
    done
    read SERVICE_ID_SELECTED
    SERVICE_CHOICE=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    # if option doesn't exist
    if [[ -z $SERVICE_CHOICE ]]
    then
  MAIN_MENU "\nThat option doesn't exist, please choose from the provided list!\n"
    else
    echo -e "\nWhat's your phone number?\n"
    read CUSTOMER_PHONE
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  # If phone number doesn't exist
    if [[ -z $CUSTOMER_ID ]]
    then
    echo -e "\nSeems like this is your first time here, what's your name?\n"
    read CUSTOMER_NAME 
  # insert new customer into customers
  NEW_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')") 
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    echo -e "\nWhat time would you like to come in?\n"
    read SERVICE_TIME
  # insert appointment
  NEW_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', $SERVICE_CHOICE, '$SERVICE_TIME')") 
    echo -e "\nI have put you down for a$NAME at $SERVICE_TIME, $CUSTOMER_NAME.\n"
  # customer already exists
    else
  RETURNING_CUSTOMER=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    echo -e "\nWelcome back$RETURNING_CUSTOMER!, what time would you like to come in?\n"
    read SERVICE_TIME
  # insert appoitment
    echo "$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES('$CUSTOMER_ID', $SERVICE_CHOICE, '$SERVICE_TIME')")"
    echo -e "\nI have put you down for a$NAME at $SERVICE_TIME,$RETURNING_CUSTOMER.\n"
    fi
   fi
}
MAIN_MENU
