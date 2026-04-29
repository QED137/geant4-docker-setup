#!/bin/bash
# ============================================
# Geant4 Docker Setup Script
# Tested on Ubuntu Linux 22.04
# ============================================

echo ""
echo "╔══════════════════════════════════════╗"
echo "║     Geant4 Docker Setup Script       ║"
echo "╚══════════════════════════════════════╝"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "⚠ Docker not found. Installing Docker..."
    sudo apt update
    sudo apt install -y docker.io
    sudo systemctl enable --now docker
    sudo usermod -aG docker $USER
    echo ""
    echo "✅ Docker installed!"
    echo "⚠ Please log out and back in, then run this script again."
    exit 1
else
    echo "✅ Docker found: $(docker --version)"
fi

# Check docker compose
if ! docker compose version &> /dev/null; then
    echo "⚠ Docker Compose plugin not found. Installing..."
    sudo apt install -y docker-compose-plugin
else
    echo "✅ Docker Compose found: $(docker compose version)"
fi

# Create required folders
echo ""
echo "→ Creating folders..."
mkdir -p geant4-datasets
mkdir -p workdir
echo "✅ Folders created: geant4-datasets/ workdir/"

# Copy .env from example if not exists
if [ ! -f .env ]; then
    cp .env.example .env
    echo "✅ Created .env from template"
else
    echo "✅ .env already exists"
fi

# Enable X11 forwarding
echo ""
echo "→ Enabling X11 display forwarding..."
xhost local:root
echo "✅ X11 enabled"

# Pull Docker images
echo ""
echo "→ Pulling Geant4 Docker images (this may take a few minutes)..."
docker pull carlomt/geant4:latest
docker pull carlomt/geant4:latest-gui
echo "✅ Images pulled"

# Download Geant4 datasets
echo ""
echo "→ Downloading Geant4 datasets (~2GB, this will take a while)..."
echo "  Go grab a coffee ☕"
echo ""
docker compose run --rm prepare
echo ""
echo "✅ Datasets downloaded"

# Done!
echo ""
echo "╔══════════════════════════════════════╗"
echo "║         Setup Complete! 🎉           ║"
echo "╚══════════════════════════════════════╝"
echo ""
echo "To start Geant4 with GUI visualization:"
echo "  ./start-gui.sh"
echo ""
echo "To start Geant4 in batch mode (no GUI):"
echo "  ./start-batch.sh"
echo ""
