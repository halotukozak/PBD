CREATE FUNCTION get_parameter_value(
    @name VARCHAR(50)
)
    RETURNS VARCHAR(50)
AS
BEGIN
    RETURN (SELECT TOP 1 value
            FROM Parameter
            WHERE name LIKE @name
              AND date <= CURRENT_TIMESTAMP
            ORDER BY date DESC);
END;
GO
CREATE FUNCTION is_internship_finished(
    @student_id INT
)
    RETURNS BIT
AS
BEGIN
    DECLARE @result BIT;
    IF EXISTS(SELECT *
              FROM StudentInternship
              WHERE student_id = @student_id
                AND exam_result >= CAST(dbo.get_parameter_value('internship_exam_required_result') AS INT))
        SET @result = 1;
    ELSE
        SET @result = 0;

    RETURN @result;
END;
GO

CREATE FUNCTION was_present_on_meeting(
    @student_id INT,
    @meeting_id INT
)
    RETURNS BIT
AS
BEGIN
    DECLARE @result BIT;
    IF EXISTS(SELECT *
              FROM StudentMeetingAttendance
              WHERE student_id = @student_id
                AND meeting_id = @meeting_id)
        SET @result = 1;
    ELSE
        SET @result = 0;

    RETURN @result;
END;
GO

CREATE FUNCTION get_student_info(
    @student_id INT
)
    RETURNS TABLE
        AS
        RETURN
            (
                SELECT *
                FROM Student
                WHERE id = @student_id
            );
GO

CREATE FUNCTION get_teacher_info(
    @teacher_id INT
)
    RETURNS TABLE
        AS
        RETURN
            (
                SELECT *
                FROM Teacher
                WHERE id = @teacher_id
            );
GO

CREATE FUNCTION get_translator_info(
    @translator_id INT
)
    RETURNS TABLE
        AS
        RETURN
            (
                SELECT *
                FROM Translator
                WHERE id = @translator_id
            );
GO

CREATE FUNCTION get_last_semester(
    @studies_id INT
)
    RETURNS INT
AS
BEGIN
    RETURN (SELECT TOP 1 number
            FROM Semester
            WHERE studies_id = @studies_id
            ORDER BY number DESC);
END;
GO

CREATE FUNCTION is_enrolled_on_studies(
    @student_id INT,
    @studies_id INT
)
    RETURNS BIT
AS
BEGIN
    DECLARE @result BIT;
    IF EXISTS(SELECT *
              FROM StudentStudies
              WHERE student_id = @student_id
                AND studies_id = @studies_id)
        SET @result = 1;
    ELSE
        SET @result = 0;

    RETURN @result;
END;
GO

CREATE FUNCTION get_studies_of_semester(
    @semester_id INT
)
    RETURNS INT
AS
BEGIN
    RETURN (SELECT studies_id
            FROM Semester
            WHERE id = @semester_id);
END;
GO

CREATE FUNCTION get_student_basket(
    @student_id INT
)
    RETURNS INT
AS
BEGIN
    RETURN (SELECT TOP 1 id
            FROM Basket
            WHERE student_id = @student_id
              AND state = 'open'
            ORDER BY create_date DESC);
END;
GO

CREATE FUNCTION get_basket_items(
    @basket_id INT
)
    RETURNS TABLE AS
        RETURN
            (
                SELECT *
                FROM BasketItem
                WHERE basket_id = @basket_id
            );
GO

CREATE FUNCTION studies_start_date(
    @studies_id INT
)
    RETURNS DATE
AS
BEGIN
    RETURN (SELECT TOP 1 start_date
            FROM Semester
            WHERE studies_id = @studies_id
            ORDER BY number);
END;
GO

CREATE FUNCTION course_start_date(
    @course_id INT
)
    RETURNS DATE
AS
BEGIN
    RETURN (SELECT TOP 1 start_date
            FROM Module
            WHERE course_id = @course_id
            ORDER BY start_date);
END;
GO

CREATE FUNCTION get_parameter_history(
    @parameter_name VARCHAR(50)
)
    RETURNS TABLE
        AS
        RETURN
            (
                SELECT TOP 100 PERCENT value, date
                FROM Parameter
                WHERE name = @parameter_name
                ORDER BY date DESC
            );
GO

CREATE FUNCTION course_advance_income(
    @course_id INT
)
    RETURNS INT
AS
BEGIN
    RETURN
        (SELECT ISNULL((SELECT SUM(Course.advance_price)
                        FROM Course
                                 INNER JOIN StudentCourse
                                            ON Course.id = StudentCourse.course_id AND
                                               StudentCourse.full_payment_date IS NULL
                        WHERE Course.id = @course_id
                        GROUP BY Course.id), 0));
END;
GO

CREATE FUNCTION course_full_income(
    @course_id INT
)
    RETURNS INT
AS
BEGIN
    RETURN
        (SELECT ISNULL((SELECT SUM(Course.price)
                        FROM Course
                                 INNER JOIN StudentCourse
                                            ON Course.id = StudentCourse.course_id AND
                                               StudentCourse.full_payment_date IS NOT NULL
                        WHERE Course.id = @course_id
                        GROUP BY Course.id), 0));
END;
GO

CREATE FUNCTION studies_registration_income(
    @studies_id INT
)
    RETURNS INT
AS
BEGIN
    RETURN
        (SELECT ISNULL((SELECT SUM(Studies.registration_price)
                        FROM Studies
                                 INNER JOIN StudentStudies
                                            ON Studies.id = StudentStudies.studies_id
                        WHERE Studies.id = @studies_id
                        GROUP BY Studies.id), 0));
END;
GO

CREATE FUNCTION semester_income(
    @semester_id INT
)
    RETURNS INT
AS
BEGIN
    RETURN
        (SELECT ISNULL((SELECT SUM(Semester.price)
                        FROM Semester
                                 INNER JOIN StudentSemester
                                            ON Semester.id = StudentSemester.semester_id
                        WHERE Semester.id = @semester_id
                        GROUP BY Semester.id), 0));
END;
GO

CREATE FUNCTION students_enrolled_on_studies(
    @studies_id INT
)
    RETURNS TABLE
        AS
        RETURN
            (
                SELECT Student.id, Student.first_name, Student.last_name
                FROM Student
                         INNER JOIN StudentStudies ON Student.id = StudentStudies.student_id
                WHERE StudentStudies.studies_id = @studies_id
            );
GO

CREATE FUNCTION students_enrolled_on_course(
    @course_id INT
)
    RETURNS TABLE
        AS
        RETURN
            (
                SELECT Student.id, Student.first_name, Student.last_name
                FROM Student
                         INNER JOIN StudentCourse ON Student.id = StudentCourse.student_id
                WHERE StudentCourse.course_id = @course_id
            );
GO


CREATE FUNCTION students_enrolled_on_webinar(
    @webinar_id INT
)
    RETURNS TABLE
        AS
        RETURN
            (
                SELECT Student.id, Student.first_name, Student.last_name
                FROM Student
                         INNER JOIN StudentWebinar ON Student.id = StudentWebinar.student_id
                WHERE StudentWebinar.webinar_id = @webinar_id
            );
GO

CREATE FUNCTION students_enrolled_on_semester(
    @semester_id INT
)
    RETURNS TABLE
        AS
        RETURN
            (
                SELECT Student.id, Student.first_name, Student.last_name
                FROM Student
                         INNER JOIN StudentSemester ON Student.id = StudentSemester.student_id
                WHERE StudentSemester.semester_id = @semester_id
            );
GO

CREATE FUNCTION students_enrolled_on_meeting(
    @meeting_id INT
)
    RETURNS TABLE
        AS
        RETURN
            (
                SELECT TOP 100 PERCENT *
                FROM (SELECT Student.id, Student.first_name, Student.last_name
                      FROM Student
                               INNER JOIN StudentMeeting ON Student.id = StudentMeeting.student_id
                      WHERE StudentMeeting.meeting_id = @meeting_id

                      UNION

                      SELECT Student.id, Student.first_name, Student.last_name
                      FROM Student
                               INNER JOIN StudentCourse ON Student.id = StudentCourse.student_id
                               INNER JOIN Course ON Course.id = StudentCourse.course_id
                               INNER JOIN Module ON Module.course_id = Course.id
                               INNER JOIN Meeting ON Meeting.module_id = Module.id
                      WHERE Meeting.id = @meeting_id

                      UNION

                      SELECT Student.id, Student.first_name, Student.last_name
                      FROM Student
                               INNER JOIN StudentSemester ON Student.id = StudentSemester.student_id
                               INNER JOIN Semester ON Semester.id = StudentSemester.semester_id
                               INNER JOIN Subject ON Subject.semester_id = Semester.id
                               INNER JOIN Meeting ON Meeting.subject_id = Subject.id
                      WHERE Meeting.id = @meeting_id) as Students
                ORDER BY Students.id
            );
GO

CREATE FUNCTION students_present_on_meeting(
    @meeting_id INT
)
    RETURNS TABLE
        AS
        RETURN
            (
                SELECT TOP 100 PERCENT Student.id, Student.first_name, Student.last_name
                FROM Student
                         INNER JOIN StudentMeetingAttendance AS Attendance ON Student.id = Attendance.student_id
                WHERE Attendance.meeting_id = @meeting_id
                ORDER BY Student.id
            );
GO

CREATE FUNCTION meeting_attendance_list(
    @meeting_id INT
)
    RETURNS TABLE
        AS
        RETURN
            (
                SELECT TOP 100 PERCENT Students.id,
                                       Students.first_name,
                                       Students.last_name,
                                       dbo.was_present_on_meeting(Students.id, @meeting_id) AS present
                FROM dbo.students_enrolled_on_meeting(@meeting_id) AS Students
                ORDER BY Students.id
            );
GO

CREATE FUNCTION does_meetings_overlap(
    @meeting1_id INT,
    @meeting2_id INT
)
    RETURNS BIT
AS
BEGIN
    DECLARE @meeting1_start DATETIME = (SELECT datetime FROM Meeting WHERE Meeting.id = @meeting1_id)
    DECLARE @meeting1_end DATETIME = (DATEADD(MINUTE, (SELECT length FROM Meeting WHERE Meeting.id = @meeting1_id),
                                              @meeting1_start))
    DECLARE @meeting2_start DATETIME = (SELECT datetime FROM Meeting WHERE Meeting.id = @meeting2_id)
    DECLARE @meeting2_end DATETIME = (DATEADD(MINUTE, (SELECT length FROM Meeting WHERE Meeting.id = @meeting2_id),
                                              @meeting2_start))
    DECLARE @result BIT
    IF (@meeting1_start < @meeting2_end AND @meeting2_start < @meeting1_end)
        SET @result = 1;
    ELSE
        SET @result = 0;
    RETURN @result;
END;
GO

CREATE FUNCTION student_meetings(
    @student_id INT
)
    RETURNS TABLE
        AS
        RETURN
            (
                SELECT Meeting.*
                FROM StudentMeeting
                         INNER JOIN Meeting ON StudentMeeting.meeting_id = Meeting.id
                WHERE StudentMeeting.student_id = @student_id

                UNION

                SELECT Meeting.*
                FROM StudentCourse
                         INNER JOIN Course ON StudentCourse.course_id = Course.id
                         INNER JOIN Module ON Course.id = Module.course_id
                         INNER JOIN Meeting ON Module.id = Meeting.module_id
                WHERE StudentCourse.student_id = @student_id

                UNION

                SELECT Meeting.*
                FROM StudentSemester
                         INNER JOIN Semester ON StudentSemester.semester_id = Semester.id
                         INNER JOIN Subject ON Semester.id = Subject.semester_id
                         INNER JOIN Meeting ON Subject.id = Meeting.subject_id
                WHERE StudentSemester.student_id = @student_id
            );
GO

CREATE FUNCTION teacher_meetings(
    @teacher_id INT
)
    RETURNS TABLE
        AS
        RETURN
            (
                SELECT *
                FROM Meeting
                WHERE Meeting.substituting_teacher_id = @teacher_id

                UNION

                SELECT Meeting.*
                FROM Module
                         INNER JOIN Meeting ON Module.id = Meeting.module_id AND
                                               Meeting.substituting_teacher_id IS NULL
                WHERE Module.teacher_id = @teacher_id

                UNION

                SELECT Meeting.*
                FROM Subject
                         INNER JOIN Meeting ON Subject.id = Meeting.subject_id AND
                                               Meeting.substituting_teacher_id IS NULL
                WHERE Subject.teacher_id = @teacher_id
            );
GO

CREATE FUNCTION teacher_subjects(
    @teacher_id INT
)
    RETURNS TABLE
        AS
        RETURN
            (
                SELECT Subject.id, Subject.name
                FROM Subject
                WHERE Subject.teacher_id = @teacher_id
            );

CREATE FUNCTION teacher_modules(
    @teacher_id INT
)
    RETURNS TABLE
        AS
        RETURN
            (
                SELECT Course.title AS course_title, Module.id as module
                FROM Module
                         INNER JOIN Course ON Module.course_id = Course.id
                WHERE Module.teacher_id = @teacher_id
            );

CREATE FUNCTION teacher_webinars(
    @teacher_id INT
)
    RETURNS TABLE
        AS
        RETURN
            (
                SELECT Webinar.id, Webinar.title
                FROM Webinar
                WHERE Webinar.teacher_id = @teacher_id
            );

CREATE FUNCTION translator_meetings(
    @translator_id INT
)
    RETURNS TABLE
        AS
        RETURN
            (
                SELECT *
                FROM Meeting
                WHERE Meeting.translator_id = @translator_id
            );
GO

CREATE FUNCTION translator_webinars(
    @translator_id INT
)
    RETURNS TABLE
        AS
        RETURN
            (
                SELECT Webinar.id, Webinar.title
                FROM Webinar
                WHERE Webinar.translator_id = @translator_id
            );

CREATE FUNCTION student_overlapping_meetings(
    @student_id INT
)
    RETURNS BIT
BEGIN
    RETURN (SELECT MAX(CAST(dbo.does_meetings_overlap(id, next_meeting_id) AS INT))
            FROM (SELECT id, LEAD(id) OVER (ORDER BY datetime) AS next_meeting_id
                  FROM dbo.student_meetings(@student_id)) AS Meetings
            WHERE Meetings.next_meeting_id IS NOT NULL)
END;
GO

CREATE FUNCTION teacher_overlapping_meetings(
    @teacher_id INT
)
    RETURNS BIT
BEGIN
    RETURN (SELECT MAX(CAST(dbo.does_meetings_overlap(id, next_meeting_id) AS INT))
            FROM (SELECT id, LEAD(id) OVER (ORDER BY datetime) AS next_meeting_id
                  FROM dbo.teacher_meetings(@teacher_id)) AS Meetings
            WHERE Meetings.next_meeting_id IS NOT NULL)
END;
GO

CREATE FUNCTION translator_overlapping_meetings(
    @translator_id INT
)
    RETURNS BIT
BEGIN
    RETURN (SELECT MAX(CAST(dbo.does_meetings_overlap(id, next_meeting_id) AS INT))
            FROM (SELECT id, LEAD(id) OVER (ORDER BY datetime) AS next_meeting_id
                  FROM dbo.translator_meetings(@translator_id)) AS Meetings
            WHERE Meetings.next_meeting_id IS NOT NULL)
END;
GO

CREATE FUNCTION studies_graduates(
    @studies_id INT
)
    RETURNS TABLE
        AS
        RETURN
            (
                SELECT Student.id, Student.first_name, Student.last_name
                FROM Student
                         INNER JOIN StudentStudies ON StudentStudies.student_id = Student.id AND
                                                      StudentStudies.credit_date IS NOT NULL AND
                                                      StudentStudies.studies_id = @studies_id
            );
GO

CREATE FUNCTION course_graduates(
    @course_id INT
)
    RETURNS TABLE
        AS
        RETURN
            (
                SELECT Student.id, Student.first_name, Student.last_name
                FROM Student
                         INNER JOIN StudentCourse ON StudentCourse.student_id = Student.id AND
                                                     StudentCourse.credit_date IS NOT NULL AND
                                                     StudentCourse.course_id = @course_id
            );
GO

CREATE FUNCTION room_meetings(
    @room_id INT
)
    RETURNS TABLE
        AS
        RETURN
            (
                SELECT *
                FROM Meeting
                WHERE Meeting.substituting_room_id = @room_id

                UNION

                SELECT Meeting.*
                FROM Module
                         INNER JOIN Meeting ON Module.id = Meeting.module_id AND
                                               Meeting.substituting_room_id IS NULL
                WHERE Module.room_id = @room_id

                UNION

                SELECT Meeting.*
                FROM Subject
                         INNER JOIN Meeting ON Subject.id = Meeting.subject_id AND
                                               Meeting.substituting_room_id IS NULL
                WHERE Subject.room_id = @room_id
            );
GO

CREATE FUNCTION room_overlapping_meetings(
    @room_id INT
)
    RETURNS BIT
BEGIN
    RETURN (SELECT MAX(CAST(dbo.does_meetings_overlap(id, next_meeting_id) AS INT))
            FROM (SELECT id, LEAD(id) OVER (ORDER BY datetime) AS next_meeting_id
                  FROM dbo.room_meetings(@room_id)) AS Meetings
            WHERE Meetings.next_meeting_id IS NOT NULL)
END;
GO

CREATE FUNCTION basket_item_price(
    @course_id INT = NULL,
    @meeting_id INT = NULL,
    @studies_id INT = NULL,
    @webinar_id INT = NULL
)
    RETURNS INT
AS
BEGIN
    DECLARE @price INT
    IF @course_id IS NOT NULL
        SET @price = (SELECT price FROM Course WHERE id = @course_id)
    ELSE
        IF @meeting_id IS NOT NULL
            SET @price = (SELECT standalone_price FROM Meeting WHERE id = @meeting_id)
        ELSE
            IF @studies_id IS NOT NULL
                SET @price = (SELECT registration_price FROM Studies WHERE id = @studies_id)
            ELSE
                IF @webinar_id IS NOT NULL
                    SET @price = (SELECT price FROM Webinar WHERE id = @webinar_id)
    RETURN @price
END;
GO

CREATE FUNCTION failed_payments(
    @start_date DATE = NULL,
    @end_date DATE = NULL
)
    RETURNS TABLE
        AS
        RETURN
            (
                SELECT Basket.id,
                       CAST(SUM(dbo.basket_item_price(BasketItem.course_id, BasketItem.meeting_id,
                                                 BasketItem.studies_id,
                                                 BasketItem.webinar_id)) / 100.0 AS DECIMAL(10, 2)) AS price
                FROM Basket
                         INNER JOIN BasketItem ON BasketItem.basket_id = Basket.id
                WHERE state = 'failed_payment'
                  AND (@start_date IS NULL OR payment_date >= @start_date)
                  AND (@end_date IS NULL OR payment_date <= @end_date)
                GROUP BY Basket.id
            );
GO

CREATE FUNCTION successful_payments(
    @start_date DATE = NULL,
    @end_date DATE = NULL
)
    RETURNS TABLE
        AS
        RETURN
            (
                SELECT Basket.id,
                       CAST(SUM(dbo.basket_item_price(BasketItem.course_id, BasketItem.meeting_id,
                                                 BasketItem.studies_id,
                                                 BasketItem.webinar_id)) / 100.0 AS DECIMAL(10, 2)) AS price
                FROM Basket
                         INNER JOIN BasketItem ON BasketItem.basket_id = Basket.id
                WHERE state = 'success_payment'
                  AND (@start_date IS NULL OR payment_date >= @start_date)
                  AND (@end_date IS NULL OR payment_date <= @end_date)
                GROUP BY Basket.id
            );
GO
