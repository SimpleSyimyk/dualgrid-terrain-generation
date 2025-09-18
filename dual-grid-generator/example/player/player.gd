extends CharacterBody2D

var speed: int = 10000
var direction: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	direction = Input.get_vector("ui_left", "ui_right", "ui_up", 'ui_down')
	velocity = direction * speed * delta
	move_and_slide()
