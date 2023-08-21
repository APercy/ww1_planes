
function ww1_planes_lib.spawn_bullet(self, player_name, ent_name, strength)
	local pos = self.object:get_pos()
    if not pos then return end
	pos.y = pos.y + (0 or self._plane_y_offset_for_bullet)
    local rotation = airutils.normalize_rotations(self.object:get_rotation())
    local dir = airutils.rot_to_dir(rotation)
    local yaw = rotation.y
    local curr_velocity = self.object:get_velocity() --we could be flying
	local bullet_obj = nil
	bullet_obj = minetest.add_entity(pos, ent_name)

	if not bullet_obj then
		return
	end
    minetest.sound_play("ww1_planes_gun", {
        object = self.object,
        max_hear_distance = 50,
        gain = 1.0,
        fade = 0.0,
        pitch = 1.0,
    }, true)

	local lua_ent = bullet_obj:get_luaentity()
	lua_ent.shooter_name = player_name
    lua_ent.damage = lua_ent.damage * (math.random(5, 15)/10)
	bullet_obj:set_yaw(yaw)
	local velocity = vector.multiply(dir, strength)
    velocity = vector.add(velocity, curr_velocity) --sum with the current velocity
	bullet_obj:set_velocity(velocity)
end

local function add_hole(moveresult, obj_pos)
    if moveresult == nil then return end
    if minetest.registered_nodes[minetest.get_node(moveresult.collisions[1].node_pos).name]  and
        minetest.registered_nodes[minetest.get_node(moveresult.collisions[1].node_pos).name].tiles and
        minetest.registered_nodes[minetest.get_node(moveresult.collisions[1].node_pos).name].tiles[1]
    then
        local hit_texture = minetest.registered_nodes[minetest.get_node(moveresult.collisions[1].node_pos).name].tiles[1]

        if hit_texture.name ~= nil then
            hit_texture = hit_texture.name
        end

        minetest.add_particle({
            pos = obj_pos,
            velocity = {x=0, y=0, z=0},
          	acceleration = {x=0, y=0, z=0},
            expirationtime = 30,
            size = math.random(10,20)/10,
            collisiondetection = false,
            vertical = false,
            texture = "ww1_planes_bullet_hole.png",
            glow = 0,
        })

        for i=1,math.random(4,8) do
            minetest.add_particle({
                pos = obj_pos,
                velocity = {x=math.random(-3.0,3.0), y=math.random(2.0,5.0), z=math.random(-3.0,3.0)},
              	acceleration = {x=math.random(-3.0,3.0), y=math.random(-10.0,-15.0), z=math.random(-3.0,3.0)},
                expirationtime = 0.5,
                size = math.random(10,20)/10,
                collisiondetection = true,
                vertical = false,
                texture = ""..hit_texture.."^[resize:4x4".."",
                glow = 0,
            })
        end
    end
end

function ww1_planes_lib.register_bullet(ent_name, inv_image, bullet_texture, description, bullet_damage, bullets_max_stack)
    bullets_max_stack = bullets_max_stack or 99
	minetest.register_entity(ent_name, {
		hp_max = 5,
		physical = true,
		collisionbox = {-0.1, -0.1, -0.1, 0.1, 0.1, 0.1},
		visual = "sprite",
		textures = {bullet_texture},
        lastpos = {},
		visual_size = {x = 0.15, y = 0.15},
        collide_with_objects = false,
		old_pos = nil,
		velocity = nil,
		is_liquid = nil,
		shooter_name = "",
        damage = bullet_damage,
		groups = {bullet = 1},
        _total_time = 0,

		on_activate = function(self)
			self.object:set_acceleration({x = 0, y = -9.81, z = 0})
		end,

		on_step = function(self, dtime, moveresult)
            self._total_time = self._total_time + dtime
            if self._total_time > 5 then
                --destroy after 5 seconds
                self.object:remove()
            end

			local pos = self.object:get_pos()
            if not pos then return end
			self.old_pos = self.old_pos or pos
			local velocity = self.object:get_velocity()
			local hit_bullet_sound = "airutils_collision"

			local cast = minetest.raycast(self.old_pos, pos, true, true)
			local thing = cast:next()
			while thing do
				if thing.type == "object" and thing.ref ~= self.object then
                    local is_the_shooter_vehicle = false
                    local ent = thing.ref:get_luaentity()
                    if ent then
                        if ent.driver_name then
                            if ent.driver_name == self.shooter_name then is_the_shooter_vehicle = true end
                        end
                    end
					if (not thing.ref:is_player() or thing.ref:get_player_name() ~= self.shooter_name) and is_the_shooter_vehicle == false then
                        --minetest.chat_send_all("acertou "..thing.ref:get_entity_name())
						thing.ref:punch(self.object, 1.0, {
							full_punch_interval = 0.5,
		                    groupcaps={
			                    choppy={times={[1]=2.10, [2]=0.90, [3]=0.50}, uses=30, maxlevel=3},
		                    },
							damage_groups = {fleshy=self.damage}
						})
						local thing_pos = thing.ref:get_pos()
						if thing_pos then
                            minetest.sound_play(hit_bullet_sound, {
                                object = self.object,
                                max_hear_distance = 50,
                                gain = 1.0,
                                fade = 0.0,
                                pitch = 1.0,
                            }, true)
						end
						self.object:remove()

                        --do damage on my old planes
                        --[[if ent then
                            if ent.hp_max then ent.hp_max = ent.hp_max - self.damage end
                        end]]--

						if minetest.is_protected(pos, self.shooter_name) then
							return
						end

						return
					end
				elseif thing.type == "node" then
					local node_name = minetest.get_node(thing.under).name
                    if not node_name or node_name == nil or node_name == "" or node_name == "ignore" then return end
					local drawtype = minetest.registered_nodes[node_name]["drawtype"]
					if drawtype == 'liquid' then
						if not self.is_liquid then
							self.velocity = velocity
							self.is_liquid = true
							local liquidviscosity = minetest.registered_nodes[node_name]["liquid_viscosity"]
							local drag = 1/(liquidviscosity*3)
							self.object:set_velocity(vector.multiply(velocity, drag))
							self.object:set_acceleration({x = 0, y = -1.0, z = 0})
							--TODO splash here
						end
					elseif self.is_liquid then
						self.is_liquid = false
						if self.velocity then
							self.object:set_velocity(self.velocity)
						end
						self.object:set_acceleration({x = 0, y = -9.81, z = 0})
					end
					if minetest.registered_items[node_name].walkable then
                        minetest.sound_play(hit_bullet_sound, {
                            object = self.object,
                            max_hear_distance = 50,
                            gain = 1.0,
                            fade = 0.0,
                            pitch = 1.0,
                        }, true)
						self.object:remove()

                        --add the hole
                        add_hole(moveresult, pos)

                        --explode TNT
                        local node = minetest.get_node(pos)
                        local node_name = node.name
                        if node_name == "tnt:tnt" then minetest.set_node(pos, {name = "tnt:tnt_burning"}) end

						if minetest.is_protected(pos, self.shooter_name) then
							return
						end

                        local player = minetest.get_player_by_name(self.shooter_name)
                        if player then
                            minetest.node_punch(pos, node, player, {damage_groups={fleshy=20}})--{type = "punch"})
                        end

						--replace node
						--minetest.set_node(pos, {name = "air"})
                        --minetest.add_item(pos,node_name)

						return
					end
				end
				thing = cast:next()
			end
            --TODO set a trail here using the stored old position
			self.old_pos = pos
		end,
	})
	minetest.register_craftitem(ent_name, {
		description = description,
		inventory_image = inv_image,
		stack_max = bullets_max_stack,
	})
end
