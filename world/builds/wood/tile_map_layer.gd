extends TileMapLayer

# Dicionário que mapeia qual "desenho" vira qual "Cena" no jogo.
var mapa_de_blocos = {
	# O seu bloco vertical (Exemplo: está na posição 0, 0)
	Vector2i(0, 0): preload("res://world/builds/wood/bloco_madeira_vertical.tscn"),
	
	# O seu NOVO bloco horizontal (Substitua X e Y pelas coordenadas do Atlas)
	Vector2i(1, 0): preload("res://world/builds/wood/bloco_madeira_horizontal.tscn")
}

func _ready():
	# Assim que a fase é carregada, chamamos a função de substituição
	substituir_tiles_estaticos()

func substituir_tiles_estaticos():
	# get_used_cells() agora não precisa do número da camada!
	# Ele pega todos os quadradinhos pintados neste TileMapLayer específico.
	var celulas_pintadas = get_used_cells()
	
	for celula in celulas_pintadas:
		
		# get_cell_atlas_coords() também não precisa mais da camada.
		var coordenada_do_desenho = get_cell_atlas_coords(celula)
		
		if mapa_de_blocos.has(coordenada_do_desenho):
			
			# 1. Instancia o objeto real
			var cena_salva = mapa_de_blocos[coordenada_do_desenho]
			var novo_bloco_fisico = cena_salva.instantiate()
			
			# 2. Descobre a posição em pixels
			var posicao_em_pixels = map_to_local(celula)
			
			# Ajusta a posição global
			novo_bloco_fisico.global_position = to_global(posicao_em_pixels)
			
			# 3. Adiciona o bloco na cena pai
			get_parent().call_deferred("add_child", novo_bloco_fisico)
			
			# 4. Apaga o desenho "falso" do TileMapLayer
			erase_cell(celula)
