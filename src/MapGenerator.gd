# Godot 4.5 / GDScript
# MapGenerator.gd
# - 화면 전체 크기를 cols x rows로 나누고,
#   타일 자체를 tile_w x tile_h 픽셀 크기로 생성하여 TileMap에 베이크.
# - 검정(이동 가능=0), 흰색(이동 불가=1)
extends Node2D
class_name MapGenerator

# 외부에서 잘못 연결해도 에러 방지용(사용하지 않아도 무방)
signal request_back_to_menu

# 격자 크기(열/행)
@export var cols: int = 32
@export var rows: int = 18

# 타일 픽셀 크기(정확히 화면을 채우기 위해 가로/세로 분리)
@export var tile_w: int = 40
@export var tile_h: int = 40

# 랜덤 맵 파라미터
@export var fill_ratio: float = 0.45   # 초기 벽(흰색=1) 비율
@export var smooth_steps: int = 4       # 스무딩 횟수
@export var seed: int = -1

# 내부 상태
var _grid: Array = []                   # rows x cols, 0/1
var _rng: RandomNumberGenerator
var _tilemap: TileMap
var _tileset: TileSet
var _src_black_id: int = -1             # 이동 가능(검정) 소스 ID
var _src_white_id: int = -1             # 이동 불가(흰색) 소스 ID

func _ready() -> void:
    # 필요 시 자동 생성
    # generate()
    pass

func generate() -> void:
    _setup_rng()
    _build_tileset()
    _init_grid()
    _random_fill()
    _smooth_map(smooth_steps)
    _bake_tilemap()

# --- RNG 세팅
func _setup_rng() -> void:
    _rng = RandomNumberGenerator.new()
    if seed < 0:
        _rng.randomize()
    else:
        _rng.seed = seed

# --- 타일셋(검정/흰색)을 tile_w x tile_h로 생성
func _build_tileset() -> void:
    _tileset = TileSet.new()
    # ★ 중요: TileMap 격자 크기를 타일 픽셀 크기와 일치시켜야 함
    _tileset.tile_size = Vector2i(tile_w, tile_h)

    # 단색 텍스처 생성 (mipmaps=false, filtering은 타일맵에서 NEAREST로 강제)
    var tex_black = _make_solid_texture(Color(0, 0, 0, 1), tile_w, tile_h)
    var tex_white = _make_solid_texture(Color(1, 1, 1, 1), tile_w, tile_h)

    # AtlasSource 생성 — 패딩 사용으로 경계선 틈 방지
    var src_black = TileSetAtlasSource.new()
    src_black.texture = tex_black
    src_black.use_texture_padding = true
    _src_black_id = _tileset.add_source(src_black)
    src_black.create_tile(Vector2i(0, 0))

    var src_white = TileSetAtlasSource.new()
    src_white.texture = tex_white
    src_white.use_texture_padding = true
    _src_white_id = _tileset.add_source(src_white)
    src_white.create_tile(Vector2i(0, 0))

# 단색 텍스처 만들기 (mipmap 꺼진 RGBA8)
func _make_solid_texture(color: Color, w: int, h: int) -> Texture2D:
    var img = Image.create(w, h, false, Image.FORMAT_RGBA8) # use_mipmaps=false
    img.fill(color)
    var tex = ImageTexture.create_from_image(img)
    return tex

# --- 그리드 초기화 (0=검정, 1=흰색)
func _init_grid() -> void:
    _grid = []
    for y in range(rows):
        var row: Array = []
        row.resize(cols)
        _grid.append(row)

# --- 초기 무작위 채우기(가장자리 벽 고정)
func _random_fill() -> void:
    for y in range(rows):
        for x in range(cols):
            var is_border = (x == 0 or y == 0 or x == cols - 1 or y == rows - 1)
            if is_border:
                _grid[y][x] = 1
            else:
                _grid[y][x] = int(_rng.randf() < fill_ratio)

# --- Cellular Automata 스무딩
func _smooth_map(steps: int) -> void:
    for i in range(steps):
        _grid = _smooth_step(_grid)

func _smooth_step(src: Array) -> Array:
    var dst: Array = []
    for y in range(rows):
        var row: Array = []
        for x in range(cols):
            var wall_count = _count_walls_around(src, x, y)
            var current = src[y][x]
            if wall_count > 4:
                row.append(1)
            elif wall_count < 4:
                row.append(0)
            else:
                row.append(current)
        dst.append(row)
    return dst

func _count_walls_around(g: Array, cx: int, cy: int) -> int:
    var count = 0
    for dy in range(-1, 2):
        for dx in range(-1, 2):
            if dx == 0 and dy == 0:
                continue
            var nx = cx + dx
            var ny = cy + dy
            if nx < 0 or ny < 0 or nx >= cols or ny >= rows:
                count += 1
            else:
                count += int(g[ny][nx] == 1)
    return count

# --- TileMap으로 베이크(스케일 X, 타일 자체가 tile_w x tile_h)
func _bake_tilemap() -> void:
    if is_instance_valid(_tilemap):
        remove_child(_tilemap)
        _tilemap.queue_free()

    _tilemap = TileMap.new()
    _tilemap.tile_set = _tileset
    _tilemap.rendering_quadrant_size = 64
    _tilemap.position = Vector2.ZERO

    # ★ 중요: 필터를 최근접으로 강제 — 타일 경계선 틈(점) 제거
    _tilemap.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

    add_child(_tilemap)

    var layer = 0
    _tilemap.clear_layer(layer)

    # 정확히 cols x rows만큼 채우기
    for y in range(rows):
        for x in range(cols):
            var v = _grid[y][x]
            if v == 0:
                _tilemap.set_cell(layer, Vector2i(x, y), _src_black_id, Vector2i(0, 0))
            else:
                _tilemap.set_cell(layer, Vector2i(x, y), _src_white_id, Vector2i(0, 0))
