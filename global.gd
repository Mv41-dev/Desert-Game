extends Node

# Sinais globais para gerenciar a vida no jogo inteiro
signal vida_alterada(nova_vida: int)
signal jogador_morreu

var vida_maxima: int = 3
var vida_atual: int = 3

func _ready() -> void:
	vida_atual = vida_maxima

func tomar_dano(quantidade: int) -> void:
	vida_atual -= quantidade
	vida_atual = clamp(vida_atual, 0, vida_maxima)
	
	# Emite o sinal avisando a nova quantidade de vida
	vida_alterada.emit(vida_atual)
	
	if vida_atual <= 0:
		jogador_morreu.emit()

func curar(quantidade: int) -> void:
	vida_atual += quantidade
	vida_atual = clamp(vida_atual, 0, vida_maxima)
	vida_alterada.emit(vida_atual)
