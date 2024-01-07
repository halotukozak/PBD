package org.oolab.model

import com.microsoft.sqlserver.jdbc.SQLServerException
import io.github.serpro69.kfaker.Faker
import kotlinx.coroutines.flow.asFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.mapNotNull
import kotlinx.coroutines.flow.toList
import model.*
import mu.KotlinLogging
import org.jetbrains.exposed.sql.StdOutSqlLogger
import org.jetbrains.exposed.sql.addLogger
import org.jetbrains.exposed.sql.insert
import org.jetbrains.exposed.sql.insertAndGetId
import org.jetbrains.exposed.sql.transactions.experimental.newSuspendedTransaction

class InsertManager(private val faker: Faker) {
  private val logger = KotlinLogging.logger("InsertManager")

  init {
    require(logger.isWarnEnabled && logger.isInfoEnabled && logger.isDebugEnabled) {
      "Logger not configured properly"
    }
  }

  suspend fun insertMeetings(
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
        it[standalonePrice] = faker.finance.price()
        it[translatorId] = if (faker.random.nextBoolean()) translatorIds.random() else null
        it[substitutingTeacherId] = if (faker.random.nextBoolean()) teacherIds.random() else null
        it[studentLimit] = faker.random.nextInt(1, 20)
      }
    }
  }.mapNotNull { it?.value }

  suspend fun insertModules(
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

  suspend fun insertCourses(
    n: Int = 10,
  ): List<Int> = List(n) {
    safeTransaction {
      Course.new {
        price = faker.finance.price()
        advancePrice = faker.finance.price()
        subject = faker.commerce.productName()
        language = faker.nation.language()
        studentLimit = faker.random.nextInt(1, 5)
      }
    }
  }.mapNotNull { it?.id?.value }

  suspend fun insertRooms(
    n: Int = 10,
  ): List<Int> = List(n) {
    safeTransaction {
      Room.new {
        number = faker.string.numerify("##.##")
        building = faker.address.buildingNumber()
      }
    }
  }.mapNotNull { it?.id?.value }

  suspend fun insertBaskets(
    studentIds: List<Int>,
    n: Int = 10,
  ): List<Int> = List(n) {
    safeTransaction {
      val isOpen = faker.random.nextBoolean()
      val createDat = faker.date()
      Baskets.insertAndGetId {
        it[studentId] = studentIds.random()
        it[paymentUrl] = if (isOpen) null else faker.internet.url(
          domain = faker.minecraft.mobs(),
          content = faker.harryPotter.quotes(),
        )
        it[state] = if (isOpen) BasketState.open else BasketState.entries.filter { it != BasketState.open }.random()
        it[createDate] = createDat
        it[paymentDate] = if (faker.random.nextBoolean()) faker.date(createDat) else null
      }
    }
  }.mapNotNull { it?.value }

  suspend fun insertInternships(
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

  suspend fun insertSubjects(
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

  suspend fun insertSemesters(
    studiesIds: List<Int>,
  ): List<Int> = studiesIds.flatMap { studiesId ->
    val numberOfSemesters = faker.random.nextInt(1, 12)
    generateSequence(faker.date().let { it to faker.date(it) }) { (_, endDate) ->
      endDate.plusDays(1)?.let { it to it.plusMonths(6) }
    }
      .take(numberOfSemesters)
      .mapIndexed { i, x -> i to x }
      .asFlow()
      .map { (i, dates) ->
        safeTransaction {
          Semesters.insertAndGetId {
            it[number] = i + 1
            it[this.studiesId] = studiesId
            it[schedule] =
              faker.internet.url(domain = faker.coffee.blendName(), content = faker.spongebob.quotes()).take(50)
            it[startDate] = dates.first
            it[endDate] = dates.second
          }
        }
      }
      .mapNotNull { it?.value }
      .toList()
  }

  suspend fun insertStudies(
    n: Int = 10,
  ): List<Int> = List(n) {
    safeTransaction {
      Studies.new {
        syllabus =
          List(faker.random.nextInt(5, 30)) { faker.bible.quote() }.reduce { s, other -> "$s $other" }.take(5000)
        price = faker.finance.price()
        advancePrice = faker.finance.price()
        language = faker.nation.language()
        studentLimit = faker.random.nextInt(1, 5)
      }
    }
  }.mapNotNull { it?.id?.value }

  suspend fun insertWebinars(
    translatorIds: List<Int>,
    teacherIds: List<Int>,
    n: Int = 10,
  ): List<Int> = List(n) {
    safeTransaction {
      Webinars.insertAndGetId {
        it[price] = faker.finance.price()
        it[date] = faker.dateTime()
        it[url] = faker.internet.url(domain = faker.witcher.potions(), content = faker.starWars.quote())
        it[language] = faker.nation.language()
        it[translatorId] = if (faker.random.nextBoolean()) translatorIds.random() else null
        it[teacherId] = teacherIds.random()
      }
    }
  }.mapNotNull { it?.value }

  suspend fun insertTranslators(
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

  suspend fun insertTeachers(
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

  suspend fun insertStudents(
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

  suspend fun insertBasketItems(
    basketIds: List<Int>,
    courseIds: List<Int>,
    meetingIds: List<Int>,
    studiesIds: List<Int>,
    webinarIds: List<Int>,
    max: Int = 10,
  ): Int = basketIds.flatMap { basket ->
    List(faker.random.nextInt(max)) {
      val content = faker.random.nextInt(0, 3)
      safeTransaction {
        BasketItems.insert {
          it[basketId] = basket
          it[courseId] = if (content == 0) courseIds.random() else null
          it[meetingId] = if (content == 1) meetingIds.random() else null
          it[studiesId] = if (content == 2) studiesIds.random() else null
          it[webinarId] = if (content == 3) webinarIds.random() else null
        }
      }
    }
  }.count()

  suspend fun insertInternshipStudents(
    internshipIds: List<Int>,
    studentIds: List<Int>,
    max: Int = 10,
  ): Int = internshipIds.flatMap { internship ->
    List(faker.random.nextInt(max)) {
      safeTransaction {
        InternshipStudent.insert {
          it[internshipId] = internship
          it[studentId] = studentIds.random()
          it[examResult] = faker.random.nextInt(0, 100)
        }
      }
    }
  }.count()

  suspend fun insertStudentCourses(
    courseIds: List<Int>,
    studentIds: List<Int>,
    max: Int = 10,
  ): Int = studentIds.flatMap { student ->
    List(faker.random.nextInt(max)) {
      safeTransaction {
        StudentCourses.insert {
          it[studentId] = student
          it[courseId] = courseIds.random()
        }
      }
    }
  }.count()

  suspend fun insertStudentMeetings(
    meetingIds: List<Int>,
    studentIds: List<Int>,
    max: Int = 10,
  ): Int = studentIds.flatMap { student ->
    List(faker.random.nextInt(max)) {
      safeTransaction {
        StudentMeetings.insert {
          it[studentId] = student
          it[meetingId] = meetingIds.random()
          it[paymentDate] = faker.date()
        }
      }
    }
  }.count()

  suspend fun insertStudentMeetingAttendance(
    meetingIds: List<Int>,
    studentIds: List<Int>,
    max: Int = 10,
  ): Int = studentIds.flatMap { student ->
    List(faker.random.nextInt(max)) {
      safeTransaction {
        StudentMeetingAttendance.insert {
          it[studentId] = student
          it[meetingId] = meetingIds.random()
        }
      }
    }
  }.count()

  suspend fun insertStudentWebinars(
    webinarIds: List<Int>,
    studentIds: List<Int>,
    max: Int = 10,
  ): Int = studentIds.flatMap { student ->
    List(faker.random.nextInt(max)) {
      safeTransaction {
        StudentWebinars.insert {
          it[studentId] = student
          it[webinarId] = webinarIds.random()
          it[paymentDate] = faker.date()
        }
      }
    }
  }.count()

  suspend fun insertStudentStudies(
    studiesIds: List<Int>,
    studentIds: List<Int>,
    max: Int = 10,
  ): Int = studentIds.flatMap { student ->
    val registrationPaymentDat = faker.date()
    List(faker.random.nextInt(max)) {
      safeTransaction {
        StudentStudies.insert {
          it[studentId] = student
          it[studiesId] = studiesIds.random()
          it[registrationPaymentDate] = registrationPaymentDat
          it[certificatePostDate] = if (faker.random.nextBoolean()) faker.date(registrationPaymentDat) else null
        }
      }
    }
  }.count()

  suspend fun insertStudentSemesters(
    semesterIds: List<Int>,
    studentIds: List<Int>,
    max: Int = 10,
  ): Int = studentIds.flatMap { student ->
    List(faker.random.nextInt(max)) {
      safeTransaction {
        StudentSemesters.insert {
          it[studentId] = student
          it[semesterId] = semesterIds.random()
          it[paymentDate] = faker.date()
        }
      }
    }
  }.count()


  private suspend fun <T> safeTransaction(f: () -> T): T? = try {
    newSuspendedTransaction {
      addLogger(StdOutSqlLogger)
      f()
    }
  } catch (e: SQLServerException) {
    logger.warn(e.message)
    if (listOf(
        "Violation of UNIQUE KEY constraint",
        "Violation of PRIMARY KEY constraint",
        "Cannot insert duplicate key",
      ).any { it in e.message.orEmpty() }
    ) null
    else {
      throw e
    }
  }

}