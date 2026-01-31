extends Area2D

signal destroyed(points: int)

var speed := 120.0
var health := 30
var points := 75
var wobble_time := 0.0

func _ready() -> void:
    add_to_group("asteroid")
    set_collision_layer_value(2, true)
    set_collision_mask_value(1, true)
    area_entered.connect(_on_area_entered)
    queue_redraw()

func _process(delta: float) -> void:
    global_position.y += speed * delta
    rotation += delta * 0.5
    wobble_time += delta
    queue_redraw()
    var viewport_size := get_viewport_rect().size
    if global_position.y > viewport_size.y + 80:
        queue_free()

func take_damage(amount: int) -> void:
    health -= amount
    if health <= 0:
        destroyed.emit(points)
        queue_free()

func _on_area_entered(area: Area2D) -> void:
    if area.has_method("apply_damage"):
        area.apply_damage(20)
        queue_free()

func _draw() -> void:
    var wobble := 1.0 + sin(wobble_time * 3.0) * 0.05
    var base_color := Color(0.6, 0.6, 0.65)
    draw_circle(Vector2.ZERO, 18 * wobble, base_color)
    draw_line(Vector2(-6, -2), Vector2(6, 4), base_color.darkened(0.2), 2)
