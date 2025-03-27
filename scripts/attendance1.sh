#!/bin/bash

#touch the files before if not initiated here

attendance_db="../data/attendance_db.csv"
students_db="../data/students.csv"
notifications_db="../data/notifications.csv"
batch_report="../data/batch_report.csv"


mark_attendance() {
    while true; do
        read -p "Enter student name (or type 'exit' to stop): " student_name
        if [[ "$student_name" == "exit" ]]; then
            break
        fi
        read -p "Enter course name: " course_name
        date=$(date +%Y-%m-%d)  
        read -p "Present? (yes/no): " status

        echo "$student_name,$course_name,$date,$status" >> "$attendance_db"
        echo "Attendance recorded successfully!"
    done
}


view_attendance() {
    read -p "Enter student name: " student_name
    echo "Attendance record for $student_name:"
    awk -F, -v name="$student_name" 'tolower($1) == tolower(name) {print}' "$attendance_db"
}


calculate_attendance() {
    student_name=$1
    total_days=$(awk -F, -v name="$student_name" 'tolower($1) == tolower(name) {count++} END {print count}' "$attendance_db")
    present_days=$(awk -F, -v name="$student_name" 'tolower($1) == tolower(name) && tolower($4) ~ /^yes$/ {count++} END {print count}' "$attendance_db")

    # if default values is empty
    total_days=${total_days:-0}
    present_days=${present_days:-0}

    if [ "$total_days" -eq 0 ]; then
        echo 0
        return
    fi

    attendance_percentage=$(( (present_days * 100) / total_days ))
    echo "$attendance_percentage"
}


batch_attendance() {
    echo "Name,Course,Email,GitHub,Attendance%" > "$batch_report"
    
    while IFS=, read -r name email github course; do
        attendance_percentage=$(calculate_attendance "$name")

        # Treating percentage as an integer
        attendance_percentage=${attendance_percentage:-0}

        
        
        echo "$name,$course,$email,$github,$attendance_percentage%" >> "$batch_report"
    done < <(tail -n +2 "$students_db")

    echo "Batch attendance report generated: $batch_report"
}


attendance_menu() {
    while true; do
        echo "Attendance Management"
        echo "1. Mark Attendance"
        echo "2. View Attendance"
        echo "3. Calculate Attendance Percentage"
        echo "4. Generate Batch Attendance Report"
        echo "5. Exit"
        
        read -p "Enter your choice: " choice
        case $choice in
            1) mark_attendance ;;
            2) view_attendance ;;
            3) read -p "Enter student name: " student_name; calculate_attendance "$student_name" ;;
            4) batch_attendance ;;
            5) exit ;;
            *) echo "Invalid choice, please try again." ;;
        esac
    done
}

attendance_menu

