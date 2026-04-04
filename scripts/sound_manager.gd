extends Node

# preload ไฟล์เสียงทั้งหมดไว้เลย
const SOUNDS = {
	"shoot": preload("res://audios/shoot.wav"),
	"hit": preload("res://audios/hit.wav"),
	"enemy_died": preload("res://audios/died.wav"),
	"exp_collect": preload("res://audios/pickupCoin.wav")
}

const BGM = preload("res://audios/bgm.wav")


# pool ของ AudioStreamPlayer สำหรับเล่นหลายเสียงพร้อมกัน
const POOL_SIZE = 8
var _players: Array[AudioStreamPlayer] = []
var _bgm_player: AudioStreamPlayer = null

func _ready() -> void:
	# สร้าง AudioStreamPlayer ไว้ล่วงหน้า POOL_SIZE ตัว
	for i in POOL_SIZE:
		var player = AudioStreamPlayer.new()
		add_child(player)
		_players.append(player)
		
	# สร้าง BGM Player แยกต่างหาก
	_bgm_player = AudioStreamPlayer.new()
	_bgm_player.stream = BGM
	_bgm_player.volume_db = -10.0 # เบากว่า sfx หน่อย
	_bgm_player.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_bgm_player)
	
func play_bgm() -> void:
	if _bgm_player.playing:
		return
	_bgm_player.play()

func stop_bgm() -> void:
	_bgm_player.stop()

func set_bgm_volume(db: float) -> void:
	_bgm_player.volume_db = db
		
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
