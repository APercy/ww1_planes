

albatros_d5={}

function albatros_d5.register_parts_method(self)
    local pos = self.object:get_pos()

    local wheels=minetest.add_entity(pos,'albatros_d5:wheels')
    wheels:set_attach(self.object,'',{x=0,y=0,z=0},{x=0,y=0,z=0})
    self.wheels = wheels
    airutils.add_paintable_part(self, self.wheels)

    local cabin=minetest.add_entity(pos,'ww1_planes_lib:cabin')
    cabin:set_attach(self.object,'',{x=0,y=0,z=0},{x=0,y=0,z=0})
    self.cabin = cabin

    local altimeter = airutils.plot_altimeter_gauge(self, 500, 40, 220)
    local speed = airutils.plot_speed_gauge(self, 500, 150, 220)
    local rpm = airutils.plot_power_gauge(self, 500, 260, 220)
    local fuel = airutils.plot_fuel_gauge(self, 500, 380, 260)
    self.initial_properties.textures[19] = "airutils_brown.png"..altimeter..speed..rpm..fuel

    --set stick position
    self.cabin:set_bone_position("stick", {x=0,y=-3.65,z=-4}, {x=0,y=0,z=0})
    self.cabin:set_bone_position("speed", {x=-0.97,y=4.32,z=-4.05}, {x=0,y=0,z=0})
    self.cabin:set_bone_position("fuel", {x=3.44,y=3.6,z=-4.05}, {x=0,y=0,z=0})
    self.cabin:set_bone_position("altimeter_pt_1", {x=-3.075,y=4.32,z=-4.05}, {x=0,y=0,z=0})
    self.cabin:set_bone_position("altimeter_pt_2", {x=-3.075,y=4.32,z=-4.05}, {x=0,y=0,z=0})
    self.cabin:set_bone_position("power", {x=1.16,y=4.32,z=-4.05}, {x=0,y=0,z=0})
    self.cabin:set_bone_position("climber", {x=0,y=4.32,z=-3}, {x=0,y=0,z=0})
end

function albatros_d5.destroy_parts_method(self)
    if self.wheels then self.wheels:remove() end
    if self.cabin then self.cabin:remove() end
end

function albatros_d5.step_additional_function(self)

    if (self.driver_name==nil) and (self.co_pilot==nil) then --pilot or copilot
        return
    end

    --set stick position
    self.cabin:set_bone_position("stick", {x=0,y=-3.65,z=-4}, {x=self._elevator_angle/2,y=0,z=self._rudder_angle})

    --speed
    local speed_angle = airutils.get_gauge_angle(self._indicated_speed, -45)
    self.cabin:set_bone_position("speed", {x=-0.97,y=4.32,z=-4.05}, {x=0,y=0,z=speed_angle})

    --fuel
    local fuel_percentage = (self._energy*100)/self._max_fuel
    local fuel_angle = -(fuel_percentage*180)/100
    self.cabin:set_bone_position("fuel", {x=3.44,y=3.6,z=-4.05}, {x=0,y=0,z=fuel_angle})

    --altimeter
    local pos = self._curr_pos
    local altitude = (pos.y / 0.32) / 100
    local hour, minutes = math.modf( altitude )
    hour = math.fmod (hour, 10)
    minutes = minutes * 100
    minutes = (minutes * 100) / 100
    local minute_angle = (minutes*-360)/100
    local hour_angle = (hour*-360)/10 + ((minute_angle*36)/360)
    self.cabin:set_bone_position("altimeter_pt_1", {x=-3.075,y=4.32,z=-4.05}, {x=0,y=0,z=hour_angle})
    self.cabin:set_bone_position("altimeter_pt_2", {x=-3.075,y=4.32,z=-4.05}, {x=0,y=0,z=minute_angle})

    local power_indicator_angle = airutils.get_gauge_angle(self._power_lever/6.5)
    self.cabin:set_bone_position("power", {x=1.16,y=4.32,z=-4.05}, {x=0,y=0,z=power_indicator_angle-90})

    self.cabin:set_bone_position("climber", {x=0,y=4.32,z=-3}, {x=0,y=0,z=0})
end

local lower_texture = "(albatros_d5_lower.png^[multiply:#a0def3)^(albatros_d5_lower.png^[mask:albatros_d5_marks.png)"
albatros_d5.plane_properties = {
	initial_properties = {
	    physical = true,
        collide_with_objects = true,
	    collisionbox = {-1.2, -1.60, -1.2, 1.2, 1.2, 1.2}, --{-1,0,-1, 1,0.3,1},
	    selectionbox = {-1.2, -1.28, -1.2, 1.2, 1.2, 1.2},
	    visual = "mesh",
        backface_culling = false,
	    mesh = "albatros_d5_body.b3d",
        stepheight = 0.5,
        textures = {
                    "airutils_black.png", --nacele
                    "albatros_d5_painting_2.png", --asa superior
                    "albatros_d5_painting.png", --asa inferior
                    lower_texture, --camuflagem inferior
                    "airutils_black.png", --cabos
                    "airutils_black.png", --assento
                    "airutils_metal.png", --bequilha
                    "albatros_d5_painting_2.png", --ailerons - sup
                    "albatros_d5_painting_2.png", --empenagem
                    lower_texture, --profundor inferior
                    "albatros_d5_painting_2.png", --cone da cauda
                    "airutils_black.png", --escapamento
                    "albatros_d5_painting_2.png", --estab horizontal
                    "albatros_d5_painting_2.png", --estab vertical
                    "albatros_d5_painting.png", --fuselagem
                    "albatros_d5_propeller.png", --helice
                    "airutils_painting_2.png", --cubo helice
                    "airutils_brown.png", --nacele
                    "airutils_brown.png", --painel
                    "airutils_black.png", --armas
                    "airutils_painting.png", --montantes
                    "airutils_black2.png", --motor
                    "airutils_black.png", --cabecotes
                    "albatros_d5_painting_2.png", --nariz
                    },
    },
    textures = {},
    _anim_frames = 24,
    _unlock_roll = true,
	driver_name = nil,
	sound_handle = nil,
    owner = "",
    static_save = true,
    infotext = "",
    hp_max = 50,
    shaded = true,
    show_on_minimap = true,
    springiness = 0.1,
    buoyancy = 1.02,
    physics = airutils.physics,
    _vehicle_name = "Albatros",
    _needed_licence = ww1_planes_lib.licence_name,
    _use_camera_relocation = true,
    _seats = {{x=0,y=-1.5,z=-8.89039},},
    _seats_rot = {0},  --necessary when using reversed seats
    _have_copilot = false, --wil use the second position of the _seats list
    _max_plane_hp = 50,
    _enable_fire_explosion = true,
    _longit_drag_factor = 0.13*0.13,
    _later_drag_factor = 2.0,
    _wing_angle_of_attack = 2.0,
    _wing_span = 10, --meters
    _min_speed = 4,
    _max_speed = 10,
    _max_fuel = 10,
    _speed_not_exceed = 20,
    _damage_by_wind_speed = 2,
    _hard_damage = true,
    _min_attack_angle = -1.5,
    _max_attack_angle = 90,
    _elevator_auto_estabilize = 100,
    _tail_lift_min_speed = 2,
    _tail_lift_max_speed = 8,
    _max_engine_acc = 8.5,
    _tail_angle = 14, --degrees
    _lift = 16,
    _trunk_slots = 2, --the trunk slots
    _rudder_limit = 40.0,
    _elevator_limit = 30.0,
    _elevator_response_attenuation = 10,
    _pitch_intensity = 0.4,
    _yaw_intensity = 20,
    _yaw_turn_rate = 14,
    _elevator_pos = {x=0, y=0.15842, z=-44.153},
    _rudder_pos = {x=0,y=6.76323,z=-38.4982},
    _aileron_r_pos = {x=32.2813,y=10.2,z=-6.01676},
    _aileron_l_pos = {x=-32.2813,y=10.2,z=-6.01676},
    _color = "#c2914f",
    _color_2 = "#919469",
    _rudder_angle = 0,
    _acceleration = 0,
    _engine_running = false,
    _angle_of_attack = 0,
    _elevator_angle = 0,
    _power_lever = 0,
    _last_applied_power = 0,
    _energy = 1.0,
    _last_vel = {x=0,y=0,z=0},
    _longit_speed = 0,
    _show_hud = false,
    _instruction_mode = false, --flag to intruction mode
    _command_is_given = false, --flag to mark the "owner" of the commands now
    _autopilot = false,
    _auto_pilot_altitude = 0,
    _last_accell = {x=0,y=0,z=0},
    _last_time_command = 1,
    _inv = nil,
    _inv_id = "",
    _collision_sound = "airutils_collision", --the col sound
    _engine_sound = "albatros_d5_engine",
    _painting_texture = {"airutils_painting.png","albatros_d5_painting.png",}, --the texture to paint
    _painting_texture_2 = {"airutils_painting_2.png","albatros_d5_painting_2.png",}, --the texture to paint
    _mask_painting_associations = {["albatros_d5_painting.png"] = "albatros_d5_marks.png",["albatros_d5_lower.png"] = "albatros_d5_marks.png",["albatros_d5_painting_2.png"] = "albatros_d5_marks.png",},
    _register_parts_method = albatros_d5.register_parts_method, --the method to register plane parts
    _destroy_parts_method = albatros_d5.destroy_parts_method,
    _plane_y_offset_for_bullet = 1,
    _custom_punch_when_attached = ww1_planes_lib._custom_punch_when_attached, --the method to execute click action inside the plane
    _custom_pilot_formspec = ww1_planes_lib.pilot_formspec,
    --_custom_pilot_formspec = airutils.pilot_formspec,
    _custom_step_additional_function = albatros_d5.step_additional_function,

    get_staticdata = airutils.get_staticdata,
    on_deactivate = airutils.on_deactivate,
    on_activate = airutils.on_activate,
    logic = airutils.logic,
    on_step = airutils.on_step,
    on_punch = airutils.on_punch,
    on_rightclick = airutils.on_rightclick,
}

dofile(minetest.get_modpath("albatros_d5") .. DIR_DELIM .. "crafts.lua")
dofile(minetest.get_modpath("albatros_d5") .. DIR_DELIM .. "entities.lua")

--
-- items
--

settings = Settings(minetest.get_worldpath() .. "/albatros_d5_settings.conf")
local function fetch_setting(name)
    local sname = name
    return settings and settings:get(sname) or minetest.settings:get(sname)
end




