extends Node2D

@onready var musicsNode: Node = $Musics

const SILENT_DB := -80.0
const SFX_POOL_SIZE := 12
const DEFAULT_VOLUME := 0.6
const AUDIO_CONFIG_PATH := "user://audio.cfg"
const VOLUME_BUSES: Array[StringName] = [&"Master", &"Music", &"Effect"]

const SFX : = {
	&"click": preload("res://assets/sound/button_clicked.mp3"),
	&"navigate": preload("res://assets/sound/button_navigate.mp3"),
	&"ennemy_death": preload("res://assets/sound/ennemy_death.wav"),
	&"fireball": preload("res://assets/sound/fireball.mp3"),
	&"healing": preload("res://assets/sound/healing.mp3"),
	&"player_attack": preload("res://assets/sound/player_attack.wav"),
	&"player_death": preload("res://assets/sound/player_death.wav"),
	&"respawn": preload("res://assets/sound/respawn.mp3"),
	&"teleport": preload("res://assets/sound/teleport.mp3")
}

var _tracks := {}
var _base_db := {}
var _fades := {} 
var _current: AudioStreamPlayer

var masterIndex : int = AudioServer.get_bus_index("Master")
var musicIndex : int = AudioServer.get_bus_index("Music")
var effectIndex : int = AudioServer.get_bus_index("Effect")


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	for audio in musicsNode.get_children():
		if audio is AudioStreamPlayer:
			_tracks[String(audio.name)] = audio
			_base_db[audio] = audio.volume_db
		
	load_volumes()


func _create_player(bus: StringName) -> AudioStreamPlayer:
	var audioPlayer = AudioStreamPlayer.new()
	audioPlayer.bus = bus
	add_child(audioPlayer)
	return audioPlayer
	

func play_music(track: StringName, fade := 1.0) -> void:
	var nextStream: AudioStreamPlayer = _tracks.get(String(track))
	
	if nextStream == null:
		push_warning("Musique inconnue : %s" % track)
		return
		
	if _current == nextStream and _current.playing:
		return
	
	_current = nextStream
	
	# Fondu qui éteint les player qui jouent
	for audio in _tracks.values():
		if audio != nextStream and audio.playing:
			_fade_to(audio, SILENT_DB, fade, true)
	
	# Lancer la prochaine en fondu
	if not nextStream.playing:
		nextStream.volume_db = SILENT_DB
		nextStream.stream_paused = false
		nextStream.play()
		
	_fade_to(nextStream, _base_db[nextStream], fade)
	

func stop_music(fade := 1.0) -> void:
	if _current:
		_fade_to(_current, SILENT_DB, fade, true)
		_current = null
	
	
# Fondu en amplitude.
func _fade_to(audioPlayer: AudioStreamPlayer, target_db: float, duration: float, stop_when_done := false) -> void:
	if _fades.has(audioPlayer):
		_fades[audioPlayer].kill() 
		
	var tween := create_tween()
	_fades[audioPlayer] = tween
	
	tween.tween_method(
		func(v: float): 
			audioPlayer.volume_db = linear_to_db(maxf(v, 0.01)),
			db_to_linear(audioPlayer.volume_db),
			db_to_linear(target_db),
			duration
	)
		
	if stop_when_done:
		tween.tween_callback(audioPlayer.stop)
	
	
# value : 0.0 à 1.0 (cursor value)
func set_volume(bus_name: StringName, value: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1:
		return
	AudioServer.set_bus_volume_db(idx, linear_to_db(maxf(value, 0.01)))
	AudioServer.set_bus_mute(idx, value < 0.01)


func get_volume(bus_name: StringName) -> float:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx == -1 or AudioServer.is_bus_mute(idx):
		return 0.0
	return db_to_linear(AudioServer.get_bus_volume_db(idx))
	

# sauvegarde des paramètres audios

func save_volumes() -> void:
	var cfg := ConfigFile.new()
	cfg.load(AUDIO_CONFIG_PATH) 
	
	for bus in VOLUME_BUSES:
		cfg.set_value("audio", String(bus), get_volume(bus))
		
	var err := cfg.save(AUDIO_CONFIG_PATH)
	if err != OK:
		push_warning("Impossible d'enregistrer les réglages (erreur %d)" % err)


func load_volumes() -> void:
	var cfg := ConfigFile.new()
	var found := cfg.load(AUDIO_CONFIG_PATH) == OK
	
	for bus in VOLUME_BUSES:
		var value: float = DEFAULT_VOLUME
		if found:
			value = clampf(cfg.get_value("audio", String(bus), DEFAULT_VOLUME), 0.0, 1.0)
		
		set_volume(bus, value)
