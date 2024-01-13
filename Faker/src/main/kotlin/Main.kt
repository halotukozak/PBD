package org.oolab.model

import com.typesafe.config.Config
import com.typesafe.config.ConfigFactory
import com.typesafe.config.ConfigValue
import io.github.serpro69.kfaker.faker
import model.*
import mu.KotlinLogging
import org.jetbrains.exposed.sql.Database
import org.jetbrains.exposed.sql.SchemaUtils
import org.jetbrains.exposed.sql.deleteAll
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.transactions.transaction

suspend fun main() {
  val logger = KotlinLogging.logger("Main")
  require(logger.isWarnEnabled && logger.isInfoEnabled && logger.isDebugEnabled) {
    "Logger not configured properly"
  }

  val config = ConfigFactory.load("application.conf")

  val fakerConfig = config.getConfig("app")
  val dbConfig = config.getConfig("database")

  logger.info { "Config loaded" }

  Database.connect(
    url = dbConfig.getString("url"),
    driver = dbConfig.getString("driver"),
    user = dbConfig.getString("user"),
    password = dbConfig.getString("password")
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
    StudentInternship,
    Parameters,
    StudentCourses,
    StudentMeetings,
    StudentMeetingAttendance,
    StudentWebinars,
  ).let {
    transaction { SchemaUtils.sortTablesByReferences(it) }.asReversed()
  }

  logger.info { "Tables initialized" }

  val names = tables.map { it.tableName }.toSet()
  val dbNames = SchemaUtils::listTables.now().map { it.removePrefix("dbo.") }.toSet()

  require(names == dbNames) {
    "Missing tables in database: ${dbNames - names}\nMissing tables in code: ${names - dbNames}"
  }
  require(!SchemaUtils.checkCycle(*tables.toTypedArray()))

  logger.info { "Tables checked" }

  transaction {
    SchemaUtils.statementsRequiredToActualizeScheme(*tables.toTypedArray())
  }.let {
    require(it.isEmpty()) {
      "Invalid schemas:\n${it.joinToString("\n")}"
    }
  }

  logger.info { "Schemas checked" }

  val tableNamesToDrop = dbConfig.getList("tablesToDrop").map(ConfigValue::render)
  tables.filter { it.tableName in tableNamesToDrop }.forEach {
    it::deleteAll.now()
    require(it.selectAll()::empty.now()) {
      "Table ${it.tableName} is not empty"
    }
  }
  logger.info { "Tables cleared" }


  val insertManager = InsertManager(faker, fakerConfig)

  logger.info { "InsertManager initialized" }

  val studentIds = insertManager.insertStudents()
  logger.info { "$studentIds Students inserted" }
  val teacherIds = insertManager.insertTeachers()
  logger.info { "$teacherIds Teachers inserted" }
  val translatorIds = insertManager.insertTranslators()
  logger.info { "$translatorIds Translators inserted" }
  val languagesIds = insertManager.insertLanguages()
  logger.info { "$languagesIds Languages inserted" }
  val webinarIds = insertManager.insertWebinars()
  logger.info { "$webinarIds Webinars inserted" }
  val subjectIds = insertManager.insertSubjects()
  logger.info { "$subjectIds Subjects inserted" }
  val studiesIds = insertManager.insertStudies()
  logger.info { "$studiesIds Studies inserted" }
  val semesterIds = insertManager.insertSemesters()
  logger.info { "$semesterIds Semesters inserted" }
  val internshipIds = insertManager.insertInternships()
  logger.info { "$internshipIds Internships inserted" }
  val basketIds = insertManager.insertBaskets()
  logger.info { "$basketIds Baskets inserted" }
  val roomIds = insertManager.insertRooms()
  logger.info { "$roomIds Rooms inserted" }
  val courseIds = insertManager.insertCourses()
  logger.info { "$courseIds Courses inserted" }
  val moduleIds = insertManager.insertModules()
  logger.info { "$moduleIds Modules inserted" }
  val meetingIds = insertManager.insertMeetings()
  logger.info { "$meetingIds Meetings inserted" }
  if (fakerConfig.getBoolean("parameters")) {
    val parameters = insertManager.insertParameters()
    logger.info { "$parameters Parameters inserted" }
  }

  val basketItems = insertManager.insertBasketItems()
  logger.info { "$basketItems BasketItems inserted" }
  val internshipStudents = insertManager.insertStudentInternship()
  logger.info { "$internshipStudents InternshipStudents inserted" }
  val studentCourses = insertManager.insertStudentCourses()
  logger.info { "$studentCourses StudentCourses inserted" }
  val studentMeetings = insertManager.insertStudentMeetings()
  logger.info { "$studentMeetings StudentMeetings inserted" }
  val studentMeetingAttendance = insertManager.insertStudentMeetingAttendance()
  logger.info { "$studentMeetingAttendance StudentMeetingAttendance inserted" }
  val studentWebinars = insertManager.insertStudentWebinars()
  logger.info { "$studentWebinars StudentWebinars inserted" }
  val studentStudies = insertManager.insertStudentStudies()
  logger.info { "$studentStudies StudentStudies inserted" }
  val languageTranslators = insertManager.insertTranslatorLanguage()
  logger.info { "$languageTranslators LanguageTranslators inserted" }
}

fun <T> (() -> T).now(): T = transaction { this@now() }

fun Config.getRange(path: String): IntRange = getString(path).split("..").let { it[0].toInt()..it[1].toInt() }