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
