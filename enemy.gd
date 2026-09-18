extends CharacterBody2D

@export var speed: float = 60.0
@export var vida: int = 1
@export var dano: int = 1

const GRAVITY: float = 980.0

var player: Node2D = null
var pode_dar_dano: bool = true

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:

	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if player != null:

		var direcao: float = signf(
			player.global_position.x - global_position.x
		)

		velocity.x = direcao * speed

		if direcao != 0:
			sprite.flip_h = direcao > 0

		if sprite.sprite_frames.has_animation("walk"):
			sprite.play("walk")

	else:

		velocity.x = 0

		if sprite.sprite_frames.has_animation("idle"):
			sprite.play("idle")

	move_and_slide()

	for i in get_slide_collision_count():

		var colisao = get_slide_collision(i)
		var objeto = colisao.get_collider()

		if objeto != null and objeto.is_in_group("player"):

			print("COLIDIU COM PLAYER!")

			causar_dano()


func _on_detection_area_body_entered(body: Node2D) -> void:

	if body.is_in_group("player"):
		player = body


func _on_detection_area_body_exited(body: Node2D) -> void:

	if body == player:
		player = null


func causar_dano() -> void:

	if not pode_dar_dano:
		return

	if player == null:
		return

	pode_dar_dano = false

	player.tomar_dano(dano)

	await get_tree().create_timer(1.0).timeout

	pode_dar_dano = true


func tomar_dano(quantidade: int) -> void:

	vida -= quantidade

	print("INIMIGO TOMOU DANO!")
	print("Vida do inimigo: ", vida)

	if vida <= 0:
		morrer()


func morrer() -> void:

	print("INIMIGO MORREU!")

	queue_free()
