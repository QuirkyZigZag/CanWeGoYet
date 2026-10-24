extends Node2D

@onready var audio: AudioStreamPlayer = $AudioStream0
@onready var voice_audio: AudioStreamPlayer = $AudioStream3

var sounds: Array[AudioStream] = []
var sound_index: int = 0

var voices;


func _ready() -> void:
	randomize()

	# Load your wav files here
	sounds = [
		load("res://assets/music/Extremely Loud Incorrect Buzzer.wav"),
		load("res://assets/music/Look No.wav"),
		load("res://assets/music/Nuh Uh Peak.wav"),
		load("res://assets/music/Pursuer.wav")
	]
	
	voices = [load("res://assets/music/sfx/canwegoyetsfx_voice1.wav"),
	load("res://assets/music/sfx/canwegoyetsfx_voice2.wav"),
	load("res://assets/music/sfx/canwegoyetsfx_voice3.wav"),
	load("res://assets/music/sfx/canwegoyetsfx_voice4.wav"),
	load("res://assets/music/sfx/canwegoyetsfx_voice5.wav"),
	load("res://assets/music/sfx/canwegoyetsfx_voice6.wav"),
	load("res://assets/music/sfx/canwegoyetsfx_voice7.wav"),
	load("res://assets/music/sfx/canwegoyetsfx_voice8.wav"),
	load("res://assets/music/sfx/canwegoyetsfx_voice9.wav"),
	load("res://assets/music/sfx/canwegoyetsfx_voice10.wav"),
	load("res://assets/music/sfx/canwegoyetsfx_voice11.wav"),
	load("res://assets/music/sfx/canwegoyetsfx_voice12.wav")]
	
	
	audio.connect("finished", play_next_sound)
	

	# Randomize order once per run
	sounds.shuffle()
	play_next_sound()


func play_next_sound() -> void:
	if sounds.is_empty():
		return

	audio.stream = sounds[sound_index]
	audio.play()

	sound_index += 1
	if sound_index >= sounds.size():
		sound_index = 0


func play_voice_line():
	if voices.is_empty():
		return

	var random_voice = voices[randi_range(0, voices.size() - 1)]
	voice_audio.stream = random_voice
	voice_audio.play()
	print("Playing voice:", random_voice)
