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
              FROM InternshipStudent
              WHERE student_id = @student_id
                AND exam_result >= CAST(dbo.get_parameter('internship_exam_required_result') AS INT))
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
    @study_id INT
)
    RETURNS INT
AS
BEGIN
    RETURN (SELECT TOP 1 number
            FROM Semester
            WHERE studies_id = @study_id
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
