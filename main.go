package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
)

type BridgeRequest struct {
	UserAddress string `json:"userAddress"`
	Amount      uint64 `json:"amount"`
	TxHash      string `json:"txHash"`
}

var processedTransactions = make(map[string]bool)

func lockTokens(w http.ResponseWriter, r *http.Request) {
	var request BridgeRequest
	err := json.NewDecoder(r.Body).Decode(&request)
	if err != nil {
		http.Error(w, "Invalid request", http.StatusBadRequest)
		return
	}

	if processedTransactions[request.TxHash] {
		http.Error(w, "Transaction already processed", http.StatusConflict)
		return
	}

	processedTransactions[request.TxHash] = true
	fmt.Fprintf(w, "Tokens locked successfully for %s", request.UserAddress)
}

func main() {
	http.HandleFunc("/lock", lockTokens)
	fmt.Println("Cross-chain bridge backend running on port 8080...")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
