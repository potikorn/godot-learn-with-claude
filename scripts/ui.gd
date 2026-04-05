extends CanvasLayer

# อ้างอิง node ลูก
@onready var game_over_screen = $GameOverScreen
@onready var level_up_screen = $LevelUpScreen
@onready var victory_screen = $VictoryScreen
@onready var hp_bar = $HUD/HPBar
@onready var exp_bar = $HUD/EXPBar
@onready var wave_label = $HUD/WaveLabel
@onready var enemy_label = $HUD/EnemyLabel
@onready var break_label = $HUD/BreakLabel

# @onready คือ "ดึง node นี้มาเพื่อ scene พร้อมแล้ว"
# ถ้าดึงตอน _ready() มันจะยังไม่ ready เสมอไป

var wave_manager: Node = null
var break_timer: float = 0.0
var is_counting_down: bool = false

func _ready() -> void:
	# ซ่อนทั้งคู่ตอนเริ่ม
	game_over_screen.visible = false
	level_up_screen.visible = false
	break_label.visible = false
	victory_screen.visible = false
	
	# เชื่อมปุ่ม restart
	$GameOverScreen/VBoxContainer/Button.pressed.connect(_on_restart_pressed)
	
	# เชื่อมปุ่ม upgrade ทั้งสาม
	$LevelUpScreen/VBoxContainer/Button.pressed.connect(
		func(): _on_upgrade_selected("speed")
	)
	$LevelUpScreen/VBoxContainer/Button2.pressed.connect(
		func(): _on_upgrade_selected("damage")
	)
	$LevelUpScreen/VBoxContainer/Button3.pressed.connect(
		func(): _on_upgrade_selected("fire_rate")
	)
	$LevelUpScreen/VBoxContainer/Button4.pressed.connect(
		func(): _on_upgrade_selected("add_orbit_bullet")
	)
	$VictoryScreen/VBoxContainer/Button.pressed.connect(_on_restart_pressed)
	
	# เชื่อม WaveManger signals
	wave_manager = get_parent().get_node("WaveManager")
	wave_manager.wave_started.connect(_on_wave_started)
	wave_manager.wave_completed.connect(_on_wave_completed)
	wave_manager.all_waves_completed.connect(_on_all_waves_completed)
	
func _process(delta: float) -> void:
	_update_enemy_count()
	
	# countdown ระหว่าง wave
	if is_counting_down:
		break_timer -= delta
		if break_timer > 0:
			break_label.text = "WAVE CLEAR!\nNext wave in: %d" % ceil(break_timer)
		else:
			is_counting_down = false
			break_label.visible = false
			# บอก WaveManager ว่าพร้อมแล้ว
			wave_manager.ready_for_next_wave.emit()
			
# Wave signals
func _on_wave_started(wave_number: int) -> void:
	wave_label.text = "Wave %d / %d" % [wave_number, 10]
	_update_enemy_count()
	
func _on_wave_completed(wave_number: int) -> void:
	# แสดง upgrade menu ตรงนี้แทน
	show_level_up()
	
	# เริ่ม countdown หลัง upgrade เสร็จ
	break_timer = 5.0
	is_counting_down = false # จะเริ่มหลัง unpause
	
func _on_all_waves_completed() -> void:
	victory_screen.visible = true
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	
func _update_enemy_count() -> void:
	var count = get_tree().get_nodes_in_group("enemies").size()
	enemy_label.text = "Enemies: %d" % count

func notify_enemy_died() -> void:
	_update_enemy_count()
	
func update_hp(current: float, maximum: float) -> void:
	hp_bar.max_value = maximum
	hp_bar.value = current
	
func update_exp(current: float, maximum: float) -> void:
	exp_bar.max_value = maximum
	exp_bar.value = current
	
func show_game_over() -> void:
	game_over_screen.visible = true
	# process_mode ของ UI ต้อง Always เพราะเกม pause อยู่
	process_mode = Node.PROCESS_MODE_ALWAYS

func show_level_up() -> void:
	level_up_screen.visible = true
	get_tree().paused = true

func _on_restart_pressed() -> void:
	get_tree().paused = false
	# กลับ main menu แทน reload
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
	
func _on_upgrade_selected(type: String) -> void:
	level_up_screen.visible = false
	get_tree().paused = false
	
	# เริ่ม countdown หลังจาก unpause
	is_counting_down = true
	break_label.visible = true
	
	# หา player แล้วส่ง upgrade ไป
	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.apply_upgrade(type)
