FROM golang:1.23-alpine

WORKDIR /app

COPY go.mod .
COPY main.go .

RUN apk add --no-cache tzdata

RUN go mod tidy
RUN go build -o main .
EXPOSE 8080
CMD ["./main"]