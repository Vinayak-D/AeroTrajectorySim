# AeroTrajectorySim

A simple 3D aerospace trajectory simulator built in Godot 4.7. The project loads trajectory data from CSV files, spawns UAV and missile agents, and visualizes their motion in a 3D scene with a basic HUD and camera switching.

## Download
Please download the project [here](https://vdengineering.itch.io/aerospace-flight-trajectory-simulator).
Video [here](https://youtu.be/XaGb6fs_dxQ)

## Features
- Reads trajectory CSV files and interpolates position/orientation over time
- Automatically spawns UAV and missile objects based on file names
- Displays live position and heading information in a HUD
- Lets you switch between active agent cameras using the `1` key

## Project structure
- `main.gd` — scans the `trajectories` folder, loads trajectory data, and manages agent/camera setup
- `agent.gd` — applies trajectory interpolation to each spawned agent
- `ui_manager.gd` — updates the in-game HUD and prompt text
- `trajectories/` — place your CSV trajectory files here (files should include `uav` or `missile` in the name)

## How to run
1. Open the project in Godot 4.7 or later.
2. Add trajectory CSV files to the `trajectories` folder.
3. Press Play in the Godot editor or export the project and run the built binary.
4. Press `1` to switch between the active cameras.




