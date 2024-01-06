package model

import io.github.serpro69.kfaker.Faker
import io.github.serpro69.kfaker.provider.Internet
import io.github.serpro69.kfaker.provider.Name
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.LocalTime
import java.time.ZoneOffset
import java.util.concurrent.ThreadLocalRandom

fun Faker.date(
  startDate: LocalDate = LocalDate.of(1900, 1, 1),
  endDate: LocalDate = LocalDate.of(2100, 12, 31),
): LocalDate {
  val startSeconds = startDate.toEpochDay()
  val endSeconds = endDate.toEpochDay()
  val randomTime = ThreadLocalRandom.current().nextLong(startSeconds, endSeconds)

  return LocalDate.ofEpochDay(randomTime)
}

fun Faker.dateTime(
  startTime: LocalDateTime = LocalDateTime.of(LocalDate.of(1900, 1, 1), LocalTime.MIN),
  endTime: LocalDateTime = LocalDateTime.of(LocalDate.of(2100, 12, 31), LocalTime.MAX),
): LocalDateTime {
  val startSeconds = startTime.toEpochSecond(ZoneOffset.UTC)
  val endSeconds = endTime.toEpochSecond(ZoneOffset.UTC)
  val randomTime = ThreadLocalRandom.current().nextLong(startSeconds, endSeconds)

  return LocalDateTime.ofEpochSecond(randomTime, 0, ZoneOffset.UTC)
}

fun Internet.url(domain: String = domain(), content: String): String = "https://${domain.slug()}/${content.slug()}".take(200)
fun Internet.email(name: Name): String = with(name) {
  email(
    "${firstName()} ${lastName()}"
      .replace(".", "")
      .replace(" ", ".")
      .lowercase()
  )
}

fun String.slug() = lowercase()
  .replace("\n", " ")
  .replace("[^a-z\\d\\s]".toRegex(), " ")
  .split(" ")
  .joinToString("-")
  .replace("-+".toRegex(), "-")