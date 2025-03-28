#!/bin/bash

# Course Assignment Script with Role-Based Access

students_file="//home/ec2-user/Student-Management-Portal/data/students.csv"
courses_file="//home/ec2-user/Student-Management-Portal/data/courses.csv"
trainers_file="//home/ec2-user/Student-Management-Portal/data/trainers.csv"
users_file="//home/ec2-user/Student-Management-Portal/data/users.csv"

# Colours
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
CYAN='\e[36m'
RESET='\e[0m'

# Function to get user role
get_user_role()
{
	local email=$1
	role=$(grep "^$email," $users_file | cut -d',' -f2)
	echo "$role"
}

# Function to display available courses
display_courses()
{
	echo -e "${CYAN}Available Courses:${RESET}"
	awk -F',' '{print NR ". " $1 " (Seats: " $2 ")"}' $courses_file
}

# Function to add a new course
add_course()
{
    	read -p "Enter Course Name: " course_name
    	read -p "Enter Available Seats: " seats
    	echo "$course_name,$seats" >> $courses_file
    	echo -e "${GREEN}Course added successfully!${RESET}"
}

# Function to remove a course
remove_course()
{
    	display_courses
    	read -p "Choose a course to remove (Enter Number): " course_choice
    	sed -i "${course_choice}d" $courses_file
    	echo -e "${GREEN}Course removed successfully!${RESET}"
}

# Function to update course seat availability
update_course_seats()
{
    	display_courses
    	read -p "Choose a course to update (Enter Number): " course_choice
    	read -p "Enter new seat availability: " new_seats
    	awk -F',' -v num=$course_choice -v seats=$new_seats 'NR==num {$2=seats}1' OFS=',' $courses_file > temp && mv temp $courses_file
	echo -e "${GREEN}Course seat availability updated!${RESET}"
}

# Function to upddate/add course preference for a student
update_course_preference() {
    student_email=$1

    echo -e "\nAvailable Courses:"
    awk -F',' '{print NR, "-", $1}' "$courses_file"

    read -p "Enter the number corresponding to your preferred course: " choice

    # Get course name from choice
    preferred_course=$(awk -F',' -v num="$choice" 'NR == num {print $1}' "$courses_file")

    if [[ -n "$preferred_course" ]]; then
        # Update student CSV with preference
        awk -F',' -v email="$student_email" -v course="$preferred_course" 'BEGIN{OFS=","} 
            $2 == email {$5 = course}1' "$students_file" > temp && mv temp "$students_file"

        echo -e "${GREEN}Your course preference has been updated to $preferred_course!${RESET}"
    else
        echo -e "${RED}Invalid choice. Please try again.${RESET}"
    fi
}

# Function to display all students and their details
view_all_students()
{
	echo -e "${CYAN}All Students and Assigned Courses:${RESET}"
	column -s, -t $students_file
}

# Function to display all trainers and their details
view_all_trainers()
{
	echo -e "${CYAN}All Trainers and Assigned Courses:${RESET}"
	column -s, -t $trainers_file
}

# Function to view students assigned to a trainer
view_assigned_students() 
{
	local trainer_email=$user_email
	echo -e "${CYAN}Students Assigned to You:${RESET}"
	awk -F',' -v trainer_email="$trainer_email" 'NR==FNR {if ($2==trainer_email) courses[$5]; next} $4 in courses {print $0}' $trainers_file $students_file
}

# Function to assign a student to a course
assign_student()
{
	read -p "Enter Student Email: " student_email
	display_courses
	read -p "Choose a course (Enter Number): " course_choice

	course_name=$(awk -F',' -v num=$course_choice 'NR==num {print $1}' $courses_file)
	seats=$(awk -F',' -v num=$course_choice 'NR==num {print $2}' $courses_file)

	if [[ "$seats" -gt 0 ]]; then
		sed -i "/$student_email/c\\$(grep "^.*,$student_email,.*" $students_file | awk -F',' -v c="$course_name" 'BEGIN{OFS=","} {$4=c; print}')" $students_file
		awk -F',' -v num=$course_choice 'NR==num {$2=$2-1}1' OFS=',' $courses_file > temp && mv temp $courses_file
		echo -e "${GREEN}Student assigned to $course_name successfully!${RESET}"
	else
		echo -e "${YELLOW}No seats available for $course_name. Assigning automatically...${RESET}"
		auto_assign_student $student_email
	fi
}

# Function to auto-assign students if seats are full
auto_assign_student() {
    student_email=$1
    preferred_course=$(awk -F',' -v email="$student_email" '$2 == email {print $5}' "$students_file")

    if [[ -n "$preferred_course" ]]; then
        seats_available=$(awk -F',' -v c="$preferred_course" '$1 == c {print $2}' "$courses_file")

        if [[ "$seats_available" -gt 0 ]]; then
            # Assign student to their preferred course
            sed -i "/$student_email/c\\$(grep "^.*,$student_email,.*" $students_file | awk -F',' -v c="$preferred_course" 'BEGIN{OFS=","} {$4=c; print}')" $students_file

            # Update course seats
            awk -F',' -v c="$preferred_course" 'BEGIN{OFS=","} {if ($1==c) $2=$2-1}1' "$courses_file" > temp && mv temp "$courses_file"

            echo -e "${GREEN}Student auto-assigned to $preferred_course!${RESET}"
        else
            echo -e "${RED}Preferred course is full. Manual intervention needed.${RESET}"
        fi
    else
        echo -e "${RED}No preference set. Assign manually.${RESET}"
    fi
}

# Assign trainers to courses
assign_trainers() {
	echo -e "${CYAN}Assigning trainers to courses...${RESET}"
	while IFS=',' read -r course_name _; do
		trainer_email=$(shuf -n 1 $trainers_file | cut -d',' -f2)
        	sed -i "/$trainer_email/c\\$(grep "^.*,$trainer_email,.*" $trainers_file | awk -F',' -v c="$course_name" 'BEGIN{OFS=","} {$5=c; print}')" $trainers_file
	done < $courses_file
	echo -e "${GREEN}Trainers assigned successfully.${RESET}"
}

# Infinite loop for login and menu selection
while true; 
do
	# Get User Email to distinguish roles
	echo -e "${CYAN}Enter your email: ${RESET}"
	read user_email
	user_role=$(get_user_role "$user_email")

	while true;
	do
		if [[ "$user_role" == "admin" ]]; then
			echo -e "${YELLOW}--------Admin Menu--------${RESET}"
			echo -e "${YELLOW}--------------------------${RESET}"
			echo -e "${CYAN}1.${RESET} Assign Student to Course"
			echo -e "${CYAN}2.${RESET} Auto-Assign Student"
			echo -e "${CYAN}3.${RESET} Assign Trainers to Courses"
			echo -e "${CYAN}4.${RESET} View All Students"
			echo -e "${CYAN}5.${RESET} View All Trainers"
			echo -e "${CYAN}6.${RESET} Add Course"
            		echo -e "${CYAN}7.${RESET} Remove Course"
            		echo -e "${CYAN}8.${RESET} Update Course Seats"
			echo -e "${CYAN}9.${RESET} Logout"
			echo -e "${CYAN}10.${RESET} Back to Main Menu"
			read -p "Choose an option: " choice
			case $choice in
				1) assign_student;;
				2) read -p "Enter Student Email: " student_email; auto_assign_student $student_email;;
				3) assign_trainers;;
				4) view_all_students;;
				5) view_all_trainers;;
				6) add_course;;
                		7) remove_course;;
                		8) update_course_seats;;
				9) break;;
				10) break 2;;
				*) echo -e "${RED}Invalid option.${RESET}";;
			esac
		elif [[ "$user_role" == "trainer" ]]; then
			echo -e "${YELLOW}-------Trainer Menu-------${RESET}"
			echo -e "${YELLOW}--------------------------${RESET}"
			echo -e "${CYAN}1.${RESET} View Assigned Courses"
			echo -e "${CYAN}2.${RESET} View Assigned Students"
			echo -e "${CYAN}3.${RESET} Logout"
			echo -e "${CYAN}4.${RESET} Back to Main Menu"
			read -p "Choose an option: " choice
			case $choice in
                		1) grep "$user_email" $trainers_file | awk -F',' '{print "Assigned Course: "$5}';;
				2) view_assigned_students;;
                		3) break;;
                		4) break 2;;
                		*) echo -e "${RED}Invalid option.${RESET}";;
            		esac
        	elif [[ "$user_role" == "student" ]]; then
            		echo -e "${YELLOW}-------Student Menu-------${RESET}"
			echo -e "${YELLOW}--------------------------${RESET}"
            		echo -e "${CYAN}1.${RESET} View Assigned Course"
	      		echo -e "${CYAN}2.${RESET} Add/Update Your Course Preference"
            		echo -e "${CYAN}3.${RESET} Logout"
            		echo -e "${CYAN}4.${RESET} Back to Main Menu"
            		read -p "Choose an option: " choice
            		case $choice in
                		1) grep "$user_email" $students_file | awk -F',' '{print "Assigned Course: "$4}';;
                		2) update_course_preference
		  		2) break;;
                		3) break 2;;
                		*) echo -e "${RED}Invalid option.${RESET}";;
            		esac
        	else
            		echo -e "${RED}Access Denied: Unknown Role${RESET}"
            		break
        	fi
    	done
done
