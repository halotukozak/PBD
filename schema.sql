-- Drop all foreign keys
DECLARE @Sql VARCHAR(MAX) = '';
SELECT @Sql += 'ALTER TABLE ' + table_name + ' DROP CONSTRAINT ' + constraint_name + ';'
FROM information_schema.table_constraints
WHERE constraint_type = 'FOREIGN KEY';

-- Execute the generated statements
EXEC sp_executesql @Sql;

-- Drop all tables
SET @Sql = '';
SELECT @Sql += 'DROP TABLE ' + table_name + ';'
FROM information_schema.tables
WHERE table_type = 'BASE TABLE';

-- Execute the generated DROP TABLE statements
EXEC sp_executesql @Sql;


CREATE TABLE Student
(
    id           int          NOT NULL IDENTITY (1, 1),
    name         varchar(50)  NOT NULL,
    surname      varchar(50)  NOT NULL,
    address      varchar(200) NOT NULL,
    email        varchar(50)  NOT NULL UNIQUE,
    phone_number varchar(20)  NOT NULL UNIQUE,

    PRIMARY KEY (id),
)

CREATE TABLE Teacher
(
    id           int          NOT NULL IDENTITY (1, 1),
    name         varchar(50)  NOT NULL,
    surname      varchar(50)  NOT NULL,
    address      varchar(200) NOT NULL,
    email        varchar(50)  NOT NULL UNIQUE,
    phone_number varchar(20)  NOT NULL UNIQUE,

    PRIMARY KEY (id),
)

CREATE TABLE Translator
(
    id           int          NOT NULL IDENTITY (1, 1),
    language     varchar(50)  NOT NULL,
    name         varchar(50)  NOT NULL,
    surname      varchar(50)  NOT NULL,
    address      varchar(200) NOT NULL,
    email        varchar(50)  NOT NULL UNIQUE,
    phone_number varchar(20)  NOT NULL UNIQUE,

    PRIMARY KEY (id),
)

CREATE TABLE Webinar
(
    id            int                          NOT NULL IDENTITY (1, 1),
    price         float       DEFAULT 0        NOT NULL,
    date          date                         NOT NULL,
    url           varchar(200)                 NOT NULL UNIQUE,
    language      varchar(50) DEFAULT 'Polish' NOT NULL,
    translator_id int,
    teacher_id    int                          NOT NULL,

    PRIMARY KEY (id),

    FOREIGN KEY (translator_id) REFERENCES Translator (id),
    FOREIGN KEY (teacher_id) REFERENCES Teacher (id),

    CHECK (price >= 0),
)

CREATE TABLE StudentWebinar
(
    student_id   int  NOT NULL,
    webinar_id   int  NOT NULL,
    payment_date date NOT NULL,

    PRIMARY KEY (student_id, webinar_id),

    FOREIGN KEY (student_id) REFERENCES Student (id),
    FOREIGN KEY (webinar_id) REFERENCES Webinar (id),
)

CREATE TABLE Course
(
    id            int                          NOT NULL IDENTITY (1, 1),
    price         float                        NOT NULL,
    advance_price float                        NOT NULL,
    subject       varchar(100)                 NOT NULL,
    language      varchar(50) DEFAULT 'Polish' NOT NULL,
    student_limit int                          NOT NULL,

    PRIMARY KEY (id),

    CHECK (price > 0),
    CHECK (advance_price >= 0),
    CHECK (student_limit > 0),
)

CREATE TABLE StudentCourse
(
    student_id            int  NOT NULL,
    course_id             int  NOT NULL,
    advance_payment_date  date NOT NULL,
    full_payment_date     date,
    credit_date           date,
    certificate_post_date date,

    PRIMARY KEY (student_id, course_id),

    FOREIGN KEY (student_id) REFERENCES Student (id),
    FOREIGN KEY (course_id) REFERENCES Course (id),

    CHECK (advance_payment_date <= full_payment_date),
    CHECK (full_payment_date <= credit_date),
    CHECK (credit_date <= certificate_post_date),
)

CREATE TABLE Room
(
    id       int         NOT NULL IDENTITY (1, 1),
    number   varchar(10) NOT NULL,
    building varchar(50) NOT NULL,

    PRIMARY KEY (id),
)

CREATE TABLE Module
(
    id         int         NOT NULL IDENTITY (1, 1),
    course_id  int         NOT NULL,
    type       varchar(15) NOT NULL,
    room_id    int,
    teacher_id int         NOT NULL,

    PRIMARY KEY (id),

    FOREIGN KEY (course_id) REFERENCES Course (id),
    FOREIGN KEY (room_id) REFERENCES Room (id),
    FOREIGN KEY (teacher_id) REFERENCES Teacher (id),

    CHECK (
        type = 'hybrid' OR
        type = 'in_person' AND room_id IS NOT NULL OR
        type IN ('online_sync', 'online_async') AND room_id IS NULL
        ),
)

CREATE TABLE StudentMeetingAttendance
(
    student_id int NOT NULL,
    meeting_id int NOT NULL,

    PRIMARY KEY (student_id, meeting_id),
)

CREATE TABLE Studies
(
    id            int                          NOT NULL IDENTITY (1, 1),
    syllabus      varchar(1000),
    price         float                        NOT NULL,
    advance_price float                        NOT NULL,
    language      varchar(50) DEFAULT 'Polish' NOT NULL,
    student_limit int                          NOT NULL,

    PRIMARY KEY (id),

    CHECK (price > 0),
    CHECK (advance_price >= 0),
    CHECK (student_limit > 0),
)

CREATE TABLE Semester
(
    id         int         NOT NULL IDENTITY (1, 1),
    number     int         NOT NULL,
    studies_id int         NOT NULL,
    schedule   varchar(50) NOT NULL,
    start_date date        NOT NULL,
    end_date   date        NOT NULL,

    PRIMARY KEY (id),

    FOREIGN KEY (studies_id) REFERENCES Studies (id),
    CHECK (number > 0 AND number <= 12),
    CHECK (start_date < end_date),
    UNIQUE (studies_id, number),
)

CREATE TABLE StudentSemester
(
    student_id   int  NOT NULL,
    semester_id  int  NOT NULL,
    payment_date date NOT NULL,

    PRIMARY KEY (student_id, semester_id),

    FOREIGN KEY (student_id) REFERENCES Student (id),
    FOREIGN KEY (semester_id) REFERENCES Semester (id),
)

CREATE TABLE StudentStudies
(
    student_id                int  NOT NULL,
    studies_id                int  NOT NULL,
    registration_payment_date date NOT NULL, -- wpisowe
    certificate_post_date     date,

    PRIMARY KEY (student_id, studies_id),

    FOREIGN KEY (student_id) REFERENCES Student (id),
    FOREIGN KEY (studies_id) REFERENCES Studies (id),

    CHECK (registration_payment_date < certificate_post_date),
)

CREATE TABLE Subject
(
    id          int          NOT NULL IDENTITY (1, 1),
    name        varchar(200) NOT NULL,
    semester_id int          NOT NULL,
    teacher_id  int          NOT NULL,

    PRIMARY KEY (id),
)

CREATE TABLE Internship
(
    id         int  NOT NULL IDENTITY (1, 1),
    studies_id int  NOT NULL,
    date       date NOT NULL,

    PRIMARY KEY (id),

    FOREIGN KEY (studies_id) REFERENCES Studies (id),
)

CREATE TABLE InternshipAttendance
(
    student_id    int           NOT NULL,
    internship_id int           NOT NULL,
    attended_days int DEFAULT 0 NOT NULL,

    PRIMARY KEY (student_id, internship_id),

    FOREIGN KEY (student_id) REFERENCES Student (id),

    CHECK (attended_days >= 0),
)

CREATE TABLE InternshipExam
(
    student_id    int NOT NULL,
    internship_id int NOT NULL,
    result        int NOT NULL,

    PRIMARY KEY (student_id, internship_id),

    FOREIGN KEY (student_id) REFERENCES Student (id),
    FOREIGN KEY (internship_id) REFERENCES Internship (id),

    CHECK (result >= 0 AND result <= 100),
)

CREATE TABLE Meeting
(
    id                      int         NOT NULL IDENTITY (1, 1),
    module_id               int,
    subject_id              int,
    url                     varchar(200),
    date                    date        NOT NULL,
    type                    varchar(10) NOT NULL,
    standalone_price        float,
    translator_id           int,
    substituting_teacher_id int,
    student_limit           int         NOT NULL,

    PRIMARY KEY (id),

    FOREIGN KEY (module_id) REFERENCES Module (id),
    FOREIGN KEY (subject_id) REFERENCES Subject (id),
    FOREIGN KEY (translator_id) REFERENCES Translator (id),
    FOREIGN KEY (substituting_teacher_id) REFERENCES Teacher (id),

    CHECK (
        module_id IS NOT NULL AND subject_id IS NULL OR
        module_id IS NULL AND subject_id IS NOT NULL
        ),
    CHECK (type = 'in_person' OR type IN ('online', 'video') AND url IS NOT NULL),

    CHECK (student_limit > 0),
    CHECK (standalone_price is NULL OR standalone_price > 0),
)

CREATE TABLE StudentMeeting
(
    student_id   int NOT NULL,
    meeting_id   int NOT NULL,
    payment_date date,

    PRIMARY KEY (student_id, meeting_id),

    FOREIGN KEY (student_id) REFERENCES Student (id),
    FOREIGN KEY (meeting_id) REFERENCES Meeting (id),
)

CREATE TABLE Basket
(
    id           int         NOT NULL IDENTITY (1, 1),
    student_id   int         NOT NULL,
    payment_url  varchar(200),
    state        varchar(15) NOT NULL,
    create_date  date        NOT NULL,
    payment_date date        NOT NULL,

    PRIMARY KEY (id),

    FOREIGN KEY (student_id) REFERENCES Student (id),

    CHECK (state IN ('open', 'pending_payment', 'success_payment', 'failed_payment')),
    CHECK (state = 'open' OR payment_url IS NOT NULL ),
    CHECK (payment_date >= create_date),
)

CREATE TABLE BasketItem
(
    basket_id  int NOT NULL,
    course_id  int,
    meeting_id int,
    studies_id int,
    webinar_id int,

    PRIMARY KEY (basket_id, course_id, meeting_id, studies_id, webinar_id),

    FOREIGN KEY (basket_id) REFERENCES Basket (id),
    FOREIGN KEY (course_id) REFERENCES Course (id),
    FOREIGN KEY (meeting_id) REFERENCES Meeting (id),
    FOREIGN KEY (studies_id) REFERENCES Studies (id),
    FOREIGN KEY (webinar_id) REFERENCES Webinar (id),

    CHECK (
        (course_id IS NULL AND meeting_id IS NULL AND studies_id IS NULL AND webinar_id IS NOT NULL) OR
        (course_id IS NULL AND meeting_id IS NULL AND studies_id IS NOT NULL AND webinar_id IS NULL) OR
        (course_id IS NULL AND meeting_id IS NOT NULL AND studies_id IS NULL AND webinar_id IS NULL) OR
        (course_id IS NOT NULL AND meeting_id IS NULL AND studies_id IS NULL AND webinar_id IS NULL)
        )
)
CREATE TABLE Parameter
(
    name  varchar(50) NOT NULL,
    value varchar(50) NOT NULL,
    date  date        NOT NULL,

    PRIMARY KEY (name, date),
)

CREATE TRIGGER StudentWebinarPaymentDate
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
END;

CREATE TRIGGER MeetingStudentLimit
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
                                          INNER JOIN dbo.StudentSemester
                                                     on Subject.semester_id = StudentSemester.semester_id)
    SELECT @meeting_students = (SELECT DISTINCT COUNT(*)
                                FROM inserted
                                         INNER JOIN StudentMeeting on inserted.id = StudentMeeting.meeting_id);


    IF @course_students + @semester_students + @meeting_students > student_limit
        BEGIN
            RAISERROR ('Student limit cannot be lower than number of students', 16, 1);
        END
END;

CREATE TRIGGER StudiesSyllabus
    ON Studies
    AFTER INSERT, UPDATE
    AS
BEGIN
    DECLARE @studies_start_date DATE;
    SELECT @studies_start_date = (SELECT S.start_date
                                  FROM inserted
                                           INNER JOIN Semester S on inserted.id = S.studies_id
                                  WHERE number = 1)

    IF syllabus IS NULL AND @studies_start_date < GETDATE()
        BEGIN
            RAISERROR ('Syllabus cannot be empty after the first semester started.', 16, 1);
        END
END;