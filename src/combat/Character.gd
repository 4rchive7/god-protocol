extends Node2D
class_name Character

@export var stats: StatBlock
@export var behavior: Resource
@export var team_tag: String = "player"
@export var attack_range: float = 96.0  # 겹침 보장을 위해 약간 여유

# 히트박스/허트박스
var hitbox_up
var hitbox_mid
var hitbox_down
var hitbox_power
var hurtbox

# 상태
var parry_active: bool = false
var parry_timer: float = 0.0
var poise_meter: float = 0.0
var disarm_meter: float = 0.0
var is_disarmed: bool = false
var action_cd: float = 0.0

var enemy_ref
var context: Dictionary = {}

# 시각/방향
var hit_flash_timer: float = 0.0
var swing_fx_timer: float = 0.0
var current_lane: String = ""
var facing_dir: int = 1  # +1: 오른쪽, -1: 왼쪽

# HP바
var hp_bar

func _ready():
	if stats == null:
		stats = StatBlock.new()
	_build_hurtbox()
	_build_hitboxes()
	_build_hpbar()
	set_process(true)
	scale.x = 1 

# --- 공개 API ---
func configure_as(side: String, team: String) -> void:
	team_tag = team
	facing_dir = 1 if side == "left" else -1
	_apply_facing(facing_dir)

func set_enemy(e) -> void:
	enemy_ref = e
	_ensure_facing()

# --- 루프 ---
func _process(delta):
	if hit_flash_timer > 0.0:
		hit_flash_timer -= delta
	if swing_fx_timer > 0.0:
		swing_fx_timer -= delta
	queue_redraw()

func _physics_process(delta):
	stats.stamina = min(stats.stamina + stats.stamina_recovery * delta, stats.stamina_max)

	_ensure_facing()

	if _try_approach_enemy(delta):
		return

	if parry_active:
		parry_timer -= delta
		if parry_timer <= 0.0:
			parry_active = false

	if action_cd > 0.0:
		action_cd -= delta
		return
	if behavior == null or enemy_ref == null:
		return

	context["enemy_parry_state"] = enemy_ref.parry_active

	var decision = behavior.decide(delta, stats, enemy_ref.stats, context)
	var act = String(decision.get("action","wait"))
	var intent_time = float(decision.get("intent_time", 0.2))
	var cost = float(decision.get("stamina_cost", 0.0))

	if stats.stamina < cost:
		_guard(0.35)
		return

	match act:
		"wait", "guard":
			_guard(intent_time)
		"parry_on":
			_parry(intent_time, cost)
		"feint":
			_feint(intent_time, cost)
		"attack_up":
			current_lane = "up"
			_attack_line(hitbox_up, intent_time, cost)
		"attack_mid":
			current_lane = "mid"
			_attack_line(hitbox_mid, intent_time, cost)
		"attack_down":
			current_lane = "down"
			_attack_line(hitbox_down, intent_time, cost)
		"power_attack":
			current_lane = "power"
			if not is_disarmed:
				_power_attack(intent_time, cost)
			else:
				_guard(0.5)

# --- 그리기 ---
func _draw():
	var base_col = Color(0.2, 0.75, 0.95) if team_tag == "player" else Color(0.95, 0.55, 0.25)
	var body_col = base_col.lightened(0.15)
	var outline = Color.WHITE
	var parry_col = Color(0.5, 1.0, 1.0)
	var hit_col = Color(1.0, 0.25, 0.2)

	if hit_flash_timer > 0.0:
		body_col = hit_col

	var body_rect = Rect2(-16, -48, 32, 64)
	draw_rect(body_rect, body_col, true)
	draw_rect(body_rect, outline, false, 2.0)
	draw_circle(Vector2(0, -60), 8, body_col)
	draw_circle(Vector2(0, -60), 8, outline)

	if parry_active:
		draw_arc(Vector2(0, -36), 22, 0, TAU, 24, parry_col, 3.0)

	if swing_fx_timer > 0.0:
		var t = clamp(swing_fx_timer / 0.12, 0.0, 1.0)
		var wcol = base_col.lerp(Color.WHITE, 0.5)
		var thickness = 4.0 + 6.0 * t
		var p0 = Vector2(12, -34)
		var p1 = Vector2(48, -34)
		if current_lane == "mid":
			p0 = Vector2(12, -8)
			p1 = Vector2(52, -8)
		elif current_lane == "down":
			p0 = Vector2(12, 20)
			p1 = Vector2(46, 20)
		elif current_lane == "power":
			p0 = Vector2(16, -6)
			p1 = Vector2(64, -6)
			thickness = thickness + 3.0
		if facing_dir < 0:
			p0.x = -p0.x
			p1.x = -p1.x
		draw_line(p0, p1, wcol, thickness, true)

# --- 맞기/공격 ---
func apply_hit(damage: int, stun_power: float, disarm_power: float) -> void:
	if parry_active:
		parry_active = false
		action_cd = 0.1
		context["parry_success"] = true
		swing_fx_timer = 0.08
		current_lane = "mid"
		return

	stats.hp -= damage
	hit_flash_timer = 0.15
	poise_meter += stun_power
	disarm_meter += disarm_power

	if poise_meter >= stats.poise:
		poise_meter = 0.0
		action_cd = 0.5
	if disarm_meter >= max(1.0, stats.poise * 0.8):
		disarm_meter = 0.0
		is_disarmed = true
		await get_tree().create_timer(1.2).timeout
		is_disarmed = false

	if stats.hp <= 0:
		queue_free()

# --- 방향/접근 ---
func _ensure_facing() -> void:
	# 화면 연출 고정: 플레이어는 오른쪽을, 적은 왼쪽을 보게 강제
	var desired = 1 if team_tag == "player" else -1
	if desired != facing_dir:
		_apply_facing(desired)

func _apply_facing(dir: int) -> void:
	facing_dir = dir
	if is_instance_valid(hitbox_up):
		hitbox_up.set_dir(dir)
	if is_instance_valid(hitbox_mid):
		hitbox_mid.set_dir(dir)
	if is_instance_valid(hitbox_down):
		hitbox_down.set_dir(dir)
	if is_instance_valid(hitbox_power):
		hitbox_power.set_dir(dir)

func _try_approach_enemy(delta: float) -> bool:
	if enemy_ref == null:
		return false
	var dx = enemy_ref.global_position.x - global_position.x
	var dist = abs(dx)

	# 살짝 더 붙어서 실제 겹치도록 여유(-12)
	var desired_dist = max(attack_range - 12.0, 0.0)
	if dist > desired_dist:
		var step = min(dist - desired_dist, stats.speed * delta)
		global_position.x += sign(dx) * step
		action_cd = max(action_cd, 0.02)
		return true
	return false

# --- 구축 ---
func _build_hurtbox() -> void:
	var HB = load("res://src/combat/hit/Hurtbox.gd")
	hurtbox = HB.new()
	add_child(hurtbox)
	var cs = CollisionShape2D.new()
	var rect = RectangleShape2D.new()
	rect.size = Vector2(40, 70)
	cs.shape = rect
	cs.position = Vector2(0, -10)
	hurtbox.add_child(cs)
	hurtbox.team_tag = team_tag

func _build_hitboxes() -> void:
	var Hitbox = load("res://src/combat/hit/Hitbox.gd")

	# 전방 도달거리/폭을 대폭 증가 (겹침 보장)
	# 기존 대비 +30~40px 정도 더 앞으로, 폭/높이도 넓힘
	hitbox_up = Hitbox.new()
	add_child(hitbox_up)
	hitbox_up.setup_rect(Vector2(90, 36), Vector2(80, -36))   # size, offset
	hitbox_up.damage = stats.attack_power
	hitbox_up.stun_power = 12.0
	hitbox_up.owner_team = team_tag

	hitbox_mid = Hitbox.new()
	add_child(hitbox_mid)
	hitbox_mid.setup_rect(Vector2(100, 38), Vector2(88, -8))
	hitbox_mid.damage = stats.attack_power
	hitbox_mid.stun_power = 10.0
	hitbox_mid.owner_team = team_tag

	hitbox_down = Hitbox.new()
	add_child(hitbox_down)
	hitbox_down.setup_rect(Vector2(90, 34), Vector2(82, 20))
	hitbox_down.damage = stats.attack_power
	hitbox_down.stun_power = 9.0
	hitbox_down.owner_team = team_tag

	hitbox_power = Hitbox.new()
	add_child(hitbox_power)
	hitbox_power.setup_rect(Vector2(120, 44), Vector2(110, -6))
	hitbox_power.damage = int(stats.attack_power * 1.8)
	hitbox_power.stun_power = 28.0
	hitbox_power.disarm_power = stats.disarm_power
	hitbox_power.owner_team = team_tag

	# 현재 바라보는 방향(facing_dir) 기준으로 오프셋 반영
	_apply_facing(facing_dir)


func _build_hpbar():
	var HBUI = load("res://src/ui/HealthBar.gd")
	hp_bar = HBUI.new()
	add_child(hp_bar)
	hp_bar.position = Vector2(0, -86)
	if hp_bar.has_method("set"):
		hp_bar.set("target", self)

# --- 액션 ---
func _guard(t: float) -> void:
	action_cd = t
	current_lane = ""

func _parry(t: float, cost: float) -> void:
	parry_active = true
	parry_timer = t
	stats.stamina -= cost
	action_cd = t

func _feint(t: float, cost: float) -> void:
	stats.stamina -= cost
	action_cd = t
	context["did_feint"] = true
	swing_fx_timer = 0.06
	current_lane = "mid"

func _attack_line(h, windup: float, cost: float) -> void:
	stats.stamina -= cost
	action_cd = windup
	context["did_attack"] = true
	await get_tree().create_timer(max(0.05, windup * 0.6)).timeout
	if is_instance_valid(h):
		swing_fx_timer = 0.12
		h.swing(0.08)

func _power_attack(windup: float, cost: float) -> void:
	stats.stamina -= cost
	action_cd = windup
	context["did_attack"] = true
	await get_tree().create_timer(max(0.1, windup)).timeout
	if is_instance_valid(hitbox_power):
		swing_fx_timer = 0.16
		hitbox_power.swing(0.12)
