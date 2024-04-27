FROM golang:alpine AS builder
WORKDIR /build
COPY . .
RUN go build -o "api" ./cmd/api

FROM alpine
ENV PUBLIC_OBJECT_STORAGE_URL=${PUBLIC_OBJECT_STORAGE_URL}
WORKDIR /build
COPY --from=builder "/build/api" "api"
CMD ["./api"]
EXPOSE 8081

