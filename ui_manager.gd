extends CanvasLayer

# Agent instances
var agents: Array[Node3D] = []
# Selected Agent
var current_camera: int = 0
# Labels
var labels: Array[Label] = []
var labels_container: VBoxContainer
var _x: float = -12
var _pitch_scale: float = 3.933
var _pitch_max: float = 118.0

func set_agents(instances: Array[Node3D]) -> void:
	agents = instances

func set_camera(index: int) -> void:
	current_camera = index

func _ready() -> void:
	$HUD.visible = true
	get_viewport().size_changed.connect(_position_hud)
	_position_hud()
	_reset_hud()
	_set_prompt()

func _position_hud() -> void:
	var viewport_size := get_viewport().get_visible_rect().size
	$HUD.position = Vector2(viewport_size.x/1.125, viewport_size.y/1.30)
	$HUD.scale = Vector2(0.4, 0.4)
	
func _reset_hud() -> void:
	$HUD/posN.text = str(000)
	$HUD/posE.text = str(000)
	$HUD/posD.text = str(000)
	$HUD/HDG.text = str(000)
	$HUD/needle.rotation = 0
	$HUD/reticle.position = Vector2(_x,_x)

func _set_prompt() -> void:
	$Prompt.visible = true
	$Prompt.text = "Press 1 To Switch Cameras"
	$Prompt.add_theme_color_override("font_outline_color", Color.BLACK)
	#Set prompt in the middle top of the screen
	$Prompt.position = Vector2(get_viewport().size.x/2.5, 10)

func _process(_delta: float) -> void:
	if agents.is_empty():
		return
	var agent_i: Node3D = agents[current_camera]
	$HUD/posN.text = str(round(-agent_i.position.z))
	$HUD/posE.text = str(round(agent_i.position.x))
	$HUD/posD.text = str(round(agent_i.position.y))
	$HUD/HDG.text = str(round(-agent_i.rotation.y * 180 / PI))
	$HUD/needle.rotation = -agent_i.rotation.y
	var pitch: float = agent_i.rotation.x * (180 / PI)
	var pitch_offset: float = pitch * _pitch_scale
	pitch_offset = clamp(pitch_offset, -_pitch_max, _pitch_max)
	$HUD/reticle.position = Vector2(_x, _x - pitch_offset)
