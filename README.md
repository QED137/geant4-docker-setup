# Geant4 Docker Setup 🔬

> Easy, one-click Geant4 setup using Docker with working GUI visualization on Linux.
> No painful local installation. No dependency hell. Just works.

![Geant4](https://img.shields.io/badge/Geant4-11.3.2-blue)
![Docker](https://img.shields.io/badge/Docker-required-blue)
![Platform](https://img.shields.io/badge/Platform-Ubuntu%20Linux-orange)
![License](https://img.shields.io/badge/License-MIT-green)

---

## Why This Exists

Installing Geant4 locally is painful:

```
Without this repo:                  With this repo:
──────────────────                  ────────────────
Install CMake manually              git clone ...
Install Qt5 manually                ./setup.sh
Install all dependencies            ./start-gui.sh
Compile Geant4 (~1 hour)           ✅ Done. Geant4 running with GUI
Fix errors...
Fix more errors...
GUI still not working...
```

This repo was built from real experience troubleshooting Geant4 + Docker + GUI on Ubuntu Linux. Everything is pre-configured and working.

---

## Requirements

- Ubuntu Linux (tested on 22.04)
- Docker installed
- ~5GB free disk space
- Internet connection (first time only)

---

## Quick Start

```bash
# 1. Clone this repo
git clone https://github.com/YOUR_USERNAME/geant4-docker-setup
cd geant4-docker-setup

# 2. Run setup (downloads everything, takes ~10-20 minutes)
./setup.sh

# 3. Start Geant4 with GUI
./start-gui.sh
```

That's it. You are inside a fully working Geant4 environment.

---

## What setup.sh Does

```
1. Checks Docker is installed       (installs if missing)
2. Creates required folders         (geant4-datasets/, workdir/)
3. Creates .env from template       (.env.example → .env)
4. Pulls Docker images              (carlomt/geant4:latest-gui)
5. Downloads Geant4 datasets        (~2GB, saved permanently)
6. Enables X11 display forwarding   (for GUI)
```

---

## Running the B1 Example

After `./start-gui.sh` you are inside the container. Run:

```bash
# Copy B1 example to your workspace
cp -r $G4EXAMPLES/basic/B1 ~/B1

# Build it
cd ~/B1
mkdir build && cd build
cmake ..
make -j$(nproc)

# Run it
./exampleB1
```

A Qt window will open. In the **Session:** box at the bottom type:

```
/run/beamOn 10
```

You will see **particle tracks flying through the detector**. 🎉

---

## Daily Workflow

```
Every day:

TERMINAL 1                          TERMINAL 2
──────────                          ──────────
cd geant4-docker-setup              code workdir/MyProject/
./start-gui.sh                        │
                                      │ edit .cc files
cd ~/MyProject/build                  │ save
make -j$(nproc)  ◄───────────────────┘
./MyProject
  → Qt window opens
  → /run/beamOn 10
```

- **Write code** → on your HOST machine with VSCode or any editor
- **Build & Run** → inside the container
- **Files** → always safe in `workdir/` on your machine

---

## Creating Your Own Project

```bash
# On HOST machine — copy B1 as starting point
cp -r workdir/B1 workdir/MyProject

# Rename main file
cd workdir/MyProject
mv exampleB1.cc main.cc

# Edit CMakeLists.txt:
# Change: project(B1)            → project(MyProject)
# Change: add_executable(exampleB1 ...) → add_executable(MyProject main.cc ...)

# Build inside container
cd ~/MyProject
mkdir build && cd build
cmake ..
make -j$(nproc)
./MyProject
```

---

## Project Structure

```
geant4-docker-setup/
├── README.md                 ← you are here
├── docker-compose.yml        ← container configuration
├── .env.example              ← environment template
├── setup.sh                  ← one-click installer
├── start-gui.sh              ← launch with GUI visualization
├── start-batch.sh            ← launch without GUI (faster)
├── geant4-datasets/          ← datasets live here (created by setup)
└── workdir/                  ← YOUR projects live here
    └── (your projects)
```

---

## Useful Geant4 Visualization Commands

Type these in the **Session:** box in the Qt window:

| Command | What it does |
|---|---|
| `/run/beamOn 10` | Shoot 10 particles |
| `/run/beamOn 100` | Shoot 100 particles |
| `/vis/viewer/refresh` | Refresh the view |
| `/vis/enable` | Enable visualization |
| `/vis/viewer/flush` | Update/flush view |
| `/vis/drawVolume` | Draw detector geometry |
| `/vis/viewer/set/viewpointThetaPhi 120 150` | Change viewing angle |
| `/vis/viewer/zoom 1.5` | Zoom in |

---

## cmake vs make

| Situation | Command |
|---|---|
| First time building | `cmake .. && make -j$(nproc)` |
| Edited existing .cc or .hh file | `make -j$(nproc)` |
| Added a new .cc file | `cmake .. && make -j$(nproc)` |
| Changed CMakeLists.txt | `cmake .. && make -j$(nproc)` |

---

## How Docker Works Here

```
Docker Image  = Geant4 pre-installed (~3GB, downloaded once)
Container     = temporary environment, deleted when you exit
workdir/      = YOUR files, permanent, lives on YOUR machine

Image is shared by ALL your projects.
5 projects = image (~3GB) + your code (~few MB each)
NOT 5 × 3GB!
```

---

## Troubleshooting

| Problem | Fix |
|---|---|
| Black Qt window | Already fixed: `G4VIS_DEFAULT_DRIVER=TSG_QT_ZB` in `.env` |
| `Cannot connect to X server` | Run `xhost local:root` before starting |
| `Permission denied` when deleting files | Use `sudo rm -rf` on HOST |
| Datasets not found | Run `docker compose run --rm prepare` |
| Container has no internet | Download datasets on HOST: `docker compose run --rm prepare` |
| Qt window empty after run | Type `/vis/enable` then `/vis/viewer/flush` in Session box |
| `echo $G4EXAMPLES` is empty | Use `find /opt -name "B1" -type d` to locate examples |

---

## Key Configuration — Why TSG_QT_ZB?

The standard OpenGL driver (`OGL`) requires direct GPU access which Docker cannot provide by default. After testing all available drivers:

```
OGL (OpenGL Qt)      → black screen ❌
OGLSX (OpenGL X11)   → black screen ❌
TSG_X11_ZB           → works but limited ⚠️
TSG_QT_ZB            → works perfectly ✅ ← we use this
```

`TSG_QT_ZB` uses software rendering (CPU-based) which works reliably inside Docker containers without GPU passthrough.

---

## Environment Variables Explained

```bash
# .env file
DOCKERDISPLAY=:0          # which screen to use for GUI
X11FOLDER=/tmp/.X11-unix  # X11 socket location
DOCKERHOME=./workdir      # your files location
G4VIS_DEFAULT_DRIVER=TSG_QT_ZB  # visualization driver that works
```

```yaml
# docker-compose.yml environment
LIBGL_ALWAYS_SOFTWARE=1   # use CPU for OpenGL (fixes black screen)
QT_X11_NO_MITSHM=1        # fix Qt shared memory issues
QT_QPA_PLATFORM=xcb       # force X11 mode on Wayland systems
```

---

## Multiple Projects

```
workdir/
├── B1/                ← reference example (keep untouched)
├── MyDetector/        ← your project 1
├── ShieldingStudy/    ← your project 2
├── Calorimeter/       ← your project 3
└── NeutronStudy/      ← your project 4
```

All projects share the **same Docker image**. No extra disk space per project.

---

## Batch Mode (No GUI)

For running large simulations without visualization:

```bash
# Start batch container (faster, no GUI overhead)
./start-batch.sh

# Run with a macro file
cd ~/MyProject/build
./MyProject run.mac
```

---

## Tested On

| OS | Docker Version | Geant4 Version | GUI |
|---|---|---|---|
| Ubuntu 22.04 | 24.x | 11.3.2 | ✅ TSG_QT_ZB |

---

## Contributing

Found a bug or have an improvement? PRs welcome!

1. Fork the repo
2. Create your branch: `git checkout -b fix/my-fix`
3. Commit: `git commit -m "Fix: description"`
4. Push: `git push origin fix/my-fix`
5. Open a Pull Request

---

## Credits

- [Geant4 Collaboration](https://geant4.org) for the simulation toolkit
- [carlomt](https://hub.docker.com/r/carlomt/geant4) for the Docker images
- Built from real troubleshooting experience at University of Tübingen

---

## License

MIT — free to use, modify and share.

---

*If this saved you time, give it a ⭐ on GitHub!*
