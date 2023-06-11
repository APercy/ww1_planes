
-- wing
minetest.register_craftitem("albatros_d5:wings",{
	description = "Albatros wings",
	inventory_image = "albatros_d5_wings.png",
})
-- fuselage
minetest.register_craftitem("albatros_d5:fuselage",{
	description = "Albatros fuselage",
	inventory_image = "albatros_d5_fuselage.png",
})

-- Albatros
minetest.register_craftitem("albatros_d5:albatros_d5", {
	description = "Albatros D5",
	inventory_image = "albatros_d5.png",
    liquids_pointable = true,

	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
        
        local pointed_pos = pointed_thing.under
        --local node_below = minetest.get_node(pointed_pos).name
        --local nodedef = minetest.registered_nodes[node_below]
        
		pointed_pos.y=pointed_pos.y+2.5
		local albatros_d5_ent = minetest.add_entity(pointed_pos, "albatros_d5:albatros_d5")
		if albatros_d5_ent and placer then
            local ent = albatros_d5_ent:get_luaentity()
            if ent then
                local owner = placer:get_player_name()
                ent.owner = owner
			    albatros_d5_ent:set_yaw(placer:get_look_horizontal())
			    itemstack:take_item()
                airutils.create_inventory(ent, ent._trunk_slots, owner)
            end
		end

		return itemstack
	end,
})

--
-- crafting
--

if minetest.get_modpath("default") then
    --[[minetest.register_craft({
	    output = "albatros_d5:wings",
	    recipe = {
		    {"wool:white", "farming:string", "wool:white"},
		    {"group:wood", "group:wood", "group:wood"},
		    {"wool:white", "default:steel_ingot", "wool:white"},
	    }
    })
    minetest.register_craft({
	    output = "albatros_d5:fuselage",
	    recipe = {
		    {"default:steel_ingot", "default:diamondblock", "default:steel_ingot"},
		    {"wool:white", "default:steel_ingot",  "wool:white"},
		    {"default:steel_ingot", "default:mese_block",   "default:steel_ingot"},
	    }
    })

	minetest.register_craft({
		output = "albatros_d5:albatros_d5",
		recipe = {
			{"albatros_d5:wings",},
			{"albatros_d5:fuselage",},
		}
	})]]--
end