dofile(minetest.get_modpath("airutils") .. DIR_DELIM .. "lib_planes" .. DIR_DELIM .. "global_definitions.lua")

--------------
-- Manual --
--------------

function ww1_planes_lib.pilot_formspec(name)
    local basic_form = table.concat({
        "formspec_version[3]",
        "size[6.0,8.0]",
	}, "")

    local player = minetest.get_player_by_name(name)
    local plane_obj = airutils.getPlaneFromPlayer(player)
    if plane_obj == nil then
        return
    end
    local ent = plane_obj:get_luaentity()

    local yaw = "false"
    if ent._yaw_by_mouse then yaw = "true" end

	basic_form = basic_form.."button[1,1.0;4,1;turn_on;Start/Stop Engines]"
	basic_form = basic_form.."button[1,2.1;4,1;hud;Show/Hide Gauges]"
	basic_form = basic_form.."button[1,3.2;4,1;inventory;Show Inventory]"
    basic_form = basic_form.."button[1,4.3;4,1;guns;Reload Guns]"
    basic_form = basic_form.."checkbox[1,5.7;yaw;Control by mouse;"..yaw.."]"
	basic_form = basic_form.."button[1,6.2;4,1;go_out;Go Out!]"

    minetest.show_formspec(name, "ww1_planes_lib:pilot_main", basic_form)
end

minetest.register_on_player_receive_fields(function(player, formname, fields)
	if formname == "ww1_planes_lib:pilot_main" then
        local name = player:get_player_name()
        local plane_obj = airutils.getPlaneFromPlayer(player)
        if plane_obj then
            local ent = plane_obj:get_luaentity()
		    if fields.turn_on then
                airutils.start_engine(ent)
		    end
            if fields.hud then
                if ent._show_hud == true then
                    ent._show_hud = false
                else
                    ent._show_hud = true
                end
            end
		    if fields.go_out then
                local touching_ground, liquid_below = airutils.check_node_below(plane_obj, 1.3)
                local is_on_ground = ent.isinliquid or touching_ground or liquid_below

                if is_on_ground then --or clicker:get_player_control().sneak then
                    if ent._passenger then --any pax?
                        local pax_obj = minetest.get_player_by_name(ent._passenger)
                        airutils.dettach_pax(ent, pax_obj)
                    end
                    ent._instruction_mode = false
                    --[[ sound and animation
                    if ent.sound_handle then
                        minetest.sound_stop(ent.sound_handle)
                        ent.sound_handle = nil
                    end
                    ent.engine:set_animation_frame_speed(0)]]--
                else
                    -- not on ground
                    if ent._passenger then
                        --give the control to the pax
                        ent._autopilot = false
                        airutils.transfer_control(ent, true)
                        ent._command_is_given = true
                        ent._instruction_mode = true
                    end
                end
                airutils.dettachPlayer(ent, player)
		    end
            if fields.guns then
                if ent._vehicle_custom_data then
                    if not ent._vehicle_custom_data._ww1_loaded_bullets then ent._vehicle_custom_data._ww1_loaded_bullets = 0 end
                    local bullets_to_take = 300 - ent._vehicle_custom_data._ww1_loaded_bullets
                    if bullets_to_take > 0 then
                        local stack = ItemStack("ww1_planes_lib:bullet1 " .. bullets_to_take)
                        local inv = airutils.get_inventory(ent)
                        if inv then
                            local taken = inv:remove_item("main", stack)
                            ent._vehicle_custom_data._ww1_loaded_bullets = ent._vehicle_custom_data._ww1_loaded_bullets + taken:get_count()
                            airutils.save_inventory(ent)
                            if taken:get_count() > 0 then
                                minetest.chat_send_player(name, core.colorize('#00ff00', " >>> Guns reloaded."))
                                minetest.sound_play("ww1_planes_gun_reload", {
                                    object = ent.object,
                                    max_hear_distance = 15,
                                    gain = 1.0,
                                    fade = 0.0,
                                    pitch = 1.0,
                                }, true)
                            else
                                minetest.chat_send_player(name, core.colorize('#ff0000', " >>> There is no bullet on plane's inventory to reload."))
                            end
                        else
                            minetest.chat_send_player(name, core.colorize('#ff0000', " >>> The guns reload seems jammed."))
                        end
                    else
                        minetest.chat_send_player(name, core.colorize('#ff0000', " >>> The reload isn't necessary now."))
                    end
                else
                    minetest.chat_send_player(name, core.colorize('#ff0000', " >>> Something wrong happened on guns reload."))
                end
            end
            if fields.inventory then
                if ent._trunk_slots then
                    airutils.show_vehicle_trunk_formspec(ent, player, ent._trunk_slots)
                end
            end
            if fields.yaw then
                if ent._yaw_by_mouse == true then
                    ent._yaw_by_mouse = false
                else
                    ent._yaw_by_mouse = true
                end
            end
        end
        minetest.close_formspec(name, "ww1_planes_lib:pilot_main")
    end
end)
