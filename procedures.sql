CREATE PROCEDURE add_student
    @first_name VARCHAR(50),
    @last_name VARCHAR(50),
    @address VARCHAR(200),
    @email VARCHAR(50),
    @phone VARCHAR(20)
AS
BEGIN
    INSERT INTO Student (first_name, last_name, address, email, phone_number)
    VALUES (@first_name, @last_name, @address, @email, @phone);
END;
GO

CREATE PROCEDURE add_teacher
    @first_name VARCHAR(50),
    @last_name VARCHAR(50),
    @address VARCHAR(200),
    @email VARCHAR(50),
    @phone VARCHAR(20)
AS
BEGIN
    INSERT INTO Teacher (first_name, last_name, address, email, phone_number)
    VALUES (@first_name, @last_name, @address, @email, @phone);
END;
GO

CREATE PROCEDURE add_translator
    @first_name VARCHAR(50),
    @last_name VARCHAR(50),
    @address VARCHAR(200),
    @email VARCHAR(50),
    @phone VARCHAR(20),
    @language VARCHAR(50)
AS
BEGIN
    INSERT INTO Translator (first_name, last_name, address, email, phone_number, language)
    VALUES (@first_name, @last_name, @address, @email, @phone, @language);
END;
GO

CREATE PROCEDURE update_student
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
            SET first_name = @first_name
            WHERE id = @student_id;
        END
    IF @last_name IS NOT NULL
        BEGIN
            UPDATE Student
            SET last_name = @last_name
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

CREATE PROCEDURE update_teacher
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
            SET first_name = @first_name
            WHERE id = @teacher_id;
        END
    IF @last_name IS NOT NULL
        BEGIN
            UPDATE Teacher
            SET last_name = @last_name
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

CREATE PROCEDURE update_translator
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
            SET first_name = @first_name
            WHERE id = @translator_id;
        END
    IF @last_name IS NOT NULL
        BEGIN
            UPDATE Translator
            SET last_name = @last_name
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

CREATE PROCEDURE add_webinar
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

CREATE PROCEDURE update_webinar
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

CREATE PROCEDURE add_course
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

CREATE PROCEDURE update_course
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

CREATE PROCEDURE add_module
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

CREATE PROCEDURE update_module
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

CREATE PROCEDURE add_studies
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

CREATE PROCEDURE update_studies
    @studies_id INT,
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
            WHERE id = @studies_id;
        END
    IF @student_limit IS NOT NULL
        BEGIN
            UPDATE Studies
            SET student_limit = @student_limit
            WHERE id = @studies_id;
        END
    IF @price IS NOT NULL
        BEGIN
            UPDATE Studies
            SET price = @price
            WHERE id = @studies_id;
        END
    IF @advance_price IS NOT NULL
        BEGIN
            UPDATE Studies
            SET advance_price = @advance_price
            WHERE id = @studies_id;
        END
    IF @syllabus IS NOT NULL
        BEGIN
            UPDATE Studies
            SET syllabus = @syllabus
            WHERE id = @studies_id;
        END
    IF @language IS NOT NULL
        BEGIN
            UPDATE Studies
            SET language = @language
            WHERE id = @studies_id;
        END
END;
GO

CREATE PROCEDURE add_semester
    @studies_id INT,
    @start_date DATE,
    @end_date DATE,
    @schedule VARCHAR(50) = NULL,
    @number INT = NULL
AS
BEGIN
    IF @number IS NULL
        SET @number = dbo.get_last_semester(@studies_id) + 1;

    INSERT INTO Semester (studies_id, number, start_date, end_date, schedule)
    VALUES (@studies_id, @number, @start_date, @end_date, @schedule);
END;
GO

CREATE PROCEDURE update_semester
    @semester_id INT,
    @studies_id INT = NULL,
    @start_date DATE = NULL,
    @end_date DATE = NULL,
    @schedule VARCHAR(50) = NULL,
    @number INT = NULL
AS
BEGIN
    IF @studies_id IS NOT NULL
        BEGIN
            UPDATE Semester
            SET studies_id = @studies_id
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

CREATE PROCEDURE add_subject
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

CREATE PROCEDURE update_subject
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

CREATE PROCEDURE add_meeting
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

CREATE PROCEDURE update_meeting
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

CREATE PROCEDURE enroll_student_for_meeting
    @student_id INT,
    @meeting_id INT,
    @payment_date DATETIME = NULL
AS
BEGIN
    INSERT INTO StudentMeeting (student_id, meeting_id, payment_date)
    VALUES (@student_id, @meeting_id, @payment_date);
END;
GO

CREATE PROCEDURE disenroll_student_from_meeting
    @student_id INT,
    @meeting_id INT
AS
BEGIN
    DELETE FROM StudentMeeting
    WHERE student_id = @student_id AND meeting_id = @meeting_id;
END;
GO

CREATE PROCEDURE register_meeting_payment
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

CREATE PROCEDURE enroll_student_for_course
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

CREATE PROCEDURE disenroll_student_from_course
    @student_id INT,
    @course_id INT
AS
BEGIN
    DELETE FROM StudentCourse
    WHERE student_id = @student_id AND course_id = @course_id;
END;
GO

CREATE PROCEDURE register_course_payment
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

CREATE PROCEDURE enroll_student_for_studies
    @student_id INT,
    @studies_id INT,
    @registration_payment_date DATETIME = NULL
AS
BEGIN
    INSERT INTO StudentStudies (student_id, studies_id, registration_payment_date)
    VALUES (@student_id, @studies_id, @registration_payment_date);
END;
GO

CREATE PROCEDURE disenroll_student_from_studies
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

CREATE PROCEDURE register_studies_payment
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

CREATE PROCEDURE send_graduation_certificate
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

CREATE PROCEDURE enroll_student_for_webinar
    @student_id INT,
    @webinar_id INT,
    @payment_date DATETIME = NULL
AS
BEGIN
    INSERT INTO StudentWebinar (student_id, webinar_id, payment_date)
    VALUES (@student_id, @webinar_id, @payment_date);
END;
GO

CREATE PROCEDURE disenroll_student_from_webinar
    @student_id INT,
    @webinar_id INT
AS
BEGIN
    DELETE FROM StudentWebinar
    WHERE student_id = @student_id AND webinar_id = @webinar_id;
END;
GO

CREATE PROCEDURE register_webinar_payment
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

CREATE PROCEDURE enroll_student_for_semester
    @student_id INT,
    @semester_id INT,
    @payment_date DATETIME = NULL
AS
BEGIN
    INSERT INTO StudentSemester (student_id, semester_id, payment_date)
    VALUES (@student_id, @semester_id, @payment_date);
END;
GO

CREATE PROCEDURE disenroll_student_from_semester
    @student_id INT,
    @semester_id INT
AS
BEGIN
    DELETE FROM StudentSemester
    WHERE student_id = @student_id AND semester_id = @semester_id;
END;
GO

CREATE PROCEDURE register_semester_payment
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

CREATE PROCEDURE enroll_student_for_internship
    @student_id INT,
    @internship_id INT
AS
BEGIN
    INSERT INTO InternshipStudent (student_id, internship_id)
    VALUES (@student_id, @internship_id);
END;
GO

CREATE PROCEDURE disenroll_student_from_internship
    @student_id INT,
    @internship_id INT
AS
BEGIN
    DELETE FROM InternshipStudent
    WHERE student_id = @student_id AND internship_id = @internship_id;
END;
GO

CREATE PROCEDURE register_internship_attendance
    @student_id INT,
    @internship_id INT
AS
BEGIN
    UPDATE InternshipStudent
    SET attended_days = attended_days + 1
    WHERE student_id = @student_id AND internship_id = @internship_id;
END;
GO

CREATE PROCEDURE register_internship_exam_result
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

CREATE PROCEDURE register_meeting_attendance
    @student_id INT,
    @meeting_id INT
AS
BEGIN
    INSERT INTO StudentMeetingAttendance (student_id, meeting_id)
    VALUES (@student_id, @meeting_id);
END;
GO

CREATE PROCEDURE add_parameter
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

CREATE PROCEDURE create_basket
@student_id INT
AS
BEGIN
    INSERT INTO Basket (student_id, state, create_date)
    VALUES (@student_id, 'open', CURRENT_TIMESTAMP);
END;
GO

CREATE PROCEDURE add_item_to_basket
    @student_id INT,
    @course_id INT = NULL,
    @meeting_id INT = NULL,
    @studies_id INT = NULL,
    @webinar_id INT = NULL
AS
BEGIN
    DECLARE @basket_id INT = dbo.get_students_basket(@student_id);

    IF @basket_id IS NULL
        BEGIN
            EXEC create_basket @student_id;
            SET @basket_id = dbo.get_students_basket(@student_id);
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

CREATE PROCEDURE remove_item_from_basket
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

CREATE PROCEDURE register_failed_payment
@basket_id INT
AS
BEGIN
    UPDATE Basket
    SET state = 'failed_payment'
    WHERE id = @basket_id;
END;
GO

CREATE PROCEDURE register_successful_payment
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
                    EXEC add_student_to_course @student_id, @current_course, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP;
                END
            IF @current_meeting IS NOT NULL
                BEGIN
                    EXEC add_student_to_meeting @student_id, @current_meeting, CURRENT_TIMESTAMP;
                END
            IF @current_studies IS NOT NULL
                BEGIN
                    EXEC add_student_to_studies @student_id, @current_studies, CURRENT_TIMESTAMP;
                END
            IF @current_webinar IS NOT NULL
                BEGIN
                    EXEC add_student_to_webinar @student_id, @current_webinar, CURRENT_TIMESTAMP;
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
