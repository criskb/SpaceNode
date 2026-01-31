extends Area2D

signal destroyed(points: int)

var speed := 80.0
var health := 250
var points := 500
var direction := 1
var pulse_time := 0.0

func _ready() -> void:
    add_to_group("boss")
    set_collision_layer_value(5, true)
    set_collision_mask_value(1, true)
    area_entered.connect(_on_area_entered)
    queue_redraw()

func _process(delta: float) -> void:
    global_position.y = lerp(global_position.y, 120.0, delta * 0.5)
    global_position.x += direction * speed * delta
    pulse_time += delta
    queue_redraw()
    var viewport_size := get_viewport_rect().size
    if global_position.x < 80 or global_position.x > viewport_size.x - 80:
        direction *= -1

func take_damage(amount: int) -> void:
    health -= amount
    if health <= 0:
        destroyed.emit(points)
        queue_free()

func _on_area_entered(area: Area2D) -> void:
    if area.has_method("apply_damage"):
        area.apply_damage(35)

func _draw() -> void:
    var pulse := 1.0 + sin(pulse_time * 4.0) * 0.06
    var hull_color := Color(0.9, 0.2, 0.2)
    draw_circle(Vector2.ZERO, 44 * pulse, hull_color)
    draw_circle(Vector2(0, 10), 20 * pulse, Color(0.2, 0.2, 0.2))
    draw_line(Vector2(-28, -8), Vector2(28, -8), hull_color.lightened(0.2), 4)
