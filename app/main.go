package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
)

func main() {
	fmt.Println("Server started 😨🎏")
	http.HandleFunc("/test", testFunc)
	log.Fatal(http.ListenAndServe(":8000", nil)) //start server
}

func testFunc(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "GET":
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		response := map[string]string{"message": "hello there"}
		json.NewEncoder(w).Encode(response)
	}
}
