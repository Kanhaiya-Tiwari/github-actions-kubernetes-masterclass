package handlers

import (
	"bytes"
	"encoding/json"
	"net/http"
	"os"
	"time"

	"github.com/gin-gonic/gin"
)

type ChatRequest struct {
	Message string `json:"message"`
}

type OllamaRequest struct {
	Model  string `json:"model"`
	Prompt string `json:"prompt"`
	Stream bool   `json:"stream"`
}

type OllamaResponse struct {
	Response string `json:"response"`
}

func ChatHandler(c *gin.Context) {
	var req ChatRequest
	if err := c.ShouldBindJSON(&req); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	ollamaURL := os.Getenv("OLLAMA_URL")
	if ollamaURL == "" {
		ollamaURL = "http://localhost:11434"
	}

	// Prepare payload for Ollama
	payload := OllamaRequest{
		Model:  "tinyllama",
		Prompt: "You are a helpful learning assistant for the SkillPulse project. The user is asking about skills, coding, databases, or DevOps. Be highly professional, friendly, and concise in your response. Keep it to 2-3 sentences. User Query: " + req.Message,
		Stream: false,
	}

	jsonData, err := json.Marshal(payload)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to marshal Ollama request"})
		return
	}

	// Send POST request to Ollama
	client := &http.Client{Timeout: 10 * time.Second}
	resp, err := client.Post(ollamaURL+"/api/generate", "application/json", bytes.NewBuffer(jsonData))
	if err != nil {
		// Fallback mock response if Ollama is not active on the system (so the pipeline and app still works cleanly!)
		c.JSON(http.StatusOK, gin.H{"response": "[Offline Sandbox] Hello! I see that Ollama is currently offline or not running locally. To activate my live AI brain, simply start Ollama on your system and run `ollama run tinylama`!"})
		return
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		c.JSON(http.StatusBadGateway, gin.H{"error": "Ollama service returned non-200 status"})
		return
	}

	var oResp OllamaResponse
	if err := json.NewDecoder(resp.Body).Decode(&oResp); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to decode Ollama response"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"response": oResp.Response})
}
