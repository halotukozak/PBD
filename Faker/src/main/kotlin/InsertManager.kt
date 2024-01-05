package org.oolab.model

import io.github.serpro69.kfaker.Faker
import model.*
import org.jetbrains.exposed.sql.StdOutSqlLogger
import org.jetbrains.exposed.sql.addLogger
import org.jetbrains.exposed.sql.transactions.transaction
import org.slf4j.LoggerFactory

class InsertManager(val faker: Faker) {
  val logger = LoggerFactory.getLogger("InsertManager")

  fun insertMeetings(
    modules: List<Module>,
    subjects: List<Subject>,
    translators: List<Translator>,
    teachers: List<Teacher>,
    n: Int = 100,
  ) = safeRepeat(n) {
    val withModule = faker.random.nextBoolean()
    Meeting.new {
      module = if (withModule) modules.random() else null
      subject = if (withModule) null else subjects.random()
      url = faker.internet.domain()
      date = faker.date()
      type = faker.random.nextEnum<MeetingType>()
      standalonePrice = faker.random.nextFloat()
      translator = if (faker.random.nextBoolean()) translators.random() else null
      substitutingTeacher = if (faker.random.nextBoolean()) teachers.random() else null
      studentLimit = faker.random.nextInt(1, 20)
    }
  }

  fun insertModules(
    courses: List<Course>,
    rooms: List<Room>,
    teachers: List<Teacher>,
    n: Int = 100,
  ) = safeRepeat(n) {
    Module.new {
      course = courses.random()
      type = faker.random.nextEnum<ModuleType>()
      room = rooms.random()
      teacher = teachers.random()
    }
  }

  fun insertCourses(
    n: Int = 100,
  ) = safeRepeat(n) {
    Course.new {
      price = faker.random.nextFloat()
      advancePrice = faker.random.nextFloat()
      subject = faker.commerce.productName()
      language = faker.nation.language()
      studentLimit = faker.random.nextInt(1, 5)
    }
  }

  fun insertRooms(
    n: Int = 100,
  ) = safeRepeat(n) {
    Room.new {
      number = faker.string.numerify("##.##")
      building = faker.address.buildingNumber()
    }
  }

  fun insertBaskets(
    students: List<Student>, n: Int = 100,
  ) = safeRepeat(n) {
    val isOpen = faker.random.nextBoolean()
    Basket.new {
      student = students.random()
      paymentUrl = if (isOpen) faker.internet.domain() else null
      state = if (isOpen) BasketState.open else BasketState.entries.filter { it != BasketState.open }.random()
      createDate = faker.date()
      paymentDate = if (faker.random.nextBoolean()) faker.date() else null
    }
  }

  fun insertInternships(
    studies: List<Studies>, n: Int = 100,
  ) = safeRepeat(n) {
    Internship.new {
      this.studies = studies.random()
      this.date = faker.date()
    }
  }

  fun insertSubjects(
    semesters: List<Semester>, teachers: List<Teacher>, n: Int = 100,
  ) = safeRepeat(n) {
    Subject.new {
      name = faker.science.branch.formalBasic()
      semester = semesters.random()
      teacher = teachers.random()
    }
  }

  fun insertSemesters(
    studies: List<Studies>, n: Int = 100,
  ) = studies.flatMap {
    val numberOfSemesters = faker.random.nextInt(1, 12)
    generateSequence(faker.date().let { it to faker.date(it) }) { (_, endDate) ->
      endDate.plusDays(1) to faker.date(endDate)
    }
      .take(numberOfSemesters)
      .map { (startDat, endDat) ->
        Semester.new {
          number = faker.random.nextInt(1, numberOfSemesters)
          this.studies = it
          schedule = faker.lorem.words()
          startDate = startDat
          endDate = endDat
        }
      }
  }

  fun insertStudies(
    n: Int = 100,
  ) = safeRepeat(n) {
    Studies.new {
      syllabus = faker.lorem.supplemental()
      price = faker.random.nextFloat()
      advancePrice = faker.random.nextFloat()
      language = faker.nation.language()
      studentLimit = faker.random.nextInt(1, 5)
    }
  }

  fun insertWebinars(
    translators: List<Translator>,
    teachers: List<Teacher>,
    n: Int = 100,
  ) = safeRepeat(n) {
    Webinar.new {
      price = faker.random.nextFloat()
      date = faker.date()
      url = faker.internet.domain()
      language = faker.nation.language()
      translator = translators.random()
      teacher = teachers.random()
    }
  }

  fun insertTranslators(
    n: Int = 100,
  ) = safeRepeat(n) {
    val (name, surname) = faker.name.let { it.name() to it.lastName() }
    Translator.new {
      this.language = faker.nation.language()
      this.name = name
      this.surname = surname
      this.address = faker.address.fullAddress()
      this.email = faker.internet.email(name)
      this.phoneNumber = faker.phoneNumber.phoneNumber()
    }
  }

  fun insertTeachers(
    n: Int = 100,
  ) = safeRepeat(n) {
    val (name, surname) = faker.name.let { it.name() to it.lastName() }
    Teacher.new {
      this.name = name
      this.surname = surname
      this.address = faker.address.fullAddress()
      this.email = faker.internet.email(name)
      this.phoneNumber = faker.phoneNumber.phoneNumber()
    }
  }

  fun insertStudents(
    n: Int = 100,
  ) = safeRepeat(n) {
    val (name, surname) = faker.name.let { it.firstName() to it.lastName() }
    Student.new {
      this.name = name
      this.surname = surname
      this.address = faker.address.fullAddress()
      this.email = faker.internet.email(name)
      this.phoneNumber = faker.phoneNumber.phoneNumber()
    }
  }

  fun <T> safeRepeat(n: Int, f: () -> T): List<T> =
    List(n) {
      try {
        transaction {
          addLogger(StdOutSqlLogger)
          f()
        }
      } catch (ignored: Exception) {
        logger.warn(ignored.message)
        null
      }
    }.filterNotNull()
}
