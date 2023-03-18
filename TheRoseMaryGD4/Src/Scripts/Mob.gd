extends CharacterBody2D
class_name Mob

func wander():
	pass

func use_gravity(delta, gravity):
	velocity.y += gravity * delta
	move_and_slide()

func move(delta, properties: Properties):
	var player_position = get_tree().get_current_scene().get_node("Player").global_position
	var direction = (player_position - global_position).normalized()
	velocity.x = move_toward(velocity.x, direction.x * properties.speed, properties.speed * delta)
	
	move_and_slide()

func stop(delta, properties):
	velocity.x = move_toward(velocity.x, 0, delta * properties.speed)
	
	move_and_slide()

func is_moving() -> bool:
	if velocity.x != 0:
		return true
	else:
		return false

func get_direction() -> int:
	if velocity.x < 0:
		return -1
	elif velocity.x > 0:
		return 1
	else:
		return 0

func attack():
	print("attack")

func stomp():
	pass

func die():
	pass

