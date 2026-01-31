extends Area2D

var speed := 700.0
var velocity := Vector2(0, -1)
var damage := 10
var length := 14.0
var thickness := 3.0

func _ready() -> void:
    add_to_group("player_bullet")
    set_collision_layer_value(3, true)
    set_collision_mask_value(2, true)
    set_collision_mask_value(5, true)
    area_entered.connect(_on_area_entered)
    queue_redraw()

func _process(delta: float) -> void:
    global_position += velocity * delta
    var viewport_size := get_viewport_rect().size
    if global_position.y < -40 or global_position.y > viewport_size.y + 40:
        queue_free()

func _on_area_entered(area: Area2D) -> void:
    if area.has_method("take_damage"):
        area.take_damage(damage)
        queue_free()

func _draw() -> void:
    draw_line(
        Vector2(0, -length * 0.5),
        Vector2(0, length * 0.5),
        Color(0.9, 0.9, 1.0),
        thickness
    )
