package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/gorilla/mux"
	"github.com/joho/godotenv"
)

// Person represents the data structure for each person
type Person struct {
	ID     string `json:"id"`
	Name   string `json:"name"`
	Phone  string `json:"phone"`
	Number int    `json:"number"`
	Email  string `json:"email"`
}

// Config holds application configuration
type Config struct {
	BackendURL string
	Port       string
}

// loadConfig loads configuration from environment variables
func loadConfig() (*Config, error) {
	// Load .env file if it exists
	godotenv.Load()

	config := &Config{
		BackendURL: getEnv("BACKEND_URL", "http://localhost:8081/api/data"),
		Port:       getEnv("PORT", "8080"),
	}

	return config, nil
}

// getEnv gets environment variable with fallback
func getEnv(key, fallback string) string {
	if value := os.Getenv(key); value != "" {
		return value
	}
	return fallback
}

// fetchDataFromBackend fetches batch data from the backend service
func fetchDataFromBackend(backendURL string) ([]Person, error) {
	client := &http.Client{
		Timeout: 10 * time.Second,
	}

	resp, err := client.Get(backendURL)
	if err != nil {
		return nil, fmt.Errorf("failed to fetch data from backend: %v", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("backend service returned status: %d", resp.StatusCode)
	}

	var people []Person
	if err := json.NewDecoder(resp.Body).Decode(&people); err != nil {
		return nil, fmt.Errorf("failed to decode response: %v", err)
	}

	return people, nil
}

// handleGetData handles the GET /data endpoint
func handleGetData(config *Config) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		people, err := fetchDataFromBackend(config.BackendURL)
		if err != nil {
			log.Printf("Error fetching data: %v", err)
			http.Error(w, fmt.Sprintf("Failed to fetch data: %v", err), http.StatusInternalServerError)
			return
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{
			"success": true,
			"data":    people,
			"count":   len(people),
		})
	}
}

// handleHealth handles the health check endpoint
func handleHealth(w http.ResponseWriter, r *http.Request) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(map[string]interface{}{
		"status": "healthy",
		"time":   time.Now().Format(time.RFC3339),
	})
}

// setupRoutes sets up the HTTP routes
func setupRoutes(config *Config) *mux.Router {
	r := mux.NewRouter()

	// API routes
	r.HandleFunc("/api/data", handleGetData(config)).Methods("GET")
	r.HandleFunc("/health", handleHealth).Methods("GET")

	// Serve static files (for a simple frontend)
	r.PathPrefix("/").Handler(http.FileServer(http.Dir("static")))

	return r
}

func main() {
	config, err := loadConfig()
	if err != nil {
		log.Fatalf("Failed to load configuration: %v", err)
	}

	log.Printf("Starting demo application on port %s", config.Port)
	log.Printf("Backend URL: %s", config.BackendURL)

	router := setupRoutes(config)

	log.Fatal(http.ListenAndServe(":"+config.Port, router))
}
