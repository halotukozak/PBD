USE u_bkozak


CREATE TRIGGER student_webinar_payment_date
    ON StudentWebinar
    AFTER INSERT, UPDATE
    AS
BEGIN
    IF EXISTS (SELECT 1
               FROM inserted
                        INNER JOIN Webinar ON webinar_id = Webinar.id
               WHERE payment_date >= Webinar.datetime)
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
    DECLARE @webinar_language_id int;
    DECLARE @translator_id int;

    SELECT @webinar_language_id = (SELECT id FROM Language WHERE name = (SELECT language FROM inserted));
    SELECT @translator_id = (SELECT translator_id
                             FROM TranslatorLanguage
                             WHERE translator_id = (SELECT translator_id FROM inserted)
                               AND language_id = @webinar_language_id);

    IF @translator_id IS NULL AND (SELECT translator_id FROM inserted) IS NOT NULL
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
    DECLARE @required_language varchar(50);
    DECLARE @required_language_id int;
    DECLARE @translator_id int;


    IF (SELECT subject_id FROM inserted) IS NOT NULL
        BEGIN
            SELECT @required_language = (SELECT S.language
                                         FROM inserted I
                                                  INNER JOIN Subject SU ON I.subject_id = SU.id
                                                  INNER JOIN Semester SE ON SU.semester_id = SE.id
                                                  INNER JOIN Studies S ON SE.studies_id = S.id);
            SELECT @required_language_id = (SELECT id FROM Language WHERE name = @required_language);
        END
    ELSE
        BEGIN
            SELECT @required_language = C.language
            FROM inserted I
                     INNER JOIN Module M ON I.module_id = M.id
                     INNER JOIN Course C ON M.course_id = C.id;
            SELECT @required_language_id = (SELECT id FROM Language WHERE name = @required_language);
        END

    SELECT @translator_id = (SELECT translator_id
                             FROM TranslatorLanguage
                             WHERE translator_id = (SELECT translator_id FROM inserted)
                               AND language_id = @required_language_id);
    IF @translator_id IS NULL AND (SELECT translator_id FROM inserted) IS NOT NULL
        BEGIN
            RAISERROR ('The language of the translator must be the same as the required language.', 16, 1);
        END
END;
GO

CREATE TRIGGER check_meeting_student_limit
    ON StudentMeeting
    AFTER INSERT, UPDATE
    AS
BEGIN
    IF (SELECT COUNT(*) FROM dbo.students_enrolled_on_meeting((SELECT meeting_id FROM inserted))) > (SELECT student_limit FROM Meeting WHERE id = (SELECT meeting_id FROM inserted))
        BEGIN
            RAISERROR ('The number of students enrolled on the meeting cannot be higher than the student limit.', 16, 1);
        END
END;
GO

CREATE TRIGGER check_course_student_limit
    ON StudentCourse
    AFTER INSERT, UPDATE
    AS
BEGIN
    IF (SELECT COUNT(*) FROM dbo.students_enrolled_on_course((SELECT course_id FROM inserted))) > (SELECT student_limit FROM Course WHERE id = (SELECT course_id FROM inserted))
        BEGIN
            RAISERROR ('The number of students enrolled on the course cannot be higher than the student limit.', 16, 1);
        END
END;
GO

CREATE TRIGGER check_studies_student_limit
    ON StudentStudies
    AFTER INSERT, UPDATE
    AS
BEGIN
    IF (SELECT COUNT(*) FROM dbo.students_enrolled_on_studies((SELECT studies_id FROM inserted))) > (SELECT student_limit FROM Studies WHERE id = (SELECT studies_id FROM inserted))
        BEGIN
            RAISERROR ('The number of students enrolled on the studies cannot be higher than the student limit.', 16, 1);
        END
END;
GO