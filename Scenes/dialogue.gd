extends Node2D

@export var char_name: String = ""
@export var name_label: RichTextLabel
@export var dialogue_label: RichTextLabel
@export var confirm_label: RichTextLabel
@export var low_pitch: float = 1.0
@export var high_pitch: float = 1.0
@export var text_arr: PackedStringArray
@export var controller: Node2D

@onready var audio_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var dialogue_timer: Timer = $DialogueTimer
@onready var blink_timer: Timer = $BlinkTimer

var text: String = ""
var text_index: int = 0
var dialogue_index: int = 0;


func _ready() -> void:
	reset()
	name_label.text = char_name
	
func set_audio(new_audio: AudioStream) -> void:
	audio_player.stream = new_audio

func set_text(new_text: String) -> void:
	text = new_text
	
func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("confirm"):
		if dialogue_timer.is_stopped():
			if text_index >= text_arr.size():
				controller.end_talk()
				text_index = 0
				return
			reset()
			play()
		else:
			early_press()

func play() -> void:
	dialogue_timer.start()
	
func pause() -> void:
	dialogue_timer.stop()
	
func early_press() -> void:
	dialogue_label.text = text
	start_confirm()
	pause()

func reset() -> void:
	dialogue_label.text = ""
	text = text_arr[text_index]
	text_index += 1
	dialogue_index = 0
	stop_confirm()
	
func start_confirm() -> void:
	confirm_label.show()
	blink_timer.start()
	
func stop_confirm() -> void:
	confirm_label.hide()
	blink_timer.stop()

func _on_dialogue_timer_timeout() -> void:
	if dialogue_index >= text.length():
		start_confirm()
		pause()
		return
		
	var new_char: String = text[dialogue_index]
	if new_char != " ":
		audio_player.pitch_scale = randf_range(low_pitch, high_pitch)
		audio_player.play()
	dialogue_label.add_text(new_char)
	dialogue_index += 1


func _on_blink_timer_timeout() -> void:
	confirm_label.visible = !confirm_label.visible
