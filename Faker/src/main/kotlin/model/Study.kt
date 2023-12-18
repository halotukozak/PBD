package model

import io.github.serpro69.kfaker.Faker
import org.jetbrains.exposed.dao.IntEntity
import org.jetbrains.exposed.dao.IntEntityClass
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.ReferenceOption
import org.jetbrains.exposed.sql.batchInsert
import org.jetbrains.exposed.sql.javatime.date

object Studies : IntIdTable() {
  val syllabus = varchar("syllabus", 1000).nullable()
  val price = float("price")
  val advancePrice = float("advance_price")
  val language = varchar("language", 50).default("Polish")
  val studentLimit = integer("student_limit")

  val priceCheck = check { price greater 0 }
  val advancePriceCheck = check { advancePrice greaterEq 0 }
  val studentLimitCheck = check { studentLimit greater 0 }
}

class Study(id: EntityID<Int>) : IntEntity(id) {
  companion object : IntEntityClass<Study>(Studies)

  var syllabus by Studies.syllabus
  var price by Studies.price
  var advancePrice by Studies.advancePrice
  var language by Studies.language
  var studentLimit by Studies.studentLimit
}

fun Faker.insertStudies(n: Int) = generateSequence {
  Study.new {
    syllabus = lorem.supplemental()
    price = random.nextFloat()
    advancePrice = random.nextFloat()
    language = nation.language()
    studentLimit = random.nextInt(1, 100)
  }
}.take(n)

object StudentSemesters : IntIdTable() {
  val studentId = integer("student_id").references(Students.id, onDelete = ReferenceOption.CASCADE)
  val semesterId = integer("semester_id").references(Semesters.id, onDelete = ReferenceOption.CASCADE)
  val paymentDate = date("payment_date")

  init {
    index(true, studentId, semesterId)
  }
}
