# ================================
# Build image
# ================================
FROM swift:6.0-jammy as build

# Install OS updates and dependencies
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get install -y libjemalloc-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# First copy only Package manifest and resolved file to cache dependencies
COPY ./Package.* ./
RUN swift package resolve

# Copy the rest of the backend source code
COPY . .

# Build release binary with optimizations
RUN swift build -c release --static-swift-stdlib

# Stage the binary
RUN mkdir -p /staging \
    && cp "$(swift build -c release --show-bin-path)/Run" /staging/Run

# ================================
# Run image
# ================================
FROM ubuntu:jammy

# Install runtime dependencies:
# - curl is required by EmailService to deliver SMTP emails to Gmail
# - ca-certificates for secure HTTPS & SMTPS connections
# - libjemalloc2 for memory management
RUN export DEBIAN_FRONTEND=noninteractive DEBCONF_NONINTERACTIVE_SEEN=true \
    && apt-get -q update \
    && apt-get install -y \
        ca-certificates \
        tzdata \
        curl \
        libjemalloc2 \
    && rm -r /var/lib/apt/lists/*

# Create a non-root vapor user
RUN useradd --user-group --create-home --system --skel /dev/null --home-dir /app vapor

WORKDIR /app

# Copy the compiled binary from build image
COPY --from=build --chown=vapor:vapor /staging/Run /app/Run

# Create Public folder
RUN mkdir -p /app/Public && chown -R vapor:vapor /app

USER vapor:vapor

EXPOSE 8080

ENTRYPOINT ["./Run"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0"]

