extends Node

# preload ไฟล์เสียงทั้งหมดไว้เลย
const SOUNDS = {
	"shoot": preload("res://audios/shoot.wav"),
	"hit": preload("res://audios/hit.wav"),
	"enemy_died": preload("res://audios/died.wav"),
	"exp_collect": preload("res://audios/pickupCoin.wav")
}

# pool ของ AudioStreamPlayer สำหรับเล่นหลายเสียงพร้อมกัน
const POOL_SIZE = 8
var _players: Array[AudioStreamPlayer] = []

func _ready() -> void:
	# สร้าง AudioStreamPlayer ไว้ล่วงหน้า POOL_SIZE ตัว
	for i in POOL_SIZE:
		var player = AudioStreamPlayer.new()
		add_child(player)
		_players.append(player)
		
func play(sound_name: String, volume_db: float = 0.0) -> void:
	if not SOUNDS.has(sound_name):
		push_warning("Sound not found: " + sound_name)
		return
	
	# หา player ที่ว่างอยู่
	var player = _get_free_player()
	if player == null:
		return
		
	player.stream = SOUNDS[sound_name]
	player.volume_db = volume_db
	player.play()

func _get_free_player() -> AudioStreamPlayer:
	for player in _players:
		if not player.playing:
			return player
	return null # ถ้าเต็มทุกตัวก็ข้ามไป
