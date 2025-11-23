FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /workspace
COPY pom.xml .
RUN --mount=type=cache,target=/root/.m2 mvn -q -e -DskipTests dependency:go-offline
COPY src ./src
RUN --mount=type=cache,target=/root/.m2 mvn -q -e -DskipTests package

FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
RUN apk add --no-cache curl postgresql-client
COPY --from=build /workspace/target/api-recetas-0.0.1-SNAPSHOT.jar app.jar
RUN addgroup -S app && adduser -S -G app app \
	&& chown -R app:app /app
USER app
EXPOSE 8081
ENTRYPOINT ["java","-jar","/app/app.jar"]
