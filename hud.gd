extends CanvasLayer

@export var cena_coracao: PackedScene
@export var vida_maxima: int = 3

var vida_atual: int = 3

@onready var container_coracoes: HBoxContainer = $HBoxContainer


func _ready() -> void:
	vida_maxima = maxi(vida_maxima, 1)
	vida_atual = clampi(vida_atual, 0, vida_maxima)

	configurar_coracoes()


func configurar_coracoes() -> void:
	for child in container_coracoes.get_children():
		container_coracoes.remove_child(child)
		child.queue_free()

	if cena_coracao == null:
		push_error("HUD: configure a cena Coracao.tscn no Inspector!")
		return

	for i in range(vida_maxima):
		var coracao = cena_coracao.instantiate()
		container_coracoes.add_child(coracao)

	atualizar_vida(vida_atual)


func atualizar_vida(quantidade_vida: int) -> void:
	vida_atual = clampi(quantidade_vida, 0, vida_maxima)

	if not is_instance_valid(container_coracoes):
		return

	var lista_coracoes = container_coracoes.get_children()

	for i in range(lista_coracoes.size()):
		var coracao = lista_coracoes[i]
		var cheio: bool = i < vida_atual

		if coracao.has_method("definir_estado"):
			coracao.definir_estado(cheio)
		else:
			push_warning("Um coração não possui o método definir_estado().")
