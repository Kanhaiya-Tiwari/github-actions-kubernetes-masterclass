# Stage 1: Build
FROM golang:1.23-alpine AS builder

WORKDIR /app

# Copy dependency files and download
COPY go.mod ./
RUN go mod tidy

# Copy the rest of the source code
COPY . .

# Build the application as a static binary
RUN CGO_ENABLED=0 GOOS=linux go build -o skillpulse .

# Stage 2: Run
FROM gcr.io/distroless/static-debian12:latest

WORKDIR /app

# Copy the binary from the builder stage
COPY --from=builder /app/skillpulse .

# Use a non-root user for security
USER nonroot:nonroot

EXPOSE 8080

CMD ["./skillpulse"]
