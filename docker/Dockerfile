# # Stage 1: Build the application with Maven
# FROM maven:3.9.4-eclipse-temurin-17 AS builder

# # Set the working directory
# WORKDIR /app

# # Copy the entire project
# COPY . /app

# # Build the application
# RUN mvn clean package -DskipTests

# # Stage 2: Create runtime image with Open Liberty
# FROM open-liberty:24.0.0.12-full-java17-openj9

# # Copy the generated JAR from the builder stage
# COPY --from=builder /app/target/demo-0.0.1-SNAPSHOT.jar /config/apps/

# # Copy Open Liberty server.xml configuration
# COPY src/main/liberty/config/server.xml /config/

# # Enable required Liberty features
# # RUN /opt/ol/wlp/bin/server featureManager install --acceptLicense --features springBoot-3.0

# # Expose ports for HTTP and HTTPS
# EXPOSE 8081 9443

# # Default command to start Open Liberty
# CMD ["/opt/ol/wlp/bin/server", "run", "defaultServer"]



FROM registry.access.redhat.com/ubi8/openjdk-17:1.15-1.1682053058 AS builder

# Install Maven 3.6+
RUN dnf -y install maven

# Build dependency offline to streamline build
RUN mkdir project
WORKDIR /home/jboss/project
COPY pom.xml .
RUN mvn dependency:go-offline

COPY src src
RUN mvn package -Dmaven.test.skip=true
# compute the created jar name and put it in a known location to copy to the next layer.
# If the user changes pom.xml to have a different version, or artifactId, this will find the jar
RUN grep version target/maven-archiver/pom.properties | cut -d '=' -f2 >.env-version
RUN grep artifactId target/maven-archiver/pom.properties | cut -d '=' -f2 >.env-id
RUN mv target/$(cat .env-id)-$(cat .env-version).jar target/export-run-artifact.jar

FROM registry.access.redhat.com/ubi8/openjdk-17-runtime:1.15-1.1682053056
COPY --from=builder /home/jboss/project/target/export-run-artifact.jar  /deployments/export-run-artifact.jar
COPY src/main/liberty/config/server.xml /config/server.xml
EXPOSE 8081
ENTRYPOINT ["/opt/jboss/container/java/run/run-java.sh", "--server.port=8081"]