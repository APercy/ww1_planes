
local S = minetest.get_translator(minetest.get_current_modname())
ww1_planes_lib = {}

dofile(minetest.get_modpath("ww1_planes_lib") .. DIR_DELIM .. "bullets.lua")

--
-- helpers and co.
--

--returns 0 for old, 1 for new
function ww1_planes_lib._custom_punch_when_attached(self, player)
    local player_proterties = player:get_properties()
    ww1_planes_lib.spawn_bullet(self, player:get_player_name(), "ww1_planes_lib:bullet1", 150)
end

ww1_planes_lib.register_bullet("ww1_planes_lib:bullet1", "ww1_planes_bullet_ico.png", "ww1_planes_box_texture.png", "Plane bullet")

minetest.register_privilege("WW1_fighter_licence", {
    description = "Gives a fighter licence to the player",
    give_to_singleplayer = true
})

minetest.register_chatcommand("ww1_plane_eject", {
	params = "",
	description = "Ejects from a WW1 plane",
	privs = {interact = true},
	func = function(name, param)
        local colorstring = core.colorize('#ff0000', " >>> you are not inside a WW1 plane")
        local player = minetest.get_player_by_name(name)
        local attached_to = player:get_attach()

		if attached_to ~= nil then
            local seat = attached_to:get_attach()
            if seat ~= nil then
                local entity = seat:get_luaentity()
                if entity then
                    if entity.name == "albatros_d5:albatros_d5" then
                        if entity.driver_name == name then
                            lib_planes.dettachPlayer(entity, player)
                        elseif entity._passenger == name then
                            local passenger = minetest.get_player_by_name(entity._passenger)
                            lib_planes.dettach_pax(entity, passenger)
                        end
                    else
			            minetest.chat_send_player(name,colorstring)
                    end
                end
            end
		else
			minetest.chat_send_player(name,colorstring)
		end
	end
})

--[[minetest.register_chatcommand("ww1_plane_manual", {
	params = "",
	description = "Planes operation manual",
	privs = {interact = true},
	func = function(name, param)
        lib_planes.manual_formspec(name)
	end
})]]--


