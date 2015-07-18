-- stops force on collision
function collisionStopper(c)
	local x, y
	for i=1, cols_len do
		local col = c[i]
		if col.normal.x == -1 or col.normal.x == 1 then x = 0 end
		if col.normal.y == -1 or col.normal.y == 1 then y = 0 end
	end
	return x, y
end

-- gravity calculation
function gravity(y, dt)
	if y < termv then
		local temp = gravt*dt
		local ty = (ty or player.y) + dt*(dy + temp/2)
		local y = y + temp
		return y
	end
end

-- general rotation
function rotation()
	local x, y = love.mouse.getPosition()
	local isDown = love.mouse.isDown
	local hip = math.sqrt(((x-w/2)^2)+((y-h/2)^2))
	local newx = math.sin((x-w/2)/hip)*TILE/2
	local newy = math.sin((y-h/2)/hip)*TILE/2

	local rot = -math.atan2(newx, newy)
end

-- Rounding Function
function round(num, idp)
	local mult = 10^(idp or 0)
	return math.floor(num * mult + 0.5) / mult
end

-- Screenshake
function shake(s)
	if s == 0 then
		return nil else
	return math.random(5,40)*s, math.random(5,40)*s end
end

-- lock on
-- sprite rotation for lock on
function lockOn(px, py, ex, ey)
	local ax = ex - px
	local ay = ey - py
	local h  = math.sqrt((ax^2)+(ay^2))
	local s = ay/h
	local c = ax/h
	return -math.atan2(s, c)
end