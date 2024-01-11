package org.oolab.model

import io.github.serpro69.kfaker.Faker
import kotlinx.coroutines.flow.asFlow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.flow.toList
import model.*
import mu.KotlinLogging
import org.jetbrains.exposed.sql.insert
import org.jetbrains.exposed.sql.insertAndGetId
import org.jetbrains.exposed.sql.transactions.experimental.newSuspendedTransaction
import java.time.LocalDateTime

@Suppress("LocalVariableName")
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
        if (withModule) it[moduleId] = moduleIds.random() else it[subjectId] = subjectIds.random()
        it[url] = faker.internet.url(domain = faker.pokemon.names(), path = faker.yoda.quotes())
        it[date] = faker.dateTime()
        it[type] = faker.random.nextEnum<MeetingType>()
        it[standalonePrice] = faker.random.nextInt(20_00..300_00)
        faker.random { it[translatorId] = translatorIds.random() }
        faker.random { it[substitutingTeacherId] = teacherIds.random() }
        it[studentLimit] = faker.random.nextInt(1..20)
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
      val _price = faker.random.nextInt(200_00..5000_00)
      Course.new {
        price = _price
        advancePrice = faker.random.nextInt(0.._price / 3)
        subject = faker.commerce.productName()
        faker.random { language = faker.nation.language() }
        studentLimit = faker.random.nextInt(1..5)
      }
    }!!
  }.map { it.id.value }

  suspend fun insertRooms(
    n: Int = 10,
  ): List<Int> = List(n) {
    safeTransaction {
      Room.new {
        number = faker.string.numerify("##.##")
        building = faker.string.bothify("?##", true)
      }
    }!!
  }.map { it.id.value }

  suspend fun insertBaskets(
    studentIds: List<Int>,
    n: Int = 10,
  ): List<Int> = List(n) {
    safeTransaction {
      val isOpen = faker.random.nextBoolean()
      val createDat = faker.date()
      studentIds.takeRandom(n).map { _studentId ->
        Baskets.insertAndGetId {
          it[studentId] = _studentId
          if (!isOpen) it[paymentUrl] = faker.internet.url(
            domain = faker.minecraft.mobs(),
            path = faker.harryPotter.quotes(),
          )
          it[state] =
            if (isOpen) BasketState.open
            else BasketState.entries.filter { state -> state != BasketState.open }.random()
          it[createDate] = createDat
          faker.random { it[paymentDate] = faker.date(createDat) }
        }
      }
    }!!
  }.flatten().map { it.value }

  suspend fun insertInternships(
    studiesIds: List<Int>,
    n: Int = 10,
  ): List<Int> = List(n) {
    safeTransaction {
      Internships.insertAndGetId {
        it[studiesId] = studiesIds.random()
        it[date] = faker.date()
      }
    }!!
  }.map { it.value }

  suspend fun insertSubjects(
    semesterIds: List<Int>,
    teacherIds: List<Int>,
    n: IntRange = 4..10,
  ): List<Int> = semesterIds.flatMap { _semesterId ->
    List(faker.random.nextInt(n)) {
      safeTransaction {
        Subjects.insertAndGetId {
          it[name] = faker.subject()
          it[semesterId] = _semesterId
          it[teacherId] = teacherIds.random()
        }
      }!!
    }
  }.map { it.value }

  suspend fun insertSemesters(
    studiesIds: List<Int>,
  ): List<Int> = studiesIds.flatMap { id ->
    val numberOfSemesters = faker.random.nextInt(1..12)
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
            it[studiesId] = id
            it[schedule] =
              faker.internet.url(domain = faker.coffee.blendName(), path = faker.spongebob.quotes()).take(50)
            it[startDate] = dates.first
            it[endDate] = dates.second
          }
        }!!.value
      }
      .toList()
  }

  suspend fun insertStudies(
    n: Int = 10,
  ): List<Int> = List(n) {
    safeTransaction {
      val _price = faker.random.nextInt(2000_00..50000_00)
      Studies.new {
        syllabus =
          List(faker.random.nextInt(5..30)) { faker.bible.quote() }.reduce { s, other -> "$s $other" }.take(5000)
        price = _price
        advancePrice = faker.random.nextInt(0.._price / 3)
        faker.random { language = faker.nation.language() }
        studentLimit = faker.random.nextInt(1..5)
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
        it[price] = faker.random.nextInt(0..300_00)
        it[date] = faker.dateTime()
        it[url] = faker.internet.url(domain = faker.witcher.potions(), path = faker.starWars.quote())
        faker.random { it[language] = faker.nation.language() }
        faker.random { it[translatorId] = translatorIds.random() }
        it[teacherId] = teacherIds.random()
      }
    }
  }.mapNotNull { it?.value }

  suspend fun insertTranslators(
    n: Int = 10,
  ): List<Int> = List(n) {
    safeTransaction {
      val person = faker.name
      Translator.new {
        language = faker.nation.language()
        name = person.firstName()
        surname = person.lastName()
        address = faker.address.fullAddress()
        email = faker.internet.email(person)
        phoneNumber = faker.phoneNumber.cellPhone.number()
      }
    }
  }.mapNotNull { it?.id?.value }

  suspend fun insertTeachers(
    n: Int = 10,
  ): List<Int> = List(n) {
    safeTransaction {
      val person = faker.name
      Teacher.new {
        name = person.firstName()
        surname = person.lastName()
        address = faker.address.fullAddress()
        email = faker.internet.email(person)
        phoneNumber = faker.phoneNumber.cellPhone.number()
      }
    }
  }.mapNotNull { it?.id?.value }

  suspend fun insertStudents(
    n: Int = 10,
  ): List<Int> = List(n) {
    safeTransaction {
      val person = faker.name
      Student.new {
        name = person.firstName()
        surname = person.lastName()
        address = faker.address.fullAddress()
        email = faker.internet.email(person)
        phoneNumber = faker.phoneNumber.cellPhone.number()
      }
    }
  }.mapNotNull { it?.id?.value }

  suspend fun insertParameters(): Int = listOf(
    "availability_period" to 30,
    "module_completion_threshold" to 80,
    "internship_completion_threshold" to 80,
    "internship_length" to 14,
    "internship_completion_threshold" to 100,
    "custom" to "¯\\_(ツ)_/¯",
    "some_date" to LocalDateTime.now(),
  ).flatMap { (_name, _value) ->
    List(faker.random.nextInt(1..5)) {
      safeTransaction {
        Parameters.insert {
          it[name] = _name
          it[value] = _value.toString()
          it[date] = faker.date()
        }
      }!!
    }
  }.count()


  suspend fun insertBasketItems(
    basketIds: List<Int>,
    courseIds: List<Int>,
    meetingIds: List<Int>,
    studiesIds: List<Int>,
    webinarIds: List<Int>,
    n: IntRange = 2..12,
  ) = basketIds.flatMap { basket ->
    listOf(
      courseIds to BasketItems.courseId,
      meetingIds to BasketItems.meetingId,
      studiesIds to BasketItems.studiesId,
      webinarIds to BasketItems.webinarId,
    ).flatMap { (ids, column) ->
      ids.takeRandom(n.last / 4).mapNotNull { id ->
        safeTransaction {
          BasketItems.insert {
            it[basketId] = basket
            it[column] = id
          }
        }
      }
    }
  }.count()

  suspend fun insertInternshipStudents(
    internshipIds: List<Int>,
    studentIds: List<Int>,
    n: IntRange = 5..10,
  ): Int = internshipIds.flatMap { _internshipId ->
    studentIds.takeRandom(faker.random.nextInt(n)).mapNotNull { id ->
      safeTransaction {
        InternshipStudent.insert {
          it[internshipId] = _internshipId
          it[studentId] = id
          it[attendedDays] = faker.random.nextInt(0..14)
          it[examResult] = faker.random.nextInt(0..100)
        }
      }
    }
  }.count()

  suspend fun insertStudentCourses(
    courseIds: List<Int>,
    studentIds: List<Int>,
    n: IntRange = 3..10,
  ): Int = studentIds.flatMap { _studentId ->
    courseIds.takeRandom(faker.random.nextInt(n)).mapNotNull { id ->
      val _advancePaymentDate = faker.date()
      val _fullPaymentDate = faker.date(_advancePaymentDate)
      val _creditDate = faker.date(_fullPaymentDate)
      val _certificatePostDate = faker.date(_creditDate)

      safeTransaction {
        StudentCourses.insert {
          it[studentId] = _studentId
          it[courseId] = id
          it[advancePaymentDate] = _advancePaymentDate
          it[fullPaymentDate] = _fullPaymentDate
          it[creditDate] = _creditDate
          it[certificatePostDate] = _certificatePostDate
        }
      }
    }
  }.count()


  suspend fun insertStudentMeetings(
    meetingIds: List<Int>,
    studentIds: List<Int>,
    n: IntRange = 3..10,
  ): Int = studentIds.flatMap { _studentId ->
    val meetings = meetingIds.takeRandom(faker.random.nextInt(n))
    meetings.mapNotNull { id ->
      safeTransaction {
        StudentMeetings.insert {
          it[studentId] = _studentId
          it[meetingId] = id
          it[paymentDate] = faker.date()
        }
      }
    }
  }.count()

  suspend fun insertStudentMeetingAttendance(
    meetingIds: List<Int>,
    studentIds: List<Int>,
    n: IntRange = 3..10,
  ): Int = studentIds.flatMap { _studentId ->
    meetingIds.takeRandom(faker.random.nextInt(n)).mapNotNull { id ->
      safeTransaction {
        StudentMeetingAttendance.insert {
          it[studentId] = _studentId
          it[meetingId] = id
        }
      }
    }
  }.count()

  suspend fun insertStudentWebinars(
    webinarIds: List<Int>,
    studentIds: List<Int>,
    n: IntRange = 3..10,
  ): Int = studentIds.flatMap { _studentId ->
    webinarIds.takeRandom(faker.random.nextInt(n)).map { id ->
      safeTransaction {
        StudentWebinars.insert {
          it[studentId] = _studentId
          it[webinarId] = id
          it[paymentDate] = faker.date()
        }
      }!!
    }
  }.count()

  suspend fun insertStudentStudies(
    studiesIds: List<Int>,
    studentIds: List<Int>,
    n: IntRange = 0..2,
  ): Int = studentIds.flatMap { _studentId ->
    val _registrationPaymentDate = faker.date()
    studiesIds.takeRandom(faker.random.nextInt(n)).mapNotNull { _studiesId ->
      safeTransaction {
        StudentStudies.insert {
          it[studentId] = _studentId
          it[studiesId] = _studiesId
          it[registrationPaymentDate] = _registrationPaymentDate
          faker.random { it[certificatePostDate] = faker.date(_registrationPaymentDate) }
        }.also {
          val semesters = Semester.find { Semesters.studiesId eq _studiesId }.map { it.id.value }
          semesters
            .take(faker.random.nextInt(semesters.indices))
            .map { _semesterId ->
              StudentSemesters.insert {
                it[studentId] = _studentId
                it[semesterId] = _semesterId
                it[paymentDate] = faker.date()
              }
            }
        }
      }
    }
  }.count()

  private suspend fun <T> safeTransaction(f: () -> T) =
    newSuspendedTransaction {
      try {
        f()
      } catch (e: Exception) {
        logger.warn(e.message)
        if (listOf(
            "Violation of UNIQUE KEY constraint",
            "Violation of PRIMARY KEY constraint",
          ).any { it in e.message.orEmpty() }
        ) null
        else {
          null
        }
      }
    }

  private fun <T> List<T>.takeRandom(n: Int): List<T> = generateSequence(::random).distinct().take(n).toList()
}