@tool
extends Control
class_name UpgradeTreeEditor
## Visual node-graph editor for TowerData upgrade trees.
##
## Usage:
## 1. Create a new scene, add a Control node, attach this script.
## 2. Set the Control's Layout to "Full Rect".
## 3. Assign a TowerData resource to the "Tower Data" export in the Inspector.
## 4. Keep the scene open in the editor -- the graph updates live.
##
## Reordering / adding / removing upgrades is done with the buttons on each
## node (dragging new wires is disabled so the graph can never get out of
## sync with the path_a / path_b arrays).

# --- layout ---
const NODE_MIN_WIDTH := 250.0
const NODE_SPACING_X := 310.0
const PATH_A_Y := 20.0
const PATH_B_Y := 540.0
const BASE_Y := 280.0
const ROW_SEPARATION := 6

const FIELD_LABEL_WIDTH := 60.0
const FIELD_TEXT_WIDTH := 138.0
const FIELD_NARROW_TEXT_WIDTH := 66.0
const FIELD_SPIN_WIDTH := 64.0

# NOTE: these are *port* indices, not row/child indices. GraphNode numbers
# connection ports separately per side (left/right) in the order enabled
# slots appear -- not by the row index passed to set_slot(). Each upgrade
# node has exactly one enabled port per side, and the base node has exactly
# two enabled right-side ports, so the values below are 0 / 0 / 0 / 1.
const UPGRADE_IN_SLOT := 0
const UPGRADE_OUT_SLOT := 0
const BASE_PATH_A_SLOT := 0
const BASE_PATH_B_SLOT := 1

# --- palette ---
const CANVAS_BG := Color(0.086, 0.09, 0.106)
const PANEL_BG := Color(0.145, 0.153, 0.176)
const BASE_ACCENT := Color(0.55, 0.58, 0.63)
const PATH_A_ACCENT := Color(0.82, 0.44, 0.32)
const PATH_B_ACCENT := Color(0.30, 0.56, 0.82)
const SAVE_ACCENT := Color(0.35, 0.62, 0.42)
const LABEL_COLOR := Color(0.72, 0.75, 0.82)

@export var tower_data: TowerData:
	set(value):
		tower_data = value
		if is_inside_tree():
			_rebuild()

var _graph: GraphEdit
var _toolbar: HBoxContainer
var _status_label: Label


func _ready() -> void:
	_build_chrome()
	_rebuild()


func _build_chrome() -> void:
	if _graph:
		return
	set_anchors_preset(Control.PRESET_FULL_RECT)

	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.add_theme_constant_override("separation", 0)
	add_child(vbox)

	var toolbar_panel := PanelContainer.new()
	var toolbar_style := StyleBoxFlat.new()
	toolbar_style.bg_color = Color(0.11, 0.115, 0.135)
	toolbar_style.content_margin_left = 10
	toolbar_style.content_margin_right = 10
	toolbar_style.content_margin_top = 6
	toolbar_style.content_margin_bottom = 6
	toolbar_panel.add_theme_stylebox_override("panel", toolbar_style)
	vbox.add_child(toolbar_panel)

	_toolbar = HBoxContainer.new()
	_toolbar.add_theme_constant_override("separation", 8)
	toolbar_panel.add_child(_toolbar)

	var add_a := Button.new()
	add_a.text = "+ Path A Upgrade"
	add_a.pressed.connect(_on_add_upgrade.bind("path_a"))
	_style_button(add_a, PATH_A_ACCENT)
	_toolbar.add_child(add_a)

	var add_b := Button.new()
	add_b.text = "+ Path B Upgrade"
	add_b.pressed.connect(_on_add_upgrade.bind("path_b"))
	_style_button(add_b, PATH_B_ACCENT)
	_toolbar.add_child(add_b)

	var save_btn := Button.new()
	save_btn.text = "Save Resource(s)"
	save_btn.pressed.connect(_on_save)
	_style_button(save_btn, SAVE_ACCENT)
	_toolbar.add_child(save_btn)

	_status_label = Label.new()
	_status_label.add_theme_color_override("font_color", LABEL_COLOR)
	_toolbar.add_child(_status_label)

	_graph = GraphEdit.new()
	_graph.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_graph.right_disconnects = false
	_graph.connection_request.connect(_on_connection_request)
	_graph.add_theme_color_override("grid_major", Color(1, 1, 1, 0.05))
	_graph.add_theme_color_override("grid_minor", Color(1, 1, 1, 0.025))
	var canvas_style := StyleBoxFlat.new()
	canvas_style.bg_color = CANVAS_BG
	_graph.add_theme_stylebox_override("panel", canvas_style)
	vbox.add_child(_graph)


func _on_connection_request(_from: StringName, _from_port: int, _to: StringName, _to_port: int) -> void:
	# Manual rewiring is disabled on purpose: the graph mirrors path_a /
	# path_b array order. Use each node's ▲ / ▼ / ✕ buttons to restructure
	# the tree instead.
	pass


func _rebuild() -> void:
	if not _graph:
		return
	for child in _graph.get_children():
		if child is GraphNode:
			child.queue_free()

	if not tower_data:
		_status_label.text = "  Assign a Tower Data resource to begin."
		return
	_status_label.text = ""

	var base_node := _create_base_node()
	_graph.add_child(base_node)

	_build_path(tower_data.path_a, "path_a", PATH_A_Y, BASE_PATH_A_SLOT)
	_build_path(tower_data.path_b, "path_b", PATH_B_Y, BASE_PATH_B_SLOT)


func _build_path(path: Array, path_key: String, y: float, base_slot: int) -> void:
	var prev_name := "base"
	var prev_slot := base_slot
	for i in path.size():
		var upgrade: UpgradeData = path[i]
		if upgrade == null:
			continue
		var node_name := "%s_%d" % [path_key, i]
		var gn := _create_upgrade_node(upgrade, path_key, i)
		gn.name = node_name
		gn.position_offset = Vector2(NODE_SPACING_X * (i + 1), y)
		_graph.add_child(gn)
		_graph.connect_node(prev_name, prev_slot, node_name, UPGRADE_IN_SLOT)
		prev_name = node_name
		prev_slot = UPGRADE_OUT_SLOT


# ---------------------------------------------------------------- styling --

func _make_panel_style(bg: Color, border: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(1)
	sb.set_corner_radius_all(7)
	sb.set_content_margin_all(9)
	sb.shadow_size = 5
	sb.shadow_color = Color(0, 0, 0, 0.25)
	return sb


func _make_titlebar_style(accent: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = accent
	sb.corner_radius_top_left = 7
	sb.corner_radius_top_right = 7
	sb.set_content_margin_all(6)
	sb.content_margin_left = 10
	return sb


func _style_node(gn: GraphNode, accent: Color) -> void:
	gn.custom_minimum_size = Vector2(NODE_MIN_WIDTH, 0)
	gn.add_theme_constant_override("separation", ROW_SEPARATION)
	gn.add_theme_stylebox_override("panel", _make_panel_style(PANEL_BG, accent.darkened(0.35)))
	gn.add_theme_stylebox_override("panel_selected", _make_panel_style(PANEL_BG.lightened(0.06), accent))
	gn.add_theme_stylebox_override("titlebar", _make_titlebar_style(accent))
	gn.add_theme_stylebox_override("titlebar_selected", _make_titlebar_style(accent.lightened(0.15)))
	gn.add_theme_color_override("title_color", Color(1, 1, 1))
	gn.add_theme_font_size_override("title_font_size", 15)


func _style_button(btn: Button, accent: Color) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = accent.darkened(0.15)
	normal.set_corner_radius_all(4)
	normal.set_content_margin_all(6)
	normal.content_margin_left = 10
	normal.content_margin_right = 10
	var hover := StyleBoxFlat.new()
	hover.bg_color = accent
	hover.set_corner_radius_all(4)
	hover.set_content_margin_all(6)
	hover.content_margin_left = 10
	hover.content_margin_right = 10
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", hover)
	btn.add_theme_color_override("font_color", Color(1, 1, 1))
	btn.add_theme_color_override("font_hover_color", Color(1, 1, 1))


func _style_mini_button(btn: Button, danger: bool = false) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(1, 1, 1, 0.06)
	normal.set_corner_radius_all(4)
	var hover := StyleBoxFlat.new()
	hover.bg_color = Color(1, 1, 1, 0.14) if not danger else Color(0.75, 0.25, 0.22, 0.8)
	hover.set_corner_radius_all(4)
	btn.custom_minimum_size = Vector2(30, 24)
	btn.add_theme_stylebox_override("normal", normal)
	btn.add_theme_stylebox_override("hover", hover)
	btn.add_theme_stylebox_override("pressed", hover)
	btn.add_theme_color_override("font_color", Color(0.85, 0.3, 0.28) if danger else Color(0.85, 0.87, 0.92))


func _separator() -> HSeparator:
	var sep := HSeparator.new()
	var line := StyleBoxFlat.new()
	line.bg_color = Color(1, 1, 1, 0.07)
	line.content_margin_top = 1
	line.content_margin_bottom = 1
	sep.add_theme_stylebox_override("separator", line)
	return sep


# ------------------------------------------------------------------- nodes --

func _create_base_node() -> GraphNode:
	var gn := GraphNode.new()
	gn.name = "base"
	gn.title = tower_data.display_name if tower_data.display_name != "" else "Base Tower"
	gn.position_offset = Vector2(0, BASE_Y)
	_style_node(gn, BASE_ACCENT)

	var name_row := HBoxContainer.new()
	name_row.add_child(_label("Name"))
	var name_edit := LineEdit.new()
	name_edit.text = tower_data.display_name
	name_edit.custom_minimum_size = Vector2(FIELD_TEXT_WIDTH, 0)
	name_edit.text_changed.connect(func(v):
		tower_data.display_name = v
		gn.title = v if v != "" else "Base Tower")
	name_row.add_child(name_edit)
	gn.add_child(name_row)

	gn.add_child(_field_row("Currency", func(): return tower_data.currency_type, func(v): tower_data.currency_type = v, FIELD_NARROW_TEXT_WIDTH))
	gn.add_child(_field_row("A Dir", func(): return tower_data.get("path_a_dir") if "path_a_dir" in tower_data else "", func(v): tower_data.set("path_a_dir", v)))
	gn.add_child(_field_row("B Dir", func(): return tower_data.get("path_b_dir") if "path_b_dir" in tower_data else "", func(v): tower_data.set("path_b_dir", v)))
	gn.add_child(_separator())
	gn.add_child(_int_field_row("Cost", func(): return tower_data.cost, func(v): tower_data.cost = v))
	gn.add_child(_separator())
	gn.add_child(_int_field_row("Damage", func(): return tower_data.damage, func(v): tower_data.damage = v))
	gn.add_child(_int_field_row("Fire Rate", func(): return tower_data.fire_rate, func(v): tower_data.fire_rate = v))
	gn.add_child(_int_field_row("Range", func(): return tower_data.tower_range, func(v): tower_data.tower_range = v))
	gn.add_child(_separator())

	var a_out := HBoxContainer.new()
	var a_label := _label("Path A")
	a_label.add_theme_color_override("font_color", PATH_A_ACCENT)
	a_out.add_child(a_label)
	var a_arrow := Label.new()
	a_arrow.text = "-->"
	a_out.add_child(a_arrow)
	gn.add_child(a_out)

	var b_out := HBoxContainer.new()
	var b_label := _label("Path B")
	b_label.add_theme_color_override("font_color", PATH_B_ACCENT)
	b_out.add_child(b_label)
	var b_arrow := Label.new()
	b_arrow.text = "-->"
	b_out.add_child(b_arrow)
	gn.add_child(b_out)

	# Row (child) index = child order above: 0 name,1 currency,2 A dir,3 B dir,
	# 4 sep,5 cost,6 sep,7 dmg,8 rate,9 range,10 sep,11 pathA,12 pathB
	# set_slot() takes the row index; connect_node() below uses the compacted
	# port index instead (BASE_PATH_A_SLOT / BASE_PATH_B_SLOT = 0 / 1).
	gn.set_slot(11, false, 0, Color.WHITE, true, 0, PATH_A_ACCENT)
	gn.set_slot(12, false, 0, Color.WHITE, true, 0, PATH_B_ACCENT)
	return gn


func _create_upgrade_node(upgrade: UpgradeData, path_key: String, index: int) -> GraphNode:
	var accent := PATH_A_ACCENT if path_key == "path_a" else PATH_B_ACCENT
	var gn := GraphNode.new()
	gn.title = upgrade.upgrade_name if upgrade.upgrade_name != "" else "Upgrade"
	_style_node(gn, accent)

	var name_row := HBoxContainer.new()
	name_row.add_child(_label("Name"))
	var name_edit := LineEdit.new()
	name_edit.text = upgrade.upgrade_name
	name_edit.custom_minimum_size = Vector2(FIELD_TEXT_WIDTH, 0)
	name_edit.text_changed.connect(func(v):
		upgrade.upgrade_name = v
		gn.title = v if v != "" else "Upgrade")
	name_row.add_child(name_edit)
	gn.add_child(name_row)
	gn.add_child(_separator())

	var cost_row := HBoxContainer.new()
	cost_row.add_child(_label("Cost"))
	var cost_spin := SpinBox.new()
	cost_spin.min_value = 0
	cost_spin.max_value = 999999
	cost_spin.step = 1
	cost_spin.custom_minimum_size = Vector2(FIELD_SPIN_WIDTH, 0)
	cost_spin.value = upgrade.cost
	cost_spin.value_changed.connect(func(v): upgrade.cost = int(v))
	cost_row.add_child(cost_spin)
	var cost_type_edit := LineEdit.new()
	cost_type_edit.text = upgrade.cost_type
	cost_type_edit.placeholder_text = "type"
	cost_type_edit.custom_minimum_size = Vector2(FIELD_NARROW_TEXT_WIDTH, 0)
	cost_type_edit.text_changed.connect(func(v): upgrade.cost_type = v)
	cost_row.add_child(cost_type_edit)
	gn.add_child(cost_row)
	gn.add_child(_separator())

	gn.add_child(_stat_pair_row("Range", func(): return upgrade.range_add, func(v): upgrade.range_add = v, func(): return upgrade.range_multi, func(v): upgrade.range_multi = v))
	gn.add_child(_stat_pair_row("Damage", func(): return upgrade.damage_add, func(v): upgrade.damage_add = v, func(): return upgrade.damage_multi, func(v): upgrade.damage_multi = v))
	gn.add_child(_stat_pair_row("Fire Rate", func(): return upgrade.fire_rate_add, func(v): upgrade.fire_rate_add = v, func(): return upgrade.fire_rate_multi, func(v): upgrade.fire_rate_multi = v))
	gn.add_child(_separator())

	var desc_row := HBoxContainer.new()
	desc_row.add_child(_label("Desc"))
	var desc_edit := LineEdit.new()
	desc_edit.text = upgrade.description
	desc_edit.custom_minimum_size = Vector2(FIELD_TEXT_WIDTH, 0)
	desc_edit.text_changed.connect(func(v): upgrade.description = v)
	desc_row.add_child(desc_edit)
	gn.add_child(desc_row)
	gn.add_child(_separator())

	var btn_row := HBoxContainer.new()
	btn_row.add_theme_constant_override("separation", 4)
	btn_row.alignment = BoxContainer.ALIGNMENT_END
	var up_btn := Button.new()
	up_btn.text = "\u25b2"
	up_btn.pressed.connect(_on_move.bind(path_key, index, -1))
	_style_mini_button(up_btn)
	btn_row.add_child(up_btn)
	var down_btn := Button.new()
	down_btn.text = "\u25bc"
	down_btn.pressed.connect(_on_move.bind(path_key, index, 1))
	_style_mini_button(down_btn)
	btn_row.add_child(down_btn)
	var del_btn := Button.new()
	del_btn.text = "\u2715"
	del_btn.pressed.connect(_on_remove.bind(path_key, index))
	_style_mini_button(del_btn, true)
	btn_row.add_child(del_btn)
	gn.add_child(btn_row)

	# Row (child) index = child order above: 0 name,1 sep,2 cost,3 sep,4 range,5 dmg,6 rate,7 sep,8 desc,9 sep,10 buttons
	# set_slot() takes the row index; connect_node() uses the compacted port
	# index instead (UPGRADE_IN_SLOT / UPGRADE_OUT_SLOT = 0 / 0, one per side).
	gn.set_slot(0, true, 0, accent, false, 0, Color.WHITE)
	gn.set_slot(10, false, 0, Color.WHITE, true, 0, accent)
	return gn


# ------------------------------------------------------------------- rows --

func _stat_pair_row(label_text: String, add_get: Callable, add_set: Callable, multi_get: Callable, multi_set: Callable) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_child(_label(label_text))
	var add_spin := SpinBox.new()
	add_spin.min_value = -99999
	add_spin.max_value = 99999
	add_spin.step = 0.1
	add_spin.custom_minimum_size = Vector2(FIELD_SPIN_WIDTH, 0)
	add_spin.value = add_get.call()
	add_spin.value_changed.connect(func(v): add_set.call(v))
	row.add_child(add_spin)
	var x_label := Label.new()
	x_label.text = "x"
	x_label.add_theme_color_override("font_color", LABEL_COLOR)
	row.add_child(x_label)
	var multi_spin := SpinBox.new()
	multi_spin.min_value = -99999
	multi_spin.max_value = 99999
	multi_spin.step = 0.05
	multi_spin.custom_minimum_size = Vector2(FIELD_SPIN_WIDTH, 0)
	multi_spin.value = multi_get.call()
	multi_spin.value_changed.connect(func(v): multi_set.call(v))
	row.add_child(multi_spin)
	return row


func _field_row(label_text: String, getter: Callable, setter: Callable, width: float = FIELD_TEXT_WIDTH) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_child(_label(label_text))
	var edit := LineEdit.new()
	edit.text = str(getter.call())
	edit.custom_minimum_size = Vector2(width, 0)
	edit.text_changed.connect(func(v): setter.call(v))
	row.add_child(edit)
	return row


func _int_field_row(label_text: String, getter: Callable, setter: Callable) -> HBoxContainer:
	var row := HBoxContainer.new()
	row.add_child(_label(label_text))
	var spin := SpinBox.new()
	spin.min_value = -999999
	spin.max_value = 999999
	spin.step = 1
	spin.custom_minimum_size = Vector2(FIELD_SPIN_WIDTH, 0)
	spin.value = getter.call()
	spin.value_changed.connect(func(v): setter.call(int(v)))
	row.add_child(spin)
	return row


func _label(text: String) -> Label:
	var l := Label.new()
	l.text = text
	l.custom_minimum_size = Vector2(FIELD_LABEL_WIDTH, 0)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	l.add_theme_color_override("font_color", LABEL_COLOR)
	return l


# ---------------------------------------------------------------- actions --

func _on_add_upgrade(path_key: String) -> void:
	if not tower_data:
		return
	var arr: Array = tower_data.get(path_key)
	var new_upgrade := UpgradeData.new()
	new_upgrade.upgrade_name = "New Upgrade"

	var dir_key := path_key + "_dir"
	var dir: String = tower_data.get(dir_key) if dir_key in tower_data else ""
	if dir != "":
		dir = dir.rstrip("/")
		if not DirAccess.dir_exists_absolute(dir):
			DirAccess.make_dir_recursive_absolute(dir)
		var file_path := _unique_upgrade_path(dir)
		new_upgrade.take_over_path(file_path)
		var err := ResourceSaver.save(new_upgrade, file_path)
		if err != OK:
			_status_label.text = "  Failed to save new upgrade (error %d)." % err

	arr.append(new_upgrade)
	tower_data.emit_changed()
	_rebuild()


func _unique_upgrade_path(dir: String) -> String:
	var index := 0
	var path := "%s/upgrade_%03d.tres" % [dir, index]
	while ResourceLoader.exists(path):
		index += 1
		path = "%s/upgrade_%03d.tres" % [dir, index]
	return path


func _on_move(path_key: String, index: int, direction: int) -> void:
	if not tower_data:
		return
	var arr: Array = tower_data.get(path_key)
	var new_index := index + direction
	if new_index < 0 or new_index >= arr.size():
		return
	var tmp = arr[index]
	arr[index] = arr[new_index]
	arr[new_index] = tmp
	tower_data.emit_changed()
	_rebuild()


func _on_remove(path_key: String, index: int) -> void:
	if not tower_data:
		return
	var arr: Array = tower_data.get(path_key)
	if index >= 0 and index < arr.size():
		arr.remove_at(index)
	tower_data.emit_changed()
	_rebuild()


func _on_save() -> void:
	if not tower_data:
		return
	var saved := 0
	if tower_data.resource_path != "":
		ResourceSaver.save(tower_data, tower_data.resource_path)
		saved += 1
	for arr in [tower_data.path_a, tower_data.path_b]:
		for u in arr:
			if u and u.resource_path != "":
				ResourceSaver.save(u, u.resource_path)
				saved += 1
	_status_label.text = "  Saved %d resource(s)." % saved
