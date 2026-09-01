extends CanvasLayer

@export var cena_coracao: PackedScene
@export var vida_maxima: int = 3

@export var vida_atual: int = 3:
	set(novo_valor):
		vida_atual = novo_valor
		atualizar_vida(vida_atual)

@onready var container_coracoes: HBoxContainer = $HBoxContainer

func _ready() -> void:
	# Espera um frame para garantir que os nós filhos do container estejam prontos
	await get_tree().process_frame
	configurar_coracoes()

func configurar_coracoes() -> void:
	# Remove elementos antigos
	for child in container_coracoes.get_children():
		child.queue_free()
	
	# Cria os corações dinamicamente
	if cena_coracao != null:
		for i in range(vida_maxima):
			var instancia = cena_coracao.instantiate()
			container_coracoes.add_child(instancia)
	
	atualizar_vida(vida_atual)

func atualizar_vida(quantidade_vida: int) -> void:
	if container_coracoes == null:
		return
		
	var lista_coracoes = container_coracoes.get_children()
	
	# Passa por cada coração criado
	for i in range(lista_coracoes.size()):
		var coracao = lista_coracoes[i]
		# Se a vida for 0, (i < 0) será falso para todos os corações, exibindo a animação "vazio"
		var esta_cheio = i < quantidade_vida
		
		if coracao.has_method("definir_estado"):
			coracao.definir_estado(esta_cheio)
