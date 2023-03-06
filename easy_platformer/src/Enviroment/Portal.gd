extends Node2D


func _ready() -> void:
	pass # Replace with function body.



func _on_Area2D_body_entered(body: Node) -> void:
	
	print("res://src/Levels/Level_" + str(1 + int(get_tree().current_scene.name)) + ".tscn")
	get_tree().change_scene("res://src/Levels/Level_" + str(int(get_tree().current_scene.name) + 1) + ".tscn")
