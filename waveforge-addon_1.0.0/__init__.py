bl_info = {
    "name": "WaveForge",
    "blender": (2, 80, 0),
    "category": "Animation",
    "author": "Your Name",
    "version": (1, 0, 0),
    "description": "Create audio-reactive visuals with full customization",
}

import bpy
from . import properties
from .operators import generate_objects, visualize_selected
from .operators import bake_to_rna
from .panels import main_ui

classes = (
    properties.WaveForgeProperties,
    generate_objects.WAVEFORGE_OT_generate_visualizer,
    visualize_selected.WAVEFORGE_OT_visualize_selected,
    bake_to_rna.WAVEFORGE_OT_bake_to_rna,
    main_ui.WAVEFORGE_PT_main_panel,
)


def register():
    for cls in classes:
        bpy.utils.register_class(cls)
    bpy.types.Scene.waveforge_props = bpy.props.PointerProperty(type=properties.WaveForgeProperties)

def unregister():
    for cls in reversed(classes):
        bpy.utils.unregister_class(cls)
    del bpy.types.Scene.waveforge_props
