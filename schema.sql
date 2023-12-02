CREATE TABLE [Student]
(
    [id]      int         NOT NULL,
    [name]    varchar(50) NOT NULL,
    [surname] varchar(50) NOT NULL,
    [adress]  varchar(50) NOT NULL,
    PRIMARY KEY ([id])
)

CREATE TABLE [Teacher]
(
    [id]      int,
    [name]    varchar(50) NOT NULL,
    [surname] varchar(50) NOT NULL
)

CREATE TABLE [StudentWebinar]
(
    [student_id]   int,
    [webinar_id]   int,
    [payment_date] date
)

CREATE TABLE [Translator]
(
    [id]       int,
    [language] varchar(50)
)

CREATE TABLE [Webinar]
(
    [id]            int,
    [price]         float,
    [date]          date,
    [url]           varchar(50),
    [language]      varchar(50) DEFAULT 'Polish',
    [translator_id] int,
    [teacher_id]    int
)

CREATE TABLE [StudentCourse]
(
    [student_id]            int,
    [course_id]             int,
    [advance_payment_date]  date,
    [full_payment_date]     date,
    [credit_date]           date,
    [certificate_post_date] date
)

CREATE TABLE [Course]
(
    [id]            int,
    [price]         float,
    [advance_price] float,
    [subject]       varchar(50),
    [language]      varchar(50) DEFAULT 'Polish',
    [student_limit] int
)

CREATE TABLE [Module]
(
    [id]         int,
    [course_id]  int,
    [type]       nvarchar(255) NOT NULL CHECK ([type] IN ('online_sync', 'online_async', 'inperson', 'hybrid')),
    [room_id]    int,
    [teacher_id] int
)

CREATE TABLE [StudentMeetingAttendance]
(
    [student_id] int,
    [meeting_id] int
)

CREATE TABLE [StudentSemester]
(
    [student_id]   int,
    [semester_id]  int,
    [payment_date] date
)

CREATE TABLE [StudentStudies]
(
    [student_id]                int,
    [studies_id]                int,
    [registration_payment_date] date,
    [certificate_post_date]     date
)

CREATE TABLE [Studies]
(
    [id]            int,
    [syllabus]      varchar(50),
    [price]         float,
    [advance_price] float,
    [language]      varchar(50),
    [student_limit] int
)

CREATE TABLE [Semester]
(
    [id]         int,
    [number]     int,
    [studies_id] int,
    [schedule]   varchar(50)
)

CREATE TABLE [Subject]
(
    [id]          int,
    [name]        varchar(50),
    [semester_id] int,
    [teacher_id]  int
)

CREATE TABLE [Internship]
(
    [id]         int,
    [studies_id] int,
    [date]       date
)

CREATE TABLE [InternshipAttendence]
(
    [student_id]    int,
    [internship_id] int,
    [attended_days] int
)

CREATE TABLE [InternshipExam]
(
    [internship_id] int,
    [student_id]    int,
    [result]        int
)

CREATE TABLE [StudentMeeting]
(
    [student_id]   int,
    [meeting_id]   int,
    [payment_date] date
)

CREATE TABLE [Room]
(
    [id]      int,
    [number]  varchar(50),
    [bulding] varchar(50)
)

CREATE TABLE [Meeting]
(
    [id]                      int,
    [module_id]               int,
    [subject_id]              int,
    [url]                     varchar(50),
    [date]                    date,
    [type]                    nvarchar(255) NOT NULL CHECK ([type] IN ('inperson', 'online', 'video')),
    [standalone_price]        float,
    [translator_id]           int,
    [substituting_teacher_id] int,
    [student_limit]           int
)

CREATE TABLE [Basket]
(
    [id]           int,
    [student_id]   int,
    [payment_url]  varchar(50),
    [state]        nvarchar(255) NOT NULL CHECK ([state] IN
                                                 ('open', 'pending_payment', 'success_payment', 'failed_payment')),
    [create_date]  date,
    [payment_date] date
)

CREATE TABLE [BasketItem]
(
    [basket_id]  int,
    [course_id]  int,
    [meeting_id] int,
    [studies_id] int,
    [webinar_id] int
)

CREATE TABLE [Parameter]
(
    [id]    int,
    [type]  varchar(50),
    [value] varchar(50),
    [date]  date
)

ALTER TABLE [StudentWebinar]
    ADD FOREIGN KEY ([student_id]) REFERENCES [Student] ([id])

ALTER TABLE [StudentWebinar]
    ADD FOREIGN KEY ([webinar_id]) REFERENCES [Webinar] ([id])

ALTER TABLE [Webinar]
    ADD FOREIGN KEY ([translator_id]) REFERENCES [Translator] ([id])

ALTER TABLE [Webinar]
    ADD FOREIGN KEY ([teacher_id]) REFERENCES [Teacher] ([id])

ALTER TABLE [StudentCourse]
    ADD FOREIGN KEY ([student_id]) REFERENCES [Student] ([id])

ALTER TABLE [StudentCourse]
    ADD FOREIGN KEY ([course_id]) REFERENCES [Course] ([id])

ALTER TABLE [Module]
    ADD FOREIGN KEY ([course_id]) REFERENCES [Course] ([id])

ALTER TABLE [Module]
    ADD FOREIGN KEY ([room_id]) REFERENCES [Room] ([id])

ALTER TABLE [Module]
    ADD FOREIGN KEY ([teacher_id]) REFERENCES [Teacher] ([id])

ALTER TABLE [StudentMeetingAttendance]
    ADD FOREIGN KEY ([student_id]) REFERENCES [Student] ([id])

ALTER TABLE [StudentMeetingAttendance]
    ADD FOREIGN KEY ([meeting_id]) REFERENCES [Meeting] ([id])

ALTER TABLE [StudentSemester]
    ADD FOREIGN KEY ([student_id]) REFERENCES [Student] ([id])

ALTER TABLE [StudentSemester]
    ADD FOREIGN KEY ([semester_id]) REFERENCES [Semester] ([id])

ALTER TABLE [StudentStudies]
    ADD FOREIGN KEY ([student_id]) REFERENCES [Student] ([id])

ALTER TABLE [StudentStudies]
    ADD FOREIGN KEY ([studies_id]) REFERENCES [Studies] ([id])

ALTER TABLE [Semester]
    ADD FOREIGN KEY ([studies_id]) REFERENCES [Studies] ([id])

ALTER TABLE [Subject]
    ADD FOREIGN KEY ([semester_id]) REFERENCES [Semester] ([id])

ALTER TABLE [Subject]
    ADD FOREIGN KEY ([teacher_id]) REFERENCES [Teacher] ([id])

ALTER TABLE [Internship]
    ADD FOREIGN KEY ([studies_id]) REFERENCES [Studies] ([id])

ALTER TABLE [InternshipAttendence]
    ADD FOREIGN KEY ([student_id]) REFERENCES [Student] ([id])

ALTER TABLE [InternshipAttendence]
    ADD FOREIGN KEY ([internship_id]) REFERENCES [Internship] ([id])

ALTER TABLE [InternshipExam]
    ADD FOREIGN KEY ([internship_id]) REFERENCES [Internship] ([id])

ALTER TABLE [InternshipExam]
    ADD FOREIGN KEY ([student_id]) REFERENCES [Student] ([id])

ALTER TABLE [StudentMeeting]
    ADD FOREIGN KEY ([student_id]) REFERENCES [Student] ([id])

ALTER TABLE [StudentMeeting]
    ADD FOREIGN KEY ([meeting_id]) REFERENCES [Meeting] ([id])

ALTER TABLE [Meeting]
    ADD FOREIGN KEY ([module_id]) REFERENCES [Module] ([id])

ALTER TABLE [Meeting]
    ADD FOREIGN KEY ([subject_id]) REFERENCES [Subject] ([id])

ALTER TABLE [Meeting]
    ADD FOREIGN KEY ([translator_id]) REFERENCES [Translator] ([id])

ALTER TABLE [Meeting]
    ADD FOREIGN KEY ([substituting_teacher_id]) REFERENCES [Teacher] ([id])

ALTER TABLE [Basket]
    ADD FOREIGN KEY ([student_id]) REFERENCES [Student] ([id])

ALTER TABLE [BasketItem]
    ADD FOREIGN KEY ([basket_id]) REFERENCES [Basket] ([id])

ALTER TABLE [BasketItem]
    ADD FOREIGN KEY ([course_id]) REFERENCES [Course] ([id])

ALTER TABLE [BasketItem]
    ADD FOREIGN KEY ([meeting_id]) REFERENCES [Meeting] ([id])

ALTER TABLE [BasketItem]
    ADD FOREIGN KEY ([studies_id]) REFERENCES [Studies] ([id])

ALTER TABLE [BasketItem]
    ADD FOREIGN KEY ([webinar_id]) REFERENCES [Webinar] ([id])
