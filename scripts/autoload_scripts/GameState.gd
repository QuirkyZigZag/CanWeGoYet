extends Node



var Game_running : bool = false;
var is_Game_over: bool = false;

var social_battery: float =100;

var likeability: float = 100;
var people:int= 0;

var playerState:String = "idle";


var GameOverMessage : String = "Really? You couldn't make it until midnight? 
Lame."


# or "You didn't talk to anyone? No wonder you got kicked out."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	#print(social_battery)
	if Game_running:
		social_battery -= delta*0.3;
		
	


func despawn_people() -> void:
	print("despawning")

	for enemy in get_tree().get_nodes_in_group("enemy"):
		if not is_instance_valid(enemy):
			continue

		# Only despawn AnimatedSprite3D enemies
		if enemy is AnimatedSprite3D:
			if enemy.has_method("despawn"):
				enemy.despawn()
			
func reset_game_settings():
	people = 0;
	social_battery = 100;
	likeability = 100;
	playerState = "idle";
	GameOverMessage = "Really? You couldn't make it until midnight? 
Lame.";
