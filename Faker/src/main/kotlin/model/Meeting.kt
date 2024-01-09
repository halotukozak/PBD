package model

import model.MeetingType.*
import org.jetbrains.exposed.dao.IntEntity
import org.jetbrains.exposed.dao.IntEntityClass
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.ReferenceOption
import org.jetbrains.exposed.sql.Table
import org.jetbrains.exposed.sql.and
import org.jetbrains.exposed.sql.javatime.date
import org.jetbrains.exposed.sql.javatime.datetime
import org.jetbrains.exposed.sql.or

object Meetings : IntIdTable("Meeting") {
  val moduleId = integer("module_id").references(Modules.id, onDelete = ReferenceOption.NO_ACTION).nullable()
  val subjectId = integer("subject_id").references(Subjects.id, onDelete = ReferenceOption.NO_ACTION).nullable()
  val url = varchar("url", 200).nullable()
  val date = datetime("date")
  val type = enumerationByName<MeetingType>("type", 10)
  val standalonePrice = float("standalone_price").nullable()
  val translatorId =
    integer("translator_id").references(Translators.id, onDelete = ReferenceOption.SET_NULL).nullable()
  val substitutingTeacherId =
    integer("substituting_teacher_id").references(Teachers.id, onDelete = ReferenceOption.NO_ACTION).nullable()
      .default(null)
  val studentLimit = integer("student_limit")

  val typeCheck = check { (moduleId neq null and (subjectId eq null)) or (moduleId eq null and (subjectId neq null)) }
  val urlCheck = check { (type eq in_person) or ((type inList listOf(online, video)) and (url neq null)) }
  val studentLimitCheck = check { studentLimit greater 0 }
  val priceCheck = check { (standalonePrice eq null) or (standalonePrice greater 0.0) }
}

class Meeting(id: EntityID<Int>) : IntEntity(id) {
  companion object : IntEntityClass<Meeting>(Meetings)

  var module by Module optionalReferencedOn Meetings.moduleId
  var subject by Subject optionalReferencedOn Meetings.subjectId
  var url by Meetings.url
  var date by Meetings.date
  var type by Meetings.type
  var standalonePrice by Meetings.standalonePrice
  var translator by Translator optionalReferencedOn Meetings.translatorId
  var substitutingTeacher by Teacher optionalReferencedOn Meetings.substitutingTeacherId
  var studentLimit by Meetings.studentLimit
  var students by Student via StudentMeetings
}

object StudentMeetings : Table("StudentMeeting") {
  val studentId = integer("student_id").references(Students.id, onDelete = ReferenceOption.CASCADE)
  val meetingId = integer("meeting_id").references(Meetings.id, onDelete = ReferenceOption.CASCADE)
  val paymentDate = date("payment_date").nullable()

  override val primaryKey: PrimaryKey = PrimaryKey(studentId, meetingId)
}


enum class MeetingType {
  in_person, online, video;
}