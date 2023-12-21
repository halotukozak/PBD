package model

import io.github.serpro69.kfaker.Faker
import org.jetbrains.exposed.dao.IntEntity
import org.jetbrains.exposed.dao.IntEntityClass
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.batchInsert
import kotlin.random.Random

object Rooms : IntIdTable("Room") {
  val number = varchar("number", 10)
  val building = varchar("building", 50)
}

class Room(id: EntityID<Int>) : IntEntity(id) {
  companion object : IntEntityClass<Room>(Rooms)

  var number by Rooms.number
  var building by Rooms.building
}
