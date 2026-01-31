extends Area2D

signal destroyed(points: int)

var speed := 150.0
var health := 20
var points := 50
var pulse_time := 0.0

func _ready() -> void:
    add_to_group("enemy")
    set_collision_layer_value(2, true)
    set_collision_mask_value(1, true)
    area_entered.connect(_on_area_entered)
    queue_redraw()

func _process(delta: float) -> void:
    global_position.y += speed * delta
    pulse_time += delta
    queue_redraw()
    var viewport_size := get_viewport_rect().size
    if global_position.y > viewport_size.y + 60:
        queue_free()

func take_damage(amount: int) -> void:
    health -= amount
    if health <= 0:
        destroyed.emit(points)
        queue_free()

func _on_area_entered(area: Area2D) -> void:
    if area.has_method("apply_damage"):
        area.apply_damage(15)
        queue_free()

func _draw() -> void:
    var pulse := 1.0 + sin(pulse_time * 6.0) * 0.08
    draw_circle(Vector2.ZERO, 14 * pulse, Color(1, 0.3, 0.3))
    draw_circle(Vector2(0, 6), 6 * pulse, Color(0.2, 0.1, 0.1))
