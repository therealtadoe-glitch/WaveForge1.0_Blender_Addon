import bpy

class WAVEFORGE_PT_main_panel(bpy.types.Panel):
    bl_label = "WaveForge"
    bl_idname = "WAVEFORGE_PT_main_panel"
    bl_space_type = 'GRAPH_EDITOR'
    bl_region_type = 'UI'
    bl_category = "WaveForge"

    def draw(self, context):
        props = context.scene.waveforge_props
        layout = self.layout

        layout.prop(props, "path")
        layout.prop(props, "intensity")
        layout.separator()

        box = layout.box()
        box.label(text="Generate Visualizer")
        box.prop(props, "columns")
        box.prop(props, "mirror_mode")
        box.operator("waveforge.generate_visualizer")

        box = layout.box()
        box.label(text="Animate Selected Objects")
        box.prop(props, "animate_location")
        box.prop(props, "animate_rotation")
        box.prop(props, "animate_scale")

        box.prop(props, "animate_axis_x")
        box.prop(props, "animate_axis_y")
        box.prop(props, "animate_axis_z")
        box.prop(props, "additive_mode")
        box.operator("waveforge.visualize_selected")

        box = layout.box()
        box.label(text="Custom RNA Bake")
        box.prop(props, "rna_path")
        box.prop(props, "array_index")
        box.operator("waveforge.bake_to_rna")
