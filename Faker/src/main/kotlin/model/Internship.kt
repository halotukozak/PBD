package model

import org.jetbrains.exposed.dao.IntEntity
import org.jetbrains.exposed.dao.IntEntityClass
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.ReferenceOption
import org.jetbrains.exposed.sql.Table
import org.jetbrains.exposed.sql.javatime.date

object Internships : IntIdTable("Internship") {
  val studiesId = integer("studies_id").references(StudiesTable.id, onDelete = ReferenceOption.CASCADE)
  val date = date("date")
}

class Internship(id: EntityID<Int>) : IntEntity(id) {
  companion object : IntEntityClass<Internship>(Internships)

  var studies by Studies referencedOn Internships.studiesId
  var date by Internships.date

  var students by Student via InternshipStudent
  var exams by Student via InternshipStudent
}

object InternshipStudent : Table("InternshipStudent") {
  val studentId = integer("student_id").references(Students.id, onDelete = ReferenceOption.CASCADE)
  val internshipId = integer("internship_id").references(Internships.id, onDelete = ReferenceOption.CASCADE)
  val attendedDays = integer("attended_days").default(0)
  val examResult = integer("exam_result")

  override val primaryKey: PrimaryKey = PrimaryKey(studentId, internshipId)


  val attendedDaysCheck = check { attendedDays greaterEq 0 }
  val resultCheck = check { examResult greaterEq 0; examResult lessEq 100 }
}