extends CharacterBody2D

const SPEED: float = 200.0
const JUMP_FORCE: float = -280.0
const GRAVITY: float = 980.0
const ATTACK_DISTANCE: float = 10.0

@export var vida: int = 5
@export var dano_ataque: int = 1

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea

var atacando: bool = false
var pode_atacar: bool = true
var olhando_direita: bool = true


func _physics_process(delta: float) -> void:

	# GRAVIDADE
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	# PULO
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_FORCE

	# MOVIMENTO
	var direction: float = Input.get_axis("left", "right")

	if direction != 0:
		velocity.x = direction * SPEED

		if direction > 0:
			olhando_direita = true
		else:
			olhando_direita = false

		anim.flip_h = not olhando_direita

		atualizar_attack_area()

	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

		if not atacando and is_on_floor():
			anim.play("idle")

	# ATAQUE
	if Input.is_action_just_pressed("ataque"):
		atacar()


	move_and_slide()


func atualizar_attack_area() -> void:

	if olhando_direita:
		attack_area.position.x = ATTACK_DISTANCE
	else:
		attack_area.position.x = -ATTACK_DISTANCE


func atacar() -> void:

	if not pode_atacar:
		return

	pode_atacar = false
	atacando = true

	atualizar_attack_area()

	anim.play("attack")

	await get_tree().create_timer(0.1).timeout

	for inimigo in attack_area.get_overlapping_bodies():

		if inimigo.has_method("tomar_dano"):
			print("ATAQUE ACERTOU O INIMIGO!")
			inimigo.tomar_dano(dano_ataque)

	await get_tree().create_timer(0.3).timeout

	atacando = false
	pode_atacar = true


func tomar_dano(quantidade: int) -> void:

	vida -= quantidade

	print("PLAYER TOMOU DANO!")
	print("Vida atual: ", vida)

	if vida <= 0:
		morrer()


func morrer() -> void:

	print("PLAYER MORREU!")

	get_tree().reload_current_scene()
