# Run Stirling PDF directly with Gradle
Write-Host "Starting Stirling PDF with security enabled..."

# Set environment variables
$env:DOCKER_ENABLE_SECURITY = "true"

# Run the application with Gradle
./gradlew bootRun --args="--server.port=8888"
