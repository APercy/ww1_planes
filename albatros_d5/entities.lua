
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
