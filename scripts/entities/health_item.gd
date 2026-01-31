extends Area2D

signal collected(kind: String)

var speed := 120.0

func _ready() -> void:
    add_to_group("pickup")
    set_collision_layer_value(4, true)
    set_collision_mask_value(1, true)
    area_entered.connect(_on_area_entered)

func _process(delta: float) -> void:
    global_position.y += speed * delta
    var viewport_size := get_viewport_rect().size
    if global_position.y > viewport_size.y + 40:
        queue_free()

func _on_area_entered(area: Area2D) -> void:
    if area.has_method("heal"):
        collected.emit("health")
        queue_free()

func _draw() -> void:
    draw_circle(Vector2.ZERO, 10, Color(0.3, 0.6, 1.0))
    draw_line(Vector2(-6, 0), Vector2(6, 0), Color(1, 1, 1), 2)
    draw_line(Vector2(0, -6), Vector2(0, 6), Color(1, 1, 1), 2)
