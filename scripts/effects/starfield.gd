extends Node2D

@export var star_count := 120
@export var min_speed := 30.0
@export var max_speed := 160.0

var stars: Array[Vector2] = []
var speeds: Array[float] = []
var viewport_size: Vector2
var rng := RandomNumberGenerator.new()

func _ready() -> void:
    rng.randomize()
    viewport_size = get_viewport_rect().size
    _generate_stars()
    queue_redraw()

func _process(delta: float) -> void:
    var current_size := get_viewport_rect().size
    if current_size != viewport_size:
        viewport_size = current_size
        _generate_stars()
    for i in range(stars.size()):
        var star := stars[i]
        star.y += speeds[i] * delta
        if star.y > viewport_size.y:
            star.y = 0.0
            star.x = rng.randf_range(0.0, viewport_size.x)
            speeds[i] = rng.randf_range(min_speed, max_speed)
        stars[i] = star
    queue_redraw()

func _generate_stars() -> void:
    stars.clear()
    speeds.clear()
    if viewport_size == Vector2.ZERO:
        return
    for i in range(star_count):
        stars.append(Vector2(
            rng.randf_range(0.0, viewport_size.x),
            rng.randf_range(0.0, viewport_size.y)
        ))
        speeds.append(rng.randf_range(min_speed, max_speed))

func _draw() -> void:
    for i in range(stars.size()):
        var brightness := remap(speeds[i], min_speed, max_speed, 0.3, 1.0)
        draw_circle(stars[i], 1.5, Color(brightness, brightness, 1.0))
