import bpy
import os
import time
from ..utils.bake import bake_sound_to_channels

class WAVEFORGE_OT_visualize_selected(bpy.types.Operator):
    bl_idname = "waveforge.visualize_selected"
    bl_label = "Animate Selected with WaveForge"
    bl_options = {'REGISTER', 'UNDO'}

    @classmethod
    def poll(cls, context):
        return context.selected_objects

    def execute(self, context):
        props = context.scene.waveforge_props
        path = bpy.path.abspath(props.path)

        if not os.path.exists(path):
            self.report({'ERROR'}, "Invalid audio path")
            return {'CANCELLED'}

        if not (props.animate_location or props.animate_rotation or props.animate_scale):
            self.report({'ERROR'}, "No transform channels selected.")
            return {'CANCELLED'}

        if not (props.animate_axis_x or props.animate_axis_y or props.animate_axis_z):
            self.report({'ERROR'}, "No axes selected.")
            return {'CANCELLED'}

        objs = sorted(context.selected_objects, key=lambda o: o.name)
        base = (21000 / 10) ** (1 / len(objs))

        l = 1
        h = 10
        for i, obj in enumerate(objs):
            l = h
            h = round(10 * (base ** (i + 1)), 2)

            bake_sound_to_channels(
                obj, context, path, l, h, props.intensity,
                props.animate_location,
                props.animate_rotation,
                props.animate_scale,
                props.animate_axis_x,
                props.animate_axis_y,
                props.animate_axis_z,
                props.additive_mode
            )

        return {'FINISHED'}
