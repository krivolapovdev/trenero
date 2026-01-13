# Build stage
FROM gradle:9.2.1-jdk25-alpine AS build

WORKDIR /app

COPY build.gradle.kts settings.gradle.kts gradle ./

RUN gradle --no-daemon dependencies

COPY . .

RUN gradle --no-daemon bootJar

# Run stage
FROM eclipse-temurin:25.0.1_8-jre-alpine-3.23

WORKDIR /app

COPY --from=build /app/build/libs/*.jar ./app.jar

ENTRYPOINT ["java", "-XX:MaxRAMPercentage=85", "-jar", "app.jar"]
