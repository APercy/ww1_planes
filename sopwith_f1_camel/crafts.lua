
-- Albatros
minetest.register_craftitem("sopwith_f1_camel:sopwith_f1_camel", {
	description = "Sopwith F1 Camel",
	inventory_image = "sopwith_f1_camel.png",
    liquids_pointable = true,

	on_place = function(itemstack, placer, pointed_thing)
		if pointed_thing.type ~= "node" then
			return
		end
        
        local pointed_pos = pointed_thing.under
        --local node_below = minetest.get_node(pointed_pos).name
        --local nodedef = minetest.registered_nodes[node_below]
        
		pointed_pos.y=pointed_pos.y+2.3
		local albatros_d5_ent = minetest.add_entity(pointed_pos, "sopwith_f1_camel:sopwith_f1_camel")
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


