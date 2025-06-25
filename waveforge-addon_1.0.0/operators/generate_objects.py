import bpy
import time
import os
from ..utils.bake import bake_sound_to_channels

class WAVEFORGE_OT_generate_visualizer(bpy.types.Operator):
    bl_idname = "waveforge.generate_visualizer"
    bl_label = "Generate WaveForge Visualizer"
    bl_description = "Create and animate audio-reactive objects"
    bl_options = {'REGISTER', 'UNDO'}

    def execute(self, context):
        props = context.scene.waveforge_props
        path = bpy.path.abspath(props.path)

        if not os.path.exists(path):
            self.report({'ERROR'}, f"Audio file not found: {path}")
            return {'CANCELLED'}

        columns = props.columns
        intensity = props.intensity
        mirror = props.mirror_mode
        base = (21000 / 10) ** (1 / columns)

        l = 1
        h = 10

        bpy.ops.screen.frame_jump(end=False)

        for i in range(columns):
            l = h
            h = round(10 * (base ** (i + 1)), 2)

            bpy.ops.mesh.primitive_cube_add(location=(0, i, 0))
            obj = bpy.context.active_object
            if not mirror:
                bpy.context.scene.cursor.location = obj.location
                bpy.context.scene.cursor.location.z -= 1
                bpy.ops.object.origin_set(type='ORIGIN_CURSOR')
                obj.location.z += 1

            obj.scale = (0.4, 0.4, 6.0)
            bpy.ops.object.transform_apply(scale=True)

            bake_sound_to_channels(obj, context, path, l, h, intensity,
                                   False, False, True,
                                   False, False, True)

        bpy.context.scene.cursor.location = (0, 0, 0)
        if bpy.context.active_object:
            bpy.context.active_object.select_set(False)
            bpy.context.view_layer.objects.active = None

        return {'FINISHED'}
