USE u_bkozak


CREATE TRIGGER student_webinar_payment_date
    ON StudentWebinar
    AFTER INSERT, UPDATE
    AS
BEGIN
    IF EXISTS (SELECT 1
               FROM inserted
                        INNER JOIN Webinar w ON webinar_id = w.id
               WHERE payment_date >= w.date)
        BEGIN
            RAISERROR ('Payment date cannot be later than webinar date', 16, 1);
        END
END

GO

CREATE TRIGGER meeting_student_limit
    ON Meeting
    AFTER INSERT, UPDATE
    AS
BEGIN
    DECLARE @course_students INT, @semester_students INT, @meeting_students INT;

    SELECT @course_students = (SELECT DISTINCT COUNT(*)
                               FROM inserted
                                        INNER JOIN Meeting ON Meeting.id = inserted.id
                                        INNER JOIN Module M on M.id = Meeting.module_id
                                        INNER JOIN Course C on C.id = M.course_id
                                        INNER JOIN StudentCourse SC on C.id = SC.course_id)
    SELECT @semester_students = (SELECT DISTINCT COUNT(*)
                                 FROM inserted
                                          INNER JOIN Subject on Subject.id = inserted.subject_id
                                          INNER JOIN StudentSemester
                                                     on Subject.semester_id = StudentSemester.semester_id)
    SELECT @meeting_students = (SELECT DISTINCT COUNT(*)
                                FROM inserted
                                         INNER JOIN StudentMeeting on inserted.id = StudentMeeting.meeting_id);


    IF @course_students + @semester_students + @meeting_students > (SELECT student_limit
                                                                    FROM inserted)
        BEGIN
            RAISERROR ('Student limit cannot be lower than number of students', 16, 1);
        END
END;

GO

CREATE TRIGGER studies_syllabus
    ON Studies
    AFTER INSERT, UPDATE
    AS
BEGIN
    DECLARE @studies_start_date DATE;
    SELECT @studies_start_date = (SELECT S.start_date
                                  FROM inserted
                                           INNER JOIN Semester S on inserted.id = S.studies_id
                                  WHERE number = 1)

    IF (SELECT syllabus FROM inserted) IS NULL AND @studies_start_date < GETDATE()
        BEGIN
            RAISERROR ('Syllabus cannot be empty after the first semester started.', 16, 1);
        END
END

GO

CREATE TRIGGER student_exam_result
    ON StudentInternship
    AFTER INSERT, UPDATE
    AS
BEGIN
    DECLARE @attended_days int;
    DECLARE @internship_required_attendance int;
    SELECT @attended_days = (SELECT attended_days
                             FROM inserted);
    --TODO
    --Use here function to get the value of the parameter
    SELECT @internship_required_attendance = (SELECT TOP 1 value
                                              FROM Parameter
                                              WHERE name LIKE @internship_required_attendance
                                                AND date <= CURRENT_TIMESTAMP
                                              ORDER BY date DESC)

    IF @attended_days < @internship_required_attendance
        BEGIN
            RAISERROR ('Student must attend the required minimum days of internship', 16, 1);
        END
END

GO


CREATE TRIGGER check_open_baskets
    ON Basket
    AFTER INSERT, UPDATE
    AS
BEGIN
    DECLARE @student_id int;
    SELECT @student_id = (SELECT student_id FROM inserted);
    IF EXISTS (SELECT 1
               FROM Basket
               WHERE student_id = @student_id
                 AND state = 'open')
        BEGIN
            RAISERROR ('Student can only have one open basket at a time', 16, 1);
        END
END;
GO

CREATE TRIGGER check_webinar_translator_language
    ON Webinar
    AFTER INSERT, UPDATE
    AS
BEGIN
    DECLARE @webinar_language varchar(50);
    DECLARE @translator_language varchar(50);

    SELECT @webinar_language = (SELECT language FROM inserted);
    SELECT @translator_language = (SELECT language
                                   FROM Translator
                                   WHERE id = (SELECT translator_id FROM inserted));

    IF @webinar_language <> @translator_language
        BEGIN
            RAISERROR ('The language of the translator must be the same as the language of the webinar.', 16, 1);
        END
END;
GO

CREATE TRIGGER check_meeting_translator_language
    ON Meeting
    AFTER INSERT, UPDATE
    AS
BEGIN
    DECLARE @translator_language varchar(50);
    DECLARE @required_language varchar(50);

    SELECT @translator_language = (SELECT language
                                   FROM Translator
                                   WHERE id = (SELECT translator_id FROM inserted));

    IF (SELECT subject_id FROM inserted) IS NOT NULL
        BEGIN
            SELECT @required_language = (SELECT S.language
            FROM inserted I
                     INNER JOIN Subject SU ON I.subject_id = SU.id
                     INNER JOIN Semester SE ON SU.semester_id = SE.id
                     INNER JOIN Studies S ON SE.studies_id = S.id);
        END
    ELSE
        BEGIN
            SELECT @required_language = C.language
            FROM inserted I
                     INNER JOIN Module M ON I.module_id = M.id
                     INNER JOIN Course C ON M.course_id = C.id;
        END

    IF @translator_language <> @required_language
        BEGIN
            RAISERROR ('The language of the translator must be the same as the required language.', 16, 1);
        END
END;
GO
