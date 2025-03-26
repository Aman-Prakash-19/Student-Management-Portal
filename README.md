# Student-Management-Portal

## Project Overvieww

A CLI-based system designed to streamline student and trainer management for mthree. The portal facilitates onboarding, course assignments, attendance tracking, and trainer management.


## User Roles:
- Admin has access to change and view everything.
- Trainer can manage course details, view student details, manage deadlines
- Student can enroll in course, view syllabus, view attendance.


## Onboarding

- Student Onboarding
  - Collect student details:
    - Emails
    - Name
    - gitHub ID
    - Resume (PDF,word)
    - College Docs
  - Course selection:
    - Display available seats
    - Allow selection based on availability
    - Auto-assign if availability is low
- Trainer Onboarding
  - Create Accounts
  - Gnerate Mthree email ids
  - Add details
    - Emails
    - Name
    - gitHub ID


## Assign course and trainer

### Students:
- Assign students to courses based on:
  - Choice & availability
  - Auto-assignment if needed
- Provide course syllabus
- assign a trainer to the students

### Trainers:
- Assign course curriculums to trainers
- Provide course content (via email?)
- Allow trainers to:
  - Modify course details
  - Move deadlines
  - View current student details
  - Access alumni information


## Attendance management
- Mark attendance
  - Only for the current day
- View attendence
  - Percentage
  - Comparison with other students
  - Send a notification when the attendance drops below a certain criteria
