
function ww1_planes_lib.register_bomb(radius) 
    local one_step = false    
    minetest.register_entity("ww1_planes_lib:bomb_"..radius, {   
        initial_properties = {
            physical = true,
            visual = "sprite",
            backface_culling = false,
            visual_size = {x = 1, y = 1, z = 1},
            textures = {"ww1_planes_lib_bomb.png"},
            collisionbox = {-.5, -.5, -.25, .5, .5, .25},
            pointable = false,
            static_save = false,
        },
        on_step = function(self,var,moveresult)
            local obj = self.object
            obj:set_acceleration({x=0,y=-9.8,z=0})
            if moveresult.collides and moveresult.collisions then
                internal.explode(obj, radius)
            end
        end
    })
end

function ww1_planes_lib.remove_nodes(pos, radius, disable_drop_nodes)
    if not disable_drop_nodes then disable_drop_nodes = true end
    local pr = PseudoRandom(os.time())
    for z = -radius, radius do
        for y = -radius, radius do
            for x = -radius, radius do
                -- do fancy stuff
                local r = vector.length(vector.new(x, y, z))
                if (radius * radius) / (r * r) >= (pr:next(80, 125) / 100) then
                    local p = {x = pos.x + x, y = pos.y + y, z = pos.z + z}
                    if check_immortal(p) == true then
                        return
                    else
                        minetest.remove_node(p)
                    end
                end
            end
        end
    end
    if disable_drop_nodes ~= false then
        local radius = radius+internal.drop_radius_addition
        for z = -radius, radius do
            for y = -radius, radius do
                for x = -radius, radius do
                    -- do fancy stuff
                    local r = vector.length(vector.new(x, y, z))
                    if (radius * radius) / (r * r) >= (pr:next(80, 125) / 100) then
                        local p = {x = pos.x + x, y = pos.y + y, z = pos.z + z}
                        if check_immortal(p) == true then
                            return
                        else
                            minetest.spawn_falling_node(p)
                        end
                    end
                end
            end
        end
    end
end

function ww1_planes_lib.explode(object, radius)
    local pos = object:get_pos()
    airutils.add_destruction_effects(pos, radius, 1)

    local objs = minetest.get_objects_inside_radius(pos, radius)
    -- remove nodes
    internal.remove_nodes(pos, radius)
    --damage entites/players
	for _, obj in pairs(objs) do
		local obj_pos = obj:get_pos()
		local dist = math.max(1, vector.distance(pos, obj_pos))
        local damage = (4 / dist) * radius
        
        if obj:is_player() then
            obj:set_hp(obj:get_hp() - damage)
        else
            local luaobj = obj:get_luaentity()

            -- object might have disappeared somehow
            if luaobj then
				local do_damage = true
				local do_knockback = true
				local entity_drops = {}
				local objdef = minetest.registered_entities[luaobj.name]

				if objdef and objdef.on_blast then
					do_damage, do_knockback, entity_drops = objdef.on_blast(luaobj, damage)
				end

				if do_knockback then
					local obj_vel = obj:get_velocity()
				end
				if do_damage then
                    obj:punch(obj, 1.0, {
                        full_punch_interval = 1.0,
                        damage_groups = {fleshy = damage},
                    }, nil)
				end
				for _, item in pairs(entity_drops) do
					add_drop(drops, item)
				end
			end

        end
    end
    object:remove()
end

function ww1_planes_lib.DropBomb(self, player)
    local s = self.speed_a
    local team = ctf_teams.get(player)
    function drop(color)
        local inventory_item = "ctf_airplane_extras:missile_token"
        local inv = player:get_inventory()
        local weild = player:get_wielded_item()
        
        if check_override(wield) then
            return
        end

        if (os.time()-last_drop >= bomb_dejitter_time and s < internal.speed) then -- to avoid bombs blowing up bombs, and also is a control factor
            last_drop = os.time()
            if inv:contains_item("main", inventory_item) then
                local stack = ItemStack(inventory_item .. " 1")
                inv:remove_item("main", stack)
                if ctf_teams.get(player) == color then
                    minetest.add_entity(player:get_pos(), "ctf_airplane_extras:missile_" .. color)
                else
                    minetest.add_entity(player:get_pos(), "ctf_airplane_extras:missile_blue")
                end
            else
                return
            end
        end
    end
    drop("red")
    drop("orange")
    drop("purple")
    drop("blue")
end
