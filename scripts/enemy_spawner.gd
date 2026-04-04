extends Node2D

@export var spawn_interval: float = 2.0 		# spawn ทุกกี่วินาที
@export var spawn_count: int = 1				# spawn กี่ตัวต่อครั้ง
@export var max_enemies: int = 50			# จำกัดสูงสุดไว้ก่อน
#@export var spawn_radius: float = 600.0		# spawn ห่างจาก player เท่าไหร่
@export var difficulty_interval: float = 15.0 # เพิ่มความยากทุกกี่วินาที

const ENEMY_SCENE = preload("res://scenes/enemy.tscn")

var spawn_timer: float = 0.0
var difficulty_timer: float = 0.0
var player: CharacterBody2D = null

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	
func _process(delta: float) -> void:
	if player == null:
		return
	
	# Diffuculty scaling
	difficulty_timer += delta
	if difficulty_timer >= difficulty_interval:
		difficulty_timer = 0.0
		_increase_difficulty()
		
	# Spawn timer
	spawn_timer += delta
	if spawn_timer >= spawn_interval:
		spawn_timer = 0.0
		_spawn_wave()
	
func _spawn_wave() -> void:
	var current_enemies = get_tree().get_nodes_in_group("enemies").size()
	if current_enemies >= max_enemies:
		return
	
	# spawn ไม่เกิน max
	var count = min(spawn_count, max_enemies - current_enemies)
	
	for i in count:
		_spawn_one_enemy()

func _spawn_one_enemy() -> void:
	# สุ่มตำแหน่งรอบ player เป็นวงกลม
	var angle = randf() * TAU
	var spawn_radius = _get_screen_radius() * 0.85
	var offset = Vector2(cos(angle), sin(angle)) * spawn_radius
	
	var enemy: CharacterBody2D = ENEMY_SCENE.instantiate()
	enemy.global_position = player.global_position + offset
	add_child(enemy)
	
func _increase_difficulty() -> void:
	spawn_count += 1
	spawn_interval = max(0.5, spawn_interval - 0.2) # เร็วขึ้นแต่ไม่ต่ำกว่า 0.5
	print("Difficulty UP — spawn: ", spawn_count, " interval: ", spawn_interval)
		
func _get_screen_radius() -> float:
	# ขนาดของสิ่งที่กล้องมองเห็นจริงๆ ตอนนั้น
	var viewport_size = get_viewport().get_visible_rect().size
	# คำนวณระยะจากกลางจอถึงมุม = spawn ออกไปนอกจอพอดี
	return viewport_size.length() / 2.0
		
		
		
