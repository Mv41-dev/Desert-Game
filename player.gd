extends CharacterBody2D

signal vida_alterada(vida_atual: int, vida_maxima: int)

const SPEED: float = 200.0
const JUMP_FORCE: float = -280.0
const GRAVITY: float = 980.0
const ATTACK_DISTANCE: float = 10.0

@export var vida_maxima: int = 3
@export var dano_ataque: int = 1

var vida: int = 3
var atacando: bool = false
var pode_atacar: bool = true
var olhando_direita: bool = true
var recebendo_dano: bool = false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea


func _ready() -> void:
	vida_maxima = maxi(vida_maxima, 1)
	vida = vida_maxima

	vida_alterada.emit(vida, vida_maxima)

	atualizar_attack_area()


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_FORCE

	var direction: float = Input.get_axis("left", "right")

	if direction != 0.0:
		velocity.x = direction * SPEED

		olhando_direita = direction > 0.0
		anim.flip_h = not olhando_direita

		atualizar_attack_area()

		if not atacando and is_on_floor():
			if anim.sprite_frames.has_animation("walk"):
				if anim.animation != "walk":
					anim.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0.0, SPEED)

		if not atacando and is_on_floor():
			if anim.sprite_frames.has_animation("idle"):
				if anim.animation != "idle":
					anim.play("idle")

	if Input.is_action_just_pressed("ataque"):
		atacar()

	move_and_slide()


func atualizar_attack_area() -> void:
	if olhando_direita:
		attack_area.position.x = ATTACK_DISTANCE
	else:
		attack_area.position.x = -ATTACK_DISTANCE


func atacar() -> void:
	if not pode_atacar or not is_inside_tree():
		return

	pode_atacar = false
	atacando = true

	atualizar_attack_area()
	anim.play("attack")

	await get_tree().create_timer(0.1).timeout

	if not is_inside_tree():
		return

	for inimigo in attack_area.get_overlapping_bodies():
		if not is_instance_valid(inimigo):
			continue

		if inimigo.is_in_group("inimigo") and inimigo.has_method("tomar_dano"):
			print("ATAQUE ACERTOU O INIMIGO!")
			inimigo.tomar_dano(dano_ataque)

	await get_tree().create_timer(0.3).timeout

	if not is_inside_tree():
		return

	atacando = false
	pode_atacar = true


func tomar_dano(quantidade: int) -> void:
	if quantidade <= 0 or recebendo_dano:
		return

	recebendo_dano = true

	vida = maxi(vida - quantidade, 0)

	print("PLAYER TOMOU DANO!")
	print("Vida atual: ", vida)

	vida_alterada.emit(vida, vida_maxima)

	if vida <= 0:
		morrer()
		return

	# Pequeno intervalo contra chamadas simultâneas de dano.
	if not is_inside_tree():
		return

	await get_tree().create_timer(0.2).timeout

	if is_inside_tree():
		recebendo_dano = false


func morrer() -> void:
	print("PLAYER MORREU!")

	if is_inside_tree():
		get_tree().reload_current_scene()
