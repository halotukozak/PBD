package org.oolab.model.model

import model.Translators
import org.jetbrains.exposed.dao.IntEntity
import org.jetbrains.exposed.dao.IntEntityClass
import org.jetbrains.exposed.dao.id.EntityID
import org.jetbrains.exposed.dao.id.IntIdTable
import org.jetbrains.exposed.sql.ReferenceOption
import org.jetbrains.exposed.sql.Table

object Languages : IntIdTable("Language") {
  val name = varchar("name", 50).uniqueIndex()
}

class Language(id: EntityID<Int>) : IntEntity(id) {
  companion object : IntEntityClass<Language>(Languages)

  var name by Languages.name
}

object TranslatorLanguage : Table("TranslatorLanguage") {
  val translatorId = integer("translator_id").references(Translators.id, onDelete = ReferenceOption.CASCADE)
  val languageId = integer("language_id").references(Languages.id, onDelete = ReferenceOption.CASCADE)

  override val primaryKey: PrimaryKey = PrimaryKey(translatorId, languageId)
}