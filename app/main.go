package main

import (
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
		fmt.Println("Hello World!")
	}
}
