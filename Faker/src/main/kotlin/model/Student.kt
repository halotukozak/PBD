package model

import io.github.serpro69.kfaker.Faker
import io.github.serpro69.kfaker.provider.Name
import org.jetbrains.exposed.dao.IntEntity
import org.jetbrains.exposed.dao.IntEntityClass
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.ReferenceOption
import org.jetbrains.exposed.sql.StdOutSqlLogger
import org.jetbrains.exposed.sql.addLogger
import org.jetbrains.exposed.sql.batchInsert
import org.jetbrains.exposed.sql.javatime.date
import org.jetbrains.exposed.sql.transactions.transaction

object Students : IntIdTable() {
  val name = varchar("name", 50)
  val surname = varchar("surname", 50)
  val address = varchar("address", 200)
  val email = varchar("email", 50).uniqueIndex()
  val phoneNumber = varchar("phone_number", 20).uniqueIndex()
}

class Student(id: EntityID<Int>) : IntEntity(id) {
  companion object : IntEntityClass<Student>(Students)

  var name by Students.name
  var surname by Students.surname
  var address by Students.address
  var email by Students.email
  var phoneNumber by Students.phoneNumber
}

object StudentStudies : IntIdTable() {
  val studentId = integer("student_id").references(Students.id, onDelete = ReferenceOption.CASCADE)
  val studiesId = integer("studies_id").references(Studies.id, onDelete = ReferenceOption.CASCADE)
  val registrationPaymentDate = date("registration_payment_date")
  val certificatePostDate = date("certificate_post_date").nullable()

  init {
    index(true, studentId, studiesId)
  }

  val dateCheck = check { registrationPaymentDate less certificatePostDate }
}


fun Faker.insertStudents(n: Int) = generateSequence {
  val faker = this
  val (name, surname) = faker.name.let { it.firstName() to it.lastName() }
  Student.new {
    name = name
    surname = surname
    address = faker.address.fullAddress()
    email = faker.internet.email()
    phoneNumber = faker.phoneNumber.cellPhone()
  }
}.take(n)
