extends Control

@export var font_fx : FontFile

class bus:
	var index
	var ui : Control
	var max_peak : float
	var fx : Array
	
	var timer
	
	func _init(bus_index, _ui, _fx):
		timer = 0
		max_peak = -200
		self.index = bus_index
		self.ui = _ui
		self.fx = _fx
	
	func update(delta, peak):
		if peak > max_peak:
			max_peak = peak
			timer = 0
		
		timer += delta
		if timer > 3:
			max_peak = peak

@onready var container = $Container
@onready var bus_template = $Container/Bus
var buses : Array

func _ready():
	# Add bus panels
	for i in AudioServer.bus_count:
		var bus_panel = bus_template.duplicate()
		container.add_child(bus_panel)
		var label : Label = bus_panel.get_node("VBox/label_name")
		label.text = AudioServer.get_bus_name(i)
		
		# Add effect labels
		var vbox = bus_panel.get_node("VBox/HBox/VBox_fx")
		var fx = Array()
		for n in AudioServer.get_bus_effect_count(i):
			var effect : AudioEffect = AudioServer.get_bus_effect(i, n)
			fx.append(effect)
			
			var fx_label = Label.new()
			fx_label.text = effect.resource_name
			fx_label.add_theme_font_override("font", font_fx)
			vbox.add_child(fx_label)
			
			vbox.visible = true
		
		vbox.set_anchors_preset(Control.PRESET_TOP_LEFT)
		vbox.pivot_offset = Vector2(0, 300)
		
		var b = bus.new(i, bus_panel, fx)
		bus_panel.get_node("VBox/HBox/Meter").assign_bus(b)
		bus_panel.get_node("VBox/HBox/Volume").assign_bus(b)
		buses.append(b)
	
	bus_template.queue_free()

func _process(delta):
	var mouse_pos = get_viewport().get_mouse_position()
	if mouse_pos.y > get_viewport_rect().size.y - 150:
		_hide()
	else:
		_show()
	
	# Update bus panels
	for b in buses:
		var peak_l = AudioServer.get_bus_peak_volume_left_db(b.index, 0)
		var peak_r = AudioServer.get_bus_peak_volume_right_db(b.index, 0)
		var peak_max = max(peak_l, peak_r)
		
		b.update(delta, peak_max)
		
		# Mute/Solo
		var label_name : Label = b.ui.get_node("VBox/label_name")
		label_name.modulate = Color.WHITE
		if AudioServer.is_bus_mute(b.index):
			label_name.modulate = Color.CRIMSON
		if AudioServer.is_bus_solo(b.index):
			label_name.modulate = Color.YELLOW
		
		# Meter fill
		var fill : ColorRect = b.ui.get_node("VBox/HBox/Meter/HBox/fill_left")
		fill.anchor_top = 1.0 - normalize_peak(peak_l)
		fill = b.ui.get_node("VBox/HBox/Meter/HBox/fill_right")
		fill.anchor_top = 1.0 - normalize_peak(peak_r)
		
		# Peak label
		var label_peak : Label = b.ui.get_node("VBox/label_peak")
		var peak_text = ""
		if b.max_peak > -200:
			peak_text = str(ceil(b.max_peak * 10) / 10.0)
		if b.max_peak > 0:
			peak_text = "+" + peak_text
		label_peak.text = peak_text
		
		# Peak label color
		if b.max_peak > 0.0:
			label_peak.modulate = Color.CRIMSON
		else:
			label_peak.modulate = Color(1.0, 1.0, 1.0, 0.5)
	
	update_fx_labels()

func update_fx_labels():
	for b in buses:
		var fx_vbox = b.ui.get_node("VBox/HBox/VBox_fx")
		for i in b.fx.size():
			var label = fx_vbox.get_child(i)
			if AudioServer.is_bus_effect_enabled(b.index, i):
				label.modulate = Color.WHITE
			else:
				label.modulate = Color.DIM_GRAY
			
			var fx = b.fx[i]
			var s = fx.resource_name
			
			# Name
			if fx.get_class() == "AudioEffectLowPassFilter":
				s = "LPF"
			if fx.get_class() == "AudioEffectBandPassFilter":
				s = "BPF"
			if fx.get_class() == "AudioEffectReverb":
				s = "Verb"
			if fx.get_class() == "AudioEffectAmplify":
				s = "Amp"
			if fx.get_class() == "AudioEffectCompressor":
				s = "Comp"
			if fx.get_class() == "AudioEffectLimiter":
				s = "Lim"
			if fx.get_class() == "AudioEffectStereoEnhance":
				s = "StEnh"
			
			# Settings
			if "volume_db" in fx:
				s = s + ", vol " + str(snapped(fx.volume_db, 0.01))
			if "resonance" in fx:
				s = s + ", res " + str(snapped(fx.resonance, 0.01))
			if "cutoff_hz" in fx:
				s = s + ", hz " + str(snapped(fx.cutoff_hz, 0.01))
			if "room_size" in fx:
				s = s + ", size " + str(snapped(fx.room_size, 0.01))
			if "wet" in fx:
				s = s + ", wet " + str(snapped(fx.wet, 0.01))
			label.text = s

# Takes a peak in db, and spits out a normalized 0 to 1 value
func normalize_peak(peak_db):
	var p = (peak_db + 200) / 200.0
	return p * p * p * p * p * p

func _hide():
	modulate = Color(1.0, 1.0, 1.0, 0.25)

func _show():
	modulate = Color(1.0, 1.0, 1.0, 0.8)
