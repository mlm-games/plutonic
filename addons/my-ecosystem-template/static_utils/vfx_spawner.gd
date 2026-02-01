## A set of helper functions for instantiating and managing common visual effects.
##[br][br]
## Simplifies spawning one-shot particles, damage numbers, and other temporary
## visual effects. Includes built-in automatic cleanup to prevent memory leaks
## and keep the scene tree tidy.
class_name VFXSpawner
extends C


## Instantiates a particle scene, plays it once, and automatically queues it for deletion.
##[br][br]
## The root node of the provided [param particle_scene] must be a particle emitter
## (like [GPUParticles2D] or [CPUParticles2D]) with its [member GPUParticles2D.one_shot]
## property enabled.
##[br]
## [param particle_scene]: A [PackedScene] of the particle system.
##[br]
## [param global_pos]: The global position to spawn the particles.
##[br]
## [param parent]: The node to parent the particles to. If [code]null[/code], it defaults to the current scene root.
static func spawn_particles(particle_scene: PackedScene, global_pos: Vector2, parent: Node = null) -> void:
	if not parent:
		parent = A.current_scene
	
	var particles = particle_scene.instantiate()
	parent.add_child(particles)
	particles.global_position = global_pos
	particles.emitting = true
	
	particles.finished.connect(particles.queue_free)


## Creates and animates a floating damage number at a given position.
##[br][br]
## The number will float upwards and fade out over one second before being freed.
##[br]
## [param amount]: The number to display.
##[br]
## [param global_pos]: The global position where the number should appear.
##[br]
## [param color]: The [Color] of the number text.
static func spawn_damage_number(amount: int, global_pos: Vector2, color: Color = Color.WHITE) -> Tween:
	var label = Label.new()
	label.text = str(amount)
	label.add_theme_color_override("font_color", color)
	label.add_theme_font_size_override("font_size", 24)
	
	A.add_child(label)
	label.global_position = global_pos
	
	var tween = label.create_tween()
	tween.set_parallel()
	tween.tween_property(label, "position:y", label.position.y - 50, 1.0)
	tween.tween_property(label, "modulate:a", 0.0, 1.0)
	tween.finished.connect(label.queue_free)
	return tween


## Attaches a [Timer] to a node that spawns a trail effect at regular intervals.
##[br][br]
## This is useful for effects like dash trails or projectile trails. The function returns
## the created [Timer] so you can stop it when the effect should end.
##[br][br]
## [b]You are responsible for stopping and freeing the returned [Timer].[/b]
## [param node]: The [Node2D] that the trail will follow.
##[br]
## [param trail_scene]: A [PackedScene] for a single piece of the trail (e.g., a simple [Sprite2D]).
##[br]
## [param interval]: The time in seconds between spawning each piece of the trail.
##[br]
## Returns: The created [Timer] node.
##[br][br]
## [codeblock lang=gdscript]
## var dash_trail_timer: Timer
##[br][br]
## func start_dash():
##     dash_trail_timer = VFXSpawner.create_trail(self, preload("res://vfx/dash_ghost.tscn"))
##[br][br]
## func stop_dash():
##     if dash_trail_timer:
##         dash_trail_timer.stop()
##         dash_trail_timer.queue_free()
## [/codeblock]
static func create_trail(node: Node2D, trail_scene: PackedScene, interval: float = 0.05) -> Timer:
	var timer = Timer.new()
	timer.wait_time = interval
	timer.timeout.connect(func():
		if not is_instance_valid(node) or not is_instance_valid(node.get_parent()): return
		var trail = trail_scene.instantiate()
		node.get_parent().add_child(trail)
		trail.global_position = node.global_position
		
		var tween = trail.create_tween()
		tween.tween_property(trail, "modulate:a", 0.0, 0.5)
		tween.finished.connect(trail.queue_free)
	)
	node.add_child(timer)
	timer.start()
	return timer
