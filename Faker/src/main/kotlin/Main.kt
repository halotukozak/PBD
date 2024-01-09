package org.oolab.model

import com.typesafe.config.ConfigFactory
import io.github.serpro69.kfaker.faker
import model.*
import mu.KotlinLogging
import org.jetbrains.exposed.sql.Database
import org.jetbrains.exposed.sql.SchemaUtils
import org.jetbrains.exposed.sql.deleteAll
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.transactions.transaction
import org.slf4j.Logger

suspend fun main() {
  val logger = KotlinLogging.logger("Main")
  require(logger.isWarnEnabled && logger.isInfoEnabled && logger.isDebugEnabled) {
    "Logger not configured properly"
  }

  val config = ConfigFactory.load("application.conf")

  logger.info { "Config loaded" }

  Database.connect(
    url = config.getConfig("database").getString("url"),
    driver = config.getConfig("database").getString("driver"),
    user = config.getConfig("database").getString("user"),
    password = config.getConfig("database").getString("password")
  )

  logger.info { "Database connected" }

  val faker = faker {
    fakerConfig {
      locale = "pl"
    }
  }

  logger.info { "Faker initialized" }

  val tables = listOf(
    Baskets,
    BasketItems,
    Courses,
    Internships,
    Meetings,
    Modules,
    Rooms,
    Semesters,
    StudiesTable,
    Subjects,
    Teachers,
    Translators,
    Webinars,
    Students,
    StudentSemesters,
    StudentStudies,
    Internships,
    InternshipStudent,
    Parameters,
    StudentCourses,
    StudentMeetings,
    StudentMeetingAttendance,
    StudentWebinars,
  ).let {
    SchemaUtils.sortTablesByReferences(it)
  }

  logger.info { "Tables initialized" }

  transaction {
    val names = tables.map { it.tableName }.toSet()
    val dbNames = SchemaUtils.listTables().map { it.removePrefix("dbo.") }.toSet()
    require(names == dbNames) {
      "Missing tables in database: ${dbNames - names}"
      "Missing tables in code: ${names - dbNames}"
    }
    require(!SchemaUtils.checkCycle(*tables.toTypedArray()))
  }

  logger.info { "Tables checked" }

  transaction {
    retry(3, logger) {
      require(tables.fold(true) { success, it ->
        try {
          it.deleteAll()
          success
        } catch (e: Exception) {
          logger.warn(e.message)
          false
        }
      })
    }
  }

  transaction {
    tables.forEach {
      require(it.selectAll().empty()) {
        "Table ${it.tableName} is not empty"
      }
    }
  }

  logger.info { "Tables cleared" }

  transaction {
    SchemaUtils.statementsRequiredToActualizeScheme(*tables.toTypedArray())
  }.let {
    require(it.isEmpty()) {
      "Invalid schemas:\n${it.joinToString("\n")}"
    }
  }

  logger.info { "Schemas checked" }

  val insertManager = InsertManager(faker)

  logger.info { "InsertManager initialized" }

  val studentIds = insertManager.insertStudents()
  logger.info { "${studentIds.count()} Students inserted" }
  val teacherIds = insertManager.insertTeachers()
  logger.info { "${teacherIds.count()} Teachers inserted" }
  val translatorIds = insertManager.insertTranslators()
  logger.info { "${translatorIds.count()} Translators inserted" }
  val webinarIds = insertManager.insertWebinars(translatorIds, teacherIds)
  logger.info { "${webinarIds.count()} Webinars inserted" }
  val studiesIds = insertManager.insertStudies()
  logger.info { "${studiesIds.count()} Studies inserted" }
  val semesterIds = insertManager.insertSemesters(studiesIds)
  logger.info { "${semesterIds.count()} Semesters inserted" }
  val subjectIds = insertManager.insertSubjects(semesterIds, teacherIds)
  logger.info { "${subjectIds.count()} Subjects inserted" }
  val internshipIds = insertManager.insertInternships(studiesIds)
  logger.info { "${internshipIds.count()} Internships inserted" }
  val basketIds = insertManager.insertBaskets(studentIds)
  logger.info { "${basketIds.count()} Baskets inserted" }
  val roomIds = insertManager.insertRooms()
  logger.info { "${roomIds.count()} Rooms inserted" }
  val courseIds = insertManager.insertCourses()
  logger.info { "${courseIds.count()} Courses inserted" }
  val moduleIds = insertManager.insertModules(courseIds, roomIds, teacherIds)
  logger.info { "${moduleIds.count()} Modules inserted" }
  val meetingIds = insertManager.insertMeetings(moduleIds, subjectIds, translatorIds, teacherIds)
  logger.info { "${meetingIds.count()} Meetings inserted" }
  val parameters = insertManager.insertParameters()
  logger.info { "$parameters Parameters inserted" }

  val basketItems = insertManager.insertBasketItems(basketIds, courseIds, meetingIds, studiesIds, webinarIds)
  logger.info { "$basketItems BasketItems inserted" }
  val internshipStudents = insertManager.insertInternshipStudents(internshipIds, studentIds)
  logger.info { "$internshipStudents InternshipStudents inserted" }
  val studentCourses = insertManager.insertStudentCourses(courseIds, studentIds)
  logger.info { "$studentCourses StudentCourses inserted" }
  val studentMeetings = insertManager.insertStudentMeetings(meetingIds, studentIds)
  logger.info { "$studentMeetings StudentMeetings inserted" }
  val studentMeetingAttendance = insertManager.insertStudentMeetingAttendance(studentIds, meetingIds)
  logger.info { "$studentMeetingAttendance StudentMeetingAttendance inserted" }
  val studentWebinars = insertManager.insertStudentWebinars(webinarIds, studentIds)
  logger.info { "$studentWebinars StudentWebinars inserted" }
  val studentStudies = insertManager.insertStudentStudies(studiesIds, studentIds)
  logger.info { "$studentStudies StudentStudies inserted" }
  val studentSemesters = insertManager.insertStudentSemesters(semesterIds, studentIds)
  logger.info { "$studentSemesters StudentSemesters inserted" }
}

fun <T> retry(
  times: Int = 3, logger: Logger, block: () -> T
): T? {
  repeat(times - 1) {
    try {
      return block()
    } catch (e: Exception) {
      logger.error(e.message)
    }
  }
  return block()
}