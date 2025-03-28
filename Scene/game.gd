extends Node2D

@export var brick_scene: PackedScene
@export var hitbox1: Area2D
@export var hitbox2: Area2D
@export var fall_duration: float = 2.0
@export var miss_y_threshold: float = 600

var score: int = 0  # Score variable

@onready var score_label: Label = $ScoreLabel  # Score UI
@onready var feedback_label: Label = $FeedbackLabel  # Floating text message
@onready var feedback_timer: Timer = $FeedbackTimer  # Timer for hiding text

const PERFECT_THRESHOLD = 10  # Perfect hit within 10 pixels of center
const GOOD_THRESHOLD = 40     # Good hit within 40 pixels
const EARLY_THRESHOLD = 500    # Too early if above 80 pixels from center

func _ready():
	$MidiPlayer.playing = true  
	update_score_label()
	feedback_timer.timeout.connect(_hide_feedback)  

	var timer = Timer.new()
	timer.wait_time = 2.5
	timer.one_shot = true
	add_child(timer)
	timer.start()
	timer.timeout.connect(_start_audio_player)

func _start_audio_player():
	$AudioStreamPlayer.play()

func _on_midi_player_midi_event(channel: Variant, event: Variant) -> void:
	if event.type == 144:
		if channel.number == 2:
			spawn_brick(channel.number, hitbox1.position.x)
		elif channel.number == 3:
			spawn_brick(channel.number, hitbox2.position.x)

func spawn_brick(channel: int, position_x: float):
	var brick = brick_scene.instantiate()
	brick.position = Vector2(position_x, hitbox1.position.y - (fall_duration * 300))
	add_child(brick)

	# Assign image based on channel
	var image_path = "res://Assets/fruit-1.png" if channel == 2 else "res://Assets/fruit-2.png"
	brick.start_fall(hitbox1.position.y, fall_duration, image_path, miss_y_threshold, self)

func _process(_delta):
	# Detect early presses before a brick enters the hitbox
	if Input.is_action_just_pressed("key1"):
		check_early_press(hitbox1)
		check_bricks_in_hitbox(hitbox1)
	if Input.is_action_just_pressed("key2"):
		check_early_press(hitbox2)
		check_bricks_in_hitbox(hitbox2)

func check_early_press(hitbox: Area2D):
	for brick in get_children():  # Check all bricks
		if brick.is_in_group("bricks"):  
			var distance = brick.position.y - hitbox.position.y  # Check distance from hitbox
			if distance < -EARLY_THRESHOLD:  # If the brick is still too high
				show_feedback("Too Early!", Color.YELLOW)
				return  # Prevent multiple penalties

func check_bricks_in_hitbox(hitbox: Area2D):
	for brick in hitbox.get_overlapping_areas():
		if brick.is_in_group("bricks"):  
			var distance = brick.position.y - hitbox.position.y  # Get relative position

			if abs(distance) <= PERFECT_THRESHOLD:
				increase_score(20)  # Perfect gives 20 points
				show_feedback("Perfect!", Color.CYAN)
			elif abs(distance) <= GOOD_THRESHOLD:
				increase_score(10)  # Good gives 10 points
				show_feedback("Good!", Color.GREEN)

			brick.queue_free()  # Remove the brick after judgment

func increase_score(amount: int):
	score += amount
	update_score_label()

func decrease_score(amount: int):
	score -= amount
	update_score_label()

func update_score_label():
	score_label.text = "Score: " + str(score)

func show_feedback(message: String, color: Color):
	feedback_label.text = message
	feedback_label.modulate = color
	feedback_label.visible = true
	feedback_timer.start()

func _hide_feedback():
	feedback_label.visible = false
