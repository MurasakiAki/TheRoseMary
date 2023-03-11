extends Node

@onready var JUMP_PARTICLES = preload("res://Assets/Particles/JumpParticles.tscn")
@onready var player = get_node("Player")

var jump_particles_list = []

func _process(delta: float) -> void:
	player = get_node("Player")
	if player != null:
		if player._is_jumping or player._is_double_jumping:
			var jump_particles = JUMP_PARTICLES.instantiate()
			jump_particles_list.append(jump_particles)
			jump_particles.set_position(Vector2(player.position.x, player.position.y + 9))
			add_child(jump_particles)
			jump_particles.get_node("CPUParticles2D").emitting = true
	else:
		pass
	
	if jump_particles_list.size() > 0:
		var particle_node = jump_particles_list[0]
		if particle_node.has_node("CPUParticles2D") and not particle_node.get_node("CPUParticles2D").emitting:
			jump_particles_list.erase(particle_node)
			particle_node.queue_free()

