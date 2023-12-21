package model

import io.github.serpro69.kfaker.Faker
import org.jetbrains.exposed.dao.IntEntity
import org.jetbrains.exposed.dao.IntEntityClass
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.batchInsert

object Teachers : IntIdTable("Teacher") {
  val name = varchar("name", 50)
  val surname = varchar("surname", 50)
  val address = varchar("address", 200)
  val email = varchar("email", 50).uniqueIndex()
  val phoneNumber = varchar("phone_number", 20).uniqueIndex()
}

class Teacher(id: EntityID<Int>) : IntEntity(id) {
  companion object : IntEntityClass<Teacher>(Teachers)

  var name by Teachers.name
  var surname by Teachers.surname
  var address by Teachers.address
  var email by Teachers.email
  var phoneNumber by Teachers.phoneNumber
}
