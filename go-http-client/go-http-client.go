package main

import (
	"fmt"
	"io/ioutil"
	"net"
	"net/http"
	"time"
)

func main() {
	dialer := &net.Dialer{
		Timeout:   30 * time.Second,
		KeepAlive: 30 * time.Second,
	}
	transport := &http.Transport{
		DialContext: dialer.DialContext,
	}
	client := &http.Client{
		Transport: transport,
	}

	for i := 0; i < 1000; i++ {
		req, err := http.NewRequest(http.MethodGet, "http://127.0.0.1:8000/get", nil)
		if err != nil {
			fmt.Println("Error creating GET request:", err)
			return
		}

		req.Header.Add("Connection", "keep-alive")

		resp, err := client.Do(req)
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
