extends Button

@export var change_to_scene : String;


func _ready() -> void:
	connect("button_down", call_scene_change)


func call_scene_change():
	SceneManager.FadeOUT()
	SceneManager.start_scene_change(change_to_scene)
