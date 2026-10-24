extends AnimatedSprite3D

# Textures for different categories
var icon_texture_1 = preload("res://assets/art/2dart/sport_icon.png")
var icon_texture_2 = preload("res://assets/art/2dart/monocle_icon.png")
var icon_texture_3 = preload("res://assets/art/2dart/pop_icon.png")
var icon_texture_4 = preload("res://assets/art/2dart/smiley.png")

@onready var icon: Sprite3D = $icon
@onready var agent: NavigationAgent3D = $NavigationAgent3D
@onready var animplayer: AnimationPlayer = $AnimationPlayer

@export var stop_distance: float = 1.0

@export var category: String = ""
@export var max_speed: float = 0.5
@export var walk_away_speed: float = 0.6

var talking: bool = false;



var categories = ["sport", "politics", "pop_culture", "recharge"]
var player: Node3D = null

var last_move_direction: Vector3 = Vector3.ZERO
var walking_away: bool = false

func _ready() -> void:
	GameState.people +=1;
	randomize()
	connect("animation_finished", cease)

	# Assign random category and icon
	category = categories[randi_range(0, categories.size() - 1)]
	match category:
		"sport": icon.texture = icon_texture_1
		"politics": icon.texture = icon_texture_2
		"pop_culture": icon.texture = icon_texture_3
		"recharge" : icon.texture = icon_texture_4

	# Find player
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
		agent.target_position = player.global_transform.origin

	add_to_group("enemy")

func _process(delta: float) -> void:
	if not GameState.Game_running:
		return

	GameState.likeability -= delta * 0.1

	# WALKING AWAY STATE
	if walking_away:
		if animation != "walk away":
			play("walk away")
		global_translate(last_move_direction * walk_away_speed * delta)
		return

	if not player:
		return

	var distance_to_player = global_transform.origin.distance_to(player.global_transform.origin)

	# NEAR PLAYER (IDLE)
	if distance_to_player <= 1.5:
		if animation != "default":
			play("default")
		return

	# WALKING TOWARDS PLAYER
	if animation != "walk_towards":
		play("walk_towards")

	agent.target_position = player.global_transform.origin

	var next_pos = agent.get_next_path_position()
	var direction = next_pos - global_transform.origin
	var distance = direction.length()
	if distance < 0.01:
		return

	direction = direction.normalized()
	last_move_direction = direction

	var move_amount = min(distance, max_speed * delta)
	global_translate(direction * move_amount)


func despawn() -> void:
	if last_move_direction == Vector3.ZERO:
		return

	if talking:
		
		AudioManager.play_voice_line()
		animplayer.play("interacted_with")
		await get_tree().create_timer(3.0).timeout

	walking_away = true
	last_move_direction = -last_move_direction.normalized()
	play("walk away")

func cease() -> void:
	GameState.people -= 1;
	queue_free()
