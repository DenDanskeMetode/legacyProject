package main

import (
	"net/http"
)

func main() {
	http.HandleFunc("/test", testFunc)

}

func testFunc(w http.ResponseWriter, r *http.Request) {

}
