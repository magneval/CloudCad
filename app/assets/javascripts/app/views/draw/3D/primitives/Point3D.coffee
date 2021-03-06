S.export(
    "views/draw/3D/primitives/Point3D"
    ["views/draw/3D/primitives/Primitive","views/draw/3D/primitives/Path3D"],
    (Primitive,Path3D)->
        class Point3D extends THREE.Vector3
            @x
            @y
            @z
            @name
            @father
            @idx

            constructor:(@x=0,@y=0,@z=0,@name,@father)->
                super(@x,@y,@z)
                if @constructor.toString?
                    arr = @constructor.toString().match(/function\s*(\w+)/)
                    if arr? and  arr.length == 2
                        @class = arr[1]
                @id = Math.guid()
            
            store:=>
                output = {
                    xtype: "point3d"
                    x: @x
                    y: @y
                    z: @z
                    name: @name
                }

            moveTo:(@x,@y,@z)=>
                if @father?
                    if @father.class = "Path3D"
                       @father.points[@idx].position.x = @x
                       @father.points[@idx].position.y = @y
                       @father.points[@idx].position.z = @z
                       @father.points[@idx].selected = true
                       @father.update()

            coords:=>
                [@x,@y,@z]

            isNear:(cord,point,tolerance)=>
                if cord == "x"
                    if @x <= point.x + tolerance && @x >= point.x - tolerance
                        return true
                else if cord == "y"
                    if @y <= point.y + tolerance && @y >= point.y - tolerance
                        return true
                else if cord == "z"
                    if @z <= point.z + tolerance && @z >= point.z - tolerance
                        return true
                else if cord == "xy" || cord == "yx"
                    if @x <= point.x + tolerance && @x >= point.x - tolerance && @y <= point.y + tolerance && @y >= point.y - tolerance
                        return true
                else if cord == "xz" || cord == "zx"
                    if @x <= point.x + tolerance && @x >= point.x - tolerance && @z <= point.z + tolerance && @z >= point.z - tolerance
                        return true
                else if cord == "yz" || cord == "zy"
                    if @y <= point.y + tolerance && @y >= point.y - tolerance && @z <= point.z + tolerance && @z >= point.z - tolerance
                        return true
                else if cord == "all"
                    if @x <= point.x + tolerance && @x >= point.x - tolerance && @y <= point.y + tolerance && @y >= point.y - tolerance && @z <= point.z + tolerance && @z >= point.z - tolerance
                        return true
                return false
            
            toString:=>
                "x:#{@x}\ny:#{@y}\nz:#{@z}"
                
            remove:->
                if @father? && @father instanceof Path3D
                    @father.removePoint(this)

            angleWith:(point)=>
)
