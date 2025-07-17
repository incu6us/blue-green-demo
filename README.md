# Demo App - Golang Web Application

A simple Golang web application that fetches batch data from a backend service and displays it in a web interface.

## Features

- Fetches batch data from a configurable backend service
- Displays data in a clean, responsive web interface
- Configurable environment variables
- Health check endpoint
- Error handling and logging

## Data Structure

The application expects data in the following format:

```json
[
  {
    "id": "1",
    "name": "John Doe",
    "phone": "+1-555-0123",
    "number": 12345,
    "email": "john.doe@example.com"
  }
]
```

## Prerequisites

- Go 1.21 or higher
- A backend service that provides data in the expected format

## Installation

1. Clone or download this repository
2. Navigate to the project directory
3. Install dependencies:

```bash
go mod tidy
```

## Configuration

The application uses environment variables for configuration. You can set them in several ways:

### Option 1: Environment Variables

```bash
export BACKEND_URL=http://localhost:9875/api/data
export PORT=9876
```

### Option 2: .env File

Copy the example file and modify it:

```bash
cp env.example .env
```

Then edit `.env` with your configuration:

```
BACKEND_URL=http://your-backend-service:8081/api/data
PORT=8080
```

### Configuration Options

- `BACKEND_URL`: URL of the backend service (default: `http://localhost:9875/api/data`)
- `PORT`: Port for the web application (default: `9876`)

## Running the Application

### Development

```bash
go run main.go
```

### Production

```bash
go build -o demo-app main.go
./demo-app
```

## Usage

1. Start the application
2. Open your browser and navigate to `http://localhost:8080`
3. The application will automatically fetch data from the backend service
4. Use the "Fetch Data" button to refresh the data
5. Use the "Clear Data" button to clear the display

## API Endpoints

- `GET /` - Web interface
- `GET /api/data` - Fetch data from backend service
- `GET /health` - Health check endpoint

## Backend Service Requirements

Your backend service should:

1. Accept GET requests at the configured URL
2. Return JSON data in the expected format
3. Return HTTP 200 status code on success
4. Include proper CORS headers if needed

### Example Backend Response

```json
[
  {
    "id": "1",
    "name": "Alice Johnson",
    "phone": "+1-555-0101",
    "number": 1001,
    "email": "alice.johnson@example.com"
  },
  {
    "id": "2",
    "name": "Bob Smith",
    "phone": "+1-555-0102",
    "number": 1002,
    "email": "bob.smith@example.com"
  }
]
```

## Development

### Project Structure

```
demo-app/
├── main.go          # Main application file
├── go.mod           # Go module file
├── go.sum           # Go dependencies checksum
├── static/          # Static web files
│   └── index.html   # Web interface
├── env.example      # Example environment configuration
└── README.md        # This file
```

### Adding Features

- Modify `main.go` to add new API endpoints
- Update `static/index.html` to enhance the web interface
- Add new environment variables in the `Config` struct

## Troubleshooting

### Common Issues

1. **Backend service not reachable**: Check the `BACKEND_URL` configuration and ensure the backend service is running
2. **Port already in use**: Change the `PORT` environment variable
3. **CORS issues**: Ensure your backend service includes proper CORS headers

### Logs

The application logs important information to stdout, including:
- Configuration values on startup
- Errors when fetching data from backend
- HTTP request details

## License

This is a demo application for educational purposes. 
