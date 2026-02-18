# iOS Floating Tab Bar (Godot)

This folder contains a drag-and-drop custom node:

- `IOSFloatingTabBar` (`ios_floating_tab_bar.gd`)

## How to use

1. Copy `ios_floating_tab_bar.gd` into your Godot project.
2. Add `IOSFloatingTabBar` from **Create Node** (or attach the script to a `Control`).
3. Position it normally in your UI (the script no longer forces anchors/offsets).
4. Customize everything from exports in the Inspector:
   - **Tab Content**: `tab_labels`, `tab_icons`, `selected_tab`
   - **Layout**: `bar_width`, `bar_height`, `content_offset`, `side_padding`, `vertical_padding`, `item_spacing`, `icon_label_spacing`
   - **Colors**: selected/unselected colors for icons and labels
   - **Bar Styling**: corner radius, border width/color
   - **Shadow**: shadow enable/color/size/offset
   - **Typography**: label size and uppercase toggle

Connect `tab_selected(index, label)` to update page content when a tab is selected.
