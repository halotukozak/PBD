package model

import org.jetbrains.exposed.dao.IntEntity
import org.jetbrains.exposed.dao.IntEntityClass
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.ReferenceOption
import org.jetbrains.exposed.sql.Table
import org.jetbrains.exposed.sql.javatime.date
import org.jetbrains.exposed.sql.javatime.datetime

object Webinars : IntIdTable("Webinar") {
  val price = integer("price").default(0)
  val date = datetime("date")
  val url = varchar("url", 200).uniqueIndex()
  val language = varchar("language", 50).default("Polish")
  val translatorId = integer("translator_id").references(Translators.id, onDelete = ReferenceOption.SET_NULL).nullable()
  val teacherId = integer("teacher_id").references(Teachers.id)

  val priceCheck = check { price greaterEq 0 }
}

class Webinar(id: EntityID<Int>) : IntEntity(id) {
  companion object : IntEntityClass<Webinar>(Webinars)

  var price by Webinars.price
  var date by Webinars.date
  var url by Webinars.url
  var language by Webinars.language
  var translator by Translator optionalReferencedOn Webinars.translatorId
  var teacher by Teacher referencedOn Webinars.teacherId
}

object StudentWebinars : Table("StudentWebinar") {
  val studentId = integer("student_id").references(Students.id, onDelete = ReferenceOption.CASCADE)
  val webinarId = integer("webinar_id").references(Webinars.id, onDelete = ReferenceOption.CASCADE)
  val paymentDate = date("payment_date")

  override val primaryKey: PrimaryKey = PrimaryKey(studentId, webinarId)

}