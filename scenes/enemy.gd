extends CharacterBody2D

# Define speed, jump strength, detection range, and target distance from the player.
@export var speed: float = 100.0
@export var jump_strength: float = -400.0  # Negative value for upward jump
@export var detection_range: float = 100.0
@export var target_offset: float = 200.0  # Distance the enemy tries to maintain from the player (to the right)

# Reference to the player node, the main TileMap node for conversion, and the TileMapLayer for edge detection.
@export var player: NodePath
@export var tilemap: NodePath  # The main TileMap node for coordinate conversion
@export var tilemap_layer: NodePath  # The TileMapLayer node for edge detection

# Function to move the enemy towards the player's right side.
func _physics_process(delta: float) -> void:
	if not player or not tilemap or not tilemap_layer:
		return

	# Get references to the player, tilemap, and tilemap layer nodes.
	var player_node: Node2D = get_node(player)
	var tilemap_node: TileMap = get_node(tilemap)
	var tilemap_layer_node: TileMapLayer = get_node(tilemap_layer)

	# Get the player's global position and calculate the target position.
	var player_position: Vector2 = player_node.global_position
	var target_position: Vector2 = player_position + Vector2(target_offset, 0)

	# Determine the direction to the target position.
	var direction: Vector2 = Vector2.ZERO
	var distance_to_target: float = global_position.distance_to(target_position)

	# Move towards the target position if not within the detection range.
	if distance_to_target > detection_range:
		if target_position.x < global_position.x:
			direction.x = -1  # Move left
		elif target_position.x > global_position.x:
			direction.x = 1  # Move right
	else:
		# Stop moving if within the detection range of the target position.
		direction.x = 0

	# Apply gravity if not on the floor.
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		# Edge detection using the TileMap.
		if is_on_floor() and direction.x != 0:
			# Calculate the position ahead of the enemy (where it would walk next).
			var ahead_position: Vector2 = global_position + Vector2(direction.x * 20, 10)  # Look ahead and slightly below

			# Convert world position to the TileMap's grid coordinates.
			var map_position: Vector2i = tilemap_node.world_to_map(ahead_position)

			# Check if there's a tile at the ahead position in the specified TileMapLayer.
			if tilemap_layer_node.get_cell(map_position) == null:
				# If there's no tile ahead (empty space), the enemy will jump.
				velocity.y = jump_strength

	# Apply movement to the enemy based on direction and speed.
	velocity.x = direction.x * speed

	# Apply velocity to move the enemy.
	move_and_slide()
