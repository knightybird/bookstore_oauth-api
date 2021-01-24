FROM golang:1.14.2-alpine3.11 AS builder

# Set necessary environment variables needed for our builder image
ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    GOOS=linux \
    GOARCH=amd64

# Move to working directory /build
WORKDIR /build

# Copy and download dependency using go mod
COPY go.mod .
COPY go.sum .
RUN go mod download

# Copy the code into the container
COPY ../../Users/Owl/Desktop/bookstore_oauth-api .

# Build the application
RUN go build -o main .

# Move to /dist directory as the place for resulting binary folder
WORKDIR /dist

# Copy binary from build to main folder
RUN cp /build/main .

# Build a small running image
FROM scratch

# Set necessary environment variables needed for our running image
ENV BOOKSTORE_OAUTH_DATASOURCE_URL='127.0.0.1' \
    BOOKSTORE_OAUTH_DATASOURCE_USERNAME='' \
    BOOKSTORE_OAUTH_DATASOURCE_PASSWORD='' \
    BOOKSTORE_OAUTH_DATASOURCE_KEYSPACE='oauth' \
    BOOKSTORE_OAUTH_ENVIRONMENT='dev'

COPY --from=builder /dist/main /

# Command to run
ENTRYPOINT ["./main"]
