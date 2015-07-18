-- objects
local bump       = require 'lib/bump'
local gamera	 = require 'lib/gamera'
local player 	 = require 'player'

-- libraries
require 'funcs'
require 'lib/debug'

local font 		 = love.graphics.newFont("graphics/fonts/AlphaMaleModern.ttf", 18);	love.graphics.setFont(font)
local cols_len   = 0 -- how many collisions are happening

-- globals
w, h  = love.graphics.getDimensions()
termv, gravt = 50, 25
world = bump.newWorld() -- World creation

tilex, tiley = 128, 128
worldx, worldy = 8e5, 2e5 -- dummy for variable map size

cb1, cb2, cb3, cb4 = w/2-w/20, w/2+w/20, h/2-h/20, h/2+h/20

-- helper function
local function drawBox(box, r,g,b)
  love.graphics.setColor(r,g,b,70)
  love.graphics.rectangle("fill", box.x, box.y, box.w, box.h)
  love.graphics.setColor(r,g,b)
  love.graphics.rectangle("line", box.x, box.y, box.w, box.h)
end

local function drawPlayer()
	drawBox(player, 0, 255, 0)	
end

-- Block functions
local blocks = {}

local function addBlock(x,y,w,h)
  local block = {x=x,y=y,w=w,h=h}
  blocks[#blocks+1] = block
  world:add(block, x,y,w,h)
end

local function drawBlocks()
  for _,block in ipairs(blocks) do
    drawBox(block, 255,0,0)
  end
end

-- Main LÖVE functions

function love.load()
  camera = gamera.new(-worldx/10, -worldy/10, worldx,	worldy) -- Camera creation
  
  player.x = 40;	player.y = 40
  world:add(player, player.x, player.y, player.w, player.h)

  addBlock(0,       0,     800, 32)
  addBlock(0,      32,      32, 600-32*2)
  addBlock(0,      600-32, 800, 32)
end

function love.update(dt)
	cols_len = 0
	updatePlayer(dt)
	if player.cs > 0.001 then s = math.min((s or 0)+dt*(player.cs/10), 0.2*(math.sqrt(player.s/50)))
	else s = math.max((s or 0) - dt, 0) end
	camera:setScale(1-s)
	camera:setPosition(player.x+player.w/2,player.y+player.h/2)
	act = math.max(act-0.5, 0)
end

function love.draw()
	camera:draw(function(l,t,w,h)
		drawBlocks()
		drawPlayer()
		if shouldDrawDebug then
			drawGrid()
			bumpDebug()
		end
	end)
	drawHUD()
	if shouldDrawDebug then
		debug()
	end
	local FPS = "FPS: " .. love.timer.getFPS()
	love.graphics.print(FPS .. t, w-font:getWidth(FPS .. t))
end

-- hate this function
function love.keypressed(k)
  if k=="escape" then love.event.quit() end
  if k=="tab"    then shouldDrawDebug = not shouldDrawDebug end
end

act = round((act or 100), 1)
function drawHUD() 	-- time constraints ate my transformation matrices	
	local s = 1
	if collisionDamage() then
		sx, sy = collisionDamage()
	else sx, sy = 0, 0 end
	local o, o2 = -player.dx*4/math.max(math.sqrt(math.abs(player.dx)),1) * s + sx, -player.dy*4/math.max(math.sqrt(math.abs(player.dy)), 1) * s + sy
	local hp = player.hp * s
	local ox, oy = 60 * s, 20 * s 
	local actm, actmax, actx = 100 * s, 100 * s + ox, act * s + ox
	local p1, p2, p3, p4, p5, p6, p7, p8, p9, p10, p11, p12, p13, p14, p15, p16, p17 = 
		oy+22*s, 	oy+42*s, 	oy+32*s, 	 actmax+10*s,	-- p1,		p2,		p3,		p4
		oy+62*s, 	oy+52*s, 	actmax-50*s, actmax-40*s,	-- p5,		p6,		p7,	 	p8
		oy+5*s,		oy+15*s, 	actx-5*s, 	 actx+5*s,		-- p9,		p10,	p11,	p12
		actx+10*s,	actx+15*s, 	oy+79*s, 	 oy+69*s		-- p13, 	p14,	p15,	p16
	local n = actm - math.floor(hp) 

	if player.hp > 25 then love.graphics.setColor(255, 180, 0, 120) -- underlays
	else love.graphics.setColor(255, 0, 0, 120) end
	love.graphics.polygon("fill", ox+o,p1+o2 , ox+o,p2+o2 , actmax+o,p2+o2 , p4+o,p3+o2 , actmax+o,p1+o2)
	if player.hp > 25 then love.graphics.setColor(20, 125, 255, 120)
	else love.graphics.setColor(255, 0, 0, 120) end
	love.graphics.polygon("fill", ox+p8+o,p2+o2 , actmax+p8+o,p2+o2 , actmax+o+p8,p5+o2 , ox+o+p8,p5+o2 , ox+o+p7,p6+o2)
	
	if player.hp > 25 then love.graphics.setColor(255, 180, 0, 220) -- overlays
	else love.graphics.setColor(255, 0, 0, 220) end
	love.graphics.polygon("fill", p11+o,p9+o2 , actx+o,p10+o2 , p12+o,p9+o2)
	love.graphics.polygon("fill", ox+o,p1+o2 , ox+o,p2+o2 , actx+o,p2+o2 , p13+o,p3+o2 , actx+o,p1+o2)
			
	local temp = tostring(act)
	local hlth = player.hpm .. " Intgrt"
	love.graphics.print(temp .. "     Act", actx - font:getWidth(temp)*s-10*s+o, oy+o2, 0, s)
	love.graphics.print((actmax - ox)/s .. "mW",  ox - font:getWidth(actmax)+actm-70*s+o, oy+44*s+o2, 0, s)

	if player.hp > 25 then love.graphics.setColor(20, 125, 255, 220) 
	else love.graphics.setColor(255, 0, 0, 220) end
	love.graphics.polygon("fill", ox+o+p8+n,p2+o2 , actmax+o+p8,p2+o2 , actmax+o+p8,p5+o2 , ox+o+p8+n,p5+o2 , ox+o+p7+n,p6+o2)	
	love.graphics.polygon("fill", actmax+o+15*s+n,p15+o2 , actmax+o+20*s+n,p16+o2 , actmax+o+25*s+n,p15+o2)	

	love.graphics.print(round(player.hp, 1) .. "     Integrity", actmax + n - font:getWidth(round(player.hp, 1))*s+o+10, oy+67*s+o2, 0, s)
	love.graphics.print(hlth, actmax + (font:getWidth(hlth)-50)*s+o, oy + 22*s+o2, 0, s)
end

function trail()
end