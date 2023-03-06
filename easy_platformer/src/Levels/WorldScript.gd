extends Node

onready var JUMP_PARTICLES = preload("res://Assets/Particles/JumpParticles.tscn")
onready var player = get_node("Player")

var jump_particles_list = []

func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	player = get_node("Player")
	if(player != null):
		if(player._is_jumping or player._is_double_jumping):
			var jump_particles = JUMP_PARTICLES.instance()
			jump_particles_list.append(jump_particles)
			jump_particles.set_position(Vector2(player.position.x, player.position.y + 9))
			add_child(jump_particles)
			jump_particles.get_node("CPUParticles2D").set_emitting(true)
	else:
		pass
	
	if(jump_particles_list.size() >= 1):
		if(jump_particles_list.front().get_node("CPUParticles2D").is_emitting() == false):
			jump_particles_list.front().queue_free()
			jump_particles_list.remove(0)


