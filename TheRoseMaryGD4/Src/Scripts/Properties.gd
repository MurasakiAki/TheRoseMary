class_name Properties

#Health
var max_health: int
var current_health: int

#Movement
var speed: float
func set_speed(set: float):
	self.speed = set

var jump_velocity: float

#Damage
var damage_range: Vector2
var crit_chance: float
var crit_mult: float

