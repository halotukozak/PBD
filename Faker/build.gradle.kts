plugins {
  kotlin("jvm") version "1.9.21"
  kotlin("plugin.serialization") version "1.9.21"
}

group = "org.faker"
version = "1.0-SNAPSHOT"

repositories {
  mavenCentral()
}

val exposedVersion: String = "0.45.0"

dependencies {
  implementation("org.jetbrains.exposed:exposed-core:$exposedVersion")
  implementation("org.jetbrains.exposed:exposed-dao:$exposedVersion")
  implementation("org.jetbrains.exposed:exposed-jdbc:$exposedVersion")
  implementation("org.jetbrains.exposed:exposed-java-time:$exposedVersion")
  implementation("io.github.serpro69:kotlin-faker:1.15.0")
  implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.0")
  implementation("com.microsoft.sqlserver:mssql-jdbc:9.4.1.jre8")
  implementation("ch.qos.logback:logback-classic:1.4.12")
  implementation("io.github.microutils:kotlin-logging-jvm:2.0.11")
  implementation("com.typesafe:config:1.4.1")
}

tasks.test {
  useJUnitPlatform()
}

kotlin {
  jvmToolchain(21)
}
