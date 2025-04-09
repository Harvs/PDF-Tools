# Debugging build script for PDF Tools with first-run password feature

Write-Host "Building PDF Tools Docker image with first-run password feature (debug mode)..." -ForegroundColor Cyan

# Step 1: Create a temporary build container with full output logging
Write-Host "Step 1: Building the application with Gradle..." -ForegroundColor Green
docker run --rm -it `
  -v "${PWD}:/app" `
  -w /app `
  gradle:8.13-jdk17 `
  bash -c "ls -la && chmod +x ./gradlew && ./gradlew build -x test --info"

# Check if build succeeded
if (!(Test-Path "build/libs/*.jar")) {
    Write-Host "Error: Build failed - JAR file not found" -ForegroundColor Red
    Write-Host "Please check the build output above for errors" -ForegroundColor Red
    exit 1
}

# Create a modified Dockerfile for debugging
$dockerfileContent = Get-Content -Path Dockerfile
$modifiedContent = $dockerfileContent -replace 'CMD .*', 'CMD ["sh", "-c", "java -Dfile.encoding=UTF-8 -jar /app.jar"]'
$modifiedContent | Set-Content -Path Dockerfile.debug

# Step 2: Build the Docker image using the debug Dockerfile
Write-Host "\nStep 2: Building Docker image (debug mode)..." -ForegroundColor Green
docker build -f Dockerfile.debug -t pdf-tools:debug .

# Step 3: Run the Docker container with security enabled (foreground mode to see logs)
Write-Host "\nStep 3: Running Docker container on port 10880 (debug mode)..." -ForegroundColor Green
Write-Host "You'll see the application logs directly. Press Ctrl+C to stop the container when finished." -ForegroundColor Yellow

docker run --rm `
  --name pdf-tools-debug `
  -e DOCKER_ENABLE_SECURITY=true `
  -p 10880:8080 `
  pdf-tools:debug
