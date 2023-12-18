package model

import io.github.serpro69.kfaker.Faker
import org.jetbrains.exposed.dao.IntEntity
import org.jetbrains.exposed.dao.IntEntityClass
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.*
import org.jetbrains.exposed.sql.javatime.date
import java.time.LocalDate

object Baskets : IntIdTable() {
  val studentId = integer("student_id").references(Students.id, onDelete = ReferenceOption.CASCADE)
  val paymentUrl = varchar("payment_url", 200).nullable()
  val state = varchar("state", 15)
  val createDate = date("create_date")
  val paymentDate = date("payment_date").nullable()

  val stateCheck = check { state inList listOf("open", "pending_payment", "success_payment", "failed_payment") }
  val urlCheck = check { (state eq "open") or (paymentUrl neq null) }
  val dateCheck = check { paymentDate greaterEq createDate }
}

class Basket(id: EntityID<Int>) : IntEntity(id) {
  companion object : IntEntityClass<Basket>(Baskets)

  var student by Student referencedOn Baskets.studentId
  var paymentUrl by Baskets.paymentUrl
  var state by Baskets.state
  var createDate by Baskets.createDate
  var paymentDate by Baskets.paymentDate
}

fun Faker.insertBaskets(n: Int) = generateSequence {
  val isOpen = random.nextBoolean()
  Basket.new {
    student = Student.all().toList().random()
    paymentUrl = if (isOpen) internet.domain() else null
    state = if (isOpen) "open" else "pending_payment" //todo
    createDate = date()
    paymentDate = if (random.nextBoolean()) date() else null
  }
}.take(n)

object BasketItems : Table() {
  val basketId = integer("basket_id").references(Baskets.id, onDelete = ReferenceOption.CASCADE)
  val courseId = integer("course_id").references(Courses.id, onDelete = ReferenceOption.CASCADE).nullable()
  val meetingId = integer("meeting_id").references(Meetings.id, onDelete = ReferenceOption.CASCADE).nullable()
  val studiesId = integer("studies_id").references(Studies.id, onDelete = ReferenceOption.CASCADE).nullable()
  val webinarId = integer("webinar_id").references(Webinars.id, onDelete = ReferenceOption.CASCADE).nullable()

  override val primaryKey = PrimaryKey(basketId, courseId, meetingId, studiesId, webinarId)

  val check = check {
    ((courseId eq null) and (meetingId eq null) and (studiesId eq null) and (webinarId neq null)) or ((courseId eq null) and (meetingId eq null) and (studiesId neq null) and (webinarId eq null)) or ((courseId eq null) and (meetingId neq null) and (studiesId eq null) and (webinarId eq null)) or ((courseId neq null) and (meetingId eq null) and (studiesId eq null) and (webinarId eq null))
  }
}