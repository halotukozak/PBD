package org.oolab.model

import com.microsoft.sqlserver.jdbc.SQLServerException
import io.github.serpro69.kfaker.Faker
import model.*
import mu.KotlinLogging
import org.jetbrains.exposed.sql.StdOutSqlLogger
import org.jetbrains.exposed.sql.addLogger
import org.jetbrains.exposed.sql.insertAndGetId
import org.jetbrains.exposed.sql.transactions.transaction

class InsertManager(private val faker: Faker) {
  private val logger = KotlinLogging.logger("InsertManager")

  init {
    require(logger.isWarnEnabled && logger.isInfoEnabled && logger.isDebugEnabled) {
      "Logger not configured properly"
    }
  }

  fun insertMeetings(
    moduleIds: List<Int>,
    subjectIds: List<Int>,
    translatorIds: List<Int>,
    teacherIds: List<Int>,
    n: Int = 10,
  ): List<Int> = List(n) {
    safeTransaction {
      val withModule = faker.random.nextBoolean()
      Meetings.insertAndGetId {
        it[moduleId] = if (withModule) moduleIds.random() else null
        it[subjectId] = if (withModule) null else subjectIds.random()
        it[url] = faker.internet.url(domain = faker.pokemon.names(), content = faker.yoda.quotes())
        it[date] = faker.dateTime()
        it[type] = faker.random.nextEnum<MeetingType>()
        it[standalonePrice] = faker.random.nextFloat()
        it[translatorId] = if (faker.random.nextBoolean()) translatorIds.random() else null
        it[substitutingTeacherId] = if (faker.random.nextBoolean()) teacherIds.random() else null
        it[studentLimit] = faker.random.nextInt(1, 20)
      }
    }
  }.mapNotNull { it?.value }

  fun insertModules(
    courseIds: List<Int>,
    roomIds: List<Int>,
    teacherIds: List<Int>,
    n: Int = 10,
  ): List<Int> = List(n) {
    val tpe = faker.random.nextEnum<ModuleType>()
    safeTransaction {
      Modules.insertAndGetId {
        it[courseId] = courseIds.random()
        it[type] = tpe
        it[roomId] = when {
          tpe == ModuleType.in_person -> roomIds.random()
          tpe == ModuleType.hybrid && faker.random.nextBoolean() -> roomIds.random()
          else -> null
        }
        it[teacherId] = teacherIds.random()
      }
    }
  }.mapNotNull { it?.value }

  fun insertCourses(
    n: Int = 10,
  ): List<Int> = List(n) {
    safeTransaction {
      Course.new {
        price = faker.random.nextFloat()
        advancePrice = faker.random.nextFloat()
        subject = faker.commerce.productName()
        language = faker.nation.language()
        studentLimit = faker.random.nextInt(1, 5)
      }
    }
  }.mapNotNull { it?.id?.value }

  fun insertRooms(
    n: Int = 10,
  ): List<Int> = List(n) {
    safeTransaction {
      Room.new {
        number = faker.string.numerify("##.##")
        building = faker.address.buildingNumber()
      }
    }
  }.mapNotNull { it?.id?.value }

  fun insertBaskets(
    studentIds: List<Int>,
    n: Int = 10,
  ): List<Int> = List(n) {
    safeTransaction {
      val isOpen = faker.random.nextBoolean()
      Baskets.insertAndGetId {
        it[studentId] = studentIds.random()
        it[paymentUrl] = if (isOpen) null else faker.internet.url(
          domain = faker.minecraft.mobs(),
          content = faker.harryPotter.quotes(),
        )
        it[state] = if (isOpen) BasketState.open else BasketState.entries.filter { it != BasketState.open }.random()
        it[createDate] = faker.date()
        it[paymentDate] = if (faker.random.nextBoolean()) faker.date() else null
      }
    }
  }.mapNotNull { it?.value }

  fun insertInternships(
    studiesIds: List<Int>,
    n: Int = 10,
  ): List<Int> = List(n) {
    safeTransaction {
      Internships.insertAndGetId {
        it[studiesId] = studiesIds.random()
        it[date] = faker.date()
      }
    }
  }.mapNotNull { it?.value }

  fun insertSubjects(
    semesterIds: List<Int>,
    teacherIds: List<Int>,
    n: Int = 10,
  ): List<Int> = List(n) {
    safeTransaction {
      Subjects.insertAndGetId {
        it[name] = faker.science.branch.formalBasic()
        it[semesterId] = semesterIds.random()
        it[teacherId] = teacherIds.random()
      }
    }
  }.mapNotNull { it?.value }

  fun insertSemesters(
    studiesIds: List<Int>,
  ): List<Int> = studiesIds.flatMap { studiesId ->
    val numberOfSemesters = faker.random.nextInt(1, 12)
    generateSequence(faker.date().let { it to faker.date(it) }) { (_, endDate) ->
      endDate.plusDays(1)?.let { it to it.plusMonths(6) }
    }
      .take(numberOfSemesters)
      .mapIndexed { i, (startDat, endDat) ->
        safeTransaction {
          Semesters.insertAndGetId {
            it[number] = i + 1
            it[this.studiesId] = studiesId
            it[schedule] =
              faker.internet.url(domain = faker.coffee.blendName(), content = faker.spongebob.quotes()).take(50)
            it[startDate] = startDat
            it[endDate] = endDat
          }
        }
      }
  }.mapNotNull { it?.value }

  fun insertStudies(
    n: Int = 10,
  ): List<Int> = List(n) {
    safeTransaction {
      Studies.new {
        syllabus =
          List(faker.random.nextInt(5, 30)) { faker.bible.quote() }.reduce { s, other -> "$s $other" }.take(5000)
        price = faker.random.nextFloat()
        advancePrice = faker.random.nextFloat()
        language = faker.nation.language()
        studentLimit = faker.random.nextInt(1, 5)
      }
    }
  }.mapNotNull { it?.id?.value }

  fun insertWebinars(
    translatorIds: List<Int>,
    teacherIds: List<Int>,
    n: Int = 10,
  ): List<Int> = List(n) {
    safeTransaction {
      Webinars.insertAndGetId {
        it[price] = faker.random.nextFloat()
        it[date] = faker.dateTime()
        it[url] = faker.internet.url(domain = faker.witcher.potions(), content = faker.starWars.quote())
        it[language] = faker.nation.language()
        it[translatorId] = if (faker.random.nextBoolean()) translatorIds.random() else null
        it[teacherId] = teacherIds.random()
      }
    }
  }.mapNotNull { it?.value }

  fun insertTranslators(
    n: Int = 10,
  ): List<Int> = List(n) {
    safeTransaction {
      val name = faker.name
      Translator.new {
        this.language = faker.nation.language()
        this.name = name.firstName()
        this.surname = name.lastName()
        this.address = faker.address.fullAddress()
        this.email = faker.internet.email(name)
        this.phoneNumber = faker.phoneNumber.phoneNumber()
      }
    }
  }.mapNotNull { it?.id?.value }

  fun insertTeachers(
    n: Int = 10,
  ): List<Int> = List(n) {
    safeTransaction {
      val (name, surname) = faker.name.let { it.name() to it.lastName() }
      Teacher.new {
        this.name = name
        this.surname = surname
        this.address = faker.address.fullAddress()
        this.email = faker.internet.email(name)
        this.phoneNumber = faker.phoneNumber.phoneNumber()
      }
    }
  }.mapNotNull { it?.id?.value }

  fun insertStudents(
    n: Int = 10,
  ): List<Int> = List(n) {
    safeTransaction {
      val name = faker.name
      Student.new {
        this.name = name.firstName()
        this.surname = name.lastName()
        this.address = faker.address.fullAddress()
        this.email = faker.internet.email(name)
        this.phoneNumber = faker.phoneNumber.phoneNumber()
      }
    }
  }.mapNotNull { it?.id?.value }

  private fun <T> safeTransaction(f: () -> T): T? = try {
    transaction {
      addLogger(StdOutSqlLogger)
      f()
    }
  } catch (e: SQLServerException) {
    logger.warn(e.message)
    if (e.message?.contains("Violation of UNIQUE KEY constraint") == true) null
    else throw e
  }
}
