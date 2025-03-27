#!/bin/bash

# Main Shell Script to manage the Student Management Portal

# Colors for formatting
RED='\e[31m'
GREEN='\e[32m'
BLUE='\e[34m'
CYAN='\e[36m'
YELLOW='\e[33m'
RESET='\e[0m'

while true;
do
	clear
	echo -e "${CYAN}==================================================${RESET}"
	echo -e "${BLUE}     Welcome to the Student Management Portal     ${RESET}"
	echo -e "${CYAN}==================================================${RESET}"
	echo -e "${YELLOW}1.${RESET} Onboarding"
	echo -e "${YELLOW}2.${RESET} Course Assignment"
	echo -e "${YELLOW}3.${RESET} Attendance Tracking"
	echo -e "${YELLOW}4.${RESET} Exit"
	echo -e "${CYAN}--------------------------------------------------${RESET}"
	read -p "Choose an option: " option

    case $option in
        1)
            ./scripts/onboarding.sh
	    ;;
        2)
            ./scripts/course_assignment.sh
            ;;
        3)
            ./scripts/attendance1.sh
            ;;
        4)
            echo -e "${GREEN}Exiting...${RESET}"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option. Please try again.${RESET}"
            sleep 2
            ;;
    esac
done
