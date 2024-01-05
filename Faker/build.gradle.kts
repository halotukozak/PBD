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
val fakerVersion: String = "1.15.0"

dependencies {
  implementation("org.jetbrains.exposed:exposed-core:$exposedVersion")
  implementation("org.jetbrains.exposed:exposed-dao:$exposedVersion")
  implementation("org.jetbrains.exposed:exposed-jdbc:$exposedVersion")
  implementation("org.jetbrains.exposed:exposed-java-time:$exposedVersion")
  implementation("io.github.serpro69:kotlin-faker:$fakerVersion")
  implementation("org.jetbrains.kotlinx:kotlinx-serialization-json:1.6.0")
  implementation("com.microsoft.sqlserver:mssql-jdbc:9.4.1.jre8")
  implementation("org.slf4j:slf4j-nop:1.7.36")
  implementation("com.typesafe:config:1.4.1")
}

tasks.test {
  useJUnitPlatform()
}

kotlin {
  jvmToolchain(21)
}
