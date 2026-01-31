extends Area2D
class_name Player

signal fired(origin: Vector2, direction: Vector2, damage: int)
signal took_damage
signal died

var speed := 340.0
var fire_cooldown := 0.0
var fire_rate := 0.25

var weapon_level := 1
var wing_level := 1
var hull_index := 0

var max_health := 100
var health := 100
var engine_time := 0.0

func _ready() -> void:
    add_to_group("player")
    set_collision_layer_value(1, true)
    set_collision_mask_value(2, true)
    set_collision_mask_value(4, true)
    set_process(true)
    queue_redraw()

func _process(delta: float) -> void:
    _handle_movement(delta)
    _handle_shooting(delta)
    engine_time += delta
    queue_redraw()

func _handle_movement(delta: float) -> void:
    var direction := Vector2(
        Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
        Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
    )
    if direction.length() > 1.0:
        direction = direction.normalized()

    var speed_modifier := 1.0 + (wing_level - 1) * 0.1
    global_position += direction * speed * speed_modifier * delta

    var viewport_size := get_viewport_rect().size
    global_position.x = clamp(global_position.x, 30, viewport_size.x - 30)
    global_position.y = clamp(global_position.y, 30, viewport_size.y - 30)

func _handle_shooting(delta: float) -> void:
    fire_cooldown = max(0.0, fire_cooldown - delta)
    if Input.is_action_pressed("shoot") and fire_cooldown <= 0.0:
        var spread := 0.15 + float(weapon_level) * 0.02
        var bullets := int(clamp(weapon_level, 1, 5))
        for i in range(bullets):
            var offset := (float(i) - (bullets - 1) / 2.0) * spread
            var direction := Vector2(0, -1).rotated(offset)
            fired.emit(global_position, direction, 10 + weapon_level * 2)
        fire_cooldown = max(0.08, fire_rate - weapon_level * 0.02)

func apply_damage(amount: int) -> void:
    health = max(health - amount, 0)
    took_damage.emit()
    if health <= 0:
        died.emit()

func heal(amount: int) -> void:
    health = min(health + amount, max_health)
    took_damage.emit()

func apply_power_up() -> void:
    weapon_level = clamp(weapon_level + 1, 1, 5)

func _draw() -> void:
    var color_palette: Array[Color] = [
        Color(0.2, 0.7, 1.0),
        Color(0.6, 0.4, 1.0),
        Color(0.2, 1.0, 0.6)
    ]
    var base_color: Color = color_palette[hull_index % color_palette.size()]
    draw_polygon(
        PackedVector2Array([Vector2(0, -20), Vector2(14, 16), Vector2(0, 8), Vector2(-14, 16)]),
        PackedColorArray([base_color, base_color, base_color, base_color])
    )
    var wing_color: Color = base_color.lightened(0.2)
    draw_line(Vector2(-16, 8), Vector2(-32, 20), wing_color, 3)
    draw_line(Vector2(16, 8), Vector2(32, 20), wing_color, 3)
    var flame := 1.0 + sin(engine_time * 12.0) * 0.2
    draw_polygon(
        PackedVector2Array([Vector2(-6, 18), Vector2(0, 32 * flame), Vector2(6, 18)]),
        PackedColorArray([Color(1.0, 0.6, 0.2), Color(1.0, 0.9, 0.5), Color(1.0, 0.6, 0.2)])
    )
