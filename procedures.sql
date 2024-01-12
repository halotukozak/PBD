CREATE PROCEDURE AddStudent
    @first_name VARCHAR(50),
    @last_name VARCHAR(50),
    @address VARCHAR(200),
    @email VARCHAR(50),
    @phone VARCHAR(20)
AS
BEGIN
    INSERT INTO Student (name, surname, address, email, phone_number)
    VALUES (@first_name, @last_name, @address, @email, @phone);
END;
GO

CREATE PROCEDURE AddTeacher
    @first_name VARCHAR(50),
    @last_name VARCHAR(50),
    @address VARCHAR(200),
    @email VARCHAR(50),
    @phone VARCHAR(20)
AS
BEGIN
    INSERT INTO Teacher (name, surname, address, email, phone_number)
    VALUES (@first_name, @last_name, @address, @email, @phone);
END;
GO

CREATE PROCEDURE AddTranslator
    @first_name VARCHAR(50),
    @last_name VARCHAR(50),
    @address VARCHAR(200),
    @email VARCHAR(50),
    @phone VARCHAR(20),
    @language VARCHAR(50)
AS
BEGIN
    INSERT INTO Translator (name, surname, address, email, phone_number, language)
    VALUES (@first_name, @last_name, @address, @email, @phone, @language);
END;
GO
-- EXEC AddStudent 'Bartłomiej', 'Kozak', 'Kraków 607 Kapitol', 'b_kozak@student.agh.edu.pl', '123321123'



CREATE PROCEDURE UpdateStudent
    @student_id INT,
    @first_name VARCHAR(50) = NULL,
    @last_name VARCHAR(50) = NULL,
    @address VARCHAR(200) = NULL,
    @email VARCHAR(50) = NULL,
    @phone VARCHAR(20) = NULL
AS
BEGIN
    IF @first_name IS NOT NULL
        BEGIN
            UPDATE Student
            SET name = @first_name
            WHERE id = @student_id;
        END
    IF @last_name IS NOT NULL
        BEGIN
            UPDATE Student
            SET surname = @last_name
            WHERE id = @student_id;
        END
    IF @address IS NOT NULL
        BEGIN
            UPDATE Student
            SET address = @address
            WHERE id = @student_id;
        END
    IF @email IS NOT NULL
        BEGIN
            UPDATE Student
            SET email = @email
            WHERE id = @student_id;
        END
    IF @phone IS NOT NULL
        BEGIN
            UPDATE Student
            SET phone_number = @phone
            WHERE id = @student_id;
        END
END;
GO

CREATE PROCEDURE UpdateTeacher
    @teacher_id INT,
    @first_name VARCHAR(50) = NULL,
    @last_name VARCHAR(50) = NULL,
    @address VARCHAR(200) = NULL,
    @email VARCHAR(50) = NULL,
    @phone VARCHAR(20) = NULL
AS
BEGIN
    IF @first_name IS NOT NULL
        BEGIN
            UPDATE Teacher
            SET name = @first_name
            WHERE id = @teacher_id;
        END
    IF @last_name IS NOT NULL
        BEGIN
            UPDATE Teacher
            SET surname = @last_name
            WHERE id = @teacher_id;
        END
    IF @address IS NOT NULL
        BEGIN
            UPDATE Teacher
            SET address = @address
            WHERE id = @teacher_id;
        END
    IF @email IS NOT NULL
        BEGIN
            UPDATE Teacher
            SET email = @email
            WHERE id = @teacher_id;
        END
    IF @phone IS NOT NULL
        BEGIN
            UPDATE Teacher
            SET phone_number = @phone
            WHERE id = @teacher_id;
        END
END;
GO

CREATE PROCEDURE UpdateTranslator
    @translator_id INT,
    @first_name VARCHAR(50) = NULL,
    @last_name VARCHAR(50) = NULL,
    @address VARCHAR(200) = NULL,
    @email VARCHAR(50) = NULL,
    @phone VARCHAR(20) = NULL,
    @language VARCHAR(50) = NULL
AS
BEGIN
    IF @first_name IS NOT NULL
        BEGIN
            UPDATE Translator
            SET name = @first_name
            WHERE id = @translator_id;
        END
    IF @last_name IS NOT NULL
        BEGIN
            UPDATE Translator
            SET surname = @last_name
            WHERE id = @translator_id;
        END
    IF @address IS NOT NULL
        BEGIN
            UPDATE Translator
            SET address = @address
            WHERE id = @translator_id;
        END
    IF @email IS NOT NULL
        BEGIN
            UPDATE Translator
            SET email = @email
            WHERE id = @translator_id;
        END
    IF @phone IS NOT NULL
        BEGIN
            UPDATE Translator
            SET phone_number = @phone
            WHERE id = @translator_id;
        END
    IF @language IS NOT NULL
        BEGIN
            UPDATE Translator
            SET language = @language
            WHERE id = @translator_id;
        END
END;
GO
-- EXEC UpdateStudent 17,  @address = 'New address';



CREATE PROCEDURE AddWebinar
    @title VARCHAR(50),
    @date DATETIME,
    @teacher_id INT,
    @url VARCHAR(200),
    @price INT = NULL,
    @language VARCHAR(50) = NULL,
    @translator_id INT = NULL
AS
BEGIN
    IF @price IS NULL
        SET @price = 0;
    IF @language IS NULL
        SET @language = 'Polish';

    INSERT INTO Webinar (title, date, teacher_id, url, price, language, translator_id)
    VALUES (@title, @date, @teacher_id, @url, @price, @language, @translator_id);
END;
GO
-- EXEC AddWebinar 'Webinar 1', '2019-01-01 12:00:00', 1, 'https://www.youtube.com/watch?v=1', 10000

CREATE PROCEDURE UpdateWebinar
    @webinar_id INT,
    @title VARCHAR(50) = NULL,
    @date DATETIME = NULL,
    @teacher_id INT = NULL,
    @url VARCHAR(200) = NULL,
    @price INT = NULL,
    @language VARCHAR(50) = NULL,
    @translator_id INT = NULL
AS
BEGIN
    IF @title IS NOT NULL
        BEGIN
            UPDATE Webinar
            SET title = @title
            WHERE id = @webinar_id;
        END
    IF @date IS NOT NULL
        BEGIN
            UPDATE Webinar
            SET date = @date
            WHERE id = @webinar_id;
        END
    IF @teacher_id IS NOT NULL
        BEGIN
            UPDATE Webinar
            SET teacher_id = @teacher_id
            WHERE id = @webinar_id;
        END
    IF @url IS NOT NULL
        BEGIN
            UPDATE Webinar
            SET url = @url
            WHERE id = @webinar_id;
        END
    IF @price IS NOT NULL
        BEGIN
            UPDATE Webinar
            SET price = @price
            WHERE id = @webinar_id;
        END
    IF @language IS NOT NULL
        BEGIN
            UPDATE Webinar
            SET language = @language
            WHERE id = @webinar_id;
        END
    IF @translator_id IS NOT NULL
        BEGIN
            UPDATE Webinar
            SET translator_id = @translator_id
            WHERE id = @webinar_id;
        END
END;
GO
-- EXEC UpdateWebinar 1, @url = 'https://www.youtube.com/watch?v=2', @teacher_id = 2



CREATE PROCEDURE AddCourse
    @title VARCHAR(50),
    @student_limit INT,
    @price INT,
    @advance_price INT = NULL,
    @language VARCHAR(50) = NULL,
    @subject VARCHAR(100) = NULL
AS
BEGIN
    IF @advance_price IS NULL
        SET @advance_price = 0;
    IF @language IS NULL
        SET @language = 'Polish';

    INSERT INTO Course (title, student_limit, price, advance_price, language, subject)
    VALUES (@title, @student_limit, @price, @advance_price, @language, @subject);
END;
GO
-- EXEC AddCourse 'C#', 10, 50000, 500, 'English', 'Programming'

CREATE PROCEDURE UpdateCourse
    @course_id INT,
    @title VARCHAR(50) = NULL,
    @student_limit INT = NULL,
    @price INT = NULL,
    @advance_price INT = NULL,
    @language VARCHAR(50) = NULL,
    @subject VARCHAR(100) = NULL
AS
BEGIN
    IF @title IS NOT NULL
        BEGIN
            UPDATE Course
            SET title = @title
            WHERE id = @course_id;
        END
    IF @student_limit IS NOT NULL
        BEGIN
            UPDATE Course
            SET student_limit = @student_limit
            WHERE id = @course_id;
        END
    IF @price IS NOT NULL
        BEGIN
            UPDATE Course
            SET price = @price
            WHERE id = @course_id;
        END
    IF @advance_price IS NOT NULL
        BEGIN
            UPDATE Course
            SET advance_price = @advance_price
            WHERE id = @course_id;
        END
    IF @language IS NOT NULL
        BEGIN
            UPDATE Course
            SET language = @language
            WHERE id = @course_id;
        END
    IF @subject IS NOT NULL
        BEGIN
            UPDATE Course
            SET subject = @subject
            WHERE id = @course_id;
        END
END;
GO
-- EXEC UpdateCourse 1, @title = 'C++', @price = 5000



CREATE PROCEDURE AddModule
    @course_id INT,
    @teacher_id INT,
    @type VARCHAR(15),
    @room_id INT = NULL
AS
BEGIN
    INSERT INTO Module (course_id, teacher_id, type, room_id)
    VALUES (@course_id, @teacher_id, @type, @room_id);
END;
GO
-- EXEC AddModule 12, 23, 'in_person', 17

CREATE PROCEDURE UpdateModule
    @module_id INT,
    @course_id INT = NULL,
    @teacher_id INT = NULL,
    @type VARCHAR(15) = NULL,
    @room_id INT = NULL
AS
BEGIN
    IF @course_id IS NOT NULL
        BEGIN
            UPDATE Module
            SET course_id = @course_id
            WHERE id = @module_id;
        END
    IF @teacher_id IS NOT NULL
        BEGIN
            UPDATE Module
            SET teacher_id = @teacher_id
            WHERE id = @module_id;
        END
    IF @type IN ('online_sync', 'online_async')
        BEGIN
            UPDATE Module
            SET type = @type,
                room_id = NULL
            WHERE id = @module_id;
        END
    IF @type = 'in_person'
        BEGIN
            UPDATE Module
            SET type = @type,
                room_id = @room_id
            WHERE id = @module_id;
        END
    IF @type = 'hybrid'
        BEGIN
            UPDATE Module
            SET type = @type
            WHERE id = @module_id;
        END
    IF @room_id IS NOT NULL
        BEGIN
            UPDATE Module
            SET room_id = @room_id
            WHERE id = @module_id;
        END
END;
GO
-- EXEC UpdateModule 1, @type = 'online_sync'



CREATE PROCEDURE AddStudy
    @title VARCHAR(50),
    @student_limit INT,
    @price INT,
    @advance_price INT = NULL,
    @syllabus VARCHAR(5000) = NULL,
    @language VARCHAR(50) = NULL
AS
BEGIN
    IF @language IS NULL
        SET @language = 'Polish';

    INSERT INTO Studies (title, student_limit, price, advance_price, syllabus, language)
    VALUES (@title, @student_limit, @price, @advance_price, @syllabus, @language);
END;
GO
-- EXEC AddStudy 'Math', 150, 400000, 50000, 'we will be learning algebra'

CREATE PROCEDURE UpdateStudy
    @study_id INT,
    @title VARCHAR(50) = NULL,
    @student_limit INT = NULL,
    @price INT = NULL,
    @advance_price INT = NULL,
    @syllabus VARCHAR(5000) = NULL,
    @language VARCHAR(50) = NULL
AS
BEGIN
    IF @title IS NOT NULL
        BEGIN
            UPDATE Studies
            SET title = @title
            WHERE id = @study_id;
        END
    IF @student_limit IS NOT NULL
        BEGIN
            UPDATE Studies
            SET student_limit = @student_limit
            WHERE id = @study_id;
        END
    IF @price IS NOT NULL
        BEGIN
            UPDATE Studies
            SET price = @price
            WHERE id = @study_id;
        END
    IF @advance_price IS NOT NULL
        BEGIN
            UPDATE Studies
            SET advance_price = @advance_price
            WHERE id = @study_id;
        END
    IF @syllabus IS NOT NULL
        BEGIN
            UPDATE Studies
            SET syllabus = @syllabus
            WHERE id = @study_id;
        END
    IF @language IS NOT NULL
        BEGIN
            UPDATE Studies
            SET language = @language
            WHERE id = @study_id;
        END
END;
GO
-- EXEC UpdateStudy 1, @syllabus = 'We will be learning geometry'



CREATE PROCEDURE AddSemester
    @study_id INT,
    @start_date DATE,
    @end_date DATE,
    @schedule VARCHAR(50) = NULL,
    @number INT = NULL
AS
BEGIN
    IF @number IS NULL
        SET @number = dbo.getLastSemester(@study_id) + 1;

    INSERT INTO Semester (studies_id, number, start_date, end_date, schedule)
    VALUES (@study_id, @number, @start_date, @end_date, @schedule);
END;
GO
-- EXEC AddSemester 1, '2020-10-01', '2021-01-01'

CREATE PROCEDURE UpdateSemester
    @semester_id INT,
    @study_id INT = NULL,
    @start_date DATE = NULL,
    @end_date DATE = NULL,
    @schedule VARCHAR(50) = NULL,
    @number INT = NULL
AS
BEGIN
    IF @study_id IS NOT NULL
        BEGIN
            UPDATE Semester
            SET studies_id = @study_id
            WHERE id = @semester_id;
        END
    IF @start_date IS NOT NULL
        BEGIN
            UPDATE Semester
            SET start_date = @start_date
            WHERE id = @semester_id;
        END
    IF @end_date IS NOT NULL
        BEGIN
            UPDATE Semester
            SET end_date = @end_date
            WHERE id = @semester_id;
        END
    IF @schedule IS NOT NULL
        BEGIN
            UPDATE Semester
            SET schedule = @schedule
            WHERE id = @semester_id;
        END
    IF @number IS NOT NULL
        BEGIN
            UPDATE Semester
            SET number = @number
            WHERE id = @semester_id;
        END
END;
GO
-- EXEC UpdateSemester 17, @end_date =  '2021-01-01', @schedule = 'https://web.usos.agh.edu.pl/kontroler.php?_action=home/plan'



CREATE PROCEDURE AddSubject
    @name VARCHAR(200),
    @semester_id INT,
    @teacher_id INT,
    @room_id INT
AS
BEGIN
    INSERT INTO Subject (name, semester_id, teacher_id, room_id)
    VALUES (@name, @semester_id, @teacher_id, @room_id);
END;
GO
-- EXEC AddSubject 'Bazy danych', 17, 1

CREATE PROCEDURE UpdateSubject
    @subject_id INT,
    @name VARCHAR(200) = NULL,
    @semester_id INT = NULL,
    @teacher_id INT = NULL,
    @room_id INT = NULL
AS
BEGIN
    IF @name IS NOT NULL
        BEGIN
            UPDATE Subject
            SET name = @name
            WHERE id = @subject_id;
        END
    IF @semester_id IS NOT NULL
        BEGIN
            UPDATE Subject
            SET semester_id = @semester_id
            WHERE id = @subject_id;
        END
    IF @teacher_id IS NOT NULL
        BEGIN
            UPDATE Subject
            SET teacher_id = @teacher_id
            WHERE id = @subject_id;
        END
    IF @room_id IS NOT NULL
        BEGIN
            UPDATE Subject
            SET room_id = @room_id
            WHERE id = @subject_id;
        END
END;
GO
-- EXEC UpdateSubject 17, @name = 'Programowanie obiektowe', @teacher_id = 23



CREATE PROCEDURE AddMeeting
    @module_id INT = NULL,
    @subject_id INT = NULL,
    @date DATETIME,
    @student_limit INT,
    @type VARCHAR(10),
    @url VARCHAR(200) = NULL,
    @substituting_room_id INT = NULL,
    @substituting_teacher_id INT = NULL,
    @translator_id INT = NULL,
    @standalone_price INT = NULL
AS
BEGIN
    INSERT INTO Meeting (module_id, subject_id, date, student_limit, type, url, substituting_room_id, substituting_teacher_id, translator_id, standalone_price)
    VALUES (@module_id, @subject_id, @date, @student_limit, @type, @url, @substituting_room_id, @substituting_teacher_id, @translator_id, @standalone_price);
END;
GO
-- EXEC AddMeeting @module_id = 1, @date = '2021-01-01 12:00:00', @student_limit = 20, @type = 'in_person'

CREATE PROCEDURE UpdateMeeting
    @meeting_id INT,
    @module_id INT = NULL,
    @subject_id INT = NULL,
    @date DATETIME = NULL,
    @student_limit INT = NULL,
    @type VARCHAR(10) = NULL,
    @url VARCHAR(200) = NULL,
    @substituting_room_id INT = NULL,
    @substituting_teacher_id INT = NULL,
    @translator_id INT = NULL,
    @standalone_price INT = NULL
AS
BEGIN
    IF @module_id IS NOT NULL OR @subject_id IS NOT NULL
        BEGIN
            UPDATE Meeting
            SET module_id = @module_id,
                subject_id = @subject_id
            WHERE id = @meeting_id;
        END
    IF @date IS NOT NULL
        BEGIN
            UPDATE Meeting
            SET date = @date
            WHERE id = @meeting_id;
        END
    IF @student_limit IS NOT NULL
        BEGIN
            UPDATE Meeting
            SET student_limit = @student_limit
            WHERE id = @meeting_id;
        END
    IF @type IN ('online, video')
        BEGIN
            UPDATE Meeting
            SET type = @type,
                url = NULL
            WHERE id = @meeting_id;
        END
    IF @type LIKE 'in_person'
        BEGIN
            UPDATE Meeting
            SET type = @type
            WHERE id = @meeting_id;
        END
    IF @url IS NOT NULL
        BEGIN
            UPDATE Meeting
            SET url = @url
            WHERE id = @meeting_id;
        END
    IF @substituting_room_id IS NOT NULL
        BEGIN
            UPDATE Meeting
            SET substituting_room_id = @substituting_room_id
            WHERE id = @meeting_id;
        END
    IF @substituting_teacher_id IS NOT NULL
        BEGIN
            UPDATE Meeting
            SET substituting_teacher_id = @substituting_teacher_id
            WHERE id = @meeting_id;
        END
    IF @translator_id IS NOT NULL
        BEGIN
            UPDATE Meeting
            SET translator_id = @translator_id
            WHERE id = @meeting_id;
        END
    IF @standalone_price IS NOT NULL
        BEGIN
            UPDATE Meeting
            SET standalone_price = @standalone_price
            WHERE id = @meeting_id;
        END
END;
GO
-- EXEC UpdateMeeting 1, @substituting_teacher_id = 27, @substituting_room_id = 17



CREATE PROCEDURE AddStudentToMeeting
    @student_id INT,
    @meeting_id INT,
    @payment_date DATETIME = NULL
AS
BEGIN
    INSERT INTO StudentMeeting (student_id, meeting_id, payment_date)
    VALUES (@student_id, @meeting_id, @payment_date);
END;
GO
-- EXEC AddStudentToMeeting 17, 23, '2021-01-01 12:00:00'

CREATE PROCEDURE RemoveStudentFromMeeting
    @student_id INT,
    @meeting_id INT
AS
BEGIN
    DELETE FROM StudentMeeting
    WHERE student_id = @student_id AND meeting_id = @meeting_id;
END;
GO
-- EXEC RemoveStudentFromMeeting 17, 23

CREATE PROCEDURE PayForMeeting
    @student_id INT,
    @meeting_id INT,
    @payment_date DATETIME = CURRENT_TIMESTAMP
AS
BEGIN
    UPDATE StudentMeeting
    SET payment_date = @payment_date
    WHERE student_id = @student_id AND meeting_id = @meeting_id;
END;
GO
-- EXEC PayForMeeting 17, 23



CREATE PROCEDURE AddStudentToCourse
    @student_id INT,
    @course_id INT,
    @advance_payment_date DATETIME = NULL,
    @full_payment_date DATETIME = NULL
AS
BEGIN
    INSERT INTO StudentCourse (student_id, course_id, advance_payment_date, full_payment_date)
    VALUES (@student_id, @course_id, @advance_payment_date, @full_payment_date);
END;
GO
-- EXEC AddStudentToCourse 17, 23, @advance_payment_date = '2021-01-01 12:00:00'

CREATE PROCEDURE RemoveStudentFromCourse
    @student_id INT,
    @course_id INT
AS
BEGIN
    DELETE FROM StudentCourse
    WHERE student_id = @student_id AND course_id = @course_id;
END;
GO
-- EXEC RemoveStudentFromCourse 17, 23

CREATE PROCEDURE PayForCourse
    @student_id INT,
    @course_id INT,
    @advance_payment_date DATETIME = CURRENT_TIMESTAMP,
    @full_payment_date DATETIME = CURRENT_TIMESTAMP
AS
BEGIN
    UPDATE StudentCourse
    SET full_payment_date = @full_payment_date,
        advance_payment_date = @advance_payment_date
    WHERE student_id = @student_id AND course_id = @course_id;
END;
GO
-- EXEC PayForCourse 17, 23



CREATE PROCEDURE AddStudentToStudies
    @student_id INT,
    @studies_id INT,
    @registration_payment_date DATETIME = NULL
AS
BEGIN
    INSERT INTO StudentStudies (student_id, studies_id, registration_payment_date)
    VALUES (@student_id, @studies_id, @registration_payment_date);
END;
GO
-- EXEC AddStudentToStudies 17, 23, @registration_payment_date = '2021-01-01 12:00:00'

CREATE PROCEDURE RemoveStudentFromStudies
    @student_id INT,
    @studies_id INT
AS
BEGIN
    DELETE FROM StudentStudies
    WHERE student_id = @student_id AND studies_id = @studies_id;

    DELETE StudentSemester
    FROM StudentSemester
             INNER JOIN Semester ON StudentSemester.semester_id = Semester.id AND Semester.studies_id = @studies_id
    WHERE student_id = @student_id;
END;
GO
-- EXEC RemoveStudentFromStudies 17, 23

CREATE PROCEDURE PayForStudies
    @student_id INT,
    @studies_id INT,
    @registration_payment_date DATETIME = CURRENT_TIMESTAMP
AS
BEGIN
    UPDATE StudentStudies
    SET registration_payment_date = @registration_payment_date
    WHERE student_id = @student_id AND studies_id = @studies_id;
END;
GO
-- EXEC PayForStudies 17, 23

CREATE PROCEDURE SendGraduationCertificate
    @student_id INT,
    @studies_id INT,
    @certificate_post_date DATETIME = CURRENT_TIMESTAMP
AS
BEGIN
    UPDATE StudentStudies
    SET certificate_post_date = @certificate_post_date
    WHERE student_id = @student_id AND studies_id = @studies_id;
END;
GO
-- EXEC SendGraduationCertificate 17, 23



CREATE PROCEDURE AddStudentToWebinar
    @student_id INT,
    @webinar_id INT,
    @payment_date DATETIME = NULL
AS
BEGIN
    INSERT INTO StudentWebinar (student_id, webinar_id, payment_date)
    VALUES (@student_id, @webinar_id, @payment_date);
END;
GO
-- EXEC AddStudentToWebinar 17, 23, @payment_date = '2021-01-01 12:00:00'

CREATE PROCEDURE RemoveStudentFromWebinar
    @student_id INT,
    @webinar_id INT
AS
BEGIN
    DELETE FROM StudentWebinar
    WHERE student_id = @student_id AND webinar_id = @webinar_id;
END;
GO
-- EXEC RemoveStudentFromWebinar 17, 23

CREATE PROCEDURE PayForWebinar
    @student_id INT,
    @webinar_id INT,
    @payment_date DATETIME = CURRENT_TIMESTAMP
AS
BEGIN
    UPDATE StudentWebinar
    SET payment_date = @payment_date
    WHERE student_id = @student_id AND webinar_id = @webinar_id;
END;
GO
-- EXEC PayForWebinar 17, 23



CREATE PROCEDURE AddStudentToSemester
    @student_id INT,
    @semester_id INT,
    @payment_date DATETIME = NULL
AS
BEGIN
    INSERT INTO StudentSemester (student_id, semester_id, payment_date)
    VALUES (@student_id, @semester_id, @payment_date);
END;
GO
-- EXEC AddStudentToSemester 17, 23

CREATE PROCEDURE RemoveStudentFromSemester
    @student_id INT,
    @semester_id INT
AS
BEGIN
    DELETE FROM StudentSemester
    WHERE student_id = @student_id AND semester_id = @semester_id;
END;
GO
-- EXEC RemoveStudentFromSemester 17, 23

CREATE PROCEDURE PayForSemester
    @student_id INT,
    @semester_id INT,
    @payment_date DATETIME = CURRENT_TIMESTAMP
AS
BEGIN
    UPDATE StudentSemester
    SET payment_date = @payment_date
    WHERE student_id = @student_id AND semester_id = @semester_id;
END;
GO
-- EXEC PayForSemester 17, 23, @payment_date = '2021-01-01 12:00:00'



CREATE PROCEDURE AddStudentToInternship
    @student_id INT,
    @internship_id INT
AS
BEGIN
    INSERT INTO InternshipStudent (student_id, internship_id)
    VALUES (@student_id, @internship_id);
END;
GO
-- EXEC AddStudentToInternship 17, 23

CREATE PROCEDURE RemoveStudentFromInternship
    @student_id INT,
    @internship_id INT
AS
BEGIN
    DELETE FROM InternshipStudent
    WHERE student_id = @student_id AND internship_id = @internship_id;
END;
GO
-- EXEC RemoveStudentFromInternship 17, 23

CREATE PROCEDURE LogInternshipAttendance
    @student_id INT,
    @internship_id INT
AS
BEGIN
    UPDATE InternshipStudent
    SET attended_days = attended_days + 1
    WHERE student_id = @student_id AND internship_id = @internship_id;
END;
GO
-- EXEC LogInternshipAttendance 17, 23

CREATE PROCEDURE SetInternshipExamResult
    @student_id INT,
    @internship_id INT,
    @exam_result INT
AS
BEGIN
    UPDATE InternshipStudent
    SET exam_result = @exam_result
    WHERE student_id = @student_id AND internship_id = @internship_id;
END;
GO
-- EXEC SetInternshipExamResult 17, 23, 60



CREATE PROCEDURE LogMeetingAttendance
    @student_id INT,
    @meeting_id INT
AS
BEGIN
    INSERT INTO StudentMeetingAttendance (student_id, meeting_id)
    VALUES (@student_id, @meeting_id);
END;
GO
-- EXEC LogMeetingAttendance 17, 23



CREATE PROCEDURE AddParameter
    @name NVARCHAR(50),
    @value NVARCHAR(50),
    @date DATE = NULL
AS
BEGIN
    IF @date IS NULL
        SET @date = CURRENT_TIMESTAMP;

    INSERT INTO Parameter (name, value, date)
    VALUES (@name, @value, @date);
END;
GO
-- EXEC AddParameter 'TEST PARAMETER', 2, '2019-01-01';
-- EXEC AddParameter 'TEST PARAMETER', 'value';



CREATE PROCEDURE CreateBasket
@student_id INT
AS
BEGIN
    INSERT INTO Basket (student_id, state, create_date)
    VALUES (@student_id, 'open', CURRENT_TIMESTAMP);
END;
GO
-- EXEC CreateBasket 17

CREATE PROCEDURE AddItemToBasket
    @student_id INT,
    @course_id INT = NULL,
    @meeting_id INT = NULL,
    @studies_id INT = NULL,
    @webinar_id INT = NULL
AS
BEGIN
    DECLARE @basket_id INT = dbo.getStudentsBasket(@student_id);

    IF @basket_id IS NULL
        BEGIN
            EXEC CreateBasket @student_id;
            SET @basket_id = dbo.getStudentsBasket(@student_id);
        END

    IF @course_id IS NOT NULL
        BEGIN
            INSERT INTO BasketItem (basket_id, course_id)
            VALUES (@basket_id, @course_id);
        END

    IF @meeting_id IS NOT NULL
        BEGIN
            INSERT INTO BasketItem (basket_id, meeting_id)
            VALUES (@basket_id, @meeting_id);
        END

    IF @studies_id IS NOT NULL
        BEGIN
            INSERT INTO BasketItem (basket_id, studies_id)
            VALUES (@basket_id, @studies_id);
        END

    IF @webinar_id IS NOT NULL
        BEGIN
            INSERT INTO BasketItem (basket_id, webinar_id)
            VALUES (@basket_id, @webinar_id);
        END
END;
GO
-- EXEC AddItemToBasket 17, @course_id = 3

CREATE PROCEDURE RemoveItemFromBasket
    @basket_id INT,
    @course_id INT = NULL,
    @meeting_id INT = NULL,
    @studies_id INT = NULL,
    @webinar_id INT = NULL
AS
BEGIN
    IF @course_id IS NOT NULL
        BEGIN
            DELETE FROM BasketItem
            WHERE basket_id = @basket_id AND course_id = @course_id;
        END

    IF @meeting_id IS NOT NULL
        BEGIN
            DELETE FROM BasketItem
            WHERE basket_id = @basket_id AND meeting_id = @meeting_id;
        END

    IF @studies_id IS NOT NULL
        BEGIN
            DELETE FROM BasketItem
            WHERE basket_id = @basket_id AND studies_id = @studies_id;
        END

    IF @webinar_id IS NOT NULL
        BEGIN
            DELETE FROM BasketItem
            WHERE basket_id = @basket_id AND webinar_id = @webinar_id;
        END
END;
GO
-- EXEC RemoveItemFromBasket 35, @course_id = 3

CREATE PROCEDURE FailBasketPayment
@basket_id INT
AS
BEGIN
    UPDATE Basket
    SET state = 'failed_payment'
    WHERE id = @basket_id;
END;
GO
-- EXEC FailBasketPayment 35

CREATE PROCEDURE ApproveBasketPayment
@basket_id INT
AS
BEGIN
    DECLARE @student_id INT = (SELECT student_id FROM Basket WHERE id = @basket_id)
    DECLARE @current_course INT
    DECLARE @current_meeting INT
    DECLARE @current_studies INT
    DECLARE @current_webinar INT

    DECLARE BasketItemCursor CURSOR FOR
        SELECT course_id, meeting_id, studies_id, webinar_id
        FROM BasketItem
        WHERE basket_id = @basket_id

    OPEN BasketItemCursor
    FETCH NEXT FROM BasketItemCursor INTO @current_course, @current_meeting, @current_studies, @current_webinar

    WHILE @@FETCH_STATUS = 0
        BEGIN
            IF @current_course IS NOT NULL
                BEGIN
                    EXEC AddStudentToCourse @student_id, @current_course, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP;
                END
            IF @current_meeting IS NOT NULL
                BEGIN
                    EXEC AddStudentToMeeting @student_id, @current_meeting, CURRENT_TIMESTAMP;
                END
            IF @current_studies IS NOT NULL
                BEGIN
                    EXEC AddStudentToStudies @student_id, @current_studies, CURRENT_TIMESTAMP;
                END
            IF @current_webinar IS NOT NULL
                BEGIN
                    EXEC AddStudentToWebinar @student_id, @current_webinar, CURRENT_TIMESTAMP;
                END

            FETCH NEXT FROM BasketItemCursor INTO @current_course, @current_meeting, @current_studies, @current_webinar
        END;

    CLOSE BasketItemCursor
    DEALLOCATE BasketItemCursor

    UPDATE Basket
    SET state = 'success_payment'
    WHERE id = @basket_id;
END;
GO
-- EXEC ApproveBasketPayment 35

















