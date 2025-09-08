# build stage
FROM maven:3.9.6-eclipse-temurin-17 AS builder
WORKDIR /workspace

COPY . .

# skip tests and copy all required dependencies
RUN mvn clean package -DskipTests dependency:copy-dependencies

FROM eclipse-temurin:17-jre
WORKDIR /app

COPY --from=builder /workspace/target/dependency ./lib
COPY --from=builder /workspace/target/*.jar app.jar

# set entrypoint to run java cli with dependencies
ENTRYPOINT ["java", "-cp", "app.jar:lib/*", "gov.nist.secauto.oscal.tools.cli.core.CLI"]
