
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
	bullet_obj:set_yaw(yaw)
	local velocity = vector.multiply(dir, strength)
    velocity = vector.add(velocity, curr_velocity) --sum with the current velocity
	bullet_obj:set_velocity(velocity)
end


function ww1_planes_lib.register_bullet(ent_name, inv_image, bullet_texture, description)
	minetest.register_entity(ent_name, {
		hp_max = 5,
		physical = false,
		collisionbox = {-0.1, -0.1, -0.1, 0.1, 0.1, 0.1},
		visual = "sprite",
		textures = {bullet_texture},
		visual_size = {x = 0.15, y = 0.15},
		old_pos = nil,
		velocity = nil,
		is_liquid = nil,
		shooter_name = "",
		groups = {bullet = 1},

		on_activate = function(self)
			self.object:set_acceleration({x = 0, y = -9.81, z = 0})
		end,

		on_step = function(self, dtime)
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
							damage_groups = {fleshy=8}
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
                        if ent then
                            if ent.hp_max then ent.hp_max = ent.hp_max - 8 end
                        end

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

						if minetest.is_protected(pos, self.shooter_name) then
							return
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
		stack_max = 1000,
	})
end
