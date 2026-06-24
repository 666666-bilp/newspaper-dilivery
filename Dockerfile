# Stage 1: Build WAR with Maven
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
# Download dependencies first (layer caching)
RUN mvn dependency:go-offline -B -q
COPY src ./src
RUN mvn package -B -q -DskipTests

# Stage 2: Run on Tomcat 10
FROM tomcat:10.1-jdk17
# Remove default apps
RUN rm -rf /usr/local/tomcat/webapps/*
# Copy WAR
COPY --from=build /app/target/newspaper-delivery.war /usr/local/tomcat/webapps/ROOT.war
EXPOSE 8080
CMD ["catalina.sh", "run"]
