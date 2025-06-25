import bpy

def bake_sound_to_channels(obj, context, path, lo, hi, intensity_multiplier,
                           anim_loc, anim_rot, anim_scale,
                           anim_x, anim_y, anim_z,
                           additive_mode=False):
    """
    Bakes sound data to specified transform channels of the given object.
    """

    if not obj.animation_data:
        obj.animation_data_create()
    if not obj.animation_data.action:
        obj.animation_data.action = bpy.data.actions.new(name=f"{obj.name}_WaveForgeAction")

    action = obj.animation_data.action
    fcurves = action.fcurves

    props_to_animate = []
    if anim_loc: props_to_animate.append('location')
    if anim_rot: props_to_animate.append('rotation_euler')
    if anim_scale: props_to_animate.append('scale')

    axes_to_animate = []
    if anim_x: axes_to_animate.append(0)
    if anim_y: axes_to_animate.append(1)
    if anim_z: axes_to_animate.append(2)

    if not props_to_animate or not axes_to_animate:
        return

    # Clear old fcurves unless in additive mode
    if not additive_mode:
        for fc in list(fcurves):
            if fc.data_path in props_to_animate and fc.array_index in axes_to_animate:
                fcurves.remove(fc)

    # Create or find needed fcurves
    fcs_to_bake = []
    for prop in props_to_animate:
        for axis in axes_to_animate:
            fc = fcurves.find(prop, index=axis)
            if not fc:
                obj.keyframe_insert(data_path=prop, index=axis, frame=context.scene.frame_current)
                fc = fcurves.find(prop, index=axis)
            if fc:
                fcs_to_bake.append(fc)

    # Switch to Graph Editor temporarily
    original_area_type = context.area.type
    context.area.type = 'GRAPH_EDITOR'

    try:
        for fc in fcurves:
            fc.select = False
        for fc in fcs_to_bake:
            fc.select = True

        bpy.ops.graph.sound_to_samples(filepath=path, low=lo, high=hi, use_additive=additive_mode)
        bpy.ops.graph.samples_to_keys()

        # Apply multiplier
        for fc in fcs_to_bake:
            if intensity_multiplier != 1.0:
                for kf in fc.keyframe_points:
                    kf.co.y *= intensity_multiplier
                    kf.handle_left.y *= intensity_multiplier
                    kf.handle_right.y *= intensity_multiplier
            fc.select = False
    finally:
        context.area.type = original_area_type
