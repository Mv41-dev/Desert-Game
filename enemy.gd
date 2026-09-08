extends CharacterBody2D

@export var speed: float = 60.0
@export var jump_force: float = -130.0
@export var vida_inimigo: int = 1
var gravity: float = 980.0

var player: Node2D = null
var is_chasing: bool = false
var is_attacking: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var attack_area: Area2D = $AttackArea

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	if is_chasing and player and not is_attacking:
		var direction = sign(player.global_position.x - global_position.x)
		velocity.x = direction * speed
		
		if direction != 0:
			# Se a arte original da cobra está olhando para a DIREITA:
			sprite.flip_h = (direction < 0)
			
			# Se a arte original do seu sprite estiver olhando para a ESQUERDA, troque a linha acima por:
			# sprite.flip_h = (direction > 0)
			
			attack_area.scale.x = -1.0 if direction < 0 else 1.0
			
		if sprite.animation != "walk":
			sprite.play("walk")
	elif not is_attacking:
		velocity.x = 0

	move_and_slide()

func _on_jump_timer_timeout() -> void:
	if is_on_floor() and is_chasing and not is_attacking:
		velocity.y = jump_force

func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		is_chasing = true

func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		is_chasing = false

func _on_attack_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not is_attacking:
		start_attack()

func start_attack() -> void:
	is_attacking = true
	velocity.x = 0
	sprite.play("attack")
	Global.tomar_dano(1)

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite.animation == "attack":
		is_attacking = false
		# Se o jogador continuar dentro da área de ataque ao terminar a animação, ataca novamente
		for body in attack_area.get_overlapping_bodies():
			if body.is_in_group("player"):
				start_attack()
				break

func tomar_dano(quantidade: int) -> void:
	vida_inimigo -= quantidade
	if vida_inimigo <= 0:
		queue_free()
