import bpy
import os
from ..utils.bake import bake_sound_to_rna

class WAVEFORGE_OT_bake_to_rna(bpy.types.Operator):
    bl_idname = "waveforge.bake_to_rna"
    bl_label = "Bake to RNA Path"
    bl_description = "Bake audio to any animatable RNA property"

    def execute(self, context):
        props = context.scene.waveforge_props
        path = bpy.path.abspath(props.path)

        if not props.rna_path:
            self.report({'ERROR'}, "Please provide a data path.")
            return {'CANCELLED'}

        if not os.path.exists(path):
            self.report({'ERROR'}, "Audio file not found.")
            return {'CANCELLED'}

        obj = context.active_object
        if not obj:
            self.report({'ERROR'}, "No active object selected.")
            return {'CANCELLED'}

        bake_sound_to_rna(
            obj=obj,
            context=context,
            rna_path=props.rna_path,
            array_index=props.array_index,
            filepath=path,
            low=10,
            high=21000,
            intensity=props.intensity,
            additive=props.additive_mode
        )

        return {'FINISHED'}
