package model

import org.jetbrains.exposed.dao.IntEntity
import org.jetbrains.exposed.dao.IntEntityClass
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IntIdTable

object Teachers : IntIdTable("Teacher") {
  val firstName = varchar("first_name", 50)
  val lastName = varchar("last_name", 50)
  val address = varchar("address", 200)
  val email = varchar("email", 50).uniqueIndex()
  val phoneNumber = varchar("phone_number", 20).uniqueIndex()
}

class Teacher(id: EntityID<Int>) : IntEntity(id) {
  companion object : IntEntityClass<Teacher>(Teachers)

  var firstName by Teachers.firstName
  var lastName by Teachers.lastName
  var address by Teachers.address
  var email by Teachers.email
  var phoneNumber by Teachers.phoneNumber
}
