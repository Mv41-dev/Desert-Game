extends Node

var musica: AudioStreamPlayer


func _ready() -> void:
	musica = AudioStreamPlayer.new()
	musica.stream = preload("res://bg_music.wav")
	musica.bus = "Music"

	add_child(musica)
	musica.play()


func tocar() -> void:
	if not musica.playing:
		musica.play()


func parar() -> void:
	musica.stop()


func pausar() -> void:
	musica.stream_paused = true


func continuar() -> void:
	musica.stream_paused = false


func definir_volume(volume_db: float) -> void:
	musica.volume_db = volume_db
