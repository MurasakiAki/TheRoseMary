extends Node2D

func clear():
	self.queue_free()

func crit_color_change(is_crit):
	
	if(is_crit == true):
		$Label.set_modulate(Color(255, 0, 0, 255))
