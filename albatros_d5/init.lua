

albatros_d5={}

function albatros_d5.register_parts_method(self)
    local pos = self.object:get_pos()

    --[[local fuel_gauge=minetest.add_entity(pos,'albatros_d5:pointer')
    local energy_indicator_angle = albatros_d5.get_gauge_angle(self._energy)
    fuel_gauge:set_attach(self.object,'',albatros_d5_GAUGE_FUEL_POSITION,{x=0,y=0,z=energy_indicator_angle})
    self.fuel_gauge = fuel_gauge

    local power_gauge=minetest.add_entity(pos,'albatros_d5:pointer')
    local power_indicator_angle = albatros_d5.get_gauge_angle(self._power_lever)
    power_gauge:set_attach(self.object,'',albatros_d5_GAUGE_POWER_POSITION,{x=0,y=0,z=power_indicator_angle})
    self.power_gauge = power_gauge

    local climb_gauge=minetest.add_entity(pos,'albatros_d5:pointer')
    local climb_angle = albatros_d5.get_gauge_angle(0)
    climb_gauge:set_attach(self.object,'',albatros_d5_GAUGE_CLIMBER_POSITION,{x=0,y=0,z=climb_angle})
    self.climb_gauge = climb_gauge

    local speed_gauge=minetest.add_entity(pos,'albatros_d5:pointer')
    local speed_angle = albatros_d5.get_gauge_angle(100)
    speed_gauge:set_attach(self.object,'',albatros_d5_GAUGE_SPEED_POSITION,{x=0,y=0,z=speed_angle})
    self.speed_gauge = speed_gauge]]--

    local wheels=minetest.add_entity(pos,'albatros_d5:wheels')
    wheels:set_attach(self.object,'',{x=0,y=0,z=0},{x=0,y=0,z=0})
    self.wheels = wheels
    airutils.add_paintable_part(self, self.wheels)

    local pilot_seat_base=minetest.add_entity(pos,'albatros_d5:seat_base')
    pilot_seat_base:set_attach(self.object,'',{x=0,y=-1.5,z=-8.89039},{x=0,y=0,z=0})
    self.pilot_seat_base = pilot_seat_base

    local stick=minetest.add_entity(pos,'albatros_d5:stick')
    stick:set_attach(self.object,'',self._stick_pos,{x=0,y=0,z=0})
    self.stick = stick

    local altimeter = airutils.plot_altimeter_gauge(self, 500, pos.y, 40, 220)
    local speed = airutils.plot_speed_gauge(self, 500, 0, self._max_speed, 150, 220)
    local fuel = airutils.plot_fuel_gauge(self, 500, self._energy, self._max_fuel, 380, 260)
    --self.initial_properties.textures[19] = "(airutils_brown.png"..altimeter..")"..speed..fuel

    --minetest.chat_send_all(self.initial_properties.textures[19])
    --airutils.paint(self.wheels:get_luaentity(), self._color)
end

function albatros_d5.destroy_parts_method(self)
    if self.wheels then self.wheels:remove() end
    if self.pilot_seat_base then self.pilot_seat_base:remove() end
    if self.stick then self.stick:remove() end
end

function albatros_d5.step_additional_function(self)
    --do not active the bellow code, it is generating memory garbage
    --[[local pos = self.object:get_pos()
    local altimeter = airutils.plot_altimeter_gauge(self, 500, pos.y, 40, 220)
    local speed = airutils.plot_speed_gauge(self, 500, self._indicated_speed, self._max_speed, 150, 220)
    local fuel = airutils.plot_fuel_gauge(self, 500, self._energy, self._max_fuel, 380, 260)
    local panel = "airutils_brown.png"..altimeter..speed..fuel
    local ent = self.object:get_luaentity()
    ent.initial_properties.textures[19] = panel
    self.object:set_properties({textures=self.initial_properties.textures})]]--
end

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
                    "albatros_d5_lower.png", --camuflagem inferior
                    "airutils_black.png", --cabos
                    "airutils_black.png", --assento
                    "airutils_metal.png", --bequilha
                    "albatros_d5_painting_2.png", --ailerons - sup
                    "albatros_d5_painting_2.png", --empenagem
                    "albatros_d5_lower.png", --profundor inferior
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
    hp_max = 80,
    shaded = true,
    show_on_minimap = true,
    springiness = 0.1,
    physics = airutils.physics,
    _max_occupants = 1,
    _max_plane_hp = 80,
    _longit_drag_factor = 0.13*0.13,
    _later_drag_factor = 2.0,
    _wing_angle_of_attack = 2.0,
    _min_speed = 4,
    _max_speed = 10,
    _max_fuel = 10,
    _speed_not_exceed = 16,
    _min_attack_angle = 0.8,
    _max_attack_angle = 90,
    _elevator_auto_estabilize = 100,
    _tail_lift_min_speed = 4,
    _tail_lift_max_speed = 8,
    _max_engine_acc = 8.5,
    _tail_angle = 14,
    _lift = 16,
    _trunk_slots = 2, --the trunk slots
    _rudder_limit = 40.0,
    _elevator_limit = 30.0,
    _pitch_intensity = 0.4,
    _yaw_intensity = 20,
    _stick_pos = {x=0,y=-6,z=-3},
    _elevator_pos = {x=0, y=0.15842, z=-44.153},
    _rudder_pos = {x=0,y=6.76323,z=-38.4982},
    _aileron_r_pos = {x=32.2813,y=10.2,z=-6.01676},
    _aileron_l_pos = {x=-32.2813,y=10.2,z=-6.01676},
    _passenger = nil,
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




