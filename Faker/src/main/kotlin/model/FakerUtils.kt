package model

import io.github.serpro69.kfaker.Faker
import io.github.serpro69.kfaker.provider.Internet
import java.time.Instant
import java.time.LocalDate
import java.time.LocalTime
import java.util.concurrent.ThreadLocalRandom

fun Faker.date(
  startTime: LocalDate = LocalDate.of(1900, 1, 1),
  endTime: LocalDate = LocalDate.of(2100, 12, 31),
): LocalDate {
  val startSeconds = startTime.toEpochDay()
  val endSeconds = endTime.toEpochDay()
  val randomTime = ThreadLocalRandom.current().nextLong(startSeconds, endSeconds)

  return LocalDate.ofEpochDay(randomTime)
}

fun Internet.email(name: String, surname: String): String = email("${name}.${surname}".lowercase())