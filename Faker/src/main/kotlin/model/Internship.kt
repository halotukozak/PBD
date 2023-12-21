package model

import io.github.serpro69.kfaker.Faker
import org.jetbrains.exposed.dao.IntEntity
import org.jetbrains.exposed.dao.IntEntityClass
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.ReferenceOption
import org.jetbrains.exposed.sql.javatime.date

object Internships : IntIdTable() {
  val studiesId = integer("studies_id").references(StudiesTable.id, onDelete = ReferenceOption.CASCADE)
  val date = date("date")
}

class Internship(id: EntityID<Int>) : IntEntity(id) {
  companion object : IntEntityClass<Internship>(Internships)

  var studies by Studies referencedOn Internships.studiesId
  var date by Internships.date
}

object InternshipAttendances : IntIdTable() {
  val studentId = integer("student_id").references(Students.id, onDelete = ReferenceOption.CASCADE)
  val internshipId = integer("internship_id").references(Internships.id, onDelete = ReferenceOption.CASCADE)
  val attendedDays = integer("attended_days").default(0)

  init {
    index(true, studentId, internshipId)
  }

  val attendedDaysCheck = check { attendedDays greaterEq 0 }
}

object InternshipExams : IntIdTable() {
  val studentId = integer("student_id").references(Students.id, onDelete = ReferenceOption.CASCADE)
  val internshipId = integer("internship_id").references(Internships.id, onDelete = ReferenceOption.CASCADE)
  val result = integer("result")

  init {
    index(true, studentId, internshipId)
  }

  val resultCheck = check { result greaterEq 0; result lessEq 100 }
}