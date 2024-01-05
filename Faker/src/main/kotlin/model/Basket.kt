package model

import model.BasketState.open
import org.jetbrains.exposed.dao.IntEntity
import org.jetbrains.exposed.dao.IntEntityClass
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.ReferenceOption
import org.jetbrains.exposed.sql.Table
import org.jetbrains.exposed.sql.and
import org.jetbrains.exposed.sql.javatime.date
import org.jetbrains.exposed.sql.or

object Baskets : IntIdTable("Basket") {
  val studentId = integer("student_id").references(Students.id, onDelete = ReferenceOption.CASCADE)
  val paymentUrl = varchar("payment_url", 200).nullable()
  val state = enumerationByName<BasketState>("state", 15)
  val createDate = date("create_date")
  val paymentDate = date("payment_date").nullable()

  val urlCheck = check { (state eq open) or (paymentUrl neq null) }
  val dateCheck = check { paymentDate greaterEq createDate }
}

class Basket(id: EntityID<Int>) : IntEntity(id) {
  companion object : IntEntityClass<Basket>(Baskets)

  var student by Student referencedOn Baskets.studentId
  var paymentUrl by Baskets.paymentUrl
  var state by Baskets.state
  var createDate by Baskets.createDate
  var paymentDate by Baskets.paymentDate

  var courses by Course via BasketItems
  var meetings by Meeting via BasketItems
  var studies by Studies via BasketItems
  var webinars by Webinar via BasketItems
}

object BasketItems : Table("BasketItem") {
  val basketId = integer("basket_id").references(Baskets.id, onDelete = ReferenceOption.CASCADE)
  val courseId = integer("course_id").references(Courses.id, onDelete = ReferenceOption.NO_ACTION).nullable()
  val meetingId = integer("meeting_id").references(Meetings.id, onDelete = ReferenceOption.NO_ACTION).nullable()
  val studiesId = integer("studies_id").references(StudiesTable.id, onDelete = ReferenceOption.NO_ACTION).nullable()
  val webinarId = integer("webinar_id").references(Webinars.id, onDelete = ReferenceOption.NO_ACTION).nullable()

  init {
    uniqueIndex(basketId, courseId, meetingId, studiesId, webinarId)
  }

  val xor = check {
    ((courseId eq null) and (meetingId eq null) and (studiesId eq null) and (webinarId neq null)) or ((courseId eq null) and (meetingId eq null) and (studiesId neq null) and (webinarId eq null)) or ((courseId eq null) and (meetingId neq null) and (studiesId eq null) and (webinarId eq null)) or ((courseId neq null) and (meetingId eq null) and (studiesId eq null) and (webinarId eq null))
  }
}

enum class BasketState {
  open, pending_payment, success_payment, failed_payment
}