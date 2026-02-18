@tool
extends Control
class_name IOSFloatingTabBar

signal tab_selected(index: int, label: String)

@export_group("Tab Content")
@export var tab_labels: PackedStringArray = ["Home", "Search", "Profile"]:
	set(value):
		tab_labels = value
		_rebuild_tabs()

@export var tab_icons: Array[Texture2D] = []:
	set(value):
		tab_icons = value
		_rebuild_tabs()

@export var selected_tab: int = 0:
	set(value):
		selected_tab = clampi(value, 0, max(tab_labels.size() - 1, 0))
		_update_visual_state()

@export_group("Layout")
@export var bar_width: float = 340.0:
	set(value):
		bar_width = maxf(value, 120.0)
		_refresh_layout()

@export var bar_height: float = 72.0:
	set(value):
		bar_height = maxf(value, 44.0)
		_refresh_layout()

@export var content_offset: Vector2 = Vector2.ZERO:
	set(value):
		content_offset = value
		_refresh_layout()

@export var side_padding: float = 18.0:
	set(value):
		side_padding = maxf(value, 0.0)
		_refresh_layout()

@export var vertical_padding: float = 8.0:
	set(value):
		vertical_padding = maxf(value, 0.0)
		_refresh_layout()

@export var item_spacing: float = 20.0:
	set(value):
		item_spacing = maxf(value, 0.0)
		_refresh_layout()

@export var icon_label_spacing: float = 6.0:
	set(value):
		icon_label_spacing = maxf(value, 0.0)
		_rebuild_tabs()

@export_group("Colors")
@export var bar_color: Color = Color(1, 1, 1, 0.95):
	set(value):
		bar_color = value
		queue_redraw()

@export var selected_icon_color: Color = Color(0.0, 0.48, 1.0, 1.0):
	set(value):
		selected_icon_color = value
		_update_visual_state()

@export var unselected_icon_color: Color = Color(0.56, 0.56, 0.58, 1.0):
	set(value):
		unselected_icon_color = value
		_update_visual_state()

@export var selected_label_color: Color = Color(0.0, 0.48, 1.0, 1.0):
	set(value):
		selected_label_color = value
		_update_visual_state()

@export var unselected_label_color: Color = Color(0.44, 0.44, 0.46, 1.0):
	set(value):
		unselected_label_color = value
		_update_visual_state()

@export_group("Bar Styling")
@export var corner_radius: float = 30.0:
	set(value):
		corner_radius = maxf(value, 0.0)
		queue_redraw()

@export var border_width: float = 1.0:
	set(value):
		border_width = maxf(value, 0.0)
		queue_redraw()

@export var border_color: Color = Color(0.85, 0.85, 0.88, 0.8):
	set(value):
		border_color = value
		queue_redraw()

@export_group("Shadow")
@export var shadow_enabled: bool = true:
	set(value):
		shadow_enabled = value
		queue_redraw()

@export var shadow_color: Color = Color(0, 0, 0, 0.18):
	set(value):
		shadow_color = value
		queue_redraw()

@export var shadow_size: Vector2 = Vector2(20, 14):
	set(value):
		shadow_size = Vector2(maxf(value.x, 0.0), maxf(value.y, 0.0))
		queue_redraw()

@export var shadow_offset: Vector2 = Vector2(0, 8):
	set(value):
		shadow_offset = value
		queue_redraw()

@export_group("Typography")
@export var label_font_size: int = 12:
	set(value):
		label_font_size = maxi(value, 8)
		_update_visual_state()

@export var label_uppercase: bool = false:
	set(value):
		label_uppercase = value
		_update_visual_state()

var _button_root: HBoxContainer
var _buttons: Array[Button] = []
var _icon_nodes: Array[TextureRect] = []
var _label_nodes: Array[Label] = []

func _ready() -> void:
	mouse_filter = MOUSE_FILTER_PASS
	_ensure_ui()
	_refresh_layout()
	_rebuild_tabs()

func _notification(what: int) -> void:
	if what == NOTIFICATION_RESIZED:
		_refresh_layout()

func _ensure_ui() -> void:
	if _button_root and is_instance_valid(_button_root):
		return

	_button_root = HBoxContainer.new()
	_button_root.name = "TabButtons"
	_button_root.alignment = BoxContainer.ALIGNMENT_CENTER
	_button_root.mouse_filter = MOUSE_FILTER_PASS
	_button_root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(_button_root)

func _refresh_layout() -> void:
	if not is_inside_tree():
		return
	_ensure_ui()

	custom_minimum_size = Vector2(bar_width, bar_height)
	size = Vector2(maxf(size.x, bar_width), maxf(size.y, bar_height))

	var bar_rect := _get_bar_rect()
	_button_root.offset_left = bar_rect.position.x + side_padding
	_button_root.offset_top = bar_rect.position.y + vertical_padding
	_button_root.offset_right = -(size.x - bar_rect.end.x + side_padding)
	_button_root.offset_bottom = -(size.y - bar_rect.end.y + vertical_padding)
	_button_root.add_theme_constant_override("separation", int(item_spacing))

	queue_redraw()

func _rebuild_tabs() -> void:
	if not is_inside_tree():
		return
	_ensure_ui()

	for child in _button_root.get_children():
		child.queue_free()

	_buttons.clear()
	_icon_nodes.clear()
	_label_nodes.clear()

	if tab_labels.is_empty():
		tab_labels = ["Tab"]

	for i in tab_labels.size():
		var button := Button.new()
		button.flat = true
		button.focus_mode = Control.FOCUS_NONE
		button.toggle_mode = true
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.size_flags_vertical = Control.SIZE_EXPAND_FILL
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.mouse_filter = MOUSE_FILTER_STOP
		button.custom_minimum_size = Vector2(60, 0)
		button.pressed.connect(_on_tab_pressed.bind(i))
		button.add_theme_stylebox_override("normal", StyleBoxEmpty.new())
		button.add_theme_stylebox_override("hover", StyleBoxEmpty.new())
		button.add_theme_stylebox_override("pressed", StyleBoxEmpty.new())
		button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())

		var content := VBoxContainer.new()
		content.alignment = BoxContainer.ALIGNMENT_CENTER
		content.mouse_filter = MOUSE_FILTER_IGNORE
		content.set_anchors_preset(Control.PRESET_FULL_RECT)
		content.add_theme_constant_override("separation", int(icon_label_spacing))

		var icon := TextureRect.new()
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.custom_minimum_size = Vector2(24, 24)
		icon.texture = tab_icons[i] if i < tab_icons.size() else null
		icon.mouse_filter = MOUSE_FILTER_IGNORE
		icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER

		var label := Label.new()
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.mouse_filter = MOUSE_FILTER_IGNORE

		content.add_child(icon)
		content.add_child(label)
		button.add_child(content)
		_button_root.add_child(button)

		_buttons.append(button)
		_icon_nodes.append(icon)
		_label_nodes.append(label)

	selected_tab = clampi(selected_tab, 0, max(tab_labels.size() - 1, 0))
	_update_visual_state()

func _update_visual_state() -> void:
	if _buttons.is_empty():
		return

	for i in _buttons.size():
		var is_selected := i == selected_tab
		var label_text := tab_labels[i] if i < tab_labels.size() else "Tab %s" % str(i + 1)
		if label_uppercase:
			label_text = label_text.to_upper()

		_buttons[i].button_pressed = is_selected
		_icon_nodes[i].modulate = selected_icon_color if is_selected else unselected_icon_color
		_label_nodes[i].text = label_text
		_label_nodes[i].add_theme_font_size_override("font_size", label_font_size)
		_label_nodes[i].add_theme_color_override("font_color", selected_label_color if is_selected else unselected_label_color)

func _on_tab_pressed(index: int) -> void:
	if index == selected_tab:
		return
	selected_tab = index
	_update_visual_state()
	tab_selected.emit(index, tab_labels[index] if index < tab_labels.size() else "")

func _draw() -> void:
	var bar_rect := _get_bar_rect()

	if shadow_enabled:
		var shadow_rect := Rect2(
			bar_rect.position + shadow_offset - shadow_size * 0.5,
			bar_rect.size + shadow_size
		)
		draw_rect(shadow_rect, shadow_color, true)

	var style := StyleBoxFlat.new()
	style.bg_color = bar_color
	style.corner_radius_top_left = int(corner_radius)
	style.corner_radius_top_right = int(corner_radius)
	style.corner_radius_bottom_left = int(corner_radius)
	style.corner_radius_bottom_right = int(corner_radius)
	style.border_color = border_color
	style.border_width_left = int(border_width)
	style.border_width_top = int(border_width)
	style.border_width_right = int(border_width)
	style.border_width_bottom = int(border_width)
	draw_style_box(style, bar_rect)

func _get_bar_rect() -> Rect2:
	var bar_pos := (size - Vector2(bar_width, bar_height)) * 0.5 + content_offset
	return Rect2(bar_pos, Vector2(bar_width, bar_height))
