extends Control

var bus

func assign_bus(_bus):
	self.bus = _bus

func process(_delta):
	queue_redraw()

func _draw():
	if bus == null:
		return
	
	var pos = Vector2(-1, 0)
	var _size = Vector2(size.x + 2, size.y)
	draw_volume_mark(pos, _size, AudioServer.get_bus_volume_db(bus.index), Color(1.0, 1.0, 1.0, 0.5))

func draw_volume_mark(pos, _size, db, color):
	var db_norm = 1 - normalize_peak(db)
	var y_offset = Vector2(0, db_norm * (_size.y - 10) + 10)
	draw_line(pos + y_offset, pos + y_offset + Vector2(_size.x, 0), color, 2.0)

# Takes a peak in db, and spits out a normalized 0 to 1 value
func normalize_peak(peak_db):
	var p = (peak_db + 200) / 200.0
	return p * p * p * p * p * p
