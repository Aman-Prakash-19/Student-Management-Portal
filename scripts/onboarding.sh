#!/bin/bash

# File paths
STUDENT_FILE="../data/students.csv"
TRAINER_FILE="../data/trainers.csv"
USERS_FILE="../data/users.csv"

# Google Form Link
GOOGLE_FORM_LINK="https://forms.gle/d19Y8Dvw9fXwbTAb8"

# Define color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[0;33m'
RESET='\033[0m'

# Define box styling
BORDER="==============================="

# Define courses with total and available seats
declare -A total_seats
declare -A available_seats

total_seats=(
    ["Software Development"]=10
    ["Data"]=8
    ["Cloud"]=6
    ["SRE & DevOps"]=5
    ["Banking and Financial Operations"]=4
    ["Product & Project Management"]=3
    ["Enterprise Technology"]=7
    ["Cyber & Networking"]=5
    ["Professional Skills"]=10
)

# Initialize available seats
for course in "${!total_seats[@]}"; do
    available_seats[$course]=${total_seats[$course]}
done

# Function to validate email
validate_email() {
    local email=$1
    [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$ ]]
}

# Function to check if email already exists in a file
is_duplicate_email() {
    local email=$1
    local file=$2
    grep -q "^.*,$email,.*$" "$file" 2>/dev/null
}

# Function to validate GitHub ID
validate_github() {
    local github=$1
    [[ "$github" =~ ^[a-zA-Z0-9_-]+$ ]]
}

# Function to update users.csv when a new user is onboarded
update_users_file() {
    local name=$1
    local email=$2
    local role=$3
    if ! grep -q "^$email," "$USERS_FILE"; then
        echo "$email,$role" >> "$USERS_FILE"
    fi
}

# Function to display a progress animation
show_progress() {
    local delay=0.1
    local spin='-\|/'
    for i in {1..10}; do
        echo -ne "\r${YELLOW}Processing ${spin:i%4:1}...${RESET}   "
        sleep "$delay"
    done
    echo -ne "\r${GREEN}✔ Done!          ${RESET}      \n"
}

# Function to trim input
trim_input() {
    echo "$1" | awk '{$1=$1};1'
}

# Function to normalize course name (case-insensitive matching)
normalize_course() {
    local input="$1"
    for course in "${!total_seats[@]}"; do
        if [[ "${course,,}" == "${input,,}" ]]; then
            echo "$course"
            return 0
        fi
    done
    return 1
}

# Student Onboarding
student_onboarding() {
    clear
    echo -e "${CYAN}$BORDER\n       Student Onboarding       \n$BORDER${RESET}"

    # Reset variables
    name=""
    email=""
    github=""
    course=""

    while [[ -z "$name" ]]; do
        read -p "Enter Student Name: " name
        name=$(trim_input "$name")
    done

    while [[ -z "$email" ]] || ! validate_email "$email" || is_duplicate_email "$email" "$STUDENT_FILE"; do
        read -p "Enter Email: " email
        email=$(trim_input "$email")
        if is_duplicate_email "$email" "$STUDENT_FILE"; then
            echo -e "${RED}Email already exists. Please enter a different email.${RESET}"
            email=""
        elif ! validate_email "$email"; then
            echo -e "${RED}Invalid email format. Try again.${RESET}"
        fi
    done

    while [[ -z "$github" ]] || ! validate_github "$github"; do
        read -p "Enter GitHub ID: " github
        github=$(trim_input "$github")
        if ! validate_github "$github"; then
            echo -e "${RED}Invalid GitHub ID. Use only letters, numbers, hyphens, or underscores.${RESET}"
        fi
    done

    while true; do
        echo -e "${CYAN}Available Courses:${RESET}"
        for course in "${!total_seats[@]}"; do
            echo -e "${YELLOW}$course${RESET} - Total Seats: ${GREEN}${total_seats[$course]}${RESET}, Available Seats: ${GREEN}${available_seats[$course]}${RESET}"
        done

        read -p "Enter the course name: " course
        course=$(trim_input "$course")
        normalized_course=$(normalize_course "$course")

        if [[ -n "$normalized_course" && ${available_seats[$normalized_course]} -gt 0 ]]; then
            echo -e "${GREEN}✔ You have selected: $normalized_course${RESET}"
            ((available_seats[$normalized_course]--))
            break
        else
            echo -e "${RED}Invalid selection or no seats available. Please choose another course.${RESET}"
        fi
    done

    echo -e "\n📤 ${CYAN}Please upload your resume and college documents using the Google Form below:${RESET}"
    echo -e "🔗 ${YELLOW}$GOOGLE_FORM_LINK${RESET}\n"

    read -p "Press Enter after you have uploaded your files..."

    # Show progress indicator
    show_progress

    echo "$name,$email,$github,$normalized_course" >> "$STUDENT_FILE"
    update_users_file "$name" "$email" "student"
    echo -e "${GREEN}✔ Student onboarded successfully!${RESET}"
}

# Trainer Onboarding
trainer_onboarding() {
    clear
    echo -e "${CYAN}$BORDER\n       Trainer Onboarding       \n$BORDER${RESET}"

    # Reset variables
    name=""
    email=""
    github=""
    course=""

    while [[ -z "$name" ]]; do
        read -p "Enter Trainer Name: " name
        name=$(trim_input "$name")
    done

    while [[ -z "$email" ]] || ! validate_email "$email" || is_duplicate_email "$email" "$TRAINER_FILE"; do
        read -p "Enter Email: " email
        email=$(trim_input "$email")
        if is_duplicate_email "$email" "$TRAINER_FILE"; then
            echo -e "${RED}Email already exists. Please enter a different email.${RESET}"
            email=""
        elif ! validate_email "$email"; then
            echo -e "${RED}Invalid email format. Try again.${RESET}"
        fi
    done

    while [[ -z "$github" ]] || ! validate_github "$github"; do
        read -p "Enter GitHub ID: " github
        github=$(trim_input "$github")
        if ! validate_github "$github"; then
            echo -e "${RED}Invalid GitHub ID.${RESET}"
        fi
    done

    while [[ -z "$course" ]]; do
        read -p "Enter Assigned Course: " course
        course=$(trim_input "$course")
    done

    local domain="mthree.com"
    local mthree_email="$(echo "$name" | tr ' ' '.')@$domain"

    # Show progress indicator
    show_progress

    echo "$name,$email,$github,$mthree_email,$course" >> "$TRAINER_FILE"
    update_users_file "$name" "$email" "trainer"
    echo -e "${GREEN}✔ Trainer onboarded successfully!${RESET}"
    echo -e "📧 Assigned Mthree Email: ${YELLOW}$mthree_email${RESET}"
}

# Main Menu
while true; do
    clear
    echo -e "${BLUE}$BORDER\n          ONBOARDING  \n$BORDER${RESET}"
    echo -e "${CYAN}1. Student Onboarding${RESET}"
    echo -e "${CYAN}2. Trainer Onboarding${RESET}"
    echo -e "${CYAN}3. Exit${RESET}"

    read -p "Enter your choice: " choice

    case $choice in
        1) student_onboarding ;;
        2) trainer_onboarding ;;
        3) echo -e "${YELLOW}Exiting...${RESET}" ; exit 0 ;;
        *) echo -e "${RED}Invalid option! Try again.${RESET}" ;;
    esac
    read -p "Press Enter to continue..."
done

