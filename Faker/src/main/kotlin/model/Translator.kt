package model

import org.jetbrains.exposed.dao.IntEntity
import org.jetbrains.exposed.dao.IntEntityClass
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IntIdTable

object Translators : IntIdTable("Translator") {
  val firstName = varchar("first_name", 50)
  val lastName = varchar("last_name", 50)
  val address = varchar("address", 200)
  val email = varchar("email", 50).uniqueIndex()
  val phoneNumber = varchar("phone_number", 20).uniqueIndex()
}

class Translator(id: EntityID<Int>) : IntEntity(id) {
  companion object : IntEntityClass<Translator>(Translators)

  var firstName by Translators.firstName
  var lastName by Translators.lastName
  var address by Translators.address
  var email by Translators.email
  var phoneNumber by Translators.phoneNumber
}

