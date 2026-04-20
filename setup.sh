#!/bin/bash

# Update system and install basic network tools (curl)
apt-get update && apt-get install -y curl || true

# Install Node.js dependencies for your MCP servers
# These correspond to the npx commands in your .mcp.json
npm install -g @a-bonus/google-docs-mcp universal-bland-ai-mcp-server mcp-remote || true

# Print verification
echo "✅ Environment setup complete."
curl --version

