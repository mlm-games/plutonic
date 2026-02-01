# Purpose: A manager for playing one-shot gameplay sounds.
# It uses an ObjectPool to efficiently manage AudioStreamPlayer instances.
# Should be added as a child to a central Utils autoload or a main scene node (or as an autoload).
class_name AutoloadAudioManager extends Node

# Configuration
const INITIAL_POOL_SIZE = 15
const MAX_POOL_SIZE = 50

var _player_pool: ObjectPool

func _ready():
	# The pool needs a scene to instantiate. Since AudioStreamPlayer is a built-in
	# type, we can't provide a .tscn file. Instead, we create a script that
	# generates the scene on the fly.
	var player_scene = PackedScene.new()
	player_scene.pack(AudioStreamPlayer.new()) # Pack a new, empty player
	
	# Create and configure the ObjectPool as a child of this manager.
	_player_pool = ObjectPool.new(player_scene, INITIAL_POOL_SIZE, MAX_POOL_SIZE)
	_player_pool.name = "AudioPlayerPool"
	add_child(_player_pool)


# Public API

func play_sound_varied(sound: AudioStream, pitch_variation: float = 0.1, volume_db: float = 0.0, bus: StringName = &"Sfx"):
	if not sound: return

	var player: AudioStreamPlayer = _player_pool.get_object()
	if not player:
		push_warning("AudioManager: Player pool is exhausted.")
		return
	
	player.stream = sound
	player.pitch_scale = randf_range(1.0 - pitch_variation, 1.0 + pitch_variation)
	player.volume_db = volume_db
	player.bus = bus
	player.play()
	
	# When the sound finishes, release the player back to the pool.
	player.finished.connect(_player_pool.release_object.bind(player), CONNECT_ONE_SHOT)


func play_random_sound(sounds: Array[AudioStream], volume_db: float = 0.0, bus: StringName = &"Sfx"):
	if sounds.is_empty(): return
	play_sound_varied(sounds.pick_random(), 0.1, volume_db, bus)

static func crossfade_music(from_player: AudioStreamPlayer, to_player: AudioStreamPlayer, duration: float = 1.0) -> Tween:
	if not from_player or not to_player: return

	to_player.volume_db = -80.0
	to_player.play()
	
	var tween = from_player.create_tween()
	tween.set_parallel()
	tween.tween_property(from_player, "volume_db", -80.0, duration)
	tween.tween_property(to_player, "volume_db", 0.0, duration)
	tween.finished.connect(from_player.stop)
	return tween
