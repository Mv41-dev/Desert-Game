extends CharacterBody2D

# Sinais para avisar o HUD e o jogo quando a vida mudar ou o jogador morrer
signal vida_alterada(nova_vida: int)
signal jogador_morreu

const SPEED = 200.0 # Velocidade de movimento lateral
const JUMP_FORCE = -280.0 # Força do pulo
var gravity = 980.0 # Força da gravidade

@export var vida_maxima: int = 3
var vida_atual: int = 3

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	vida_atual = vida_maxima

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
		if anim.animation != "attack": # Evita interromper o ataque com a animação idle
			anim.play("idle")

	move_and_slide()

# Função para aplicar dano ao jogador
func tomar_dano(quantidade: int) -> void:
	vida_atual -= quantidade
	vida_atual = clamp(vida_atual, 0, vida_maxima)
	
	# Emitimos o sinal com a nova quantidade de vida para atualizar o HUD
	vida_alterada.emit(vida_atual)
	
	if vida_atual <= 0:
		morrer()

# Função para curar o jogador
func curar(quantidade: int) -> void:
	vida_atual += quantidade
	vida_atual = clamp(vida_atual, 0, vida_maxima)
	
	vida_alterada.emit(vida_atual)

func morrer() -> void:
	jogador_morreu.emit()
	# Aqui você pode tocar uma animação de morte ou recarregar a cena
	queue_free()
