extends Node3D

@onready var person_scene: PackedScene = preload("res://scenes/person.tscn")
@export var player: CharacterBody3D  # Optional
@export var max_people: int = 5
@export var min_spawn_interval: float = 1.0
@export var max_spawn_interval: float = 3.0

var spawn_timer: Timer

func _ready():
	# Create the spawn timer
	spawn_timer = Timer.new()
	spawn_timer.one_shot = false
	spawn_timer.wait_time = randf_range(min_spawn_interval, max_spawn_interval)
	spawn_timer.connect("timeout", _spawn_person)
	add_child(spawn_timer)
	spawn_timer.start()

func _spawn_person() -> void:
	
	if GameState.people >= max_people or GameState.Game_running == false:
		return  # Don't exceed max

	# Instance the person
	
	
	var person: AnimatedSprite3D = person_scene.instantiate()

	# Add to root scene to avoid inheriting spawner scale/transform
	get_tree().current_scene.add_child(person)

	# Set independent global transform WITHOUT touching scale
	var spawn_position = global_position + Vector3(0, 0, 2)  # Slightly in front
	var spawn_transform = person.global_transform  # Keep original rotation & scale
	spawn_transform.origin = spawn_position
	person.global_transform = spawn_transform

	# Optional: face the player
	if player:
		person.look_at(player.global_transform.origin, Vector3.UP)


	# Randomize next spawn interval
	spawn_timer.wait_time = randf_range(min_spawn_interval, max_spawn_interval)
