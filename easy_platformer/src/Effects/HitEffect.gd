extends Node2D

var rng = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	self.position.x = rng.randi_range(-5, 5)
	rng.randomize()
	self.position.y = rng.randi_range(-5, 5)
	
	if get_parent().get_parent().get_parent().name == "Player":
		$Sprite.set_modulate(Color(1, 0, 0))
	else:
		$Sprite.set_modulate(Color(1, 1, 1))
	$AnimationPlayer.play("Hit")
	#print(str(position.x), str(position.y))



func _on_AnimationPlayer_animation_finished(anim_name):
	self.queue_free()
