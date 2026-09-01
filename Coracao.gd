extends Control

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func definir_estado(cheio: bool) -> void:
	if cheio:
		sprite.play("cheio")
	else:
		sprite.play("vazio")
