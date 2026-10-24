#Attached to the Agent Scene (.tscn)
#A copy of this script is instantiated each time the Agent scene is

extends Node3D

#Timestep variables
@export var sample_dt: float = 0.010
@export var loop: bool = false

#Body Camera (child node)
@onready var body_camera: Camera3D = $BodyCamera

#Trajectory values
var x_data: Array = []
var y_data: Array = []
var z_data: Array = []
var phi_data: Array = []
var theta_data: Array = []
var psi_data: Array = []
#Time
var _time: float = 0.0

func set_trajectory(x: Array, y: Array, z: Array, phi: Array, theta: Array, psi: Array):
	x_data = x
	y_data = y
	z_data = z
	phi_data = phi
	theta_data = theta
	psi_data = psi

func _apply(x: float, y: float, z: float, roll: float, pitch: float, yaw: float) -> void:
	# DCM: [0, 1, 0; 0, 0, -1; -1, 0, 0]
	position.x = y
	position.y = -z
	position.z = -x
	rotation.x = pitch
	rotation.y = -1 * yaw
	rotation.z = -1 * roll

func _process(delta: float) -> void:
	var count := x_data.size()
	if count == 0:
		return

	_time += delta
	var max_t := (count - 1) * sample_dt
	if loop and max_t > 0.0:
		_time = fmod(_time, max_t)
	else:
		_time = minf(_time, max_t)

	var t := _time / sample_dt
	var i0 := mini(int(t), count - 1)
	var i1 := mini(i0 + 1, count - 1)
	var alpha := t - float(i0)

	var x := lerpf(x_data[i0], x_data[i1], alpha)
	var y := lerpf(y_data[i0], y_data[i1], alpha)
	var z := lerpf(z_data[i0], z_data[i1], alpha)
	var roll := lerpf(phi_data[i0], phi_data[i1], alpha)
	var pitch := lerpf(theta_data[i0], theta_data[i1], alpha)
	var yaw := lerpf(psi_data[i0], psi_data[i1], alpha)
	_apply(x, y, z, roll, pitch, yaw)
	
