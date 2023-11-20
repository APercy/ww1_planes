
--
-- entity
--

albatros_d5.vector_up = vector.new(0, 1, 0)

minetest.register_entity('albatros_d5:wheels',{
initial_properties = {
	physical = false,
	collide_with_objects=false,
	pointable=false,
	visual = "mesh",
    backface_culling = false,
	mesh = "albatros_d5_wheels.b3d",
	textures = {
        "airutils_metal.png",
        "airutils_painting.png", --montantes
        "airutils_painting.png", --calota
        "airutils_metal.png",
        "airutils_black.png",
        },
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

minetest.register_entity("albatros_d5:albatros_d5", 
    airutils.properties_copy(albatros_d5.plane_properties)
)

minetest.register_entity('albatros_d5:destroyed',{
initial_properties = {
	physical = true,
	collide_with_objects=true,
	pointable=true,
	visual = "mesh",
    backface_culling = false,
    collisionbox = {-1.2, -0.65, -1.2, 1.2, 1.2, 1.2}, 
	mesh = "albatros_d5_dstr.b3d",
	textures = {
        "airutils_black.png", --nacele
        "albatros_d5_destroyed.png", --asas e empenagem
        "albatros_d5_destroyed.png", --sup controle
        "albatros_d5_destroyed.png", --cone da cauda
        "albatros_d5_destroyed.png", --estab vert
        "albatros_d5_destroyed.png", --fuselagem
        "albatros_d5_propeller.png", --helice
        "airutils_black.png", --cone helice
        "airutils_black.png", --armas
        "airutils_black.png", --montantes
        "airutils_black.png", --motor
        "albatros_d5_destroyed.png", --nariz
        },
	},
    owner = "",
    _inv_id = "",
    _inv = nil,
    _trunk_slots = 0,
    _game_time = 0,
    _elevator_pos = {x=0, y=0.15842, z=-44.153},
    _drops = {["default:steel_ingot"]=5,["default:diamond"]=1},
	
    on_activate = airutils.destroyed_on_activate,
	    
    get_staticdata=airutils.destroyed_save_static_data,

    on_rightclick = airutils.destroyed_open_inventory,	

    on_punch = airutils.destroyed_on_punch,

})
