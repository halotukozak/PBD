package model

import org.jetbrains.exposed.dao.IntEntity
import org.jetbrains.exposed.dao.IntEntityClass
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.ReferenceOption

object Subjects : IntIdTable("Subject") {
  val name = varchar("name", 200)
  val semesterId = integer("semester_id").references(Semesters.id, onDelete = ReferenceOption.CASCADE)
  val teacherId = integer("teacher_id").references(Teachers.id, onDelete = ReferenceOption.SET_NULL).nullable()
}

class Subject(id: EntityID<Int>) : IntEntity(id) {
  companion object : IntEntityClass<Subject>(Subjects)

  var name by Subjects.name
  var semester by Semester referencedOn Subjects.semesterId
  var teacher by Teacher optionalReferencedOn Subjects.teacherId
}
