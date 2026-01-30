package main

import (
	"fmt"
	"net/http"
)

func main() {
	http.HandleFunc("/test", testFunc)

}

func testFunc(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "GET":
		fmt.Println("Hello World!")
	}
}
