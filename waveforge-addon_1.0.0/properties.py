import bpy

class WaveForgeProperties(bpy.types.PropertyGroup):
    columns: bpy.props.IntProperty(name="Number of Objects", default=20, min=1)
    path: bpy.props.StringProperty(name="Audio File", subtype='FILE_PATH')
    mirror_mode: bpy.props.BoolProperty(name="Mirror Mode", default=False)
    intensity: bpy.props.FloatProperty(name="Audio Intensity", default=1.0, min=0.0, soft_max=20.0)

    animate_location: bpy.props.BoolProperty(name="Location", default=False)
    animate_rotation: bpy.props.BoolProperty(name="Rotation", default=False)
    animate_scale: bpy.props.BoolProperty(name="Scale", default=True)

    animate_axis_x: bpy.props.BoolProperty(name="X", default=False)
    animate_axis_y: bpy.props.BoolProperty(name="Y", default=False)
    animate_axis_z: bpy.props.BoolProperty(name="Z", default=True)

    additive_mode: bpy.props.BoolProperty(name="Additive", default=False)

    # RNA path inputs for custom property animation
    rna_path: bpy.props.StringProperty(
        name="Data Path",
        description="RNA path to the property (e.g. data.shape_keys.key_blocks[\"Key 1\"].value)"
    )
    array_index: bpy.props.IntProperty(
        name="Index",
        description="Index for array properties (0 for most scalar values)",
        default=0,
        min=0
    )

    info_generate: bpy.props.BoolProperty(name="Generate visualizer elements.", default=False)
    info_animate: bpy.props.BoolProperty(name="Apply animation to selected objects.", default=False)
