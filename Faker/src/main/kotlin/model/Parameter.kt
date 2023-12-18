package model

import org.jetbrains.exposed.dao.Entity
import org.jetbrains.exposed.dao.EntityClass
import org.jetbrains.exposed.dao.IntEntity
import org.jetbrains.exposed.dao.IntEntityClass
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.Table
import org.jetbrains.exposed.sql.javatime.date

object Parameters : Table() {
  val name = varchar("name", 50)
  val value = varchar("value", 50)
  val date = date("date")

  override val primaryKey = PrimaryKey(name, date)
}

class Parameter() {
  companion object : EntityClass<String, Parameter>(Parameters)

  var name by Parameters.name
  var value by Parameters.value
  var date by Parameters.date
}