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
    RETURNS INT
AS
BEGIN
    DECLARE @result INT;
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
    RETURNS INT
AS
BEGIN
    DECLARE @result INT;
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
    RETURNS INT
AS
BEGIN
    DECLARE @result INT;
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
    RETURN (@meeting1_start < @meeting2_end AND @meeting1_end > @meeting2_start) -- todo
END;
GO
