package model

import org.jetbrains.exposed.dao.IntEntity
import org.jetbrains.exposed.dao.IntEntityClass
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.ReferenceOption
import org.jetbrains.exposed.sql.Table
import org.jetbrains.exposed.sql.javatime.date

object StudiesTable : IntIdTable("Studies") {
  val title = varchar("title", 100)
  val syllabus = varchar("syllabus", 5000).nullable()
  val price = integer("price")
  val advancePrice = integer("advance_price")
  val language = varchar("language", 50).default("Polish")
  val studentLimit = integer("student_limit")

  val priceCheck = check { price greater 0 }
  val advancePriceCheck = check { advancePrice greaterEq 0 }
  val studentLimitCheck = check { studentLimit greater 0 }
}

class Studies(id: EntityID<Int>) : IntEntity(id) {
  companion object : IntEntityClass<Studies>(StudiesTable)

  var title by StudiesTable.title
  var syllabus by StudiesTable.syllabus
  var price by StudiesTable.price
  var advancePrice by StudiesTable.advancePrice
  var language by StudiesTable.language
  var studentLimit by StudiesTable.studentLimit
}

object StudentSemesters : Table("StudentSemester") {
  val studentId = integer("student_id").references(Students.id, onDelete = ReferenceOption.CASCADE)
  val semesterId = integer("semester_id").references(Semesters.id, onDelete = ReferenceOption.CASCADE)
  val paymentDate = date("payment_date")

  override val primaryKey: PrimaryKey = PrimaryKey(studentId, semesterId)
}
