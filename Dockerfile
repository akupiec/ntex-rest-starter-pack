FROM rust:alpine as builder

RUN apk add alpine-sdk musl-dev build-base upx curl

WORKDIR /app

## Copy source code
COPY Cargo.toml Cargo.lock ./
COPY src ./src

## Build release binary
RUN cargo build --release
## Pack release binary with UPX (optional)
RUN upx --best --lzma /app/target/release/my-rest-api

FROM alpine

COPY --from=builder /app/target/release/my-rest-api /app

HEALTHCHECK --start-period=1s CMD wget --no-verbose --tries=1 --spider http://localhost:8080/health || exit 1
EXPOSE 8080/tcp

ENTRYPOINT ["/app"]
