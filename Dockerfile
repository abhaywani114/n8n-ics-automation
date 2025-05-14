# Dockerfile
FROM n8nio/n8n:latest

# Set build-time variable
ARG NPM_GLOBAL_PACKAGES

# Install global packages as root
USER root
RUN if [ -n "$NPM_GLOBAL_PACKAGES" ]; then npm install -g $NPM_GLOBAL_PACKAGES; fi

# Switch back to n8n user
USER node
