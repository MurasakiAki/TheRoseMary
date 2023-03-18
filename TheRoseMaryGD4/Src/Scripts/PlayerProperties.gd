extends Node2D
class_name PlayerProperties

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
