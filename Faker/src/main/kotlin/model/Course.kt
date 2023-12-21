package model

import io.github.serpro69.kfaker.Faker
import org.jetbrains.exposed.dao.IntEntity
import org.jetbrains.exposed.dao.IntEntityClass
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.ReferenceOption
import org.jetbrains.exposed.sql.Table
import org.jetbrains.exposed.sql.batchInsert
import org.jetbrains.exposed.sql.javatime.date

object Courses : IntIdTable("Course") {
  val price = float("price")
  val advancePrice = float("advance_price")
  val subject = varchar("subject", 100)
  val language = varchar("language", 50).default("Polish")
  val studentLimit = integer("student_limit")

  val priceCheck = check { price greater 0 }
  val advancePriceCheck = check { advancePrice greaterEq 0 }
  val studentLimitCheck = check { studentLimit greater 0 }
}

class Course(id: EntityID<Int>) : IntEntity(id) {
  companion object : IntEntityClass<Course>(Courses)

  var price by Courses.price
  var advancePrice by Courses.advancePrice
  var subject by Courses.subject
  var language by Courses.language
  var studentLimit by Courses.studentLimit

  var students by Student via StudentCourses
}

object StudentCourses : Table("StudentCourse") {
  val studentId = integer("student_id").references(Students.id, onDelete = ReferenceOption.CASCADE)
  val courseId = integer("course_id").references(Courses.id, onDelete = ReferenceOption.CASCADE)
  val advancePaymentDate = date("advance_payment_date")
  val fullPaymentDate = date("full_payment_date").nullable()
  val creditDate = date("credit_date").nullable()
  val certificatePostDate = date("certificate_post_date").nullable()

  init {
    index(true, studentId, courseId)
  }

  val dateChecks =
    check { advancePaymentDate lessEq fullPaymentDate; fullPaymentDate lessEq creditDate; creditDate lessEq certificatePostDate }
}