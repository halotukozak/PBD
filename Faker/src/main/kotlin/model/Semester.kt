package model

import org.jetbrains.exposed.dao.IntEntity
import org.jetbrains.exposed.dao.IntEntityClass
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.ReferenceOption
import org.jetbrains.exposed.sql.and
import org.jetbrains.exposed.sql.javatime.date

object Semesters : IntIdTable("Semester") {
  val number = integer("number")
  val studiesId = integer("studies_id").references(StudiesTable.id, onDelete = ReferenceOption.NO_ACTION)
  val price = integer("price")
  val scheduleUrl = varchar("schedule_url", 50)
  val startDate = date("start_date")
  val endDate = date("end_date")

  val numberCheck = check { (number greater 0) and (number lessEq 12) }
  val dateCheck = check { startDate less endDate }
  val uniqueConstraint = uniqueIndex(studiesId, number)
}

class Semester(id: EntityID<Int>) : IntEntity(id) {
  companion object : IntEntityClass<Semester>(Semesters)

  var number by Semesters.number
  var studies by Studies referencedOn Semesters.studiesId
  var price by Semesters.price
  var scheduleUrl by Semesters.scheduleUrl
  var startDate by Semesters.startDate
  var endDate by Semesters.endDate
}
