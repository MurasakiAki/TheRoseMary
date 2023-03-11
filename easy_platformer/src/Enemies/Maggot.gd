extends CharacterBody2D

@export var mass = 3.5
@export var health = 5
@export var speed = 20.0
@export var max_speed = 35.5
@export var gravity = 100.0
@export var dmg = 5
@export var knockback = 1000
@export var crit_rate = 0.1
@export var crit_mult = 1.5


enum {IDLE, MOVE}

@onready var DMG_TEXT_NODE = preload("res://src/UI/DamageText.tscn")

var friction = mass * 40
var dmg_taken
var rng = RandomNumberGenerator.new()
var state
#var velocity = Vector2.ZERO
var player: Node2D
var is_dead = false
var dead_texture = preload("res://Assets/Enemy/dead_maggot.png")
var is_crit: bool
var direction
var received_knockback = 0
var knockback_vector = Vector2.ZERO
var knockback_direction

func _ready() -> void:
	state = IDLE

func _physics_process(delta: float) -> void:
	knockback_vector = knockback_vector.move_toward(Vector2.ZERO, friction * delta)
	set_velocity(knockback_vector)
	move_and_slide()
	knockback_vector = velocity

func _process(delta: float) -> void:
	
	if(health <= 0 and is_dead == false):
		die()
	
	match state:
		IDLE:
			idle_state(delta)
		MOVE:
			move_state(delta)


func idle_state(delta):
	
	velocity = velocity.move_toward(Vector2.ZERO, max_speed * delta)
	velocity.y += mass * gravity * delta
	set_velocity(velocity)
	move_and_slide()
	velocity = velocity
	if(velocity == Vector2.ZERO):
		$AnimationPlayer.play("Idle")

func move_state(delta):
	$AnimationPlayer.play("Crawl")
	
	if(player.global_position.x > self.global_position.x):
		$Sprite2D.set_flip_h(true)
		$DeadSprite.set_flip_h(true)
		$HurtHitArea/HitArea/CollisionShape2D.set_position(Vector2(13, -3))
		$PositionPoint.set_position(Vector2(13, -3))
	if(player.global_position.x < self.global_position.x):
		$Sprite2D.set_flip_h(false)
		$DeadSprite.set_flip_h(false)
		$HurtHitArea/HitArea/CollisionShape2D.set_position(Vector2(-13, -3))
		$PositionPoint.set_position(Vector2(-13, -3))
	
	direction = (player.global_position - global_position).normalized()
	velocity = velocity.move_toward(direction * max_speed, speed * delta)
	velocity.y += mass * gravity * delta
	set_velocity(velocity)
	move_and_slide()
	velocity = velocity
	
	if($PositionPoint/Marker2D.global_position.distance_to(player.get_node("PositionPoint/Marker2D").global_position) <= 10.0):
		attack_state(delta)


func attack_state(delta):
	
	rng.randomize()
	var random_crit_number = rng.randf_range(0.0, 1.0)
	if(random_crit_number <= crit_rate):
		$HurtHitArea/HitArea/CollisionShape2D.output_dmg = dmg * crit_mult
		is_crit = true
		
	else:
		$HurtHitArea/HitArea/CollisionShape2D.output_dmg = dmg
		is_crit = false
	
	$HurtHitArea/HitArea/CollisionShape2D.is_crit = is_crit
	$HurtHitArea/HitArea/CollisionShape2D.knockback = knockback
	

func die():
	is_dead = true
	$HurtHitArea/HurtArea/CollisionShape2D.set_disabled(true)
	$HurtHitArea/HitArea/CollisionShape2D.set_disabled(true)
	$MassStompArea/StompHurtArea/CollisionShape2D.set_disabled(true)
	$DetectionArea/DetectionArea/CollisionShape2D.set_disabled(true)
	$EnemyDeathEffect.get_child(0).set_emitting(true)
	$Sprite2D.set_visible(false)
	$DeadSprite.set_visible(true)
	

#Stomp hurt function
func _on_StompHurtArea_area_entered(area: Area2D) -> void:
	var player_stomp_area = area
	var player_mass = player_stomp_area.get_child(0).mass_stomp_dmg - 0.5
	
	if(player_mass >= mass):
		
		var dmg_text_node = DMG_TEXT_NODE.instantiate()
		
		add_child(dmg_text_node)
		
		dmg_taken = player_stomp_area.get_child(0).mass_stomp_dmg
		
		rng.randomize()
		var dmg_text_position_x = rng.randf_range(-5.5, 4.5)
		var dmg_text_position_y = rng.randf_range(-11.0, -15.5)
		var damage_text_position = Vector2(dmg_text_position_x, dmg_text_position_y)
		
		dmg_text_node.set_position(damage_text_position)
		dmg_text_node.get_node("AnimationPlayer").play("DmgDisappear")
		
		dmg_text_node.get_node("Label").set_text(str(dmg_taken))
		
		health = health - dmg_taken
		
	elif(player_mass < mass):
		var dmg_text_node = DMG_TEXT_NODE.instantiate()
		
		add_child(dmg_text_node)
		
		rng.randomize()
		var dmg_text_position_x = rng.randf_range(-5.5, 4.5)
		var dmg_text_position_y = rng.randf_range(-11.0, -15.5)
		var damage_text_position = Vector2(dmg_text_position_x, dmg_text_position_y)
		
		dmg_text_node.set_position(damage_text_position)
		dmg_text_node.get_node("AnimationPlayer").play("DmgDisappear")
		
		dmg_text_node.get_node("Label").set_text(str(0))

#Hurt Function
func _on_HurtArea_area_entered(area: Area2D) -> void:
	
	var dmg_text_node = DMG_TEXT_NODE.instantiate()
	
	add_child(dmg_text_node)
	
	var player_hit_area = area
	dmg_taken = player_hit_area.get_child(0).output_dmg
	var is_crit = player_hit_area.get_child(0).is_crit
	received_knockback = (player_hit_area.get_child(0).knockback * mass) / 10
	
	
	dmg_text_node.crit_color_change(is_crit)
	
	rng.randomize()
	var dmg_text_position_x = rng.randf_range(-5.5, 4.5)
	var dmg_text_position_y = rng.randf_range(-11.0, -15.5)
	var damage_text_position = Vector2(dmg_text_position_x, dmg_text_position_y)
	
	dmg_text_node.set_position(damage_text_position)
	dmg_text_node.get_node("AnimationPlayer").play("DmgDisappear")
	
	dmg_text_node.get_node("Label").set_text(str(dmg_taken))
	
	health = health - dmg_taken
	
	knockback_direction = (player.global_position - global_position).normalized()
	knockback_vector = -(knockback_direction * 100)

func _on_DetectionArea_body_entered(body: Node) -> void:
	state = MOVE
	player = body

func _on_DetectionArea_body_exited(body: Node) -> void:
	state = IDLE
