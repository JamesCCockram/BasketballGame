-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

-- Your code here
local physics = require("physics")

--background
local background = display.newImage("wallpaper.png")
background.x = display.contentCenterX
background.y = display.contentCenterY

local _W = display.contentWidth
local _H = display.contentHeight
local screenW, screenH, halfW = display.actualContentWidth, display.actualContentHeight, display.contentCenterX
ballStartingX = 70
ballStartingY = _H - 40

--draw line behind ball
local trailprops = {x= 0, y = 0,r = 10}

--Counter
local goal = 0
local scoreText = display.newText("Score: ", display.contentCenterX, 25, nativeSystemFont, 25)
local scoreNumber = display.newText(0, display.contentCenterX, 50, nativeSystemFont, 25)
local SpeedText = display.newText("Speed:", 50, 50)
local SpeedNumber = display.newText(0,50,70)

local DistanceText = display.newText("Distance:", 150, 50)
local DistanceNumber = display.newText(0, 150, 70)


--Distance
function getDistance (x1,y1,x2,y2)
	dx = x2-x1
	dy = y2-y1

	distance = math.sqrt(dy^2 + dx^2)
	roundedDistance = math.round(distance)
	print(roundedDistance)
	DistanceNumber.text = roundedDistance
end

physics.start()

--physics.setDrawMode("hybrid") --Set physics Draw mode
physics.setScale( 60 ) -- a value that seems good for small objects (based on playtesting)
physics.setGravity( 0, 0 ) -- overhead view, therefore no gravity vector
display.setStatusBar( display.HiddenStatusBar )

--Create theBall
local ballBody = { density=0.60, friction=1.0, bounce=.7, radius=15 }
	theBall = display.newImageRect( "ball_white.png", 50, 50)
	theBall.x = ballStartingX; theBall.y = ballStartingY
	physics.addBody( theBall, ballBody )
	theBall.linearDamping = 0.3
	theBall.angularDamping = 0.8
	theBall.type = "theBall"

		--Create Rotating target
	target = display.newImage( "target.png" )
	target.x = theBall.x; target.y = theBall.y; target.alpha = 0;

-- Shoot the cue ball, using a visible force vector
function cueShot( event )

	local t = event.target
	local phase = event.phase

		if "began" == phase then
			physics.setGravity( 0, 10 )
			display.getCurrentStage():setFocus( t )
			t.isFocus = true

			-- Stop current theBall motion, if any
			t:setLinearVelocity( 0, 0 )
			t.angularVelocity = 0

			target.x = t.x
			target.y = t.y

			startRotation = function()
				target.rotation = target.rotation + 4
			end

			Runtime:addEventListener( "enterFrame", startRotation )

			local showTarget = transition.to( target, { alpha=0.4, xScale=0.4, yScale=0.4, time=200 } )
			myLine = nil

			elseif t.isFocus then
				if "moved" == phase then
					if ( myLine ) then
						myLine.parent:remove( myLine ) -- erase previous line, if any
					end

				myLine = display.newLine( t.x,t.y, event.x,event.y )
				myLine:setStrokeColor( 1, 1, 1, 50/255 )
				myLine.strokeWidth = 15

				elseif "ended" == phase or "cancelled" == phase then

					display.getCurrentStage():setFocus( nil )
					t.isFocus = false

					local stopRotation = function()
					Runtime:removeEventListener( "enterFrame", startRotation )
				end

			local hideTarget = transition.to( target, { alpha=0, xScale=1.0, yScale=1.0, time=200, onComplete=stopRotation } )

			if ( myLine ) then
				myLine.parent:remove( myLine )
			end

			-- Strike the ball!
			t:applyForce( (t.x - event.x), (t.y - event.y), t.x, t.y )
			Runtime:addEventListener("enterFrame", theBallSpeed) -- speed

		end
	end

	return true	-- Stop further propagation of touch event
end


-- grass
local grass = display.newImageRect( "grass.png", screenW, 40 )
grass.anchorX = 0
grass.anchorY = 1

grass.x, grass.y = display.screenOriginX, display.actualContentHeight + display.screenOriginY
local grassShape = { -halfW,-34, halfW,-34, halfW,34, -halfW,34 }
physics.addBody( grass, "static", { friction=0.3, shape=grassShape } )

-- walls
local leftWall = display.newRect(0,0,1, 1000 )
local rightWall = display.newRect (_W, 0, 1, 1000)
local topWall = display.newRect (_W, -200, 100000, 0)
local basketballTopWall = display.newRect(display.contentWidth - 20, 50 ,40,0)
local basketballLowerWall = display.newRect(display.contentWidth - 145, _H -125 ,0,180)
--walls physics
physics.addBody(basketballLowerWall,"static", {bounce = 0.1})
physics.addBody (basketballTopWall, "static", {bounce = 0.1} )
physics.addBody (leftWall, "static", { bounce = 0.1} )
physics.addBody (rightWall, "static", { bounce = 0.1} )
physics.addBody (topWall, "static", { bounce = 0.1} )

--Basketball Hoop and Backboard
local backboard = display.newRect((display.contentWidth -45), 125	, 20, 150)
local hoop = display.newRect((display.contentWidth -94), 150, 75,10)
hoop.fill = {1,0,0}
backboard.fill = {0,0,0}
--Basketball Hoop and Backboard physics
physics.addBody (backboard, "static", {bounce = 0.1})
physics.addBody (hoop, "dynamic", {isSensor= true})

--draw line
local function redraw ()
    local Trail = display.newCircle( theBall.x + trailprops.x, theBall.y + trailprops.y, trailprops.r)
    Trail:setFillColor( 0,0.7,1 )
    transition.to( Trail, {time = 10000, alpha = 0, onComplete = function ()
        display.remove( Trail )
    end} )
    theBall:toFront( )
		scoreText:toFront()
		scoreNumber:toFront()

end

function theBallSpeed ()
	velocity = theBall:getLinearVelocity()
	velocity = math.round(velocity)
	SpeedNumber.text = velocity
end

Runtime:addEventListener( "enterFrame", redraw ) --draw line
theBall:addEventListener( "touch", cueShot ) -- Sets event listener to theBall

local function onLocalCollision( self, event )
    if ( event.phase == "began" ) then
				goal = goal + 1
				scoreNumber.text = goal
				getDistance(ballStartingX, ballStartingY, theBall.x, theBall.y)

	elseif (event.phase == "ended") then
						transition.to(theBall, {x = ballStartingX, y = ballStartingY, delay=2500,time=500, onComplete=listener})
	end
end



hoop.collision = onLocalCollision
hoop:addEventListener( "collision" )
