extends Node2D
class_name Dummy

export var mass = 1.0

enum {IDLE, HURT}

onready var DMG_TEXT_NODE = preload("res://src/UI/DamageText.tscn") 

var rng = RandomNumberGenerator.new()
var state
var dmg_taken: float
var _hits: float = 0.0

func _ready() -> void:
	$AnimationPlayer.play("DPSCounter")
	state = IDLE

func _process(delta: float) -> void:
	match state:
		IDLE:
			$AnimatedSprite.play("Idle")
		HURT:
			$AnimatedSprite.play("Hurt")
			if($AnimatedSprite.frame == 3):
				state = IDLE
	

#Hurt function
func _on_HurtArea_area_entered(area: Area2D) -> void:
	
	var dmg_text_node = DMG_TEXT_NODE.instance()
	
	add_child(dmg_text_node)
	
	_hits = _hits + 1
	
	var player_hit_area = area
	dmg_taken = player_hit_area.get_child(0).output_dmg
	var is_crit = player_hit_area.get_child(0).is_crit
	
	dmg_text_node.crit_color_change(is_crit)
	
	if(player_hit_area.get_child(0).position.x > $HurtHitArea/HurtArea/CollisionShape2D.position.x):
		$AnimatedSprite.set_flip_h(false)
	if(player_hit_area.get_child(0).position.x < $HurtHitArea/HurtArea/CollisionShape2D.position.x):
		$AnimatedSprite.set_flip_h(true)
	
	rng.randomize()
	var dmg_text_position_x = rng.randf_range(-5.5, 4.5)
	var dmg_text_position_y = rng.randf_range(-11.0, -15.5)
	var damage_text_position = Vector2(dmg_text_position_x, dmg_text_position_y)
	
	dmg_text_node.set_position(damage_text_position)
	dmg_text_node.get_node("AnimationPlayer").play("DmgDisappear")
	
	dmg_text_node.get_node("Label").set_text(str(dmg_taken))
	
	state = HURT

func count_dps():
	var dps: float
	if(dmg_taken == 0.0 or _hits == 0.0):
		pass
	else:
		dps = float(dmg_taken * _hits)
	
	$DPSCounterLabel.set_text(str(float(dps)))
	
	_hits = 0.0

#Stomp hurt function
func _on_StompHurtArea_area_entered(area: Area2D) -> void:
	var player_stomp_area = area
	var player_mass = player_stomp_area.get_child(0).mass
	
	if(player_mass >= mass):
		
		var dmg_text_node = DMG_TEXT_NODE.instance()
		
		add_child(dmg_text_node)
		
		_hits = _hits + 1
		
		dmg_taken = player_stomp_area.get_child(0).mass_stomp_dmg
		
		rng.randomize()
		var dmg_text_position_x = rng.randf_range(-5.5, 4.5)
		var dmg_text_position_y = rng.randf_range(-11.0, -15.5)
		var damage_text_position = Vector2(dmg_text_position_x, dmg_text_position_y)
		
		dmg_text_node.set_position(damage_text_position)
		dmg_text_node.get_node("AnimationPlayer").play("DmgDisappear")
		
		dmg_text_node.get_node("Label").set_text(str(dmg_taken))
