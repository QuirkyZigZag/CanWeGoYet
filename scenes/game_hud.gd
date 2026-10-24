extends Node2D


var mask_texture_1 = preload("res://assets/art/2dart/pop_mask.png")
var mask_texture_2 = preload("res://assets/art/2dart/monocle_mask.png")
var mask_texture_3 = preload("res://assets/art/2dart/sport_mask.png")


var icon_texture_1 = preload("res://assets/art/2dart/sport_icon.png")
var icon_texture_2 = preload("res://assets/art/2dart/monocle_icon.png")
var icon_texture_3 = preload("res://assets/art/2dart/pop_icon.png")

var is_anim_locked := false

@onready var socialBatteryProgress : TextureProgressBar = $CanvasLayer/Control/socialbattery;

@onready var likeabilityProgress : TextureProgressBar = $CanvasLayer/Control/likeability;

@onready var playerHUDAnimation: AnimationPlayer = $AnimationPlayer

@onready var say_hi_label : Label = $"CanvasLayer/Control/sayhipivot/say hi";

@onready var mask : Sprite2D = $Mask

@onready var timer : Label = $CanvasLayer/Control/Time

var hour: int = 23  
var minute: int = 0

var time_speed: float = 3.0
  
var _accumulator: float = 0.0


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	say_hi_label.visible = false
	
	mask.modulate = Color(1,1,1,1)
	socialBatteryProgress.min_value = 0
	socialBatteryProgress.max_value = 100
	likeabilityProgress.min_value = 0;
	likeabilityProgress.max_value = 100;
	
	
	playerHUDAnimation.connect("animation_finished", go_to_default)
	

func switch_masks(p_mask:String):
	
	if (p_mask == "sport"):
		mask.texture = mask_texture_3
		$CanvasLayer/Control/battery_label/mask_indicator.texture = icon_texture_1
	elif (p_mask == "politics"):
		mask.texture = mask_texture_2
		$CanvasLayer/Control/battery_label/mask_indicator.texture = icon_texture_2
	elif ( p_mask == "pop_culture"):
		mask.texture = mask_texture_1
		$CanvasLayer/Control/battery_label/mask_indicator.texture = icon_texture_3
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if GameState.Game_running:
	
		socialBatteryProgress.value = GameState.social_battery
		likeabilityProgress.value = GameState.likeability
		
		_accumulator += delta
		while _accumulator >= time_speed:
			_accumulator -= time_speed
			_increment_time()
		_update_label()
	
func _increment_time() -> void:
	minute += 1
	if minute >= 60:
		minute = 0
		hour += 1
		if hour >= 24:
			hour = 0  # wrap around to 0:00
			print("woooo midnight we can go now")
			if GameState.social_battery>0 and GameState.likeability > 0:
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
				SceneManager.start_scene_change("res://scenes/levels/victory_screen.tscn")
				
			

func _update_label() -> void:
	# Display in 24-hour format HH:MM
	timer.text = str(hour).pad_zeros(2) + ":" + str(minute).pad_zeros(2)
	
func place_mask_anim():
	is_anim_locked= true;
	playerHUDAnimation.play("pop_mask_on")
	
func interact_text():
	say_hi_label.visible = true;
	
func interact_text_off():
	say_hi_label.visible = false;
	
func wave_interact_anim():
	is_anim_locked = true;
	playerHUDAnimation.play("interact_wave")

func go_to_default(anim_name:String = ""):
	is_anim_locked = false
	playerHUDAnimation.play("RESET")
	
func game_over_hud():
	$CanvasLayer/Control/GameOverScreen/GameOverMessage.text = GameState.GameOverMessage
	$CanvasLayer/Control/GameOverScreen.visible = true
	
	var timer = Timer.new()
	timer.wait_time = 3.0
	timer.one_shot = true
	add_child(timer)
	timer.start()
	
	timer.connect("timeout", _on_game_over_timeout)


func _on_game_over_timeout():
	SceneManager.start_scene_change("res://scenes/levels/main_menu.tscn")
	
func is_locked()->bool:
	if is_anim_locked:
		return true
	else:
		return false
