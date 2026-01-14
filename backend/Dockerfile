# Build stage
FROM eclipse-temurin:25.0.1_8-jdk-alpine-3.23 AS build

WORKDIR /app

COPY gradlew .

COPY gradle gradle

COPY build.gradle.kts settings.gradle.kts ./

RUN chmod +x gradlew && ./gradlew --no-daemon dependencies

COPY . .

RUN ./gradlew --no-daemon bootJar

# Run stage
FROM eclipse-temurin:25.0.1_8-jre-alpine-3.23

WORKDIR /app

COPY --from=build /app/build/libs/*.jar app.jar

ENTRYPOINT ["java", "-XX:MaxRAMPercentage=85", "-jar", "app.jar"]
