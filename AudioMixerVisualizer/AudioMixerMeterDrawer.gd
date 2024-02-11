extends Control

var bus

func assign_bus(bus):
	self.bus = bus

func _process(_delta):
	update() # call draw function

func _draw():
	if bus == null:
		return
	
	var meter_ui = bus.ui.get_node("VBox/HBox/Meter/HBox")
	var pos = meter_ui.rect_global_position - rect_global_position
	var size = meter_ui.rect_size
	
	# Draw db-markings
	var db_mark_color = Color(1.0, 1.0, 1.0, 0.03)
	for i in 12:
		draw_db_mark(pos, size, i * -6, db_mark_color)
	
	# Draw max-peak line
	#var peak = 1 - normalize_peak(bus.max_peak)
	#var y_offset = Vector2(0, peak * size.y)
	#draw_line(pos + y_offset, pos + y_offset + Vector2(size.x, 0), Color.greenyellow)
	draw_db_mark(pos, size, bus.max_peak, Color(0.1, 0.8, 0.1, normalize_peak(bus.max_peak)))

func draw_db_mark(pos, size, db, color):
	var db_norm = 1 - normalize_peak(db)
	var y_offset = Vector2(0, db_norm * size.y)
	draw_line(pos + y_offset, pos + y_offset + Vector2(size.x, 0), color)

# Takes a peak in db, and spits out a normalized 0 to 1 value
func normalize_peak(peak_db):
	var p = (peak_db + 200) / 200.0
	return p * p * p * p * p * p
