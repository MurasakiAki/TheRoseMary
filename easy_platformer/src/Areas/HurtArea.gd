extends Area2D

var hit_scene = load('src/Effects/HitEffect.tscn')


func _on_HurtArea_area_entered(area):
	var hit_inst = hit_scene.instantiate()
	add_child(hit_inst)
