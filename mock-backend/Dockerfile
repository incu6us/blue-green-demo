# Build stage
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Copy source code
COPY main.go .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o mock-backend main.go

# Final stage
FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy the binary from builder stage
COPY --from=builder /app/mock-backend .

# Expose port
EXPOSE 9875

# Run the application
CMD ["./mock-backend"] 
