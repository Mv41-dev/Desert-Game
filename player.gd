extends CharacterBody2D

const SPEED = 200.0 # Velocidade de movimento lateral
const JUMP_FORCE = -280.0 # Força do pulo
var gravity = 980.0 # Força da gravidade

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# 1. Aplicar Gravidade
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. Pular
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_FORCE

	# 3. Movimentar Esquerda/Direita
	var direction = Input.get_axis("left", "right")
	
	if Input.is_action_just_pressed("ataque"):
		anim.play("attack")
	elif direction != 0:
		velocity.x = direction * SPEED
		anim.play("run")
		anim.flip_h = (direction < 0)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if anim.animation != "attack":
			anim.play("idle")

	move_and_slide()

# Função chamada quando o jogador sofre dano
func levar_dano(quantidade: int) -> void:
	Global.tomar_dano(quantidade)

# Exemplo: Sinal enviado por uma Area2D (Hurtbox) no Player ao colidir com inimigos/espinhos
func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("inimigos"):
		levar_dano(1)
