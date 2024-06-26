#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=salon --tuples-only -c"
echo -e "\n~~~~~ MY SALON ~~~~~\n"

MAIN_MENU(){
   if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
AVAILABLE_SERVICES=$($PSQL "SELECT service_id,name FROM services")
 echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR NAME BAR SIZE
    do
    echo "$SERVICE_ID) $NAME"
    done
 read SERVICE_ID_SELECTED
    # if input is not a number
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
    # send to main menu
    MAIN_MENU "That is not a valid service number."
    else
    SERVICE_AVAILABILITY=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      if [[ -z $SERVICE_AVAILABILITY ]]
    then
    #send to main menu
    MAIN_MENU "I could not find that service. What would you like today?"
    else
    SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
     echo -e "\nWhat's your phone number?"
     read CUSTOMER_PHONE
     CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE' ")
     if [[ -z $CUSTOMER_NAME ]]
    then
    echo -e "\nI don't have a record for that phone number, what's your name?"
    read CUSTOMER_NAME
    #insert new customer
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME') ")
    fi
     CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE' ")
     CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE' ")
     echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
     read SERVICE_TIME
     INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID,$SERVICE_ID_SELECTED,'$SERVICE_TIME')") 
      echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
    fi
    fi
}
MAIN_MENU "Welcome to My Salon, how can I help you?" 
