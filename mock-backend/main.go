package main

import (
	"encoding/json"
	"log"
	"net/http"
	"time"
)

// Person represents the data structure
type Person struct {
	ID     string `json:"id"`
	Name   string `json:"name"`
	Phone  string `json:"phone"`
	Number int    `json:"number"`
	Email  string `json:"email"`
}

// generateMockData creates sample data for testing
func generateMockData() []Person {
	return []Person{
		{
			ID:     "1",
			Name:   "Alice Johnson",
			Phone:  "+1-555-0101",
			Number: 1001,
			Email:  "alice.johnson@example.com",
		},
		{
			ID:     "2",
			Name:   "Bob Smith",
			Phone:  "+1-555-0102",
			Number: 1002,
			Email:  "bob.smith@example.com",
		},
		{
			ID:     "3",
			Name:   "Carol Davis",
			Phone:  "+1-555-0103",
			Number: 1003,
			Email:  "carol.davis@example.com",
		},
		{
			ID:     "4",
			Name:   "David Wilson",
			Phone:  "+1-555-0104",
			Number: 1004,
			Email:  "david.wilson@example.com",
		},
		{
			ID:     "5",
			Name:   "Eva Brown",
			Phone:  "+1-555-0105",
			Number: 1005,
			Email:  "eva.brown@example.com",
		},
	}
}

// handleData serves the mock data
func handleData(w http.ResponseWriter, r *http.Request) {
	// Add CORS headers
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Methods", "GET, OPTIONS")
	w.Header().Set("Access-Control-Allow-Headers", "Content-Type")

	// Handle preflight requests
	if r.Method == "OPTIONS" {
		w.WriteHeader(http.StatusOK)
		return
	}

	// Add a small delay to simulate network latency
	time.Sleep(100 * time.Millisecond)

	data := generateMockData()

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(data)
}

// handleHealth serves a health check endpoint
func handleHealth(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"status":  "healthy",
		"time":    time.Now().Format(time.RFC3339),
		"service": "mock-backend",
	})
}

func main() {
	http.HandleFunc("/api/data", handleData)
	http.HandleFunc("/health", handleHealth)

	log.Println("Starting mock backend service on port 8081")
	log.Println("Available endpoints:")
	log.Println("  GET /api/data - Returns mock data")
	log.Println("  GET /health   - Health check")

	log.Fatal(http.ListenAndServe(":9875", nil))
}
