package model

import io.github.serpro69.kfaker.Faker
import org.jetbrains.exposed.dao.IntEntity
import org.jetbrains.exposed.dao.IntEntityClass
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IntIdTable

object Translators : IntIdTable() {
  val language = varchar("language", 50)
  val name = varchar("name", 50)
  val surname = varchar("surname", 50)
  val address = varchar("address", 200)
  val email = varchar("email", 50).uniqueIndex()
  val phoneNumber = varchar("phone_number", 20).uniqueIndex()
}

class Translator(id: EntityID<Int>) : IntEntity(id) {
  companion object : IntEntityClass<Translator>(Translators)

  var language by Translators.language
  var name by Translators.name
  var surname by Translators.surname
  var address by Translators.address
  var email by Translators.email
  var phoneNumber by Translators.phoneNumber
}

fun Faker.insertTranslators(n: Int) = generateSequence {
  val faker = this
  val (name, surname) = faker.name.let { it.name() to it.lastName() }
  Translator.new {
    this.language = faker.nation.language()
    this.name = name
    this.surname = surname
    this.address = faker.address.fullAddress()
    this.email = faker.internet.email(name)
    this.phoneNumber = faker.phoneNumber.phoneNumber()
  }
}.take(n)