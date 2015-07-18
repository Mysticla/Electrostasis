local player = require 'player'

local function getCellRect(world, cx,cy)
  local cellSize = world.cellSize
  local l,t = world:toWorld(cx,cy)
  return l,t,cellSize,cellSize
end

function debug()
	love.graphics.setColor(0, 0, 0, 120)
	love.graphics.rectangle("fill", 0, 0, 400, 180)
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("line", 0, 0, 400, 180)
	love.graphics.print("Debug Menu:", 0, 0)	
	love.graphics.print("player x = " .. player.x, 0, 16)
	love.graphics.print("player y = " .. player.y, 0, 32)
	love.graphics.print("player w = " .. player.w, 0, 48)
	love.graphics.print("player h = " .. player.h, 0, 64)
	love.graphics.print("player speed = " .. player.cs, 0, 80)
	love.graphics.print("player x accel = " .. player.dx, 0, 96)
	love.graphics.print("player y accel = " .. player.dy, 0, 112)
	love.graphics.print("player delta x = " .. player.dtx, 0, 128)
	love.graphics.print("player delta y = " .. player.dty, 0, 144)
	love.graphics.print("Heavy Collision = " .. tostring(player.heavyCollision), 0, 160)
end

function bumpDebug()
	local bump_debug = {}

	local cellSize = world.cellSize
	local font = love.graphics.getFont()
	local fontHeight = font:getHeight()
	local topOffset = (cellSize - fontHeight) / 2
	for cy, row in pairs(world.rows) do
		for cx, cell in pairs(row) do
			local l,t,w,h = getCellRect(world, cx,cy)
			local intensity = cell.itemCount * 12 + 16
			love.graphics.setColor(255,255,255,intensity)
			love.graphics.rectangle('fill', l,t,w,h)
			love.graphics.setColor(255,255,255, 64)
			love.graphics.printf(cell.itemCount, l, t+topOffset, cellSize, 'center')
			love.graphics.setColor(255,255,255,10)
			love.graphics.rectangle('line', l,t,w,h)
		end
	end
	return bump_debug
end

function drawGrid()
	for x=0, 100 do for y=0, 100 do
			love.graphics.rectangle("line", x*128, y*128, 128, 128) end end
end