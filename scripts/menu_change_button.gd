extends Button

@export var load_menu: Node;
@export var menu_on: bool = true;


func _ready() -> void:
	
	connect("button_down", change_menu)
	
func change_menu():
	print("pressed")
	if menu_on:

		load_menu.visible = true
		GameState.Game_running = false;

	else:
		print("back")
		load_menu.visible = false
		GameState.Game_running = true;
