extends Node2D

signal wave_started(wave_number: int)
signal wave_completed(wave_number: int)
signal all_waves_completed()
signal ready_for_next_wave()

@export var total_waves: int = 10
@export var break_duration: float = 5.0
@export var base_enemy_count: int = 5 # enemy wave แรก
@export var enemy_count_scaling: int = 3 # เพิ่มต่อ wave

const ENEMY_SCENE = preload("res://scenes/enemy.tscn")

var current_wave: int = 0
var enemies_remainging: int = 0
var enemies_to_spawn: int = 0
var is_break: bool = false
var player: CharacterBody2D = null

# spawn ทีละตัวไม่ spawn พร้อมกันทั้งหมด
var spawn_timer: float = 0.0
@export var spawn_interval: float = 0.3

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	# รอ 1 วินาทีก่อนเริ่ม wave แรก
	await get_tree().create_timer(1.0).timeout
	_start_next_wave()
	
func _process(delta: float) -> void:
	if is_break or player == null:
		return
	
	# spawn enemy ทีละตัวตาม interval
	if enemies_to_spawn > 0:
		spawn_timer -= delta
		if spawn_timer <= 0:
			spawn_timer = spawn_interval
			_spawn_one_enemy()
			enemies_to_spawn -= 1
	
	# เช็คว่า wave จบหรือยัง
	# ต้อง spawn หมดแล้ว และไม่มี enemy เหลือใน scene
	if enemies_to_spawn == 0:
		var alive = get_tree().get_nodes_in_group("enemies").size()
		if alive == 0 and enemies_remainging > 0:
			enemies_remainging = 0
			_on_wave_completed()
	
func _start_next_wave() -> void:
	current_wave += 1
	
	if current_wave > total_waves:
		all_waves_completed.emit()
		return
		
	# คำนวณจำนวน enemy ของ wave นี้
	var count = base_enemy_count + (current_wave - 1) * enemy_count_scaling
	enemies_to_spawn = count
	enemies_remainging = count
	spawn_timer = 0.0
	is_break = false
	
	wave_started.emit(current_wave)
	
func _on_wave_completed() -> void:
	is_break = true
	wave_completed.emit(current_wave)
	
	if current_wave >= total_waves:
		all_waves_completed.emit()
		return
	
	# รอ break duration แล้วค่อยเริ่ม wave ถัดไป
	await ready_for_next_wave
	_start_next_wave()

func _spawn_one_enemy() -> void:
	if player == null:
		return
	var angle = randf() * TAU
	var radius = get_viewport().get_visible_rect().size.length() / 2.0 * 0.85
	var offset = Vector2(cos(angle), sin(angle)) * radius
	
	var enemy: CharacterBody2D = ENEMY_SCENE.instantiate()
	enemy.global_position = player.global_position + offset
	
	enemy.type = _pick_enemy_type()
	
	# scale HP และ speed ตาม wave
	enemy.max_hp = 30.0 + (current_wave - 1) * 10.0
	enemy.speed = 90.0 + (current_wave - 1) * 5.0
	
	add_child(enemy)
	
func _pick_enemy_type() -> int:
	# wave แรกๆ มีแต่ normal
	# ยิ่ง wave สูง โอกาสเจอ fast และ tank มากขึ้น
	var roll = randf()  # 0.0 - 1.0
	
	if current_wave < 3:
		return Enemy.Type.NORMAL
	elif current_wave < 6:
		# wave 3-5: 70% normal, 30% fast
		if roll < 0.70:
			return Enemy.Type.NORMAL
		else:
			return Enemy.Type.FAST
	else:
		# wave 6+: 50% normal, 30% fast, 20% tank
		if roll < 0.50:
			return Enemy.Type.NORMAL
		elif roll < 0.80:
			return Enemy.Type.FAST
		else:
			return Enemy.Type.TANK
	
	
	
	
