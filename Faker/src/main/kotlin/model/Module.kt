package model

import model.ModuleType.*
import org.jetbrains.exposed.dao.IntEntity
import org.jetbrains.exposed.dao.IntEntityClass
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.ReferenceOption
import org.jetbrains.exposed.sql.Table
import org.jetbrains.exposed.sql.and
import org.jetbrains.exposed.sql.javatime.date
import org.jetbrains.exposed.sql.or

object Modules : IntIdTable("Module") {
  val courseId = integer("course_id").references(Courses.id, onDelete = ReferenceOption.CASCADE)
  val type = enumerationByName<ModuleType>("type", 10)
  val roomId = integer("room_id").references(Rooms.id, onDelete = ReferenceOption.NO_ACTION).nullable()
  val teacherId = integer("teacher_id").references(Teachers.id, onDelete = ReferenceOption.NO_ACTION)
  val startDate = date("start_date")

  val typeCheck = check {
    (type eq hybrid) or ((type eq in_person) and (roomId neq null)) or ((type inList listOf(
      online_sync, online_async
    )) and (roomId eq null))
  }
}

class Module(id: EntityID<Int>) : IntEntity(id) {
  companion object : IntEntityClass<Module>(Modules)

  var course by Course referencedOn Modules.courseId
  var type by Modules.type
  var room by Room optionalReferencedOn Modules.roomId
  var teacher by Teacher referencedOn Modules.teacherId
  var startDate by Modules.startDate
}


object StudentMeetingAttendance : Table("StudentMeetingAttendance") {
  val studentId = integer("student_id").references(Students.id, onDelete = ReferenceOption.CASCADE)
  val meetingId = integer("meeting_id").references(Meetings.id, onDelete = ReferenceOption.CASCADE)

  override val primaryKey: PrimaryKey = PrimaryKey(studentId, meetingId)

}

enum class ModuleType {
  hybrid, in_person, online_sync, online_async
}