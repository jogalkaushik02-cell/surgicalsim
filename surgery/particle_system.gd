extends Node

## ParticleSystem - Blood and tissue visual effects

var particles_pool: Array[GPUParticles3D] = []
var max_particles: int = 20

# Particle materials
var blood_material: ParticleProcessMaterial = null
var tissue_material: ParticleProcessMaterial = null

signal particle_created(type: String, position: Vector3)
signal particle_finished(type: String)

func _ready() -> void:
	_setup_particle_materials()

func _setup_particle_materials() -> void:
	# Blood particles
	blood_material = ParticleProcessMaterial.new()
	blood_material.direction = Vector3(0, 1, 0)
	blood_material.spread = 45.0
	blood_material.initial_velocity_min = 0.5
	blood_material.initial_velocity_max = 1.5
	blood_material.gravity = Vector3(0, -9.8, 0)
	blood_material.scale_min = 0.01
	blood_material.scale_max = 0.03
	blood_material.color = Color(0.8, 0.0, 0.0, 0.9)
	
	# Tissue particles (small debris)
	tissue_material = ParticleProcessMaterial.new()
	tissue_material.direction = Vector3(0, 1, 0)
	tissue_material.spread = 60.0
	tissue_material.initial_velocity_min = 0.2
	tissue_material.initial_velocity_max = 0.8
	tissue_material.gravity = Vector3(0, -5.0, 0)
	tissue_material.scale_min = 0.005
	tissue_material.scale_max = 0.015
	tissue_material.color = Color(0.9, 0.7, 0.6, 0.8)

func create_blood_splash(position: Vector3, intensity: float = 1.0) -> GPUParticles3D:
	var particles = _get_or_create_particle()
	if not particles:
		return null
	
	particles.process_material = blood_material.duplicate()
	particles.amount = int(20 * intensity)
	particles.lifetime = 1.5
	particles.one_shot = true
	particles.explosiveness = 0.9
	particles.position = position
	
	# Adjust velocity based on intensity
	var mat = particles.process_material as ParticleProcessMaterial
	mat.initial_velocity_min *= intensity
	mat.initial_velocity_max *= intensity
	
	particles.emitting = true
	particle_created.emit("blood", position)
	
	# Auto-cleanup
	var timer = get_tree().create_timer(2.0)
	timer.timeout.connect(func(): 
		particles.emitting = false
		particle_finished.emit("blood")
	)
	
	return particles

func create_tissue_debris(position: Vector3, count: int = 5) -> GPUParticles3D:
	var particles = _get_or_create_particle()
	if not particles:
		return null
	
	particles.process_material = tissue_material.duplicate()
	particles.amount = count
	particles.lifetime = 1.0
	particles.one_shot = true
	particles.explosiveness = 0.7
	particles.position = position
	
	particles.emitting = true
	particle_created.emit("tissue", position)
	
	var timer = get_tree().create_timer(1.5)
	timer.timeout.connect(func(): 
		particles.emitting = false
		particle_finished.emit("tissue")
	)
	
	return particles

func create_smoke(position: Vector3) -> GPUParticles3D:
	var particles = _get_or_create_particle()
	if not particles:
		return null
	
	var mat = ParticleProcessMaterial.new()
	mat.direction = Vector3(0, 1, 0)
	mat.spread = 30.0
	mat.initial_velocity_min = 0.3
	mat.initial_velocity_max = 0.8
	mat.gravity = Vector3(0, -0.5, 0)
	mat.scale_min = 0.02
	mat.scale_max = 0.05
	mat.color = Color(0.5, 0.5, 0.5, 0.3)
	
	particles.process_material = mat
	particles.amount = 15
	particles.lifetime = 2.0
	particles.one_shot = true
	particles.explosiveness = 0.5
	particles.position = position
	
	particles.emitting = true
	particle_created.emit("smoke", position)
	
	var timer = get_tree().create_timer(2.5)
	timer.timeout.connect(func(): 
		particles.emitting = false
		particle_finished.emit("smoke")
	)
	
	return particles

func create_cut_trail(start_pos: Vector3, end_pos: Vector3) -> void:
	var direction = (end_pos - start_pos).normalized()
	var distance = start_pos.distance_to(end_pos)
	var steps = int(distance / 0.01)
	
	for i in range(steps):
		var pos = start_pos + direction * (i * 0.01)
		create_tissue_debris(pos, 2)
		if i % 3 == 0:
			create_blood_splash(pos, 0.3)

func _get_or_create_particle() -> GPUParticles3D:
	# Find inactive particle
	for particles in particles_pool:
		if not particles.emitting:
			return particles
	
	# Create new if pool not full
	if particles_pool.size() < max_particles:
		var particles = GPUParticles3D.new()
		particles.name = "Particles_" + str(particles_pool.size())
		add_child(particles)
		particles_pool.append(particles)
		return particles
	
	# Reuse oldest
	return particles_pool[0]

func clear_all_particles() -> void:
	for particles in particles_pool:
		particles.emitting = false
		particles.queue_free()
	particles_pool.clear()
