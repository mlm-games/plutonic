## A singleton-like class for managing common audio operations.
##
## Provides static functions to easily play sounds with variat[br][br]ions, select sounds
## from a list, and crossfade music tracks. This avoids the need to manually
## create and manage [AudioStreamPlayer] nodes for simple, one-shot sounds.
class_name AudioManager
extends RefCounted

## Plays a sound with a random pitch variation. Not performant, use the object pool's instance instead.
##[br][br]
## Creates a temporary [AudioStreamPlayer], sets its properties, plays the sound,
## and automatically frees the player once it has finished. This is perfect for
## sound effects that need to sound less repetitive.
##[br]
## [param sound]: The [AudioStream] to play.
##[br]
## [param pitch_variation]: The amount of random pitch shift to apply. A value of 0.1 allows a range from 0.9 to 1.1.
##[br]
## [param volume_db]: The volume of the sound in decibels.
static func play_static_sound_varied(sound: AudioStream, pitch_variation: float = 0.1, volume_db: float = 0.0) -> void:
	if not sound: return
	
	var player = AudioStreamPlayer.new()
	A.add_child(player)
	player.stream = sound
	player.pitch_scale = randf_range(1.0 - pitch_variation, 1.0 + pitch_variation)
	player.volume_db = volume_db
	player.play()
	player.finished.connect(player.queue_free)


## Plays a random sound from an array of [AudioStream]s. Not performant, use the object pool's instance instead.
##[br][br]
## This function is a convenient wrapper around [method play_sound_varied]. It will
## pick a random stream from the provided array and play it with a default pitch variation.
##[br][br]
## [param sounds]: An [Array] of [AudioStream]s to choose from.
##[br]
## [param volume_db]: The volume of the sound in decibels.
static func play_static_random_sound(sounds: Array[AudioStream], volume_db: float = 0.0) -> void:
	if sounds.is_empty():
		return
	play_static_sound_varied(sounds.pick_random(), 0.1, volume_db)


## Smoothly crossfades between two music tracks.
##[br][br]
## Fades out the [param from_player] while simultaneously fading in the [param to_player].
## The [param from_player] is stopped once it has completely faded out.
##[br][br]
## [param from_player]: The [AudioStreamPlayer] that is currently playing and should be faded out.
##[br]
## [param to_player]: The [AudioStreamPlayer] that should be faded in. It will start playing from the beginning.
##[br]
## [param duration]: The duration of the crossfade in seconds.
static func crossfade_music(from_player: AudioStreamPlayer, to_player: AudioStreamPlayer, duration: float = 1.0) -> void:
	#if not from_player or not to_player: return

	to_player.volume_db = -80.0 # Effectively silent
	to_player.play()
	
	var tween = from_player.create_tween()
	tween.set_parallel()
	tween.tween_property(from_player, "volume_db", -80.0, duration)
	tween.tween_property(to_player, "volume_db", 0.0, duration)
	tween.finished.connect(from_player.stop)


static func crossfade_single_player_music(player: AudioStreamPlayer, to_audio: AudioStreamWAV, duration: float = 1.0) -> void:
	var tween = player.create_tween()
	tween.tween_property(player, "volume_db", -80.0, duration/2)
	player.audio = to_audio
	tween.tween_property(player, "volume_db", 0.0, duration/2)
