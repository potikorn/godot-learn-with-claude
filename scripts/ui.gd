extends CanvasLayer

@onready var game_over_screen = $GameOverScreen
@onready var level_up_screen = $LevelUpScreen
@onready var victory_screen = $VictoryScreen
@onready var hp_bar = $HUD/HPBar
@onready var exp_bar = $HUD/EXPBar
@onready var wave_label = $HUD/WaveLabel
@onready var enemy_label = $HUD/EnemyLabel
@onready var break_container = $HUD/PanelContainer
@onready var break_label = %BreakLabel

var wave_manager: Node = null
var break_timer: float = 0.0
var is_counting_down: bool = false

# เก็บ upgrade ที่กำลังแสดงอยู่ เพื่อรู้ว่าปุ่มไหนคือ upgrade อะไร
var _pending_upgrades: Array[Dictionary] = []

func _ready() -> void:
	game_over_screen.visible = false
	level_up_screen.visible = false
	break_container.visible = false
	victory_screen.visible = false

	# Reset run state ทุกครั้งที่เริ่มเกมใหม่
	# (Singleton ยังมีชีวิตอยู่ข้ามการ change_scene ดังนั้นต้อง reset เอง)
	UpgradeManager.reset()

	# ปุ่ม restart / victory
	$GameOverScreen/VBoxContainer/Button.pressed.connect(_on_restart_pressed)
	$VictoryScreen/VBoxContainer/Button.pressed.connect(_on_restart_pressed)

	# ปุ่ม upgrade — ตอนนี้ใช้ index แทน hardcode type
	# ข้อความบนปุ่มจะถูก set ตอน show_level_up() ทุกครั้ง
	$LevelUpScreen/VBoxContainer/Button.pressed.connect(func(): _on_upgrade_selected(0))
	$LevelUpScreen/VBoxContainer/Button2.pressed.connect(func(): _on_upgrade_selected(1))
	$LevelUpScreen/VBoxContainer/Button3.pressed.connect(func(): _on_upgrade_selected(2))
	# Button4 (add_orbit_bullet เก่า) ไม่ใช้แล้ว — ซ่อนไว้
	if $LevelUpScreen/VBoxContainer.has_node("Button4"):
		$LevelUpScreen/VBoxContainer/Button4.visible = false

	# เชื่อม WaveManager signals
	wave_manager = get_parent().get_node("WaveManager")
	wave_manager.wave_started.connect(_on_wave_started)
	wave_manager.wave_completed.connect(_on_wave_completed)
	wave_manager.all_waves_completed.connect(_on_all_waves_completed)

func _process(delta: float) -> void:
	_update_enemy_count()

	if is_counting_down:
		break_timer -= delta
		if break_timer > 0:
			break_label.text = "WAVE CLEAR!\nNext wave in: %d" % ceil(break_timer)
		else:
			is_counting_down = false
			break_container.visible = false
			wave_manager.ready_for_next_wave.emit()

# === Wave signals ===

func _on_wave_started(wave_number: int) -> void:
	wave_label.text = "Wave %d / %d" % [wave_number, 10]
	_update_enemy_count()

func _on_wave_completed(_wave_number: int) -> void:
	show_level_up()
	break_timer = 5.0
	is_counting_down = false  # จะเริ่มหลัง upgrade เสร็จ

func _on_all_waves_completed() -> void:
	victory_screen.visible = true
	get_tree().paused = true
	process_mode = Node.PROCESS_MODE_ALWAYS

# === Upgrade UI ===

func show_level_up() -> void:
	_pending_upgrades = UpgradeManager.get_random_upgrades()

	# ถ้า pool ว่าง (weapon ทุกตัว max lv3 ครบแล้ว) ข้าม upgrade screen
	# ไม่งั้นเกมจะ pause ค้างโดยไม่มีปุ่มให้กด
	if _pending_upgrades.is_empty():
		is_counting_down = true
		break_container.visible = true
		return

	var buttons = [
		$LevelUpScreen/VBoxContainer/Button,
		$LevelUpScreen/VBoxContainer/Button2,
		$LevelUpScreen/VBoxContainer/Button3,
	]

	for i in buttons.size():
		if i < _pending_upgrades.size():
			var up = _pending_upgrades[i]
			buttons[i].text = up["title"] + "\n" + up["description"]
			buttons[i].visible = true
		else:
			buttons[i].visible = false

	level_up_screen.visible = true
	get_tree().paused = true

func _on_upgrade_selected(index: int) -> void:
	# ซ่อน UI ก่อน unpause
	level_up_screen.visible = false
	get_tree().paused = false

	# เริ่ม countdown ระหว่าง wave
	is_counting_down = true
	break_container.visible = true

	# Apply upgrade ผ่าน manager (manager จัดการ spawn/upgrade weapon เอง)
	if index < _pending_upgrades.size():
		UpgradeManager.apply_upgrade(_pending_upgrades[index])

# === HUD ===

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
	process_mode = Node.PROCESS_MODE_ALWAYS

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
