CREATE VIEW webinar_financial_report AS
SELECT Webinar.id, CAST(SUM(Webinar.price) / 100.0 AS DECIMAL(10, 2)) AS income
FROM Webinar
         INNER JOIN StudentWebinar on Webinar.id = StudentWebinar.webinar_id
GROUP BY Webinar.id;
GO

CREATE VIEW course_financial_report AS
SELECT Course.id,
       CAST((dbo.course_full_income(Course.id) + dbo.course_advance_income(Course.id)) /
            100.0 AS DECIMAL(10, 2)) AS income
FROM Course;
GO

CREATE VIEW studies_financial_report AS
SELECT Studies.id,
       CAST(((dbo.studies_registration_income(Studies.id) + SUM(dbo.semester_income(Semester.id))) /
             100.0) AS DECIMAL(10, 2)) AS income
FROM Studies
         INNER JOIN Semester ON Studies.id = Semester.studies_id
GROUP BY Studies.id;
GO

CREATE VIEW students_who_purchased_meeting AS
SELECT Student.id, Student.first_name, Student.last_name, COUNT(*) AS purchased_meetings
FROM StudentMeeting
         INNER JOIN Student ON StudentMeeting.student_id = Student.id
GROUP BY Student.id, Student.first_name, Student.last_name;
GO

CREATE VIEW debtor_list AS
SELECT DISTINCT TOP 100 PERCENT Student.id, Student.first_name, Student.last_name
FROM Student
         INNER JOIN StudentCourse ON Student.id = StudentCourse.student_id AND StudentCourse.full_payment_date IS NULL
ORDER BY Student.id;
GO

CREATE VIEW future_studies_students AS
SELECT TOP 100 PERCENT Studies.id AS studies, Students.id, Students.first_name, Students.last_name
FROM Studies
         CROSS APPLY dbo.students_enrolled_on_studies(Studies.id) AS students
WHERE dbo.studies_start_date(Studies.id) > CURRENT_TIMESTAMP
ORDER BY Studies.id, Students.id;
GO

CREATE VIEW future_courses_students AS
SELECT TOP 100 PERCENT Course.id AS course, Students.id, Students.first_name, Students.last_name
FROM Course
         CROSS APPLY dbo.students_enrolled_on_course(Course.id) AS Students
WHERE dbo.course_start_date(Course.id) > CURRENT_TIMESTAMP
ORDER BY Course.id, Students.id;
GO

CREATE VIEW future_webinars_students AS
SELECT TOP 100 PERCENT Webinar.id AS webinar, Students.id, Students.first_name, Students.last_name
FROM Webinar
         CROSS APPLY dbo.students_enrolled_on_webinar(Webinar.id) AS Students
WHERE Webinar.datetime > CURRENT_TIMESTAMP
ORDER BY Webinar.id, Students.id;
GO

CREATE VIEW future_meetings_students AS
SELECT TOP 100 PERCENT Meeting.id as meeting, Meeting.type, Students.id, Students.first_name, Students.last_name
FROM Meeting
         CROSS APPLY (SELECT Student.id, Student.first_name, Student.last_name
                      FROM Student
                               INNER JOIN StudentMeeting ON Student.id = StudentMeeting.student_id
                      WHERE StudentMeeting.meeting_id = Meeting.id) AS students
WHERE Meeting.datetime > CURRENT_TIMESTAMP
ORDER BY Meeting.id, Students.id;
GO

CREATE VIEW attendance_on_meetings AS
SELECT TOP 100 PERCENT Meeting.id,
                       (SELECT COUNT(*) FROM dbo.students_enrolled_on_meeting(Meeting.id)) AS enrolled_students,
                       (SELECT COUNT(*) FROM dbo.students_present_on_meeting(Meeting.id))  AS present_students
FROM Meeting
WHERE Meeting.datetime > CURRENT_TIMESTAMP
ORDER BY Meeting.id;
GO
