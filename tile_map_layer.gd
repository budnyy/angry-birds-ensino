extends TileMap

# Dicionário que mapeia qual "desenho" no TileMap vira qual "Cena" no jogo.
# A chave (Vector2i) é a coordenada do seu tile na aba TileSet (geralmente 0, 0 para o primeiro).
# O valor é a cena física pré-carregada na memória.
var mapa_de_blocos = {
	Vector2i(0, 0): preload("res://world/builds/wood/bloco_madeira.tscn")
}

func _ready():
	# Assim que a fase é carregada, chamamos a função de substituição
	# antes mesmo do jogador conseguir ver o primeiro frame do jogo.
	substituir_tiles_estaticos()

func substituir_tiles_estaticos():
	var camada = 0 # A camada do TileMap onde desenhamos os blocos
	
	# Pega uma lista com as coordenadas (x, y) de todos os quadradinhos que foram pintados
	var celulas_pintadas = get_used_cells(camada)
	
	# Vamos varrer cada quadradinho pintado, um por um
	for celula in celulas_pintadas:
		
		# Descobre qual é a imagem (coordenada no atlas) que foi pintada nessa célula
		var coordenada_do_desenho = get_cell_atlas_coords(camada, celula)
		
		# Verifica se configuramos uma cena física para essa imagem específica no nosso dicionário
		if mapa_de_blocos.has(coordenada_do_desenho):
			
			# 1. Pegamos a cena do dicionário e a instanciamos (criamos o objeto real)
			var cena_salva = mapa_de_blocos[coordenada_do_desenho]
			var novo_bloco_fisico = cena_salva.instantiate()
			
			# 2. Descobrimos onde esse bloco deve nascer na tela.
			# A função map_to_local converte a posição da grade (ex: coluna 2, linha 5) 
			# para a posição exata em pixels na tela (ex: x: 128, y: 320).
			# Na Godot 4, ela já retorna o centro exato do tile!
			var posicao_em_pixels = map_to_local(celula)
			
			# Ajustamos a posição do bloco físico recém-criado
			# Usamos to_global() para garantir que a posição não quebre se o TileMap for movido
			novo_bloco_fisico.global_position = to_global(posicao_em_pixels)
			
			# 3. Adicionamos o bloco na cena do jogo.
			# Colocamos como filho do 'pai' do TileMap (o nó Fase), 
			# para que o bloco seja independente e não sofra interferências do TileMap.
			# call_deferred manda a Godot adicionar o nó com segurança ao final do frame atual.
			get_parent().call_deferred("add_child", novo_bloco_fisico)
			
			# 4. A mágica final: apagamos o desenho "falso" do TileMap!
			# O jogador nunca saberá que ele esteve ali.
			erase_cell(camada, celula)
