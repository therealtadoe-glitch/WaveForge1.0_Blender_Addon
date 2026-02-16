extends Control

# Attach this script to an empty Control node in a Godot 4 scene.
# It procedurally creates an iOS-style tab bar and content pages.

const TAB_DEFINITIONS := [
	{"title": "Home", "icon": "⌂"},
	{"title": "Search", "icon": "⌕"},
	{"title": "Library", "icon": "☰"},
	{"title": "Profile", "icon": "◉"}
]

const ACTIVE_COLOR := Color(0.04, 0.47, 0.95)
const INACTIVE_COLOR := Color(0.53, 0.55, 0.60)

var _content_root: MarginContainer
var _tab_buttons: Array[Button] = []
var _pages: Array[Control] = []
var _current_tab := 0


func _ready() -> void:
	name = "IOSStyledTabBarDemo"
	set_anchors_preset(Control.PRESET_FULL_RECT)
	_build_ui()
	_select_tab(0)


func _build_ui() -> void:
	# Safe area padding + bottom spacing to keep content clear of the tab bar.
	var outer_margin := MarginContainer.new()
	outer_margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	outer_margin.add_theme_constant_override("margin_left", 16)
	outer_margin.add_theme_constant_override("margin_top", 16)
	outer_margin.add_theme_constant_override("margin_right", 16)
	outer_margin.add_theme_constant_override("margin_bottom", 26)
	add_child(outer_margin)

	var main := VBoxContainer.new()
	main.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	main.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main.add_theme_constant_override("separation", 14)
	outer_margin.add_child(main)

	# Top content container (changes with selected tab).
	_content_root = MarginContainer.new()
	_content_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_content_root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_content_root.add_theme_constant_override("margin_bottom", 10)
	main.add_child(_content_root)

	for i in TAB_DEFINITIONS.size():
		var page := _build_page(i)
		page.visible = false
		_content_root.add_child(page)
		_pages.append(page)

	# iOS-like floating/translucent tab bar container.
	var tab_shell := PanelContainer.new()
	tab_shell.custom_minimum_size = Vector2(0, 76)
	tab_shell.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tab_shell.size_flags_vertical = Control.SIZE_SHRINK_END
	tab_shell.add_theme_stylebox_override("panel", _make_tab_shell_style())
	main.add_child(tab_shell)

	var tab_margin := MarginContainer.new()
	tab_margin.add_theme_constant_override("margin_left", 8)
	tab_margin.add_theme_constant_override("margin_top", 8)
	tab_margin.add_theme_constant_override("margin_right", 8)
	tab_margin.add_theme_constant_override("margin_bottom", 8)
	tab_shell.add_child(tab_margin)

	var tabs_row := HBoxContainer.new()
	tabs_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	tabs_row.alignment = BoxContainer.ALIGNMENT_CENTER
	tabs_row.add_theme_constant_override("separation", 6)
	tab_margin.add_child(tabs_row)

	for i in TAB_DEFINITIONS.size():
		var tab_data: Dictionary = TAB_DEFINITIONS[i]
		var tab_button := _build_tab_button(tab_data["icon"], tab_data["title"], i)
		tabs_row.add_child(tab_button)
		_tab_buttons.append(tab_button)


func _build_page(index: int) -> Control:
	var tab_data: Dictionary = TAB_DEFINITIONS[index]

	var page := PanelContainer.new()
	page.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	page.size_flags_vertical = Control.SIZE_EXPAND_FILL
	page.add_theme_stylebox_override("panel", _make_page_style())

	var page_margin := MarginContainer.new()
	page_margin.add_theme_constant_override("margin_left", 28)
	page_margin.add_theme_constant_override("margin_top", 28)
	page_margin.add_theme_constant_override("margin_right", 28)
	page_margin.add_theme_constant_override("margin_bottom", 28)
	page.add_child(page_margin)

	var stack := VBoxContainer.new()
	stack.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stack.size_flags_vertical = Control.SIZE_EXPAND_FILL
	stack.alignment = BoxContainer.ALIGNMENT_CENTER
	stack.add_theme_constant_override("separation", 10)
	page_margin.add_child(stack)

	var icon_label := Label.new()
	icon_label.text = str(tab_data["icon"])
	icon_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	icon_label.add_theme_font_size_override("font_size", 56)
	stack.add_child(icon_label)

	var title_label := Label.new()
	title_label.text = "%s Tab" % tab_data["title"]
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.add_theme_font_size_override("font_size", 32)
	title_label.add_theme_color_override("font_color", Color(0.14, 0.15, 0.20))
	stack.add_child(title_label)

	var subtitle := Label.new()
	subtitle.text = "Procedurally generated iOS-style tab interface"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 17)
	subtitle.add_theme_color_override("font_color", Color(0.41, 0.44, 0.52))
	stack.add_child(subtitle)

	return page


func _build_tab_button(icon: String, title: String, index: int) -> Button:
	var button := Button.new()
	button.text = "%s\n%s" % [icon, title]
	button.clip_text = true
	button.custom_minimum_size = Vector2(70, 56)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	button.size_flags_vertical = Control.SIZE_EXPAND_FILL
	button.flat = true
	button.alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	button.add_theme_font_size_override("font_size", 14)
	button.add_theme_color_override("font_hover_color", ACTIVE_COLOR)
	button.add_theme_color_override("font_pressed_color", ACTIVE_COLOR)
	button.add_theme_stylebox_override("normal", _make_button_style(false))
	button.add_theme_stylebox_override("hover", _make_button_style(true))
	button.add_theme_stylebox_override("pressed", _make_button_style(true))
	button.add_theme_stylebox_override("focus", _make_button_style(true))
	button.pressed.connect(_on_tab_pressed.bind(index))
	return button


func _select_tab(index: int) -> void:
	_current_tab = clamp(index, 0, TAB_DEFINITIONS.size() - 1)

	for i in _pages.size():
		_pages[i].visible = i == _current_tab

	for i in _tab_buttons.size():
		var is_active := i == _current_tab
		var button := _tab_buttons[i]
		button.modulate = Color.WHITE
		button.add_theme_color_override("font_color", ACTIVE_COLOR if is_active else INACTIVE_COLOR)
		button.add_theme_stylebox_override("normal", _make_button_style(is_active))


func _on_tab_pressed(index: int) -> void:
	_select_tab(index)


func _make_page_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1.0, 1.0, 1.0, 0.92)
	style.corner_radius_top_left = 28
	style.corner_radius_top_right = 28
	style.corner_radius_bottom_left = 28
	style.corner_radius_bottom_right = 28
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.08)
	style.shadow_size = 12
	style.content_margin_left = 0
	style.content_margin_top = 0
	style.content_margin_right = 0
	style.content_margin_bottom = 0
	return style


func _make_tab_shell_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.95, 0.96, 0.98, 0.90)
	style.border_width_top = 1
	style.border_width_bottom = 1
	style.border_width_left = 1
	style.border_width_right = 1
	style.border_color = Color(1.0, 1.0, 1.0, 0.72)
	style.corner_radius_top_left = 22
	style.corner_radius_top_right = 22
	style.corner_radius_bottom_left = 22
	style.corner_radius_bottom_right = 22
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.15)
	style.shadow_size = 16
	return style


func _make_button_style(active: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	style.bg_color = Color(0.85, 0.91, 1.0, 0.9) if active else Color(0.0, 0.0, 0.0, 0.0)
	return style
