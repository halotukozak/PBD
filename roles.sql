CREATE ROLE system;
GRANT EXECUTE ON  add_item_to_basket TO system;
GRANT EXECUTE ON  remove_item_from_basket TO system;
GRANT EXECUTE ON  register_failed_payment TO system;
GRANT EXECUTE ON register_successful_payment TO system;
GRANT EXECUTE ON  send_graduation_certificate TO system;



CREATE ROLE scheduler;
GRANT SELECT ON future_studies_students TO scheduler;
GRANT SELECT ON future_courses_students TO scheduler;
GRANT SELECT ON future_webinars_students TO scheduler;
GRANT SELECT ON future_meetings_students TO scheduler;
GRANT SELECT ON student_bilocation_list TO scheduler;
GRANT SELECT ON teacher_bilocation_list TO scheduler;
GRANT SELECT ON translator_bilocation_list TO scheduler;
GRANT SELECT ON room_bilocation_list TO scheduler;

GRANT EXECUTE ON does_meetings_overlap TO scheduler;
GRANT EXECUTE ON student_overlapping_meetings TO scheduler;
GRANT EXECUTE ON teacher_overlapping_meetings TO scheduler;
GRANT EXECUTE ON translator_overlapping_meetings TO scheduler;
GRANT EXECUTE ON room_meetings TO scheduler;
GRANT EXECUTE ON room_overlapping_meetings TO scheduler;

GRANT EXECUTE ON add_webinar TO scheduler;
GRANT EXECUTE ON update_webinar TO scheduler;
GRANT EXECUTE ON add_course TO scheduler;
GRANT EXECUTE ON update_course TO scheduler;
GRANT EXECUTE ON add_module TO scheduler;
GRANT EXECUTE ON update_module TO scheduler;
GRANT EXECUTE ON add_studies TO scheduler;
GRANT EXECUTE ON update_studies TO scheduler;
GRANT EXECUTE ON add_semester TO scheduler;
GRANT EXECUTE ON update_semester TO scheduler;
GRANT EXECUTE ON add_subject TO scheduler;
GRANT EXECUTE ON update_subject TO scheduler;
GRANT EXECUTE ON add_meeting TO scheduler;
GRANT EXECUTE ON update_meeting TO scheduler;
GRANT EXECUTE ON enroll_student_for_meeting TO scheduler;
GRANT EXECUTE ON disenroll_student_from_meeting TO scheduler;
GRANT EXECUTE ON enroll_student_for_course TO scheduler;
GRANT EXECUTE ON disenroll_student_from_course TO scheduler;
GRANT EXECUTE ON enroll_student_for_studies TO scheduler;
GRANT EXECUTE ON disenroll_student_from_studies TO scheduler;
GRANT EXECUTE ON enroll_student_for_webinar TO scheduler;
GRANT EXECUTE ON disenroll_student_from_webinar TO scheduler;
GRANT EXECUTE ON enroll_student_for_semester TO scheduler;
GRANT EXECUTE ON enroll_student_for_internship TO scheduler;
GRANT EXECUTE ON disenroll_student_from_semester TO scheduler;
GRANT EXECUTE ON disenroll_student_from_internship TO scheduler;



CREATE ROLE rector;
GRANT SELECT ON master_list TO rector;
GRANT SELECT ON graduates_without_diploma TO rector;

GRANT EXECUTE ON is_internship_finished TO rector;
GRANT EXECUTE ON students_enrolled_on_studies TO rector;
GRANT EXECUTE ON students_enrolled_on_semester TO rector;
GRANT EXECUTE ON get_student_info TO rector;
GRANT EXECUTE ON get_teacher_info TO rector;
GRANT EXECUTE ON get_translator_info TO rector;
GRANT EXECUTE ON get_last_semester TO rector;
GRANT EXECUTE ON is_enrolled_on_studies TO rector;
GRANT EXECUTE ON get_parameter_history TO rector;
GRANT EXECUTE ON student_meetings TO rector;
GRANT EXECUTE ON studies_graduates TO rector;
GRANT EXECUTE ON course_graduates TO rector;

GRANT EXECUTE ON add_student TO rector;
GRANT EXECUTE ON add_teacher TO rector;
GRANT EXECUTE ON add_translator TO rector;
GRANT EXECUTE ON update_student TO rector;
GRANT EXECUTE ON update_teacher TO rector;
GRANT EXECUTE ON update_translator TO rector;
GRANT EXECUTE ON register_internship_exam_result TO rector;
GRANT EXECUTE ON add_parameter TO rector;



CREATE ROLE manager;
GRANT SELECT ON webinar_financial_report TO manager;
GRANT SELECT ON course_financial_report TO manager;
GRANT SELECT ON studies_financial_report TO manager;
GRANT SELECT ON students_who_purchased_meeting TO manager;
GRANT SELECT ON debtor_list TO manager;
GRANT SELECT ON future_studies_students TO manager;
GRANT SELECT ON future_courses_students TO manager;
GRANT SELECT ON future_webinars_students TO manager;
GRANT SELECT ON future_meetings_students TO manager;
GRANT SELECT ON pending_payments TO manager;

GRANT EXECUTE ON get_student_info TO manager;
GRANT EXECUTE ON get_teacher_info TO manager;
GRANT EXECUTE ON get_translator_info TO manager;
GRANT EXECUTE ON get_student_basket TO manager;
GRANT EXECUTE ON get_parameter_history TO manager;
GRANT EXECUTE ON course_advance_income TO manager;
GRANT EXECUTE ON course_full_income TO manager;
GRANT EXECUTE ON studies_registration_income TO manager;
GRANT EXECUTE ON semester_income TO manager;
GRANT EXECUTE ON failed_payments TO manager;
GRANT EXECUTE ON successful_payments TO manager;

GRANT EXECUTE ON add_parameter TO manager;



CREATE ROLE student;
GRANT EXECUTE ON studies_start_date TO student;
GRANT EXECUTE ON course_start_date TO student;
GRANT EXECUTE ON teacher_meetings TO student;
GRANT EXECUTE ON teacher_subjects TO student;
GRANT EXECUTE ON teacher_modules TO student;
GRANT EXECUTE ON teacher_webinars TO student;
GRANT EXECUTE ON room_meetings TO student;
GRANT EXECUTE ON student_meetings TO student;
GRANT EXECUTE ON basket_item_price TO student;



CREATE ROLE teacher;
GRANT SELECT ON attendance_on_meetings TO teacher;

GRANT EXECUTE ON was_present_on_meeting TO teacher;
GRANT EXECUTE ON get_studies_of_semester TO teacher;
GRANT EXECUTE ON studies_start_date TO teacher;
GRANT EXECUTE ON course_start_date TO teacher;
GRANT EXECUTE ON students_enrolled_on_course TO teacher;
GRANT EXECUTE ON students_enrolled_on_webinar TO teacher;
GRANT EXECUTE ON students_enrolled_on_meeting TO teacher;
GRANT EXECUTE ON students_present_on_meeting TO teacher;
GRANT EXECUTE ON meeting_attendance_list TO teacher;
GRANT EXECUTE ON teacher_meetings TO teacher;
GRANT EXECUTE ON teacher_subjects TO teacher;
GRANT EXECUTE ON teacher_modules TO teacher;
GRANT EXECUTE ON teacher_webinars TO teacher;
GRANT EXECUTE ON room_meetings TO teacher;

GRANT EXECUTE ON register_internship_attendance TO teacher;
GRANT EXECUTE ON register_meeting_attendance TO teacher;



CREATE ROLE translator;
GRANT EXECUTE ON translator_meetings TO translator;
GRANT EXECUTE ON translator_webinars TO translator;



CREATE ROLE administrator;
GRANT ALL PRIVILEGES ON u_bkozak.dbo TO administrator;