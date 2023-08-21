
function ww1_planes_lib.register_bomb(radius, ent_name, inv_image, bomb_texture, description, bomb_max_stack) 
    local one_step = false
    bomb_max_stack = bomb_max_stack or 99
    minetest.register_entity(ent_name, {   
        initial_properties = {
            physical = true,
            visual = "sprite",
            backface_culling = false,
            visual_size = {x = 1, y = 1, z = 1},
            textures = {bomb_texture},
            collisionbox = {-.5, -.5, -.25, .5, .5, .25},
            pointable = false,
            static_save = false,
        },
        on_step = function(self,var,moveresult)
            local obj = self.object
            obj:set_acceleration({x=0,y=-9.8,z=0})
            if moveresult.collides and moveresult.collisions then
                ww1_planes_lib.explode(obj, radius)
            end
        end
    })
	minetest.register_craftitem(ent_name, {
		description = description,
		inventory_image = inv_image,
		stack_max = bomb_max_stack,
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
                    minetest.remove_node(p)
                end
            end
        end
    end
    if disable_drop_nodes ~= false then
        local radius = radius
        for z = -radius, radius do
            for y = -radius, radius do
                for x = -radius, radius do
                    -- do fancy stuff
                    local r = vector.length(vector.new(x, y, z))
                    if (radius * radius) / (r * r) >= (pr:next(80, 125) / 100) then
                        local p = {x = pos.x + x, y = pos.y + y, z = pos.z + z}
                        minetest.spawn_falling_node(p)
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
    ww1_planes_lib.remove_nodes(pos, radius)
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

function ww1_planes_lib.spawn_bomb(self, player_name, ent_name, strength)
	local pos = self.object:get_pos()
    if not pos then return end
    local rotation = airutils.normalize_rotations(self.object:get_rotation())
    local dir = airutils.rot_to_dir(rotation)
    local yaw = rotation.y
    local curr_velocity = self.object:get_velocity() --we could be flying
	local bomb_obj = nil
	bomb_obj = minetest.add_entity(pos, ent_name)

	if not bomb_obj then
		return
	end
    minetest.sound_play("default_dug_metal.1", {
        object = self.object,
        max_hear_distance = 50,
        gain = 1.0,
        fade = 0.0,
        pitch = 1.0,
    }, true)

	local velocity = vector.multiply(dir, strength)
    velocity = vector.add(velocity, curr_velocity) --sum with the current velocity
	bomb_obj:set_velocity(velocity)
end

