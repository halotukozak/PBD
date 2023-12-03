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
    id      int          NOT NULL IDENTITY (1, 1),
    name    varchar(50)  NOT NULL,
    surname varchar(50)  NOT NULL,
    address varchar(200) NOT NULL,

    PRIMARY KEY (id),
)

CREATE TABLE Teacher
(
    id      int         NOT NULL IDENTITY (1, 1),
    name    varchar(50) NOT NULL,
    surname varchar(50) NOT NULL,

    PRIMARY KEY (id),
)

CREATE TABLE Translator
(
    id       int         NOT NULL IDENTITY (1, 1),
    language varchar(50) NOT NULL,

    PRIMARY KEY (id),
)

CREATE TABLE Webinar
(
    id            int                          NOT NULL IDENTITY (1, 1),
    price         float                        NOT NULL,
    date          date                         NOT NULL,
    url           varchar(200)                  NOT NULL,
    language      varchar(50) DEFAULT 'Polish' NOT NULL,
    translator_id int                          NOT NULL,
    teacher_id    int                          NOT NULL,

    PRIMARY KEY (id),

    FOREIGN KEY (translator_id) REFERENCES Translator (id),
    FOREIGN KEY (teacher_id) REFERENCES Teacher (id),
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
)

CREATE TABLE StudentCourse
(
    student_id            int  NOT NULL,
    course_id             int  NOT NULL,
    advance_payment_date  date NOT NULL,
    full_payment_date     date NOT NULL,
    credit_date           date NOT NULL,
    certificate_post_date date NOT NULL,

    PRIMARY KEY (student_id, course_id),

    FOREIGN KEY (student_id) REFERENCES Student (id),
    FOREIGN KEY (course_id) REFERENCES Course (id),
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
    id         int           NOT NULL IDENTITY (1, 1),
    course_id  int           NOT NULL,
    type       varchar(15) NOT NULL,
    room_id    int           NOT NULL,
    teacher_id int           NOT NULL,

    PRIMARY KEY (id),

    FOREIGN KEY (course_id) REFERENCES Course (id),
    FOREIGN KEY (room_id) REFERENCES Room (id),
    FOREIGN KEY (teacher_id) REFERENCES Teacher (id),

    CHECK (type IN ('online_sync', 'online_async', 'in_person', 'hybrid'))
)

CREATE TABLE StudentMeetingAttendance
(
    student_id int NOT NULL,
    meeting_id int NOT NULL,

    PRIMARY KEY (student_id, meeting_id),
)

CREATE TABLE Studies
(
    id            int           NOT NULL IDENTITY (1, 1),
    syllabus      varchar(1000) NOT NULL,
    price         float         NOT NULL,
    advance_price float         NOT NULL,
    language      varchar(50)   NOT NULL,
    student_limit int           NOT NULL,

    PRIMARY KEY (id),
)

CREATE TABLE Semester
(
    id         int         NOT NULL IDENTITY (1, 1),
    number     int         NOT NULL,
    studies_id int         NOT NULL,
    schedule   varchar(50) NOT NULL,

    PRIMARY KEY (id),

    FOREIGN KEY (studies_id) REFERENCES Studies (id),
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
    registration_payment_date date NOT NULL,
    certificate_post_date     date NOT NULL,

    PRIMARY KEY (student_id, studies_id),

    FOREIGN KEY (student_id) REFERENCES Student (id),
    FOREIGN KEY (studies_id) REFERENCES Studies (id),
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
    student_id    int NOT NULL,
    internship_id int NOT NULL,
    attended_days int NOT NULL,

    PRIMARY KEY (student_id, internship_id),

    FOREIGN KEY (student_id) REFERENCES Student (id),
)

CREATE TABLE InternshipExam
(
    student_id    int NOT NULL,
    internship_id int NOT NULL,
    result        int NOT NULL,

    PRIMARY KEY (student_id, internship_id),

    FOREIGN KEY (student_id) REFERENCES Student (id),
    FOREIGN KEY (internship_id) REFERENCES Internship (id),
)

CREATE TABLE Meeting
(
    id                      int          NOT NULL IDENTITY (1, 1),
    module_id               int          NOT NULL,
    subject_id              int          NOT NULL,
    url                     varchar(200) NOT NULL,
    date                    date         NOT NULL,
    type                    varchar(10) NOT NULL,
    standalone_price        float        NOT NULL,
    translator_id           int          NOT NULL,
    substituting_teacher_id int          NOT NULL,
    student_limit           int          NOT NULL,

    PRIMARY KEY (id),

    FOREIGN KEY (module_id) REFERENCES Module (id),
    FOREIGN KEY (subject_id) REFERENCES Subject (id),
    FOREIGN KEY (translator_id) REFERENCES Translator (id),
    FOREIGN KEY (substituting_teacher_id) REFERENCES Teacher (id),

    CHECK (type IN ('in_person', 'online', 'video'))
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
    id           int           NOT NULL IDENTITY (1, 1),
    student_id   int           NOT NULL,
    payment_url  varchar(200)   NOT NULL,
    state        varchar(15) NOT NULL,
    create_date  date          NOT NULL,
    payment_date date          NOT NULL,

    PRIMARY KEY (id),

    FOREIGN KEY (student_id) REFERENCES Student (id),

    CHECK (state IN ('open', 'pending_payment', 'success_payment', 'failed_payment'))
)

CREATE TABLE BasketItem
(
    basket_id  int NOT NULL,
    course_id  int,
    meeting_id int,
    studies_id int,
    webinar_id int,

--     nwm wsm jak to z nullami wygląda, pasowałoby na prodzie sprawdzić
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
    id    int         NOT NULL IDENTITY (1, 1),
    type  varchar(50) NOT NULL,
    value varchar(50) NOT NULL,
    date  date        NOT NULL,

    PRIMARY KEY (id),
)
