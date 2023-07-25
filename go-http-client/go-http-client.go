package main

import (
	"fmt"
	"io/ioutil"
	"net/http"
)

func main() {
	for i := 0; i < 100; i++ {
		resp, err := http.Get("http://127.0.0.1:8000/get")
		if err != nil {
			fmt.Println("Error sending GET request:", err)
			return
		}
		defer resp.Body.Close()

		body, err := ioutil.ReadAll(resp.Body)
		if err != nil {
			fmt.Println("Error reading response:", err)
			return
		}

		fmt.Println(i+1, string(body))
	}
}
