extends Node2D

@onready var sprite: Sprite2D = $BrickSprite
var game_ref  # Reference to game.gd

func _ready():
	add_to_group("bricks")

func start_fall(target_y: float, duration: float, image_path: String, miss_y: float, game):
	# Set texture
	var texture = load(image_path)
	if texture:
		sprite.texture = texture

	game_ref = game  # Store reference to game.gd

	# Tween to make the brick fall
	var tween = create_tween()
	tween.tween_property(self, "position:y", target_y + 300, duration)

	await tween.finished

	# If the brick falls past the miss threshold, trigger a "Miss!"
	if position.y >= miss_y:  
		game_ref.decrease_score(10)  # Deduct 10 points for a miss
		game_ref.show_feedback("Miss!", Color.RED)
		print("Miss!")  # Debugging

	queue_free()  # Remove the brick
