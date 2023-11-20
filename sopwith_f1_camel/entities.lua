
--
-- entity
--

sopwith_camel.vector_up = vector.new(0, 1, 0)

minetest.register_entity('sopwith_f1_camel:wheels',{
initial_properties = {
	physical = false,
	collide_with_objects=false,
	pointable=false,
	visual = "mesh",
    backface_culling = false,
	mesh = "sopwith_f1_camel_wheels.b3d",
	textures = {
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

minetest.register_entity("sopwith_f1_camel:sopwith_f1_camel", 
    airutils.properties_copy(sopwith_camel.plane_properties)
)

minetest.register_entity('sopwith_f1_camel:destroyed',{
initial_properties = {
	physical = true,
	collide_with_objects=true,
	pointable=true,
	visual = "mesh",
    backface_culling = false,
    collisionbox = {-1.2, -0.65, -1.2, 1.2, 1.2, 1.2}, 
	mesh = "sopwith_f1_camel_dstr.b3d",
	textures = {
        "airutils_black.png", --nacele
        "sopwith_f1_camel_dstr.png", --asas
        "sopwith_f1_camel_dstr.png", --asas embaixo
        "airutils_burned_metal.png", --nariz
        "airutils_burned_metal.png", --nariz
        "airutils_black.png", --parede de fogo
        "sopwith_f1_camel_dstr.png", --empenagem
        "sopwith_f1_camel_dstr.png", --estab hor
        "sopwith_f1_camel_dstr.png", --estab vert
        "sopwith_f1_camel_dstr.png", --fuselagem traseira
        "sopwith_f1_camel_dstr.png", --fuselaqgem posterior
        "sopwith_f1_propeller.png", --helice
        "airutils_black.png", --cubo helice
        "sopwith_f1_camel_radial_cilinder.png", -- motor pt 1
        "sopwith_f1_camel_radial_cilinder_2.png", -- motor pt 2
        "airutils_black.png", --armas
        "airutils_black.png", --montantes
        },
	},
    owner = "",
    _inv_id = "",
    _inv = nil,
    _trunk_slots = 0,
    _game_time = 0,
    _elevator_pos = {x=0, y=0.35842, z=-36.353},
    _drops = {["default:steel_ingot"]=5,["default:diamond"]=1},

    on_activate = airutils.destroyed_on_activate,
	    
    get_staticdata=airutils.destroyed_save_static_data,

    on_rightclick = airutils.destroyed_open_inventory,

    on_punch = airutils.destroyed_on_punch,

})
