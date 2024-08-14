# First stage: Build the Java JAR application
FROM openjdk:11-jre-slim AS jar-build

# Set the working directory
WORKDIR /app

# Copy the JAR file to the build directory
COPY server.jar /app/server.jar

# Second stage: Use Tomcat as a base and copy WAR and JAR files
FROM tomcat:latest

# Copy the WAR file into the webapps directory of Tomcat
COPY /webapp/target/*.war /usr/local/tomcat/webapps/

# Copy the JAR file from the first stage into the Tomcat container
COPY --from=jar-build /app/server.jar /usr/local/tomcat/server.jar

# Start both Tomcat and the Java application
CMD ["sh", "-c", "catalina.sh run & java -jar /usr/local/tomcat/server.jar"]


# FROM tomcat:latest
# RUN cp -R  /usr/local/tomcat/webapps.dist/*  /usr/local/tomcat/webapps
# COPY /webapp/target/*.war /usr/local/tomcat/webapps

