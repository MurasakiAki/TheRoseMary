extends Node2D

var has_ended: bool

func _ready():
	print("start")
	$RichTextLabel.set_visible(false)
	$Sprite2D.set_visible(false)
	has_ended = false
	$AnimationPlayer.play("DeathAnimation")

func _process(delta):
	if has_ended and Input.is_action_just_pressed("Accept"):
		self.queue_free()

func _on_animation_player_animation_finished(animname):
	animname = "DeathAnimation"
	has_ended = true
