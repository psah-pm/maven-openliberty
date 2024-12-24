# Stage 1: Build the application with Maven
FROM maven:3.9.4-eclipse-temurin-17 AS builder

# Set the working directory
WORKDIR /app

# Copy the entire project
COPY . /app

# Build the application
RUN mvn clean package -DskipTests

# Stage 2: Create runtime image with Open Liberty
FROM open-liberty:24.0.0.12-full-java17-openj9

# Copy the generated JAR from the builder stage
COPY --from=builder /app/target/demo-0.0.1-SNAPSHOT.jar /config/apps/

# Copy Open Liberty server.xml configuration
COPY src/main/liberty/config/server.xml /config/

# Enable required Liberty features
RUN /opt/ol/wlp/bin/server featureManager install --acceptLicense --features springBoot-3.0

# Expose ports for HTTP and HTTPS
# EXPOSE 9080 9443
EXPOSE 8081

# Default command to start Open Liberty
CMD ["/opt/ol/wlp/bin/server", "run", "defaultServer"]
