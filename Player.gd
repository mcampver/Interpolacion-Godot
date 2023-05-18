extends Area2D

signal hit

export var speed = 200 # How fast the player will move (pixels/sec).
var screen_size # Size of the game window
var direction
var target_position = Vector2.ZERO
var current_velocity = Vector2.ZERO

onready var position2D = $Position2D

func _ready():
	screen_size = get_viewport_rect().size
	hide()

func _process(delta):
	if target_position != position:
		position += current_velocity * delta

	var target_velocity = Vector2.ZERO # The target velocity for interpolation.
	if Input.is_action_pressed("move_right"):
		target_velocity.x += 1
	if Input.is_action_pressed("move_left"):
		target_velocity.x -= 1
	if Input.is_action_pressed("move_down"):
		target_velocity.y += 1
	if Input.is_action_pressed("move_up"):
		target_velocity.y -= 1

	if target_velocity.length() > 0:
		target_velocity = target_velocity.normalized()
		current_velocity = current_velocity.linear_interpolate(target_velocity * speed, 0.5)
		$AnimatedSprite.play()
	else:
		current_velocity = current_velocity.linear_interpolate(Vector2.ZERO, 0.5)
		$AnimatedSprite.stop()

	position.x = clamp(position.x + current_velocity.x * delta, 0, screen_size.x)
	position.y = clamp(position.y + current_velocity.y * delta, 0, screen_size.y)

	if current_velocity.x != 0:
		$AnimatedSprite.animation = "right"
		$AnimatedSprite.flip_h = true
		$AnimatedSprite.flip_h = current_velocity.x < 0
	elif current_velocity.y != 0:
		$AnimatedSprite.animation = "up"
		$AnimatedSprite.flip_v = current_velocity.y > 0
	elif current_velocity.y == 400:
		print(current_velocity.x)
		$AnimatedSprite.flip_v = true
		$AnimatedSprite.flip_v = current_velocity.y > 0

func start(pos):
	position = pos
	target_position = pos
	show()
	$CollisionShape2D.disabled = false


func _on_Player_body_entered(_body):
	hide() # Player disappears after being hit.
	emit_signal("hit")
	# Must be deferred as we can't change physics properties on a physics callback.
	$CollisionShape2D.set_deferred("disabled", true)
