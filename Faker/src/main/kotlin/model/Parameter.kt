package model

import org.jetbrains.exposed.dao.IntEntity
import org.jetbrains.exposed.dao.IntEntityClass
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.javatime.date

object Parameters : IntIdTable("Parameter") {
  val name = varchar("name", 50)
  val value = varchar("value", 50)
  val date = date("date")

  init {
    uniqueIndex(name, date)
  }

}

class Parameter(id: EntityID<Int>) : IntEntity(id) {
  companion object : IntEntityClass<Parameter>(Parameters)

  var name by Parameters.name
  var value by Parameters.value
  var date by Parameters.date
}