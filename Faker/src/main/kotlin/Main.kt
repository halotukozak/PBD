package org.oolab.model

import com.typesafe.config.ConfigFactory
import io.github.serpro69.kfaker.faker
import model.*
import org.jetbrains.exposed.sql.Database
import org.jetbrains.exposed.sql.SchemaUtils
import org.jetbrains.exposed.sql.deleteAll
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.transactions.transaction
import org.slf4j.LoggerFactory

fun main() {
  val config = ConfigFactory.load("application.conf")

  Database.connect(
    url = config.getConfig("database").getString("url"),
    driver = config.getConfig("database").getString("driver"),
    user = config.getConfig("database").getString("user"),
    password = config.getConfig("database").getString("password")
  )

  val logger = LoggerFactory.getLogger("Main")

  val faker = faker {
    fakerConfig {
      locale = "pl"
    }
  }

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
  ).also {
    SchemaUtils.sortTablesByReferences(it)
  }

  transaction {
    val names = tables.map { it.tableName }.toSet()
    val dbNames = SchemaUtils.listTables().map { it.removePrefix("dbo.") }.toSet()
    require(names == dbNames) {
      "Missing tables in database: ${dbNames - names}"
      "Missing tables in code: ${names - dbNames}"
    }
    require(!SchemaUtils.checkCycle(*tables.toTypedArray()))
  }

  transaction {
    while (tables.any { it.selectAll().count() > 0 }) { //to avoid constraint violations, the order should be changed
      tables.forEach {
        try {
          it.deleteAll()
        } catch (e: Exception) {
          logger.warn(e.message)
        }
      }
    }
  }

  transaction {
    SchemaUtils.statementsRequiredToActualizeScheme(*tables.toTypedArray())
  }.let {
    require(it.isEmpty()) {
      "Invalid schemas:\n${it.joinToString("\n")}"
    }
  }

  val insertManager = InsertManager(faker)

  val students = insertManager.insertStudents()
  val teachers = insertManager.insertTeachers()
  val translators = insertManager.insertTranslators()
  val webinars = insertManager.insertWebinars(translators, teachers)
  val studies = insertManager.insertStudies()
  val semesters = insertManager.insertSemesters(studies)
  val subjects = insertManager.insertSubjects(semesters, teachers)
  val internships = insertManager.insertInternships(studies)
  val baskets = insertManager.insertBaskets(students)
  val rooms = insertManager.insertRooms()
  val courses = insertManager.insertCourses()
  val modules = insertManager.insertModules(courses, rooms, teachers)
  val meetings = insertManager.insertMeetings(modules, subjects, translators, teachers)
}
