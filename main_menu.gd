extends Control

func _on_btn_jogar_pressed():
	# Carrega a primeira fase
	get_tree().change_scene_to_file("res://level_1.tscn")

func _on_btn_sair_pressed():
	# Fecha o jogo e volta para a área de trabalho do Windows/Mac
	get_tree().quit()
