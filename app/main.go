package main

import (
    "encoding/json"
    "fmt"
    "html/template"
    "log"
    "net/http"
    "os"
    "time"
)

type PageData struct {
    Title           string
    Time            string
    Hostname        string
    BackgroundColor string
    APIKey          string
}

type TimeResponse struct {
    KyivTime string `json:"kyiv_time"`
    UTCTime  string `json:"utc_time"`
    Hostname string `json:"hostname"`
}

func apiHandler(w http.ResponseWriter, r *http.Request) {
    kyivLocation, err := time.LoadLocation("Europe/Kiev")
    if err != nil {
        log.Printf("Error loading Kyiv timezone: %v", err)
        kyivLocation = time.UTC
    }

    hostname, _ := os.Hostname()
    now := time.Now()
    
    response := TimeResponse{
        KyivTime: now.In(kyivLocation).Format("2006-01-02 15:04:05 MST"),
        UTCTime:  now.UTC().Format("2006-01-02 15:04:05 MST"),
        Hostname: hostname,
    }

    w.Header().Set("Content-Type", "application/json")
    json.NewEncoder(w).Encode(response)
}

const htmlTemplate = `
<!DOCTYPE html>
<html>
<head>
    <title>{{.Title}}</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background: {{.BackgroundColor}} !important;
            min-height: 100vh;
        }
        .container {
            background-color: rgba(255, 255, 255, 0.9);
            padding: 40px;
            border-radius: 10px;
            box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
        }
        h1 {
            color: #2c3e50;
            margin-bottom: 20px;
        }
        .info {
            color: #666;
            line-height: 1.6;
        }
        .time {
            font-family: monospace;
            background-color: #f8f9fa;
            padding: 10px;
            border-radius: 4px;
            margin: 10px 0;
        }
        .secret {
            background-color: #ffe6e6;
            padding: 10px;
            border-radius: 4px;
            margin: 10px 0;
            border: 1px dashed #ff9999;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>{{.Title}}</h1>
        <div class="info">
            <p>Welcome to this Docker container running in Azure!</p>
            <p>Container Hostname: <strong>{{.Hostname}}</strong></p>
            <p class="time">Server Time: {{.Time}}</p>
            <p class="secret">API Key: {{.APIKey}}</p>
        </div>
    </div>
</body>
</html>`

func main() {
    port := os.Getenv("PORT")
    if port == "" {
        port = "8080"
    }

    title := os.Getenv("APP_TITLE")
    if title == "" {
        title = "Azure Container Demo"
    }
    
    bgColor := os.Getenv("BG_COLOR")
    if bgColor == "" {
        bgColor = "linear-gradient(135deg,rgb(58, 90, 138) 0%,rgb(127, 35, 127) 100%)"
    }

    apiKey := os.Getenv("API_KEY")
    if apiKey == "" {
        apiKey = "No API Key Found"
    }

    tmpl := template.Must(template.New("page").Parse(htmlTemplate))

    http.HandleFunc("/api/time", apiHandler)
    http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
        hostname, _ := os.Hostname()
        data := PageData{
            Title:           title,
            Time:            time.Now().Format(time.RFC1123),
            Hostname:        hostname,
            BackgroundColor: bgColor,
            APIKey:          apiKey,
        }

        w.Header().Set("Content-Type", "text/html; charset=utf-8")
        if err := tmpl.Execute(w, data); err != nil {
            log.Printf("Error executing template: %v", err)
            fmt.Fprintf(w, "Error generating page")
            return
        }
    })

    log.Printf("Server starting on port %s", port)
    log.Fatal(http.ListenAndServe(":"+port, nil))
}