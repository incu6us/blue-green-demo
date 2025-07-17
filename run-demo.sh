#!/bin/bash

echo "Starting Demo Application..."

# Function to cleanup background processes on exit
cleanup() {
    echo "Shutting down services..."
    kill $DEMO_PID $MOCK_PID 2>/dev/null
    exit 0
}

# Set trap to cleanup on script exit
trap cleanup SIGINT SIGTERM

# Start mock backend service
echo "Starting mock backend service on port 8081..."
cd mock-backend
go run main.go &
MOCK_PID=$!
cd ..

# Wait a moment for mock backend to start
sleep 2

# Start demo application
echo "Starting demo application on port 8080..."
go run main.go &
DEMO_PID=$!

echo ""
echo "Services started successfully!"
echo "Demo app: http://localhost:8080"
echo "Mock backend: http://localhost:8081/api/data"
echo ""
echo "Press Ctrl+C to stop all services"

# Wait for background processes
wait 