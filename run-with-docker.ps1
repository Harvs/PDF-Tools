# Run the application using the official Docker image with security enabled

# Pull the latest image
Write-Host "Pulling the latest Stirling-PDF image..."
docker pull frooodle/s-pdf:latest

# Run with security enabled to test our first-run password feature
Write-Host "Starting Stirling-PDF with security enabled..."

# The --rm flag removes the container when it's stopped
# -e sets environment variables - we need DOCKER_ENABLE_SECURITY=true for our feature
# -p maps port 8080 inside container to port 8080 on host
# -v mounts a volume for config persistence
docker run --rm -d \
  --name stirling-pdf-test \
  -e DOCKER_ENABLE_SECURITY=true \
  -p 8080:8080 \
  -v "$(pwd)/configs:/configs" \
  frooodle/s-pdf:latest

Write-Host "\nStirling-PDF is running with security enabled at http://localhost:8080"
Write-Host "You should be redirected to the first-run password setup page."
Write-Host "To stop the container, run: docker stop stirling-pdf-test"
