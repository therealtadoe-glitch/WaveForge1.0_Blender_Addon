# iOS Floating Tab Bar (Godot)

This folder contains a drag-and-drop custom node:

- `IOSFloatingTabBar` (`ios_floating_tab_bar.gd`)

## How to use

1. Copy `ios_floating_tab_bar.gd` into your Godot project.
2. Add a `Control` node in your scene and attach the script, or add it directly from the **Create Node** dialog by searching for `IOSFloatingTabBar`.
3. In the Inspector, edit exported properties:
   - **Tab Content**: `tab_labels`, `tab_icons`, `selected_tab`
   - **Layout**: `bar_width`, `bar_height`, `bottom_offset`, `side_padding`, `item_spacing`, `icon_label_spacing`
   - **Colors**: selected/unselected colors for icons and labels
   - **Bar Styling**: corner radius, border width/color
   - **Shadow**: shadow enable/color/blur/offset
   - **Typography**: label size and uppercase toggle

Connect the `tab_selected(index, label)` signal to react when the user switches tabs.
