#CREDITS------------------------------------
#Download UAV model: https://sketchfab.com/3d-models/chaklun-fixed-wing-uav-e53bf464e35b4cdba60d5d0af02f0fd9
#Download Missile model: https://sketchfab.com/3d-models/aim-9-missile-caaf15b49bac4144b6c6be577c2b872a
#---------------------------------------------

#Begin----------------------------------------------------------------------------------------------

extends Node3D

#UAV Scene instance
var uav_scene: PackedScene = preload("res://uav.tscn")
var missile_scene: PackedScene = preload("res://missile.tscn")
#All trajectory files
@export var trajectoryFiles: Array
#Number of trajectory files = Number of agents (agents)
@export var numAgents: int = 0
#Array of Agent instances
var agent_instances: Array[Node3D] = []
#Active Agent camera (null initialized)
var active_camera_index: int = 0

# Get the path to the compiled executable.
var exe_path: String = OS.get_executable_path()
# Get the directory containing the executable.
var exe_dir: String = exe_path.get_base_dir()
# Empty trajectories folder beside the executable
var trajectories_dir: String = ""
var trajectories_path: String = ""

#Ready to go
func _ready() -> void:
	print("[main] _ready start")
	scan_files()
	print("[main] scan_files done: numAgents=", numAgents, " files=", trajectoryFiles)
	spawn_agents()
	print("[main] spawn_agents done: instances=", agent_instances.size())
	process_trajectories()
	print("[main] process_trajectories done")
	setup_labels()
	print("[main] setup_labels done")
	initialize_camera()
	print("[main] initialize_camera done: active_camera_index=", active_camera_index)

#Load trajectory filenames
func scan_files() -> Array:
	#Clear trajectoryFiles and numAgents
	trajectoryFiles.clear()
	numAgents = 0

	# Locate the external "trajectories" folder.
	if OS.has_feature("editor"):
		# Running from the Godot editor.
		trajectories_dir = "res://trajectories"
	else:
		# Running as an exported application.
		trajectories_dir = exe_dir.path_join("trajectories")

	# Globalize the path to ensure it is absolute.
	trajectories_path = ProjectSettings.globalize_path(trajectories_dir) if trajectories_dir.begins_with("res://") else trajectories_dir

	#Check if folder exists, if not, exit
	if not DirAccess.dir_exists_absolute(trajectories_path):
		push_error("Missing folder `trajectories` beside the executable...exiting now")
		get_tree().quit()
		return []
	var files := DirAccess.get_files_at(trajectories_path)
	#file_name <String>
	for file_name in files:
		if file_name.get_extension().to_lower() == "csv":
			if "uav" in file_name.to_lower() or "missile" in file_name.to_lower():
				trajectoryFiles.append(file_name.to_lower())
			else:
				push_warning("Unknown agent, .csv file name must contain `uav` or `missile`: %s" % file_name)	

	#How many agents to spawn
	numAgents = len(trajectoryFiles)
	if numAgents == 0:
		push_error("Either none or no valid .csv files found in root://trajectories...exiting now:")
		get_tree().quit()
		return []
	return trajectoryFiles

#Spawn agents
func spawn_agents() -> void:
	for i in range (numAgents):
		var _file: String = trajectoryFiles[i]
		#If "uav" in trajectory file name, spawn UAV, else spawn missile
		var _agent: Node3D
		if "uav" in _file:
			_agent = uav_scene.instantiate()
		elif "missile" in _file:
			_agent = missile_scene.instantiate()
		#Add agent to main scene and array
		add_child(_agent)
		agent_instances.append(_agent)

#Process Trajectories
func process_trajectories() -> void:
	#Scan each trajectoryFiles and load agent trajectory in sequence
	for i in range(trajectoryFiles.size()):
		var path := trajectories_path.path_join(trajectoryFiles[i])
		var file := FileAccess.open(path, FileAccess.READ)
		if file == null:
			push_error("Failed to open trajectory file: %s" % path)
			continue

		var x: Array = []
		var y: Array = []
		var z: Array = []
		var phi: Array = []
		var theta: Array = []
		var psi: Array = []
		var line_number: int = 0

		while not file.eof_reached():
			var line := file.get_line().strip_edges()
			line_number += 1
			if line.is_empty():
				push_warning("Empty line in trajectory file: %s, skipping line %d" % [path, line_number])
				continue
			var cols := line.split(",")
			if cols.size() < 6:
				push_warning("Need 6 columns in trajectory file: %s, skipping line %d: %s" % [path, line_number, line])
				continue
			x.append(cols[0].to_float())
			y.append(cols[1].to_float())
			z.append(cols[2].to_float())
			phi.append(cols[3].to_float())
			theta.append(cols[4].to_float())
			psi.append(cols[5].to_float())

		if i < agent_instances.size():
			agent_instances[i].set_trajectory(x, y, z, phi, theta, psi)

#Process camera input events (Key #1)
func _unhandled_key_input(event: InputEvent):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_1 and not agent_instances.is_empty():
			active_camera_index = (active_camera_index + 1) % agent_instances.size()
			#Switch camera
			for i in range(agent_instances.size()):
				agent_instances[i].body_camera.current = (i == active_camera_index)
				$GUI.set_camera(active_camera_index)

#Send Agent instances to ui_manager
func setup_labels() -> void:
	$GUI.set_agents(agent_instances)

#Initialize camera
func initialize_camera() -> void:
	if len(agent_instances) > 0:
		agent_instances[0].body_camera.current = 1
