package main

import (
	"fmt"
	"io"
	"math/rand"
	"net/http"
	"os"
)

func getRandomString() string {
	var letters = []rune("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
	b := make([]rune, 14)
	for i := range b {
		b[i] = letters[rand.Intn(len(letters))]
	}
	return string(b)
}

func UploadHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != http.MethodPost {
		http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
		return
	}

	file, handler, err := r.FormFile("image")
	if err != nil {
		http.Error(w, "File not found", http.StatusBadRequest)
		return
	}

	defer file.Close()
	maxSize := int64(5 * 1024 * 1024)
	r.Body = http.MaxBytesReader(w, r.Body, maxSize)

	if err := r.ParseMultipartForm(maxSize); err != nil {
		http.Error(w, "File too large", http.StatusBadRequest)
		return
	}

	fileName := handler.Filename
	if fileName == "" {
		http.Error(w, "File name not found", http.StatusBadRequest)
		return
	}

	fileType := handler.Header.Get("Content-Type")
	fileExt := ""
	switch fileType {
	case "image/jpeg", "image/jpg":
		fileExt = ".jpg"
	case "image/png":
		fileExt = ".png"
	case "image/gif":
		fileExt = ".gif"
	default:
		http.Error(w, "Invalid file type. Only JPEG, PNG and GIF are allowed", http.StatusBadRequest)
		return
	}

	fmt.Println("File name:", fileName, "File type:", fileType)
	randomString := getRandomString()
	dst, err := os.Create("/var/www/images/" + randomString + fileExt)
	if err != nil {
		fmt.Println(err)
		http.Error(w, "Failed to create file", http.StatusInternalServerError)
		return
	}
	defer dst.Close()

	if _, err := io.Copy(dst, file); err != nil {
		http.Error(w, "Failed to save file", http.StatusInternalServerError)
		return
	}

	serverURL := "http://" + r.Host + "/images/" + randomString + fileExt
	fmt.Fprintf(w, `{"url": "%s"}`, serverURL)
}

func main() {
	fmt.Println("Server is running on port 3000")
	http.HandleFunc("/upload", UploadHandler)
	http.ListenAndServe(":3000", nil)
}
