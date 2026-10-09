extends CharacterBody2D

@export var speed: float = 60.0
@export var vida: int = 1
@export var dano: int = 1
@export var intervalo_dano: float = 1.0

const GRAVITY: float = 980.0

var player: Node2D = null
var pode_dar_dano: bool = true
var morto: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	add_to_group("inimigo")


func _physics_process(delta: float) -> void:
	if morto:
		return

	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0.0

	if is_instance_valid(player):
		var direcao: float = signf(
			player.global_position.x - global_position.x
		)

		velocity.x = direcao * speed

		if direcao != 0.0:
			sprite.flip_h = direcao > 0.0

		if sprite.sprite_frames.has_animation("walk"):
			if sprite.animation != "walk":
				sprite.play("walk")
	else:
		player = null
		velocity.x = 0.0

		if sprite.sprite_frames.has_animation("idle"):
			if sprite.animation != "idle":
				sprite.play("idle")

	move_and_slide()

	for i in range(get_slide_collision_count()):
		var colisao = get_slide_collision(i)
		var objeto = colisao.get_collider()

		if objeto is Node2D and objeto.is_in_group("player"):
			player = objeto
			causar_dano()


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player:
		player = null


func causar_dano() -> void:
	if morto or not pode_dar_dano:
		return

	if not is_instance_valid(player):
		return

	if not player.has_method("tomar_dano"):
		return

	pode_dar_dano = false

	player.tomar_dano(dano)

	# Evita acessar a árvore se o inimigo sair da cena.
	if not is_inside_tree():
		return

	await get_tree().create_timer(intervalo_dano).timeout

	if not is_inside_tree() or morto:
		return

	pode_dar_dano = true


func tomar_dano(quantidade: int) -> void:
	if morto or quantidade <= 0:
		return

	vida -= quantidade

	print("INIMIGO TOMOU DANO!")
	print("Vida do inimigo: ", vida)

	if vida <= 0:
		morrer()


func morrer() -> void:
	if morto:
		return

	morto = true
	print("INIMIGO MORREU!")
	queue_free()
