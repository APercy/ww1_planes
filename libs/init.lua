
local S = minetest.get_translator(minetest.get_current_modname())
ww1_planes_lib = {}
ww1_planes_lib.licence_name = "WW1_flight_licence"

dofile(minetest.get_modpath("ww1_planes_lib") .. DIR_DELIM .. "bullets.lua")
dofile(minetest.get_modpath("ww1_planes_lib") .. DIR_DELIM .. "bombs.lua")
dofile(minetest.get_modpath("ww1_planes_lib") .. DIR_DELIM .. "forms.lua") --custom form for the planes

--
-- helpers and co.
--

minetest.register_entity('ww1_planes_lib:cabin',{
initial_properties = {
	physical = false,
	collide_with_objects=false,
	pointable=false,
	visual = "mesh",
	mesh = "ww1_planes_lib_cabin.b3d",
	textures = {"airutils_white.png", "airutils_metal.png", "airutils_black.png", "airutils_red.png", },
	},
	
    on_activate = function(self,std)
	    self.sdata = minetest.deserialize(std) or {}
	    if self.sdata.remove then self.object:remove() end
    end,
	    
    get_staticdata=function(self)
      self.sdata.remove=true
      return minetest.serialize(self.sdata)
    end,
	
})

--returns 0 for old, 1 for new
function ww1_planes_lib._custom_punch_when_attached(self, player)
    local ctrl = player:get_player_control()
    if ctrl.aux1 then
        local inv = airutils.get_inventory(self)
        if not inv then return end

        local total_taken = 0
        local stack = ItemStack("ww1_planes_lib:bomb1 1")
        local taken = inv:remove_item("main", stack)
        local total_taken = taken:get_count()

        if total_taken > 0 then
            airutils.save_inventory(self)
            ww1_planes_lib.spawn_bomb(self, player:get_player_name(), "ww1_planes_lib:bomb1", 1)
        end
    else
        if self._vehicle_custom_data._ww1_loaded_bullets then
            if self._vehicle_custom_data._ww1_loaded_bullets > 0 then
                local total_bullets = self._vehicle_custom_data._ww1_loaded_bullets
                ww1_planes_lib.spawn_bullet(self, player:get_player_name(), "ww1_planes_lib:bullet1", 300)
                self._vehicle_custom_data._ww1_loaded_bullets = total_bullets - 1

                minetest.after(0.1, function()
                    if player then
                        ww1_planes_lib.spawn_bullet(self, player:get_player_name(), "ww1_planes_lib:bullet1", 300)
                        self._vehicle_custom_data._ww1_loaded_bullets = total_bullets - 2
                    end
                end)
            end
        end
    end
end

ww1_planes_lib.register_bullet("ww1_planes_lib:bullet1", "ww1_planes_bullet_ico.png", "ww1_planes_box_texture.png", "Plane bullet", 8, 300)

--ww1_planes_lib.register_bomb(radius, ent_name, inv_image, bomb_texture, description, bomb_max_stack) 
ww1_planes_lib.register_bomb(5, "ww1_planes_lib:bomb1", "ww1_planes_lib_bomb.png", "ww1_planes_lib_bomb.png", "A bomb to drop over the enemy field", 5) 

minetest.register_craft({
	output = "ww1_planes_lib:bullet1 50",
	recipe = {
		{"default:bronze_ingot", "default:bronze_ingot", "default:bronze_ingot"},
		{"default:bronze_ingot", "tnt:gunpowder", "default:bronze_ingot"},
		{"default:bronze_ingot", "tnt:gunpowder", "default:bronze_ingot"},
	}
})

minetest.register_privilege("WW1_flight_licence", {
    description = "Gives a flight licence to the player",
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
                    if entity.name == "albatros_d5:albatros_d5" or entity.name == "sopwith_f1_camel:sopwith_f1_camel" then
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


