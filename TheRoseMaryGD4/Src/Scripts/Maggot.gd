extends Mob

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var player_detected: bool = false
var properties = Properties.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	properties.set_speed(80)
	properties.damage_range = Vector2(5, 10)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	use_gravity(delta, gravity)
	sprite_control(properties)
	
	if player_detected:
		move(delta, properties)
	else:
		stop(delta, properties)
	

#Detecting player
func _on_area_2d_body_entered(body):
	if body.name == "Player":
		player_detected = true
	

func _on_area_2d_body_exited(body):
	if body.name == "Player":
		player_detected = false
	

func _on_hit_area_2d_body_entered(body):
	if body.name == "Player":
		var player = body
		player.take_damage(attack(properties))
