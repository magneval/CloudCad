### Solid3D Class ###
# Solid3D is the main class for all solids, currently only extrusion solid are supported generated via Path3D
define(
    "views/draw/3D/primitives/Solid3D"
    [
        "views/draw/3D/primitives/Primitive"
        "views/draw/3D/primitives/Point3D"
        "views/draw/3D/primitives/Segment"
        "views/draw/3D/primitives/Path3D"
    ],
    (Primitive,Point3D,Segment,Path3D)->
        class CC.views.draw.primitives.Solid3D extends Primitive
            @points
            @segments
            @plane
            @lastPoint
            @selectedPoint
            @selectedSegment
            #### *constructor(`attr`)* method takes one argument
            #* the *attr* object that cointains various options  
            #Currently these options are supported:  
            #   * *color*: (the color of the path and of the extruded mesh)
            #   * *threePath*: (an existing THREE.Path to be converted to Path3D)
            #   * *points*: (an array of points representig the points of the path)
            #   * *name*: (a name for the object, useful for yet to be implemented object referencing)
            #   * *start*: a single point where the path is starting
            #
            # If one of the above options isn't specified or attr isn't given the appropriate default is set.  
            # Also a `Particle System` is used to identify points along the shape and an hidden Shperical mesh is attached to each vertext to detect collision
            constructor:(attr)->
                super()

                defaults = {
                    generator : undefined
                    extrusionValue : undefined
                    color : 0x8866ff
                    layer:"scene"
                }

                unless attr?
                    @generator = defaults.generator
                    @extrusionValue = defaults.extrusionValue
                    @color = defaults.color
                    layer = defaults.layer
                else
                    if attr.generator? then @generator = attr.generator else @generator = defaults.generator
                    if attr.extrusionValue? then @extrusionValue = attr.extrusionValue else @extrusionValue = defaults.extrusionValue
                    if attr.color? then @color = attr.color else @color = defaults.color
                
                if @generator? and @generator.class = "Path3D"
                    shape = new THREE.Shape(@generator.points)
                    material = new THREE.MeshLambertMaterial({
                        color: @generator.color
                        ambient: 0x111111
                        blending: 1
                        shading: 1
                    })
                    @mesh = new THREE.Mesh(
                        shape.extrude({
                            amount:@extrusionValue,
                            bevelEnabled:false,
                            material: material,
                            extrudeMaterial: material
                        }),
                        material
                    )
                    @mesh.father = this
                    @add(@mesh)
            
            #### *toggleSelection(`hexColor`)* method takes one argument
            #* the *hexColor* number that represent the color for the selection  
            #
            # If object is not selected then selection color is applied otherwise the original color is applied
            toggleSelection:(hexColor)=>
                color = if hexColor? then hexColor else 0x0000bb
                if @selected
                    @selected = false
                    @mesh.material.color.setHex(@color)
                else
                    @selected = true
                    @mesh.material.color.setHex(color)

            #### *update()* method takes no argument
            #Update forces updates to the internals
            update:=>
                @lastPoint = @point("last")
                @line.geometry.__dirtyVertices = true
                @line.geometry.__dirtyNormals = true
                @particles.__dirtyVertices = true
            
            #### *start(`point`)* method takes one argument
            #* the starting *point* from wich the Path should start
            start:(point)=>
                point = @validatePoint(point)
                if point
                    point.idx = @points.length
                    point.father = this
                    @points.push(point)
                    @threePath.moveTo(point)

            #### *add(`point`)* method takes one argument
            #* the *point* to be added to the Path
            #add:(point)=>
            #    point = @validatePoint(point)
            #    if point
            #        point.idx = @points.length
            #        point.father = this
            #        @points.push(point)
            #        if @points.length>0
            #            @threePath.lineTo(point)
            #        else
            #            @threePath.moveTo(point)

            insert:(idx,point)=>
                ###
                #debugger
                split = idx
                idx++

                if @validatePoint(point)
                    point.father = this
                    point.idx = idx
                    points_before = @points[0..split]
                    points_before.push(point)
                    points_after = @points[idx..@points.length-1]
                    @points = points_before.concat(points_after)
                    @paperPath.insert(idx,point)
                    @rearrangePoints()
                    @update()
                ###

            remove:(el)=>
                ###
                if el instanceof Point3D
                    @removePoint(el)
                else if el instanceof Segment
                    @removeSegment(el)
                ###

            removePoint:(point)=>
                ###
                @points.remove(point) if point in @points
                @paperPath.removeSegment(point.idx)
                @rearrangePoints()
                ###

            move:(el,newPos)=>
                if el instanceof Point3D
                    @movePoint(el,newPos)
                else if el instanceof Segment
                    @moveSegment(el,newPos)
            #### *movePoint(`index`,`newPoint`)* method takes two argument
            #* the *index* of the point that has to be moved
            #* the *newPoint* representing the new position of the element  
            #this method simply update the position of the vertex at the given index and triggers the update method once done
            movePoint:(index,newPoint)=>
                if index == 0
                    last = @points.length-1
                    @points[0] = newPoint
                    @points[last] = newPoint

                    @line.geometry.vertices[0].position = newPoint
                    @line.geometry.vertices[last].position = newPoint
                    
                    @particles.vertices[0].position = newPoint
                    @particles.vertices[last].position = newPoint
                else
                    @points[index] = newPoint
                    @line.geometry.vertices[index].position = newPoint
                    @particles.vertices[index].position = newPoint
                @update()

            moveSegment:(el,newPos)=>

            point:(selector)=>
                ###
                unless selector?
                    return null
                else if selector == "last"
                    return @points[@points.length-1]
                else if selector == "first"
                    return @points[0]
                else if selector == "selected"
                    return @points[@selectedPoint]
                else if typeof(selector) == "number" && selector < @points.length && selector > -1
                    return @points[parseInt(selector)]
                ###
            
            pointNear:(point,tollerance)=>
                ###
                for i in [0...@segments.length]
                    if @paperPath.segments[i].point.isClose(point,tollerance)
                        @selectedPoint = i
                        return @selectedPoint
                return null
                ###
            
            segmentNear:(point,tollerance)=>
                ###
                #debugger
                nearPoint = @paperPath.getNearestPoint(new paper.Point(point.x,point.y))
                circle = new paper.Path.Circle(nearPoint, 3);
                @update()
                if nearPoint.isClose(point,tollerance)
                    for segment in @paperPath.segments
                        start = segment.point
                        if segment.index < @paperPath.segments.length
                            end = segment.next.point
                        else
                            end = @paperPath.segments[0].point
                        crossproduct = (nearPoint.y - start.y) * (end.x - start.x) - (nearPoint.x - start.x) * (end.y - start.y)
                        dotproduct = (nearPoint.x - start.x) * (end.x - start.x) + (nearPoint.y - start.y)*(end.y - start.y)
                        squaredlengthba = (end.x - start.x)*(end.x - start.x) + (end.y - start.y)*(end.y - start.y)

                        if Math.abs(crossproduct) <= 0.000001 && dotproduct <= squaredlengthba && dotproduct >= 0
                            return segment.index

                else
                    false
                ###

            #### *extrude(`point`)* method takes one argument
            #* the *lenght* of the extrusion  
            # This method returns a new mesh containig the extruded shape  
            # Path is turned invisible when creating the 3D shape
            extrude:(value)=>
                @line.visible = false
                shape = new THREE.Shape(@points)
                material = new THREE.MeshLambertMaterial({
                    color: @color
                    ambient: 0x111111
                    blending: 1
                    shading: 1
                })
                @extrusion = new THREE.Mesh(
                    shape.extrude({
                        amount:value,
                        bevelEnabled:false,
                        material: material,
                        extrudeMaterial: material
                    }),
                    material
                )
                @extrusion.generator = this
                window.stage3d.world.remove(this)
                window.stage3d.world.add(@extrusion)
            #### *validatePoint(`point`)* method takes one argument
            #* the *point* variable that needs to be checked  
            # This method checks if the argument is a valid point and attemps to create one if it can othwise `false` is returned
            validatePoint:(point)=>
                if point instanceof Array
                    if point.length == 2
                        if @name?
                            return point = new Point3D(point[0],point[1],name + points.length,this) 
                        else
                            return point = new Point3D(point[0],point[1],null,this)
                else if point instanceof Point3D
                    return point
                else
                    return false

            rearrangePoints:=>
                i=0
                for point in @points    
                    point.idx = i 
                    i++
)
            