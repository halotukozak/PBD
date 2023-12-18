package model

import org.jetbrains.exposed.dao.Entity
import org.jetbrains.exposed.dao.IntEntity
import org.jetbrains.exposed.dao.IntEntityClass
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.javatime.date

object Meetings : IntIdTable() {
  val moduleId = integer("module_id").references(Modules.id, onDelete = ReferenceOption.CASCADE).nullable()
  val subjectId = integer("subject_id").references(Subjects.id, onDelete = ReferenceOption.CASCADE).nullable()
  val url = varchar("url", 200).nullable()
  val date = date("date")
  val type = varchar("type", 10)
  val standalonePrice = float("standalone_price").nullable()
  val translatorId = integer("translator_id").references(Translators.id, onDelete = ReferenceOption.CASCADE)
  val substitutingTeacherId =
    integer("substituting_teacher_id").references(Teachers.id, onDelete = ReferenceOption.CASCADE)
  val studentLimit = integer("student_limit")

  val typeCheck = check { (moduleId neq null and (subjectId eq null)) or (moduleId eq null and (subjectId neq null)) }
  val urlCheck = check { (type eq "in_person") or ((type inList listOf("online", "video")) and (url neq null)) }
  val studentLimitCheck = check { studentLimit greater 0 }
  val priceCheck = check { (standalonePrice eq null) orIfNotNull (standalonePrice greater 0) }
}

class Meeting(id: EntityID<Int>) : IntEntity(id) {
  companion object : IntEntityClass<Meeting>(Meetings)

  var module by Module optionalReferencedOn Meetings.moduleId
  var subject by Subject optionalReferencedOn Meetings.subjectId
  var url by Meetings.url
  var date by Meetings.date
  var type by Meetings.type
  var standalonePrice by Meetings.standalonePrice
  var translator by Translator referencedOn Meetings.translatorId
  var substitutingTeacher by Teacher optionalReferencedOn Meetings.substitutingTeacherId
  var studentLimit by Meetings.studentLimit
}

object StudentMeetings : IntIdTable() {
  val studentId = integer("student_id").references(Students.id, onDelete = ReferenceOption.CASCADE)
  val meetingId = integer("meeting_id").references(Meetings.id, onDelete = ReferenceOption.CASCADE)
  val paymentDate = date("payment_date").nullable()

  init {
    index(true, studentId, meetingId)
  }
}