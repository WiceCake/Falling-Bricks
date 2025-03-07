extends Area2D

var active_brick = null

func _ready() -> void:
	area_entered.connect(_on_brick_entered)
	area_exited.connect(_on_brick_exited)
	
func _on_brick_entered(area):
	if area.is_in_group("bricks"):
		active_brick = area

func _on_brick_exited(area):
	if area == active_brick:
		active_brick = null

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("hit") and active_brick:
		print("Key pressed! Brick is hit")
		active_brick.queue_free()
		active_brick = null
