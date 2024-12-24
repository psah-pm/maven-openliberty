# Use the UBI8 OpenJDK image as the base for building the application
FROM registry.access.redhat.com/ubi8/openjdk-17:1.15-1.1682053058 AS builder

# Set the working directory
WORKDIR /home/jboss/project

# Copy the Maven POM file to use it for downloading dependencies
COPY pom.xml . 

# Download dependencies offline
RUN mvn dependency:go-offline

# Copy the source code
COPY src src

# Build the Spring Boot application and skip tests
RUN mvn package -Dmaven.test.skip=true

# Get the JAR file name (if the version or artifactId changes)
RUN grep version target/maven-archiver/pom.properties | cut -d '=' -f2 >.env-version
RUN grep artifactId target/maven-archiver/pom.properties | cut -d '=' -f2 >.env-id

# Move the built JAR to a known location for the next stage
RUN mv target/$(cat .env-id)-$(cat .env-version).jar target/export-run-artifact.jar

# Use Open Liberty image for runtime and configuration
FROM open-liberty:24.0.0.12-full-java17-openj9

# Copy the Spring Boot JAR file from the builder stage
COPY --from=builder /home/jboss/project/target/export-run-artifact.jar /config/apps/demo-0.0.1-SNAPSHOT.jar

# Copy the Open Liberty configuration
COPY src/main/liberty/config/server.xml /config/

# Enable the required Liberty features for Spring Boot
RUN /opt/ol/wlp/bin/server featureManager install --acceptLicense --features springBoot-3.0

# Expose the necessary ports
EXPOSE 9080 9443

# Start Open Liberty with the Spring Boot application
CMD ["/opt/ol/wlp/bin/server", "run", "defaultServer"]
