extends Control

var bus

func assign_bus(_bus):
	self.bus = _bus

func _process(_delta):
	queue_redraw()

func _draw():
	if bus == null:
		return
	
	var meter_ui = bus.ui.get_node("VBox/HBox/Meter/HBox")
	var pos = meter_ui.global_position - global_position
	var _size = meter_ui.size
	
	# Draw db-markings
	var db_mark_color = Color(1.0, 1.0, 1.0, 0.03)
	for i in 12:
		draw_db_mark(pos, _size, i * -6, db_mark_color)
	
	# Draw max-peak line
	draw_db_mark(pos, _size, bus.max_peak, Color(0.1, 0.8, 0.1, normalize_peak(bus.max_peak)))

func draw_db_mark(pos, _size, db, color):
	var db_norm = 1 - normalize_peak(db)
	var y_offset = Vector2(0, db_norm * _size.y)
	draw_line(pos + y_offset, pos + y_offset + Vector2(_size.x, 0), color)

# Takes a peak in db, and spits out a normalized 0 to 1 value
func normalize_peak(peak_db):
	var p = (peak_db + 200) / 200.0
	return p * p * p * p * p * p
