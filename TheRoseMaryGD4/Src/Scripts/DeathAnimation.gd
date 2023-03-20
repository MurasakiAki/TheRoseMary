extends Node2D

func _on_animation_player_animation_finished(animname):
	animname = "DeathAnimation"
	if(Input.is_action_just_pressed("ui_accept")):
		self.queue_free()
