extends CharacterBody2D
class_name Player

#Health
var max_health: int = 100
var current_health: int = max_health

#Movement
var speed: float = 200
var jump_velocity: float = -400

#Damage
var damage_range: Vector2 = Vector2(1, 2)
var crit_chance: float = 0.5
var crit_mult: float = 1.2

func move(delta, gravity):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta
	
	#Handle Idling
	if velocity == Vector2.ZERO:
		$AnimationPlayer.play("Idle")
	
	# Handle Jump and Running.
	var direction = Input.get_axis("left", "right")
	var is_running = is_on_floor() and not is_zero_approx(velocity.x)
	var is_falling = not is_on_floor() and velocity.y > 0
	
	if direction > 0:
		$Body/Sprite2D.set_flip_h(false)
	elif direction < 0:
		$Body/Sprite2D.set_flip_h(true)
	
	if Input.is_action_just_pressed("jump") and is_on_floor():
		if is_on_floor():
			velocity.y = jump_velocity
			$AnimationPlayer.play("Jump")
		elif is_running:
			velocity.y = jump_velocity
			$AnimationPlayer.play("Jump")
	elif is_running:
		$AnimationPlayer.play("Run")
	elif is_falling:
		$AnimationPlayer.play("Falling")
	velocity.x = move_toward(velocity.x, direction * speed, speed)
	move_and_slide()

func take_damage(attack: Attack):
	current_health -= attack.damage
	print(current_health)
	if current_health <= 0:
		die()

func die():
	var death_screen = load("res://Src/Player/DeathAnimation.tscn").instantiate()
	
	#set it to player scene
