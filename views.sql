USE u_bkozak

-- 1. Raporty finansowe – zestawienie przychodów dla każdego webinaru
CREATE VIEW webinar_financial_report AS
SELECT Webinar.id, SUM(webinar.price) AS income
FROM Webinar
INNER JOIN StudentWebinar ON Webinar.id = StudentWebinar.webinar_id
GROUP BY Webinar.id
GO
-- 2. Raporty finansowe – zestawienie przychodów dla każdego kursu
CREATE VIEW course_financial_report AS
SELECT Course.id, SUM(Course.price) AS income
FROM Course
INNER JOIN StudentCourse ON Course.id = StudentCourse.course_id WHERE full_payment_date IS NOT NULL
GROUP BY Course.id

SELECT Course.id, SUM(Course.advance_price) AS income
FROM Course
INNER JOIN StudentCourse ON Course.id = StudentCourse.course_id WHERE full_payment_date IS NULL
GROUP BY Course.id

SELECT Course.id, Meeting.id, Meeting.standalone_price AS income
FROM Course
INNER JOIN Module ON Course.id = Module.course_id
INNER JOIN Meeting ON Module.id = Meeting.module_id
INNER JOIN StudentMeeting ON Meeting.id = StudentMeeting.meeting_id
WHERE Meeting.id = 512
-- GROUP BY Course.id, Meeting.id
GO
-- 3. Raporty finansowe – zestawienie przychodów dla każdych studiów
CREATE VIEW studies_financial_report AS
SELECT Studies.id, SUM(webinar.price) AS income
FROM Studies
INNER JOIN Course ON Studies.id = Course.studies_id
INNER JOIN Webinar ON Course.id = Webinar.course_id
INNER JOIN StudentWebinar ON Webinar.id = StudentWebinar.webinar_id
GROUP BY Studies.id
GO

-- 2. Lista „dłużników” – osoby, które skorzystały z usług, ale nie uiściły opłat.
-- 3. Ogólny raport dotyczący liczby zapisanych osób na przyszłe wydarzenia (z informacją,
-- czy wydarzenie jest stacjonarnie, czy zdalnie).
-- 4. Ogólny raport dotyczący frekwencji na zakończonych już wydarzeniach.
-- 5. Lista obecności dla każdego szkolenia z datą, imieniem, nazwiskiem i informacją czy
-- uczestnik był obecny, czy nie.
-- 6. Raport bilokacji: lista osób, które są zapisane na co najmniej dwa przyszłe szkolenia,
-- które ze sobą kolidują czasowo.