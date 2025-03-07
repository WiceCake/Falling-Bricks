extends Node2D

@export var brick_scene: PackedScene
@onready var music_player = $MusicPlayer
@onready var spawn_timer = $SpawnTimer
@onready var spawn_point = $SpawnPoint

var note_data = []  # Stores note times in seconds
var tempo = 120  # Default BPM
var seconds_per_beat = 0.5  # Will be calculated dynamically

func _ready():
	load_mboy_data()  # Load .mboy file
	music_player.play()  # Start music

func load_mboy_data():
	var mboy_path = "res://Songs/old_time_slow.mboy"
	var file = FileAccess.open(mboy_path, FileAccess.READ)
	
	if file:
		var content = file.get_as_text()
		var json = JSON.new()
		var error = json.parse(content)
		
		if error == OK:
			var mboy_data = json.data
			tempo = mboy_data.get("tempo", 120)  # Extract BPM
			seconds_per_beat = 60.0 / tempo  # Convert BPM to seconds per beat

			# Extract notes with corrected timing
			for track in mboy_data.get("tracks", []):
				for bar in track.get("bars", []):
					var bar_index = bar.get("index", 0)  # Bar number
					var beats_per_bar = bar.get("quarters_count", 4)  # Usually 4
					
					for note in bar.get("notes", []):
						var pos_in_seconds = (note.get("pos", 0) / 1000.0)  # Convert ms → sec
						
						# 🔹 Calculate absolute time in song
						var time_in_song = (bar_index * beats_per_bar * seconds_per_beat) + pos_in_seconds
						note_data.append(time_in_song)
			
			note_data.sort()  # Ensure notes are in order
			print("Parsed Notes with BPM:", note_data)  # Debugging output
		else:
			print("Failed to parse .mboy file!")
	else:
		print("Failed to open .mboy file!")

func _process(_delta):
	spawn_brick()  # Check if we need to spawn notes continuously

func spawn_brick():
	var song_time = music_player.get_playback_position()  # Get current song time

	# 🔹 FIX: Properly sync note spawning with beats
	while note_data.size() > 0 and song_time >= note_data[0]:  
		spawn_note()
		note_data.pop_front()  # Remove the spawned note

func spawn_note():
	if brick_scene:
		var note = brick_scene.instantiate()
		note.position = spawn_point.position  # Spawn from defined point
		add_child(note)
		print("Spawned note at:", music_player.get_playback_position())
	else:
		print("Error: Brick scene not assigned!")
