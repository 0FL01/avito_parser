# Build stage
FROM debian:12-slim as builder

# Install build dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    python3.11 \
    python3-pip \
    python3-venv \
    curl \
    gnupg \
    && rm -rf /var/lib/apt/lists/*

# Create app directory and virtual environment
WORKDIR /app
RUN python3 -m venv /app/venv

# Install Python dependencies
COPY requirements.txt .
RUN /app/venv/bin/pip install --no-cache-dir -r requirements.txt

# Runtime stage
FROM debian:12-slim

# Install runtime dependencies with cleanup including curl and Python
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        python3.11 \
        curl \
        libnss3 \
        libgconf-2-4 \
        libfontconfig1 \
        libx11-xcb1 \
        libxcomposite1 \
        libxcursor1 \
        libxdamage1 \
        libxfixes3 \
        libxkbcommon-x11-0 \
        libxrandr2 \
        libasound2 \
        libatk1.0-0 \
        libcairo2 \
        libcups2 \
        libdbus-1-3 \
        libexpat1 \
        libgbm1 \
        libgcc1 \
        libglib2.0-0 \
        libgtk-3-0 \
        libpango-1.0-0 \
        libpangocairo-1.0-0 \
        libx11-6 \
        libxext6 \
        libxss1 \
        fonts-liberation \
        xdg-utils \
        lsb-release \
        ca-certificates \
        libvulkan1 \
    && ln -s /usr/bin/python3.11 /usr/bin/python3 \
    && rm -rf /var/lib/apt/lists/*

# Install Chrome with cleanup
RUN curl -sSL https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o /tmp/chrome.deb && \
    apt-get update && \
    apt-get install -y --no-install-recommends /tmp/chrome.deb && \
    rm -rf /var/lib/apt/lists/* /tmp/chrome.deb

# Set up working directory
WORKDIR /app

# Copy virtual environment from builder
COPY --from=builder /app/venv /app/venv

# Copy application files
COPY db_service.py \
     custom_exception.py \
     lang.py \
     AvitoParser.py \
     locator.py \
     parser_cls.py \
     xlsx_service.py \
     user_agent_pc.txt \
     settings.ini \
     ./

# Set the virtual environment as part of PATH, including system paths
ENV PATH="/app/venv/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

# Run the parser using the full path to virtual environment's Python
CMD ["/app/venv/bin/python3", "parser_cls.py"]
