# Simple script to build and test Stirling-PDF with first-run password feature

# Step 1: Pull the base image
docker pull gradle:8.13-jdk17

# Step 2: Build the application
Write-Host "Building the application..." -ForegroundColor Green
docker run --rm -v "${PWD}:/app" -w /app gradle:8.13-jdk17 ./gradlew clean build -x test

# Step 3: Build the Docker image
Write-Host "Building Docker image..." -ForegroundColor Green
docker build -t stirling-pdf:test .

# Step 4: Run with security enabled
Write-Host "Running container with security enabled..." -ForegroundColor Green
docker run -d --name stirling-pdf-test -e DOCKER_ENABLE_SECURITY=true -p 8080:8080 stirling-pdf:test

Write-Host "\nStirling-PDF is running at http://localhost:8080" -ForegroundColor Cyan
Write-Host "You should see the first-run password setup page." -ForegroundColor Cyan
Write-Host "To stop the container: docker stop stirling-pdf-test" -ForegroundColor Yellow
