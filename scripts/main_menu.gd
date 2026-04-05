extends Control


func _ready() -> void:
	# เชื่อมปุ่มกับ function
	$VBoxContainer/Play.pressed.connect(_on_play_pressed)
	$VBoxContainer/Quit.pressed.connect(_on_quit_pressed)
	# เล่น BGM ที่ main menu ด้วย
	SoundManager.play_bgm()

func _on_play_pressed() -> void:
	# เปลี่ยนไป world scene
	get_tree().change_scene_to_file("res://scenes/world.tscn")
	
func _on_quit_pressed() -> void:
	get_tree().quit()
