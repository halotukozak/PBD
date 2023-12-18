package model

import io.github.serpro69.kfaker.Faker
import java.time.Instant
import java.time.LocalDate
import java.time.LocalTime
import java.util.concurrent.ThreadLocalRandom

fun Faker.date(startTime: LocalDate = LocalDate.MIN, endTime: LocalDate = LocalDate.MAX): LocalDate {
  val startSeconds = startTime.toEpochDay()
  val endSeconds = endTime.toEpochDay()
  val randomTime = ThreadLocalRandom.current().nextLong(startSeconds, endSeconds)

  return LocalDate.ofEpochDay(randomTime)
}