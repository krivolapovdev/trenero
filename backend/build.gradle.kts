plugins {
    java
    id("org.springframework.boot") version "4.0.0"
    id("io.spring.dependency-management") version "1.1.7"
    id("com.diffplug.spotless") version "8.1.0"
    id("com.netflix.dgs.codegen") version "8.3.0"
}

group = "tech.trenero"
description = "backend"
version = "1.0.0"

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(25)
    }
}

configurations {
    compileOnly {
        extendsFrom(configurations.annotationProcessor.get())
    }
}

repositories {
    mavenCentral()
}

val springModulithVersion = "2.0.0"
val openApiVersion = "3.0.0"
val mapStructVersion = "1.6.3"
val jjwtVersion = "0.13.0"
val googleApiClientVersion = "2.8.1"
val uuidCreatorVersion = "6.1.0"
val graphqlScalarsVersion = "24.0"
dependencies {
    implementation("org.springframework.boot:spring-boot-starter-webmvc")
    implementation("org.springframework.boot:spring-boot-starter-validation")
    implementation("org.springframework.boot:spring-boot-starter-data-jpa")
    implementation("org.springframework.boot:spring-boot-starter-actuator")
    implementation("org.springframework.boot:spring-boot-starter-security")
    implementation("org.springframework.boot:spring-boot-starter-graphql")
    implementation("org.springframework.boot:spring-boot-starter-flyway")
    implementation("org.springframework.modulith:spring-modulith-starter-core:$springModulithVersion")
    implementation("org.springdoc:springdoc-openapi-starter-webmvc-ui:$openApiVersion")
    implementation("org.postgresql:postgresql")
    implementation("org.mapstruct:mapstruct:$mapStructVersion")
    implementation("io.jsonwebtoken:jjwt-api:${jjwtVersion}")
    implementation("com.google.api-client:google-api-client:${googleApiClientVersion}")
    implementation("com.github.f4b6a3:uuid-creator:${uuidCreatorVersion}")
    implementation("com.graphql-java:graphql-java-extended-scalars:${graphqlScalarsVersion}")
    implementation("org.flywaydb:flyway-core")
    implementation("org.flywaydb:flyway-database-postgresql")

    testImplementation("org.springframework.boot:spring-boot-starter-webmvc-test")
    testImplementation("org.springframework.boot:spring-boot-testcontainers")
    testImplementation("org.springframework.boot:spring-boot-starter-data-jpa-test")
    testImplementation("org.springframework.modulith:spring-modulith-starter-test:$springModulithVersion")
    testImplementation("org.testcontainers:testcontainers-postgresql")
    testImplementation("org.testcontainers:testcontainers-junit-jupiter")
    testImplementation("org.springframework.graphql:spring-graphql-test")
    testImplementation("org.springframework:spring-webflux")

    testRuntimeOnly("org.junit.platform:junit-platform-launcher")

    runtimeOnly("io.jsonwebtoken:jjwt-impl:${jjwtVersion}")
    runtimeOnly("io.jsonwebtoken:jjwt-jackson:${jjwtVersion}")

    compileOnly("org.projectlombok:lombok")

    annotationProcessor("org.projectlombok:lombok")
    annotationProcessor("org.mapstruct:mapstruct-processor:$mapStructVersion")
    annotationProcessor("org.springframework.boot:spring-boot-configuration-processor")
}

tasks.withType<Test> {
    useJUnitPlatform()
}

spotless {
    java {
        googleJavaFormat()
        target("src/**/*.java")
    }
}

tasks.generateJava {
    schemaPaths.add("${projectDir}/src/main/resources/graphql")
    packageName = "tech.trenero.backend.codegen"
    language = "java"
    addGeneratedAnnotation = true
    generateCustomAnnotations = true
    typeMapping = mutableMapOf(
        "UUID" to "java.util.UUID",
        "BigDecimal" to "java.math.BigDecimal",
        "Date" to "java.time.LocalDate",
        "DateTime" to "java.time.OffsetDateTime"
    )
}
