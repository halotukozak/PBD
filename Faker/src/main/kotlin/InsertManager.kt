package org.oolab.model

import com.typesafe.config.Config
import io.github.serpro69.kfaker.Faker
import kotlinx.coroutines.flow.asFlow
import kotlinx.coroutines.flow.count
import kotlinx.coroutines.flow.map
import model.*
import mu.KotlinLogging
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.insert
import org.jetbrains.exposed.sql.selectAll
import org.jetbrains.exposed.sql.transactions.experimental.newSuspendedTransaction
import java.time.LocalDateTime

@Suppress("LocalVariableName")
class InsertManager(private val faker: Faker, val fakerConfig: Config) {
  private val logger = KotlinLogging.logger("InsertManager")

  init {
    require(logger.isWarnEnabled && logger.isInfoEnabled && logger.isDebugEnabled) {
      "Logger not configured properly"
    }
  }

  inline fun <reified T> get(key: String): T = when (T::class) {
    Int::class -> fakerConfig.getInt(key) as T
    String::class -> fakerConfig.getString(key) as T
    LocalDateTime::class -> fakerConfig.getString(key).let(LocalDateTime::parse) as T
    IntRange::class -> fakerConfig.getRange(key) as T
    else -> throw IllegalArgumentException("Unsupported type")
  }

  suspend fun insertMeetings(): Int {
    val moduleIds = Modules.allIds()
    val subjectIds = Subjects.allIds()
    val translatorIds = Translators.allIds()
    val teacherIds = Teachers.allIds()
    return List(get("meetings")) {
      safeTransaction {
        val withModule = faker.random.nextBoolean()
        Meetings.insert {
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
    }.countNotNull()
  }

  suspend fun insertModules(): Int {
    val courseIds = Courses.allIds()
    val roomIds = Rooms.allIds()
    val teacherIds = Teachers.allIds()
    return List(get("modules")) {
      val tpe = faker.random.nextEnum<ModuleType>()
      safeTransaction {
        Modules.insert {
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
    }.countNotNull()
  }

  suspend fun insertCourses(): Int = List(get("courses")) {
    safeTransaction {
      val _price = faker.random.nextInt(200_00..5000_00)
      Course.new {
        title = "How to " + faker.verbs.base()
        price = _price
        advancePrice = faker.random.nextInt(0.._price / 3)
        subject = faker.subject()
        faker.random { language = faker.nation.language() }
        studentLimit = faker.random.nextInt(1..5)
      }
    }!!
  }.count()

  suspend fun insertRooms(): Int = List(get("rooms")) {
    safeTransaction {
      Room.new {
        number = faker.string.numerify("##.##")
        building = faker.string.bothify("?##", true)
      }
    }!!
  }.count()

  suspend fun insertBaskets(): Int {
    val studentIds = Students.allIds()
    return List(get("baskets")) {
      safeTransaction {
        val isOpen = faker.random.nextBoolean()
        val createDat = faker.date()
        studentIds.takeRandom(get("basketItems")).map { _studentId ->
          Baskets.insert {
            it[studentId] = _studentId
            if (!isOpen) it[paymentUrl] = faker.internet.url(
              domain = faker.minecraft.mobs(),
              path = faker.harryPotter.quotes(),
            )
            it[state] = if (isOpen) BasketState.open
            else BasketState.entries.filter { state -> state != BasketState.open }.random()
            it[createDate] = createDat
            faker.random { it[paymentDate] = faker.date(createDat) }
          }
        }
      }!!
    }.flatten().count()
  }

  suspend fun insertInternships(): Int {
    val studiesIds = StudiesTable.allIds()
    return studiesIds.sumOf { _studiesId ->
      generateSequence(faker.date()) { previous ->
        previous.plusMonths(6)
      }.take(faker.random.nextInt(get<IntRange>("internships")))
        .asFlow()
        .map { _date ->
          safeTransaction {
            Internships.insert {
              it[studiesId] = _studiesId
              it[date] = _date
            }
          }!!
        }.count()
    }
  }

  suspend fun insertSubjects(): Int {
    val semesterIds = Semesters.allIds()
    val teacherIds = Teachers.allIds()
    return semesterIds.sumOf { _semesterId ->
      List(faker.random.nextInt(get<Int>("subjects"))) {
        safeTransaction {
          Subjects.insert {
            it[name] = faker.subject()
            it[semesterId] = _semesterId
            it[teacherId] = teacherIds.random()
          }
        }!!
      }.count()
    }
  }

  suspend fun insertSemesters(): Int {
    val studiesIds = StudiesTable.allIds()
    return studiesIds.sumOf { _studiesId ->
      val numberOfSemesters = faker.random.nextInt(get<Int>("semesters"))
      generateSequence(faker.date()) { date ->
        date.plusMonths(6).plusDays(1)
      }
        .take(numberOfSemesters)
        .mapIndexed { i, x -> i to x }
        .asFlow()
        .map { (i, _startDate) ->
          safeTransaction {
            Semesters.insert {
              it[number] = i + 1
              it[studiesId] = _studiesId
              it[schedule] =
                faker.internet.url(domain = faker.coffee.blendName(), path = faker.spongebob.quotes()).take(50)
              it[startDate] = _startDate
              it[endDate] = _startDate.plusMonths(6)
            }
          }!!
        }.count()
    }
  }

  suspend fun insertStudies(): Int = List(get("studies")) {
    safeTransaction {
      val _price = faker.random.nextInt(2000_00..50000_00)
      Studies.new {
        title = faker.studiesName()
        syllabus =
          List(faker.random.nextInt(5..30)) { faker.bible.quote() }.reduce { s, other -> "$s $other" }.take(5000)
        price = _price
        advancePrice = faker.random.nextInt(0.._price / 3)
        faker.random { language = faker.nation.language() }
        studentLimit = faker.random.nextInt(1..5)
      }
    }
  }.countNotNull()

  suspend fun insertWebinars(): Int {
    val translatorIds = Translators.allIds()
    val teacherIds = Teachers.allIds()
    return List(get("webinars")) {
      safeTransaction {
        Webinars.insert {
          it[title] = faker.movie.title()
          it[price] = faker.random.nextInt(0..300_00)
          it[date] = faker.dateTime()
          it[url] = faker.internet.url(domain = faker.witcher.potions(), path = faker.starWars.quote())
          faker.random { it[language] = faker.nation.language() }
          faker.random { it[translatorId] = translatorIds.random() }
          it[teacherId] = teacherIds.random()
        }
      }!!
    }.count()
  }

  suspend fun insertTranslators(): Int = List(get("translators")) {
    safeTransaction {
      val (firstName, lastName) = faker.name.let { it.firstName() to it.lastName() }
      Translator.new {
        language = faker.nation.language()
        name = firstName
        surname = lastName
        address = faker.address.fullAddress()
        email = faker.internet.email(firstName, lastName)
        phoneNumber = faker.phoneNumber.cellPhone.number()
      }
    }!!
  }.count()

  suspend fun insertTeachers(): Int = List(get("teachers")) {
    safeTransaction {
      val (firstName, lastName) = faker.name.let { it.firstName() to it.lastName() }
      Teacher.new {
        name = firstName
        surname = lastName
        address = faker.address.fullAddress()
        email = faker.internet.email(firstName, lastName)
        phoneNumber = faker.phoneNumber.cellPhone.number()
      }
    }!!
  }.count()

  suspend fun insertStudents(): Int = List(get("students")) {
    safeTransaction {
      val (firstName, lastName) = faker.name.let { it.firstName() to it.lastName() }
      Student.new {
        name = firstName
        surname = lastName
        address = faker.address.fullAddress()
        email = faker.internet.email(firstName, lastName)
        phoneNumber = faker.phoneNumber.cellPhone.number()
      }
    }
  }.countNotNull()

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


  suspend fun insertBasketItems(): Int {
    val basketIds = Baskets.allIds()
    val courseIds = Courses.allIds()
    val meetingIds = Meetings.allIds()
    val studiesIds = StudiesTable.allIds()
    val webinarIds = Webinars.allIds()
    return basketIds.sumOf { basket ->
      listOf(
        courseIds to BasketItems.courseId,
        meetingIds to BasketItems.meetingId,
        studiesIds to BasketItems.studiesId,
        webinarIds to BasketItems.webinarId,
      ).flatMap { (ids, column) ->
        ids.takeRandom(get<Int>("basketItems") / 4).map { id ->
          safeTransaction {
            BasketItems.insert {
              it[basketId] = basket
              it[column] = id
            }
          }
        }
      }.countNotNull()
    }
  }

  suspend fun insertStudentInternship(): Int {
    val internshipIds = Internships.allIds()
    val studentIds = Students.allIds()

    return internshipIds.sumOf { _internshipId ->
      studentIds.takeRandom(faker.random.nextInt(get<IntRange>("studentInternship"))).map { id ->
        safeTransaction {
          StudentInternship.insert {
            it[internshipId] = _internshipId
            it[studentId] = id
            it[attendedDays] = faker.random.nextInt(0..14)
            it[examResult] = faker.random.nextInt(0..100)
          }
        }
      }.countNotNull()
    }
  }

  suspend fun insertStudentCourses(): Int {
    val studentIds = Students.allIds()
    val courseIds = Courses.allIds()
    return studentIds.sumOf { _studentId ->
      courseIds.takeRandom(faker.random.nextInt(get<IntRange>("studentCourse"))).map { id ->
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
      }.countNotNull()//todo(add metting here)
    }
  }


  suspend fun insertStudentMeetings(): Int
  //nie z kursu, nie ze studioów
  {
    val studentIds = Students.allIds()
    val meetingIds = Meetings.allIds()

    return studentIds.map { _studentId ->
      val meetings = meetingIds.takeRandom(faker.random.nextInt(get<IntRange>("studentMeetings")))
      meetings.map { id ->
        safeTransaction {
          StudentMeetings.insert {
            it[studentId] = _studentId
            it[meetingId] = id
            it[paymentDate] = faker.date()
          }
        }
      }
    }.countNotNull()
  }

  suspend fun insertStudentMeetingAttendance(): Int {
    val studentIds = Students.allIds()
    val meetingIds = Meetings.allIds()
    return studentIds.sumOf { _studentId ->
      meetingIds.takeRandom(faker.random.nextInt(get<IntRange>("studentMeetingAttendance"))).map { id ->
        safeTransaction {
          StudentMeetingAttendance.insert {
            it[studentId] = _studentId
            it[meetingId] = id
          }
        }
      }.countNotNull()
    }
  }

  suspend fun insertStudentWebinars(
  ): Int {
    val studentIds = Students.allIds()
    val webinarIds = Webinars.allIds()

    return studentIds.sumOf { _studentId ->
      webinarIds.takeRandom(faker.random.nextInt(get<IntRange>("studentWebinar"))).map { id ->
        safeTransaction {
          StudentWebinars.insert {
            it[studentId] = _studentId
            it[webinarId] = id
            it[paymentDate] = faker.date()
          }
        }!!
      }.count()
    }
  }

  suspend fun insertStudentStudies(): Int {
    val studentIds = Students.allIds()
    val studiesIds = StudiesTable.allIds()

    return studentIds.sumOf { _studentId ->
      val _registrationPaymentDate = faker.date()
      studiesIds.takeRandom(faker.random.nextInt(get<IntRange>("studentStudies"))).map { _studiesId ->
        safeTransaction {
          StudentStudies.insert {
            it[studentId] = _studentId
            it[studiesId] = _studiesId
            it[registrationPaymentDate] = _registrationPaymentDate
            faker.random { it[certificatePostDate] = faker.date(_registrationPaymentDate) }
          }.also {
            val semesters = Semester.find { Semesters.studiesId eq _studiesId }.map { it.id.value }
            semesters.take(faker.random.nextInt(semesters.indices)).map { _semesterId ->
              StudentSemesters.insert {
                it[studentId] = _studentId
                it[semesterId] = _semesterId
                it[paymentDate] = faker.date()
              }
            }
          }
        }
      }.countNotNull()
    }
  }

  private suspend fun <T> safeTransaction(f: () -> T) = newSuspendedTransaction {
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
  private fun <T> Iterable<T>.countNotNull(): Int = count { it != null }

  private fun IntIdTable.allIds() = this.selectAll().map { it[this.id].value }
}