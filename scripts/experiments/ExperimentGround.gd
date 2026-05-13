extends Node2D

const TILE_SIZE := 64
const MAP_WIDTH := 18
const MAP_HEIGHT := 12

const GRASS_A := Color("6f9f55")
const GRASS_B := Color("78aa5f")
const PATH := Color("b8905b")
const PATH_EDGE := Color("8f7048")
const GRID := Color(0.18, 0.28, 0.16, 0.18)


func _draw() -> void:
	var origin := Vector2(MAP_WIDTH, MAP_HEIGHT) * TILE_SIZE * -0.5

	for y in MAP_HEIGHT:
		for x in MAP_WIDTH:
			var tile_position := origin + Vector2(x, y) * TILE_SIZE
			var color := GRASS_A if (x + y) % 2 == 0 else GRASS_B

			if abs(y - MAP_HEIGHT / 2) <= 1 or abs(x - MAP_WIDTH / 2) <= 1:
				color = PATH

			draw_rect(Rect2(tile_position, Vector2(TILE_SIZE, TILE_SIZE)), color)
			draw_rect(Rect2(tile_position, Vector2(TILE_SIZE, TILE_SIZE)), GRID, false, 1.0)

	for y in [MAP_HEIGHT / 2 - 2, MAP_HEIGHT / 2 + 2]:
		draw_line(origin + Vector2(0, y * TILE_SIZE), origin + Vector2(MAP_WIDTH * TILE_SIZE, y * TILE_SIZE), PATH_EDGE, 2.0)

	for x in [MAP_WIDTH / 2 - 2, MAP_WIDTH / 2 + 2]:
		draw_line(origin + Vector2(x * TILE_SIZE, 0), origin + Vector2(x * TILE_SIZE, MAP_HEIGHT * TILE_SIZE), PATH_EDGE, 2.0)
