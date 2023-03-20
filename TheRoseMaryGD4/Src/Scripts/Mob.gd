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

func sprite_control(properties: Properties):
	if get_direction() == -1:
		$Mob/Body/Sprite2D.set_flip_h(false)
		$Mob/Body/HitArea/Area2D/CollisionShape2D.set_position(Vector2(-18.5, -4))
	elif get_direction() == 1:
		$Mob/Body/Sprite2D.set_flip_h(true)
		$Mob/Body/HitArea/Area2D/CollisionShape2D.set_position(Vector2(18.5, -4))
	
	if is_moving():
		$AnimationPlayer.play("Move")
	else:
		$AnimationPlayer.play("Idle")

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

func attack(properties: Properties) -> Attack:
	var rng = RandomNumberGenerator.new()
	var damage = rng.randi_range(properties.damage_range.x, properties.damage_range.y)
	print(damage)
	var attack = Attack.new()
	attack.damage = damage
	
	return attack

func stomp():
	pass

func die():
	pass

