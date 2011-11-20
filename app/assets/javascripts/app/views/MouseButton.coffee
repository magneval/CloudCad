### MouseButton ###
# MouseButton class is a simple class that represents the mouse button and his state  
# this class has no methods it just contains the coordinates to register various events
define(
    "views/MouseButton",
    ()->
        class CC.views.MouseButton

            constructor:->
                @down = false
                @start= {
                    x:0
                    y:0
                }
                @absoluteDelta= {
                    w:0
                    h:0
                }
                @delta= {
                    w:0
                    h:0
                }
                @oldDelta= {
                    w:0
                    h:0
                }
                @end={
                    x:0
                    y:0
                }
)