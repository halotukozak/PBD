package model

import org.jetbrains.exposed.sql.Table
import org.jetbrains.exposed.sql.javatime.date

object Parameters : Table("Parameter") {
  val name = varchar("name", 50)
  val value = varchar("value", 50)
  val date = date("date")

  override val primaryKey: PrimaryKey = PrimaryKey(name, date)

}