CREATE FUNCTION getParameter(
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
-- SELECT dbo.getParameter('availability_period_in_days') AS 'parameter'


CREATE FUNCTION internshipFinished(
    @student_id INT
)
    RETURNS INT
AS
BEGIN
    DECLARE @result INT;
    IF EXISTS(SELECT *
              FROM InternshipStudent
              WHERE student_id = @student_id
                AND attended_days >= CAST(dbo.getParameter('internship_required_attendance') AS INT)
                AND exam_result >= CAST(dbo.getParameter('internship_exam_required_result') AS INT))
        SET @result = 1;
    ELSE
        SET @result = 0;

    RETURN @result;
END;
GO
-- SELECT dbo.internshipFinished(348) AS 'finished'


CREATE FUNCTION presentOnMeeting(
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
-- SELECT dbo.presentOnMeeting(348, 1) AS 'present'


CREATE FUNCTION getStudentData(
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

CREATE FUNCTION getTeacherData(
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

CREATE FUNCTION getTranslatorData(
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
-- SELECT * FROM dbo.getStudentData(348)


CREATE FUNCTION getLastSemester(
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
-- SELECT dbo.getLastSemester(1) AS 'semester'

CREATE FUNCTION isOnStudies(
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
-- SELECT dbo.isOnStudies(348, 1) AS 'on_studies'

CREATE FUNCTION semesterStudies(
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
-- SELECT dbo.semesterStudies(1) AS 'studies'

CREATE FUNCTION getStudentsBasket(
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
-- SELECT dbo.getStudentsBasket(348) AS 'basket'

CREATE FUNCTION getBasketItems(
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
-- SELECT * FROM dbo.getBasketItems(3)



