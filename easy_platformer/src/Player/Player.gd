extends KinematicBody2D
class_name Player

const UP_DIRECTION = Vector2.UP

export var _speed = 40.0
export var max_speed = 120
export var acceleration = 220
export var jump_strength = 320.0
export var double_jump_strength = 250.0
export var max_jumps = 1
export var gravity = 100.0
export var mass = 8.5
export var max_health = 100.0 
export var knockback = 5
export var attack = 1
export var crit_rate = 0.1
export var crit_mult = 2
export var is_mass_stomp_enabled = false
export var mass_stomp_activation_speed = 300.0
export var mass_stomp_mult = 0


enum {MOVE, ATTACK}

onready var JUMP_PARTICLES = preload("res://Assets/Particles/JumpParticles.tscn")

var rng = RandomNumberGenerator.new()
var _jumps_made = 0
var _velocity = Vector2.ZERO
var state = MOVE
var _output_dmg
var _is_crit
var mass_stomp_dmg: float 
var _is_jumping: bool
var _is_double_jumping: bool
var _health: float
var _dmg_taken: float
var received_knockback = 0
var knockback_vector = Vector2.ZERO
var knockback_direction
var friction = mass * 40
var is_dead = false
var enemy

func _ready() -> void:
	$HitSprite.set_visible(false)
	$HealthBar/TextureProgress.set_max(max_health)
	_health = max_health

func _process(delta: float) -> void:
	if(_health <= 0.0 and is_dead == false):
		die()
	
	match state:
		MOVE:
			move_state(delta)
		ATTACK:
			attack_state()
	
	#knockback on player doesnt work idk why kill me
	#knockback_vector = knockback_vector.move_toward(Vector2.ZERO, friction * delta)
	#knockback_vector = move_and_slide(knockback_vector)


func die():
	is_dead = true
	self.queue_free()

func move_state(delta):
	var _horizontal_direction = (
		Input.get_action_strength("Right")
		- Input.get_action_strength("Left")
	)
	
	_speed += acceleration * delta
	if(_speed > max_speed):
		_speed = max_speed
	_velocity.x = _horizontal_direction * _speed
	_velocity.y += mass * gravity * delta
	
	
	var is_falling = _velocity.y > 0.0 and not is_on_floor()
	var is_jumping = Input.is_action_just_pressed("Jump") and is_on_floor()
	var is_double_jumping = Input.is_action_just_pressed("Jump") and is_falling and max_jumps > 1 and max_jumps != _jumps_made
	var is_jump_cancelled = Input.is_action_just_released("Jump") and _velocity.y < 0.0
	var is_idling = is_on_floor() and is_zero_approx(_velocity.x)
	var is_running = is_on_floor() and not is_zero_approx(_velocity.x)
	
	_is_jumping = is_jumping
	_is_double_jumping = is_double_jumping
	
	if(Input.is_action_just_pressed("Left")):
		$Sprite.set_flip_h(true)
		$HurtHitArea/HitArea/CollisionShape2D.set_position(Vector2(-6.5, 0.5))
		$HitSprite.set_flip_h(true)
		$HitSprite.set_position(Vector2(-8.5, 0.5))
		
	elif(Input.is_action_just_pressed("Right")):
		$Sprite.set_flip_h(false)
		$HurtHitArea/HitArea/CollisionShape2D.set_position(Vector2(6.5, 0.5))
		$HitSprite.set_flip_h(false)
		$HitSprite.set_position(Vector2(8.5, 0.5))
	
	if(is_jumping):
		_jumps_made += 1
		_velocity.y = -jump_strength
		$AnimationPlayer.play("StartJumping")
		
	elif(is_double_jumping):
		_jumps_made += 1
		if(_jumps_made <= max_jumps):
			_velocity.y = -double_jump_strength
			$AnimationPlayer.play("StartJumping")
	elif(is_jump_cancelled):
		_velocity.y = 0.0
	elif(is_idling):
		_jumps_made = 0
		$AnimationPlayer.play("Idle")
		_speed = 40.0
	elif(is_running):
		_jumps_made = 0
		$AnimationPlayer.play("Run")
	elif(is_falling):
		$AnimationPlayer.play("Falling")
		if(is_mass_stomp_enabled):
			if(_velocity.y >= mass_stomp_activation_speed):
				mass_stomp_dmg = (mass + 0.5) * mass_stomp_mult
				$MassStompArea/StompArea/CollisionShape2D.set_disabled(false)
				$MassStompArea/StompArea/CollisionShape2D.mass_stomp_dmg = mass_stomp_dmg
				$MassStompArea/StompArea/CollisionShape2D.mass = mass
	
	if(_velocity.y < mass_stomp_activation_speed):
		$MassStompArea/StompArea/CollisionShape2D.set_disabled(true)
	
	if(Input.is_action_just_pressed("Attack")):
		state = ATTACK
	
	_velocity = move_and_slide(_velocity, UP_DIRECTION)
	

func attack_state():
	$AnimationPlayer.play("Attack")
	
	rng.randomize()
	var random_crit_number = rng.randf_range(0.0, 1.0)
	if(random_crit_number <= crit_rate):
		_output_dmg = attack * crit_mult
		_is_crit = true
	else:
		_output_dmg = attack
		_is_crit = false
	
	
	$HurtHitArea/HitArea/CollisionShape2D.output_dmg = _output_dmg
	$HurtHitArea/HitArea/CollisionShape2D.is_crit = _is_crit
	$HurtHitArea/HitArea/CollisionShape2D.knockback = knockback

func _on_AnimationPlayer_animation_finished(anim_name = "Attack") -> void:
	state = MOVE

#PickUp
func _on_Area2D_area_entered(area: Area2D) -> void:
	if(area.get_child(0).is_double_jump == true):
		max_jumps = max_jumps + 1
	elif(area.get_child(0).is_mass_stomp == true):
		is_mass_stomp_enabled = true
		mass_stomp_mult = mass_stomp_mult + 1

#Hurt Function
func _on_HurtArea_area_entered(area: Area2D) -> void:
	
	var enemy_hit_area = area
	
	_dmg_taken = enemy_hit_area.get_child(0).output_dmg
	#received_knockback = enemy_hit_area.get_child(0).knockback / mass
	_health = _health - _dmg_taken
	enemy = enemy_hit_area.get_parent().get_parent()
	$HealthBar/TextureProgress.set_value(_health)
	
	knockback_direction = (enemy.global_position - global_position).normalized()
	knockback_vector = -(knockback_direction * received_knockback)
