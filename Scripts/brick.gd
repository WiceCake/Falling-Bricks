extends Area2D

@export var speed: float = 200.0

func _ready() -> void:
	add_to_group("bricks")

func _process(delta):
	position.y += speed * delta

	# Remove if it falls off-screen
	if position.y > 600:  # Adjust if needed
		queue_free()
