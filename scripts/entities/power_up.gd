extends Area2D

signal collected(kind: String)

var speed := 120.0
var bob_time := 0.0

func _ready() -> void:
    add_to_group("pickup")
    set_collision_layer_value(4, true)
    set_collision_mask_value(1, true)
    area_entered.connect(_on_area_entered)
    set_process(true)
    queue_redraw()

func _process(delta: float) -> void:
    global_position.y += speed * delta
    bob_time += delta
    queue_redraw()
    var viewport_size := get_viewport_rect().size
    if global_position.y > viewport_size.y + 40:
        queue_free()

func _on_area_entered(area: Area2D) -> void:
    if area.has_method("apply_power_up"):
        collected.emit("power")
        queue_free()

func _draw() -> void:
    var pulse := 1.0 + sin(bob_time * 6.0) * 0.1
    draw_circle(Vector2.ZERO, 10 * pulse, Color(0.3, 0.9, 0.4))
    draw_circle(Vector2.ZERO, 4 * pulse, Color(1, 1, 1))
