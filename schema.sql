USE u_bkozak

-- Drop all foreign keys
DECLARE @Sql NVARCHAR(MAX) = '';
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
    title         varchar(100)                 NOT NULL,
    price         int         DEFAULT 0        NOT NULL, --in Polish grosz
    date          datetime                         NOT NULL,
    url           varchar(200)                 NOT NULL UNIQUE,
    language      varchar(50) DEFAULT 'Polish' NOT NULL,
    translator_id int,
    teacher_id    int                          NOT NULL,

    PRIMARY KEY (id),

    FOREIGN KEY (translator_id) REFERENCES Translator (id) ON DELETE SET NULL,
    FOREIGN KEY (teacher_id) REFERENCES Teacher (id) ON DELETE NO ACTION,

    CONSTRAINT not_negative_webinar_price CHECK (price >= 0)
)

CREATE TABLE StudentWebinar
(
    student_id   int  NOT NULL,
    webinar_id   int  NOT NULL,
    payment_date date NOT NULL,

    PRIMARY KEY (student_id, webinar_id),

    FOREIGN KEY (student_id) REFERENCES Student (id) ON DELETE CASCADE,
    FOREIGN KEY (webinar_id) REFERENCES Webinar (id) ON DELETE CASCADE,
)

CREATE TABLE Course
(
    id            int                          NOT NULL IDENTITY (1, 1),
    title         varchar(100)                 NOT NULL,
    price         int                          NOT NULL, --in Polish grosz
    advance_price int                          NOT NULL, --in Polish grosz
    subject       varchar(100)                 NOT NULL,
    language      varchar(50) DEFAULT 'Polish' NOT NULL,
    student_limit int                          NOT NULL,

    PRIMARY KEY (id),

    CONSTRAINT positive_course_price CHECK (price > 0),
    CONSTRAINT not_negative_advance_price CHECK (advance_price >= 0),
    CONSTRAINT positive_course_student_limit CHECK (student_limit > 0),
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

    FOREIGN KEY (student_id) REFERENCES Student (id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES Course (id) ON DELETE CASCADE,

    CONSTRAINT advance_payment_date_lowerEq_full_payment_date CHECK (advance_payment_date <= full_payment_date),
    CONSTRAINT full_payment_date_lowerEq_credit_date CHECK (full_payment_date <= credit_date),
    CONSTRAINT credit_date_lowerEq_certificate_post_date CHECK (credit_date <= certificate_post_date),
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

    FOREIGN KEY (course_id) REFERENCES Course (id) ON DELETE CASCADE,
    FOREIGN KEY (room_id) REFERENCES Room (id) ON DELETE NO ACTION,
    FOREIGN KEY (teacher_id) REFERENCES Teacher (id) ON DELETE NO ACTION,

    CONSTRAINT type_and_room CHECK (
        type = 'hybrid' OR
        type = 'in_person' AND room_id IS NOT NULL OR
        type IN ('online_sync', 'online_async') AND room_id IS NULL
        ),
)

CREATE TABLE Studies
(
    id            int                          NOT NULL IDENTITY (1, 1),
    title         varchar(100)                 NOT NULL,
    syllabus      varchar(5000),
    price         int                          NOT NULL, --in Polish grosz
    advance_price int                          NOT NULL, --in Polish grosz
    language      varchar(50) DEFAULT 'Polish' NOT NULL,
    student_limit int                          NOT NULL,

    PRIMARY KEY (id),

    CONSTRAINT positive_studies_price CHECK (price > 0),
    CONSTRAINT not_negative_advance_studies_price CHECK (advance_price >= 0),
    CONSTRAINT positive_studies_student_limit CHECK (student_limit > 0),
)

CREATE TABLE Semester
(
    id           int          NOT NULL IDENTITY (1, 1),
    number       int          NOT NULL,
    studies_id   int          NOT NULL,
    schedule_url varchar(200) NOT NULL,
    start_date   date         NOT NULL,
    end_date     date         NOT NULL,

    PRIMARY KEY (id),

    FOREIGN KEY (studies_id) REFERENCES Studies (id) ON DELETE NO ACTION,
    CONSTRAINT number_between_1_and_12 CHECK (number > 0 AND number <= 12),
    CONSTRAINT start_date_lower_end_date CHECK (start_date < end_date),
    UNIQUE (studies_id, number),
)

CREATE TABLE StudentSemester
(
    student_id   int  NOT NULL,
    semester_id  int  NOT NULL,
    payment_date date NOT NULL,

    PRIMARY KEY (student_id, semester_id),

    FOREIGN KEY (student_id) REFERENCES Student (id) ON DELETE CASCADE,
    FOREIGN KEY (semester_id) REFERENCES Semester (id) ON DELETE CASCADE,
)

CREATE TABLE StudentStudies
(
    student_id                int  NOT NULL,
    studies_id                int  NOT NULL,
    registration_payment_date date NOT NULL, -- wpisowe
    certificate_post_date     date,

    PRIMARY KEY (student_id, studies_id),

    FOREIGN KEY (student_id) REFERENCES Student (id) ON DELETE CASCADE,
    FOREIGN KEY (studies_id) REFERENCES Studies (id) ON DELETE CASCADE,

    CONSTRAINT registration_payment_date_lower_certificate_post_date CHECK (registration_payment_date < certificate_post_date),
)

CREATE TABLE Subject
(
    id          int          NOT NULL IDENTITY (1, 1),
    name        varchar(200) NOT NULL,
    semester_id int          NOT NULL,
    teacher_id  int,

    PRIMARY KEY (id),

    FOREIGN KEY (semester_id) REFERENCES Semester (id) ON DELETE CASCADE,
    FOREIGN KEY (teacher_id) REFERENCES Teacher (id) ON DELETE SET NULL,
)

CREATE TABLE Internship
(
    id         int  NOT NULL IDENTITY (1, 1),
    studies_id int  NOT NULL,
    date       date NOT NULL,

    PRIMARY KEY (id),

    FOREIGN KEY (studies_id) REFERENCES Studies (id) ON DELETE CASCADE,
)

CREATE TABLE StudentInternship
(
    student_id    int           NOT NULL,
    internship_id int           NOT NULL,
    attended_days int DEFAULT 0 NOT NULL,
    exam_result   int

    PRIMARY KEY (student_id, internship_id),

    FOREIGN KEY (student_id) REFERENCES Student (id) ON DELETE CASCADE,
    FOREIGN KEY (internship_id) REFERENCES Internship (id) ON DELETE CASCADE,

    CONSTRAINT not_negative_attended_days CHECK (attended_days >= 0),
    CONSTRAINT exam_result_between_0_and_100 CHECK (exam_result >= 0 AND exam_result <= 100),
)

CREATE TABLE Meeting
(
    id                      int         NOT NULL IDENTITY (1, 1),
    module_id               int,
    subject_id              int,
    url                     varchar(200),
    date                    datetime        NOT NULL,
    type                    varchar(10) NOT NULL,
    standalone_price        int, --in Polish grosz
    translator_id           int,
    substituting_teacher_id int DEFAULT NULL,
    student_limit           int         NOT NULL,

    PRIMARY KEY (id),

    FOREIGN KEY (module_id) REFERENCES Module (id) ON DELETE NO ACTION,
    FOREIGN KEY (subject_id) REFERENCES Subject (id) ON DELETE NO ACTION,
    FOREIGN KEY (translator_id) REFERENCES Translator (id) ON DELETE SET NULL,
    FOREIGN KEY (substituting_teacher_id) REFERENCES Teacher (id) ON DELETE NO ACTION,

    CONSTRAINT polymorphic CHECK (
        module_id IS NOT NULL AND subject_id IS NULL OR
        module_id IS NULL AND subject_id IS NOT NULL
        ),
    CONSTRAINT type_and_url CHECK (type = 'in_person' OR type IN ('online', 'video') AND url IS NOT NULL),
    CONSTRAINT positive_student_limit CHECK (student_limit > 0),
    CONSTRAINT positive_standalone_price CHECK (standalone_price is NULL OR standalone_price > 0),
)

CREATE TABLE StudentMeeting
(
    student_id   int NOT NULL,
    meeting_id   int NOT NULL,
    payment_date date,

    PRIMARY KEY (student_id, meeting_id),

    FOREIGN KEY (student_id) REFERENCES Student (id) ON DELETE CASCADE,
    FOREIGN KEY (meeting_id) REFERENCES Meeting (id) ON DELETE CASCADE,
)

CREATE TABLE StudentMeetingAttendance
(
    student_id int NOT NULL,
    meeting_id int NOT NULL,

    PRIMARY KEY (student_id, meeting_id),

    FOREIGN KEY (student_id) REFERENCES Student (id) ON DELETE CASCADE,
    FOREIGN KEY (meeting_id) REFERENCES Meeting (id) ON DELETE CASCADE,
)

CREATE TABLE Basket
(
    id           int         NOT NULL IDENTITY (1, 1),
    student_id   int         NOT NULL,
    payment_url  varchar(200),
    state        varchar(15) NOT NULL,
    create_date  date        NOT NULL,
    payment_date date,

    PRIMARY KEY (id),

    FOREIGN KEY (student_id) REFERENCES Student (id) ON DELETE CASCADE,

    CONSTRAINT state_enum CHECK (state IN ('open', 'pending_payment', 'success_payment', 'failed_payment')),
    CONSTRAINT state_and_payment_url CHECK (state = 'open' OR payment_url IS NOT NULL ),
    CONSTRAINT payment_date_greaterEq_create_date CHECK (payment_date IS NULL OR payment_date >= create_date),
)

CREATE TABLE BasketItem
(
    basket_id  int NOT NULL,
    course_id  int NULL,
    meeting_id int NULL,
    studies_id int NULL,
    webinar_id int NULL,

    UNIQUE (basket_id, course_id, meeting_id, studies_id, webinar_id),

    FOREIGN KEY (basket_id) REFERENCES Basket (id) ON DELETE CASCADE,
    FOREIGN KEY (course_id) REFERENCES Course (id),
    FOREIGN KEY (meeting_id) REFERENCES Meeting (id),
    FOREIGN KEY (studies_id) REFERENCES Studies (id),
    FOREIGN KEY (webinar_id) REFERENCES Webinar (id),

    CONSTRAINT polymorphism CHECK (
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

GO

