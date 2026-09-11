extends CharacterBody2D

@export var speed: float = 60.0
@export var jump_force: float = -130.0
@export var vida_inimigo: int = 1

var gravity: float = 980.0
var player: Node2D = null
var is_chasing: bool = false
var pode_dar_dano: bool = true

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_chasing and player:
		var direction = player.global_position.x - global_position.x
		var dir_sign = sign(direction)
		
		velocity.x = dir_sign * speed
		
		if dir_sign != 0:
			sprite.flip_h = (dir_sign > 0)
			
		if sprite.animation != "walk" and sprite.sprite_frames.has_animation("walk"):
			sprite.play("walk")
	else:
		velocity.x = 0
		if sprite.sprite_frames.has_animation("idle") and sprite.animation != "idle":
			sprite.play("idle")

	move_and_slide()
	
	# Verifica se o inimigo está encostando no player usando as colisões físicas do jogo
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider and collider.is_in_group("player") and pode_dar_dano:
			causar_dano_por_contato()

func _on_jump_timer_timeout() -> void:
	if is_on_floor() and is_chasing:
		velocity.y = jump_force

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		is_chasing = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		is_chasing = false

func causar_dano_por_contato() -> void:
	pode_dar_dano = false
	Global.tomar_dano(1)
	
	await get_tree().create_timer(1.0).timeout
	pode_dar_dano = true

func tomar_dano(quantidade: int) -> void:
	vida_inimigo -= quantidade
	if vida_inimigo <= 0:
		queue_free()
