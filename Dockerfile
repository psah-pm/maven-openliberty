# Use the Open Liberty image as the base
FROM open-liberty:24.0.0.12-full-java17-openj9


# Copy the Spring Boot application JAR to the container
COPY target/demo-0.0.1-SNAPSHOT.jar /config/apps/

# Copy Open Liberty server.xml configuration
COPY src/main/liberty/config/server.xml /config/

# Enable required Liberty features
RUN /opt/ol/wlp/bin/server featureManager install --acceptLicense --features springBoot-3.0

# Expose ports for HTTP and HTTPS
EXPOSE 9080 9443

# Default command to start Open Liberty
CMD ["/opt/ol/wlp/bin/server", "run", "defaultServer"]