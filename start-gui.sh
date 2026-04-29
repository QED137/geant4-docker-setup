#!/bin/bash
# Start Geant4 with GUI visualization
xhost local:root
docker compose run --rm geant4-gui
