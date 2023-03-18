extends CharacterBody2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var player_properties = get_node("Body").get_script().new()

func _physics_process(delta):
	move(delta, player_properties)

func move(delta, properties: PlayerProperties):
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
			velocity.y = properties.jump_velocity
			$AnimationPlayer.play("Jump")
		elif is_running:
			velocity.y = properties.jump_velocity
			$AnimationPlayer.play("Jump")
	elif is_running:
		$AnimationPlayer.play("Run")
	elif is_falling:
		$AnimationPlayer.play("Falling")
	velocity.x = move_toward(velocity.x, direction * properties.speed, properties.speed)
	move_and_slide()
