# Fixed build script for PDF Tools with first-run password feature

Write-Host "Building PDF Tools Docker image with first-run password feature (fixed version)..." -ForegroundColor Cyan

# Step 1: Check if the jar exists and get its exact name
if (!(Test-Path "build/libs/*.jar")) {
    Write-Host "Building the Java application with Gradle first..." -ForegroundColor Yellow
    # Run Gradle build
    docker run --rm -it `
    -v "${PWD}:/app" `
    -w /app `
    gradle:8.13-jdk17 `
    bash -c "chmod +x ./gradlew && ./gradlew build -x test"
}

# Find the exact JAR file name
$jarFile = Get-ChildItem "build/libs/*.jar" | Select-Object -First 1
if ($null -eq $jarFile) {
    Write-Host "Error: No JAR file found in build/libs directory!" -ForegroundColor Red
    exit 1
}

Write-Host "Using JAR file: $($jarFile.Name)" -ForegroundColor Green

# Create a simplified Dockerfile for testing
$dockerFileContent = @"
FROM alpine:3.21.3

# Copy necessary files
COPY scripts /scripts
COPY pipeline /pipeline

# Copy the exact JAR file to avoid wildcard issues
COPY build/libs/$($jarFile.Name) /app.jar

# Set Environment Variables
ENV DOCKER_ENABLE_SECURITY=true

# Install Java
RUN apk add --no-cache openjdk21-jre tini bash

# Make scripts executable
RUN chmod +x /scripts/*

EXPOSE 8080/tcp

# Run only the Java application (no unoserver) to see potential errors
ENTRYPOINT ["tini", "--"]
CMD ["java", "-Dfile.encoding=UTF-8", "-jar", "/app.jar"]
"@

$dockerFileContent | Set-Content -Path "Dockerfile"

# Step 2: Build the Docker image with the simplified Dockerfile
Write-Host "Building Docker image with simplified configuration..." -ForegroundColor Green
docker build -f Dockerfile -t pdf-tools:V1 .

# Step 3: Run the Docker container
Write-Host "Running Docker container on port 8888..." -ForegroundColor Green
Write-Host "You'll see the application logs directly. Press Ctrl+C to stop when finished." -ForegroundColor Yellow

docker run --rm `
  --name pdf-tools-v1 `
  -p 8888:8080 `
  pdf-tools:v1
