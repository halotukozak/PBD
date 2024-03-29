package model

import io.github.serpro69.kfaker.Faker
import io.github.serpro69.kfaker.RandomService
import io.github.serpro69.kfaker.provider.Internet
import java.time.LocalDate
import java.time.LocalDateTime
import java.time.LocalTime
import java.time.ZoneOffset
import java.util.concurrent.ThreadLocalRandom

fun Faker.date(
  startDate: LocalDate = LocalDate.of(1980, 1, 1),
  endDate: LocalDate = LocalDate.of(2025, 12, 31),
): LocalDate {
  val startSeconds = startDate.toEpochDay()
  val endSeconds = endDate.toEpochDay()
  val randomTime = ThreadLocalRandom.current().nextLong(startSeconds, endSeconds)

  return LocalDate.ofEpochDay(randomTime)
}

fun Faker.dateTime(
  startTime: LocalDateTime = LocalDateTime.of(LocalDate.of(1980, 1, 1), LocalTime.MIN),
  endTime: LocalDateTime = LocalDateTime.of(LocalDate.of(2025, 12, 31), LocalTime.MAX),
): LocalDateTime {
  val startSeconds = startTime.toEpochSecond(ZoneOffset.UTC)
  val endSeconds = endTime.toEpochSecond(ZoneOffset.UTC)
  val randomTime = ThreadLocalRandom.current().nextLong(startSeconds, endSeconds)

  return LocalDateTime.ofEpochSecond(randomTime, 0, ZoneOffset.UTC)
}

fun Internet.url(domain: String = domain(), path: String): String =
  "https://${domain.slug()}/${path.slug()}".take(200)

fun Internet.email(name: String, surname: String): String =
  email(
    "$name $surname"
      .replace(".", "")
      .replace(" ", ".")
      .lowercase()
  )

fun String.slug() = lowercase()
  .replace("\n", " ")
  .replace("[^a-z\\d\\s]".toRegex(), " ")
  .split(" ")
  .joinToString("-")
  .replace("-+".toRegex(), "-")

fun Faker.subject(): String = when (random.nextInt(0..7)) {
  0 -> science.branch.formalBasic()
  2 -> science.branch.formalApplied()
  3 -> science.branch.empiricalSocialBasic()
  4 -> science.branch.empiricalNaturalBasic()
  5 -> science.branch.empiricalSocialApplied()
  6 -> science.branch.empiricalNaturalApplied()
  else -> "Introduction to ${programmingLanguage.name()}"
}

fun Faker.studiesName(): String = when (random.nextInt(0..6)) {
  0 -> science.branch.formalBasic()
  2 -> science.branch.formalApplied()
  3 -> science.branch.empiricalSocialBasic()
  4 -> science.branch.empiricalNaturalBasic()
  5 -> science.branch.empiricalSocialApplied()
  else -> science.branch.empiricalNaturalApplied()
}

operator fun RandomService.invoke(f: () -> Unit) {
  if (nextBoolean()) return f()
}