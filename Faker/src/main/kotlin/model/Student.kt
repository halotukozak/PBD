package model

import org.jetbrains.exposed.dao.IntEntity
import org.jetbrains.exposed.dao.IntEntityClass
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.ReferenceOption
import org.jetbrains.exposed.sql.Table
import org.jetbrains.exposed.sql.javatime.date

object Students : IntIdTable("Student") {
  val firstName = varchar("first_name", 50)
  val lastname = varchar("last_name", 50)
  val address = varchar("address", 200)
  val email = varchar("email", 50).uniqueIndex()
  val phoneNumber = varchar("phone_number", 20).uniqueIndex()
}

class Student(id: EntityID<Int>) : IntEntity(id) {
  companion object : IntEntityClass<Student>(Students)

  var firstName by Students.firstName
  var lastName by Students.lastname
  var address by Students.address
  var email by Students.email
  var phoneNumber by Students.phoneNumber

}

object StudentStudies : Table("StudentStudies") {
  val studentId = integer("student_id").references(Students.id, onDelete = ReferenceOption.CASCADE)
  val studiesId = integer("studies_id").references(StudiesTable.id, onDelete = ReferenceOption.CASCADE)
  val registrationPaymentDate = date("registration_payment_date")
  val creditDate = date("credit_date").nullable()
  val certificatePostDate = date("certificate_post_date").nullable()

  override val primaryKey: PrimaryKey = PrimaryKey(studentId, studiesId)

  val dateCheck = check { registrationPaymentDate less certificatePostDate }
}
