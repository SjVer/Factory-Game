extends KinematicBody2D

export(float) var max_speed: float = 5
export(float) var friction: float = 1
export(float) var acceleration: float = 1

const FACTOR = 100

var velocity: Vector2 = Vector2()

func _physics_process(delta):
	# player input
	var direction: Vector2 = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()
	
	# if the direction is greater than zero, it is not zero
	if direction.length():
		velocity = lerp(velocity, direction * max_speed * FACTOR, acceleration * delta)
	# otherwise apply friction
	else: velocity = lerp(velocity, Vector2.ZERO, friction * delta)

	# apply
	velocity = move_and_slide(velocity)