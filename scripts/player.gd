extends CharacterBody3D


const SPEED = 3.5
const SPRINT_SPEED = 5.0
const CROUCH_SPEED = 2.0

const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.01

var speed_modifier = SPEED

const BOB_FREQ = 2.0
const BOB_AMP = 0.06
var t_bob = 0.0

var BASE_FOV = 75
const FOV_CHANGE = 1.1
const DEFAULT_CAMERA_POS: Vector3 = Vector3(0.0, -0.05, -0.4)
var capture = true

var has_mask_on : bool = false;

var mask_settings  = ["sport", "politics", "pop_culture"]
var current_mask:String;

# transformations
const DEFAULT_TRANSFORMATION: Vector3 = Vector3(1, 1, 1)
const CROUCH_TRANSFORMATION: Vector3 = Vector3(1, 0.44, 1)

@onready var head: Node3D = $headPivot
@onready var camera: Camera3D = $headPivot/Camera3D

@onready var InteractArea: Area3D = $headPivot/interact_area

@onready var anim: AnimationPlayer = $AnimationPlayer

@onready var HUD :Node2D = $GameHUD


var current_enemy;

var has_enemy:bool;

var social_state : String = "idle"
# losing - occupied - idle


func _ready():
	GameState.Game_running = true;
	AudioManager.play_next_sound()
	GameState.reset_game_settings()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	camera.current = true
	
	InteractArea.connect("body_entered", on_body_entered)
	InteractArea.connect("body_exited", on_body_exited)


func on_body_entered(body:Node):
	if body.is_in_group("enemy"):
		print("enemy entered")
		has_enemy = true;
		current_enemy = body.get_parent()
		current_enemy.talking = true;
		HUD.interact_text()
		
		
func on_body_exited(body:Node):
	if body.is_in_group("enemy"):
		print("enemy exited")
		has_enemy = false

		if is_instance_valid(current_enemy):
			current_enemy.talking = false

		HUD.interact_text_off()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and capture:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(
			camera.rotation.x,
			deg_to_rad(-40),
			deg_to_rad(60)
		)

	if Input.is_action_just_pressed("escape"):
		capture = !capture
		Input.set_mouse_mode(
			Input.MOUSE_MODE_CAPTURED if capture else Input.MOUSE_MODE_VISIBLE
		)


func _physics_process(delta: float) -> void:
	
	if GameState.social_battery <= 0:
		
		GameState.Game_running = false;
		anim.play("faint")
		HUD.game_over_hud()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if GameState.likeability <=0:
		GameState.Game_running = false;
		global_position.x = 9.353
		global_position.z = 2.68
		
		anim.play("kicked_out")
		GameState.GameOverMessage = "Why did you bother coming if you
		weren't going to talk to anyone"
		HUD.game_over_hud()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	
	if GameState.Game_running:
		
		GameState.likeability -= delta
	
		GameState.playerState = social_state
		# Gravity
		if not is_on_floor():
			velocity += get_gravity() * delta


		if Input.is_action_just_pressed("interact"):
			if !HUD.is_locked():
				HUD.wave_interact_anim()
				if(has_enemy):
					anim.play("feedback")
					print("interacted")
					social_state = "occupied"
					GameState.despawn_people()
					
					if current_enemy.category == "recharge":
						GameState.social_battery += 20
						print("recharged")
						GameState.likeability += 10
					elif current_enemy.category == current_mask:
						print("wooo you matched")
						GameState.social_battery -= 10
						GameState.likeability += 10
					else:
						print("you did not match")
						GameState.social_battery -= 20
					
		if Input.is_action_just_pressed("select1"):
			if !HUD.is_locked():
				print("selected mask 1 (sports)")
				
				current_mask= mask_settings[0]
				HUD.switch_masks(current_mask)
				HUD.place_mask_anim()
			
		if Input.is_action_just_pressed("select2"):
			if !HUD.is_locked():
				print("selected mask 2 (politics)")
				current_mask= mask_settings[1]
				HUD.switch_masks(current_mask)
				HUD.place_mask_anim()
			
		if Input.is_action_just_pressed("select3"):
			if !HUD.is_locked():
				print("selected mask 3 (pop culture)")
				current_mask= mask_settings[2]
				HUD.switch_masks(current_mask)
				HUD.place_mask_anim()
			
		if Input.is_action_just_released("put_on"):
			pass
		

		# Movement
		var input_dir := Input.get_vector("left", "right", "up", "down")
		var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

		if is_on_floor():
			if direction:
				velocity.x = direction.x * speed_modifier
				velocity.z = direction.z * speed_modifier
			else:
				velocity.x = lerp(velocity.x, 0.0, delta * 10)
				velocity.z = lerp(velocity.z, 0.0, delta * 10)
		else:
			velocity.x = lerp(velocity.x, direction.x * speed_modifier, delta * 2)
			velocity.z = lerp(velocity.z, direction.z * speed_modifier, delta * 2)

		# Head bob (FIXED)
		if is_on_floor() and velocity.length() > 0.1:
			t_bob += delta * velocity.length()
			camera.transform.origin = _headbob(t_bob)
		else:
			t_bob = 0.0
			camera.transform.origin = camera.transform.origin.lerp(
				DEFAULT_CAMERA_POS,
				delta * 10
			)

		# Dynamic FOV
		var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 1.5)
		var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
		camera.fov = lerp(camera.fov, target_fov, delta * 8)

		move_and_slide()


func _headbob(time: float) -> Vector3:
	var pos = DEFAULT_CAMERA_POS
	pos.y += sin(time * BOB_FREQ) * BOB_AMP
	pos.x += cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
