extends Node2D

@export var health = 10.0
@export var mass = 10.0

@onready var DMG_TEXT_NODE = preload("res://src/UI/DamageText.tscn")

#PickUps:
@onready var DOUBLE_JUMP = preload("res://src/PickUps/DoubleJumpPickUp.tscn")
@onready var MASS_STOMP = preload("res://src/PickUps/MassStompPickUp.tscn")

var dmg_taken
var rng = RandomNumberGenerator.new()
var destroyed_texture = preload("res://Assets/Enviroment/skill_stone_destroyed.png")
var is_dead = false

func _process(delta: float) -> void:
	if(health <= 0 and is_dead == false):
		die()

func die():
	pickup_drop()
	$HurtHitArea/HurtArea/CollisionShape2D.set_disabled(true)
	$MassStompArea/StompHurtArea/CollisionShape2D.set_disabled(true)
	$RockDestructionParticles.get_child(0).set_emitting(true)
	$Sprite2D.set_texture(destroyed_texture)
	$Sprite2D.set_position(Vector2(0, -8))
	is_dead = true

func pickup_drop():
	rng.randomize()
	var roll_number = rng.randf_range(0.0, 1.0)
	
	if(roll_number >= 0.5):
		var double_jump = DOUBLE_JUMP.instantiate()
		
		add_child(double_jump)
		
		double_jump.set_position(Vector2(0, -30))
		
	elif(roll_number < 0.5):
		var mass_stomp = MASS_STOMP.instantiate()
		
		add_child(mass_stomp)
		
		mass_stomp.set_position(Vector2(0, -30))

#Hurt Function
func _on_HurtArea_area_entered(area: Area2D) -> void:
	var dmg_text_node = DMG_TEXT_NODE.instantiate()
	
	add_child(dmg_text_node)
	
	var player_hit_area = area
	dmg_taken = player_hit_area.get_child(0).output_dmg
	var is_crit = player_hit_area.get_child(0).is_crit
	
	dmg_text_node.crit_color_change(is_crit)
	
	rng.randomize()
	var dmg_text_position_x = rng.randf_range(-5.5, 4.5)
	var dmg_text_position_y = rng.randf_range(-11.0, -15.5)
	var damage_text_position = Vector2(dmg_text_position_x, dmg_text_position_y)
	
	dmg_text_node.set_position(damage_text_position)
	dmg_text_node.get_node("AnimationPlayer").play("DmgDisappear")
	
	dmg_text_node.get_node("Label").set_text(str(dmg_taken))
	
	health = health - dmg_taken

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
