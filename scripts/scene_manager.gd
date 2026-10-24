extends Node2D


@onready var SceneAnimationPlayer = $SceneAnimationPlayer

var scene_to_load : String;

func _ready() -> void:
	SceneAnimationPlayer.connect("animation_finished", load_to_scene)



func load_to_scene(animation:StringName) ->void:
	if animation == "fading_out":
		get_tree().change_scene_to_file(scene_to_load);
		SceneAnimationPlayer.play("fading_in")

func start_scene_change(change_to_scene : String)->void:
	SceneAnimationPlayer.play("fading_out")
	scene_to_load = change_to_scene;


func FadeOUT():
	SceneAnimationPlayer.play("fading_out")
