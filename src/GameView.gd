# Godot 4.5 / GDScript
# GameView.gd
# 역할: 화면 전체를 32x18 타일로 정확히 분할해 랜덤 맵 표시.
# 아무 입력 시 메인 메뉴 복귀 신호를 emit.
extends Node2D
signal request_back_to_menu

func _ready() -> void:
	_build_world()
	_animate_in()

func _build_world() -> void:
	# 전체 화면 크기를 기준으로 32(열) x 18(행)으로 정확히 분할
	var screen_size = get_viewport_rect().size
	var cols = 32
	var rows = 18

	var tile_w = int(floor(screen_size.x / cols))
	# 각 타일의 픽셀 크기(정수). floor로 잘라 틈 방지
	var tile_h = int(floor(screen_size.y / rows))

	# MapGenerator 스크립트를 직접 로드해서 생성
	var MapGen = preload("res://src/MapGenerator.gd")
	var map = MapGen.new()
	map.cols = cols
	map.rows = rows
	map.tile_w = tile_w
	map.tile_h = tile_h
	map.fill_ratio = 0.2
	map.smooth_steps = 4
	map.seed = -1
	map.position = Vector2.ZERO  # 화면 좌상단부터 채움

	add_child(map)
	map.generate()

func _animate_in() -> void:
	modulate = Color(1, 1, 1, 0)
	var t = create_tween()
	t.tween_property(self, "modulate:a", 1.0, 0.25)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_pressed():
		request_back_to_menu.emit()
