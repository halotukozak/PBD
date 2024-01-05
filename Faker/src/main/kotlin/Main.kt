package org.oolab.model

import com.typesafe.config.ConfigFactory
import io.github.serpro69.kfaker.Faker
import io.github.serpro69.kfaker.faker
import model.*
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.transactions.transaction
import org.slf4j.LoggerFactory

fun main() {
  val config = ConfigFactory.load("application.conf")

  val dbConfig = config.getConfig("database")
  val url = dbConfig.getString("url")
  val driver = dbConfig.getString("driver")
  val user = dbConfig.getString("user")
  val password = dbConfig.getString("password")

  Database.connect(
    url = url,
    driver = driver,
    user = user,
    password = password
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

  val studentsId = students(faker)
  val teachersId = teachers(faker)
  val translatorsId = translators(faker)
  val webinarsId = webinars(faker, translatorsId, teachersId)
  val studiesId = studies(faker)
  val semestersId = semesters(faker, studiesId)
  val subjectsId = subjects(faker, semestersId, teachersId)
  val internshipsId = internships(studiesId, faker)
  val basketsId = baskets(faker, studentsId)
  val roomsId = rooms(faker)
  val coursesId = courses(faker)
  val modulesId = modules(coursesId, faker, roomsId, teachersId)
  val meetingsId = meetings(faker, modulesId, subjectsId, translatorsId, teachersId)
}

private fun meetings(
  faker: Faker, modules: List<Int>, subjects: List<Int>, translators: List<Int>, teachers: List<Int>
) = insert(5) {
  val withModule = faker.random.nextBoolean()
  Meetings.insert {
    it[moduleId] = if (withModule) modules.random() else null
    it[subjectId] = if (withModule) null else subjects.random()
    it[url] = faker.internet.domain()
    it[date] = faker.date()
    it[type] = faker.random.nextEnum<MeetingType>()
    it[standalonePrice] = faker.random.nextFloat()
    it[translatorId] = if (faker.random.nextBoolean()) translators.random() else null
    it[substitutingTeacherId] = if (faker.random.nextBoolean()) teachers.random() else null
    it[studentLimit] = faker.random.nextInt(1, 20)
  }
}

private fun modules(
  courses: List<Int>, faker: Faker, rooms: List<Int>, teachers: List<Int>
) = insert(5) {
  Modules.insertAndGetId {
    it[courseId] = courses.random()
    it[type] = faker.random.nextEnum<ModuleType>()
    it[roomId] = rooms.random()
    it[teacherId] = teachers.random()
  }
}.map { it.value }

private fun courses(faker: Faker) = insert(5) {
  Course.new {
    price = faker.random.nextFloat()
    advancePrice = faker.random.nextFloat()
    subject = faker.commerce.productName()
    language = faker.nation.language()
    studentLimit = faker.random.nextInt(1, 5)
  }
}.map { it.id.value }

private fun rooms(faker: Faker) = insert(5) {
  Room.new {
    number = faker.string.numerify("##.##")
    building = faker.address.buildingNumber()
  }
}.map { it.id.value }

private fun baskets(
  faker: Faker, students: List<Int>
) = insert(5) {
  val isOpen = faker.random.nextBoolean()
  Baskets.insertAndGetId {
    it[studentId] = students.random()
    it[paymentUrl] = if (isOpen) faker.internet.domain() else null
    it[state] = if (isOpen) BasketState.open else BasketState.entries.filter { it != BasketState.open }.random()
    it[createDate] = faker.date()
    it[paymentDate] = if (faker.random.nextBoolean()) faker.date() else null
  }
}

private fun internships(
  studies: List<Int>, faker: Faker
) = insert(5) {
  Internships.insertAndGetId {
    it[studiesId] = studies.random()
    it[date] = faker.date()
  }
}

private fun subjects(
  faker: Faker, semesters: List<Int>, teachers: List<Int>
) = insert(5) {
  Subjects.insertAndGetId {
    it[name] = faker.science.branch.formalBasic()
    it[semesterId] = semesters.random()
    it[teacherId] = teachers.random()
  }
}.map { it.value }

private fun semesters(
  faker: Faker, studies: List<Int>
) = insert(5) {
  val startDat = faker.date()
  Semesters.insertAndGetId {
    it[number] = faker.random.nextInt(1, 12)
    it[studiesId] = studies.random()
    it[schedule] = faker.lorem.words()
    it[startDate] = startDat
    it[endDate] = faker.date(startDat)
  }
}.map { it.value }

private fun studies(faker: Faker) = insert(5) {
  Studies.new {
    syllabus = faker.lorem.supplemental()
    price = faker.random.nextFloat()
    advancePrice = faker.random.nextFloat()
    language = faker.nation.language()
    studentLimit = faker.random.nextInt(1, 5)
  }
}.map { it.id.value }

private fun webinars(
  faker: Faker, translators: List<Int>, teachers: List<Int>
) = insert(5) {
  Webinars.insertAndGetId {
    it[price] = faker.random.nextFloat()
    it[date] = faker.date()
    it[url] = faker.internet.domain()
    it[language] = faker.nation.language()
    it[translatorId] = translators.random()
    it[teacherId] = teachers.random()
  }
}

private fun translators(faker: Faker) = insert(5) {
  val (name, surname) = faker.name.let { it.name() to it.lastName() }
  Translator.new {
    this.language = faker.nation.language()
    this.name = name
    this.surname = surname
    this.address = faker.address.fullAddress()
    this.email = faker.internet.email(name)
    this.phoneNumber = faker.phoneNumber.phoneNumber()
  }
}.map { it.id.value }

private fun teachers(faker: Faker): List<Int> = insert(5) {
  val (name, surname) = faker.name.let { it.name() to it.lastName() }
  Teacher.new {
    this.name = name
    this.surname = surname
    this.address = faker.address.fullAddress()
    this.email = faker.internet.email(name)
    this.phoneNumber = faker.phoneNumber.phoneNumber()
  }
}.map { it.id.value }

private fun students(faker: Faker): List<Int> = insert(5) {
  val (name, surname) = faker.name.let { it.firstName() to it.lastName() }
  Student.new {
    this.name = name
    this.surname = surname
    this.address = faker.address.fullAddress()
    this.email = faker.internet.email(name)
    this.phoneNumber = faker.phoneNumber.phoneNumber()
  }
}.map { it.id.value }

fun <T> insert(n: Int, f: () -> T) = List(n) {
  try {
    transaction {
      addLogger(StdOutSqlLogger)
      f()
    }
  } catch (ignored: Exception) {
    null
  }
}.filterNotNull()