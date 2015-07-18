local player = {x = 0,   -- x position default
				y = 0,   -- y position default
				dx = 0,  -- x acceleration
				dy = 0,	 -- y acceleration
				w = 80,  -- width
				h = 128, -- height
				s = 100,  -- speed
				f = 8,   -- friction
				j = 10,  -- jump
				hp = 100,-- health
				cs = 0,	 -- current speed
				hpm = 100,-- max hp
				-- bools
				airDodge = true,
				isDead = false,
				heavyCollision = false,
				-- variables for delta calculation
				dtx = 0,
				dty = 0,
				}
				
function updatePlayer(dt)
	local speed = player.s
	local cols
	maxspeed = player.s / player.f
	timer = timer or 0
	dx, dy = dx or 0, dy or 0
	
	if timer > 0 then timer = math.floor(timer - dt*100) end

	-- movement
	if player.cs < speed/10 then
		if love.keyboard.isDown('right') then
			dx = dx + speed * dt
		elseif love.keyboard.isDown('left') then
			dx = dx - speed * dt
		end
		if love.keyboard.isDown('up') then
			dy = dy - speed * dt
		elseif love.keyboard.isDown('down') then
			dy = dy + speed * dt
		end
	end

	player.x, player.y, cols, cols_len = world:move(player, player.x + dx, player.y + dy)
	
	local tx, ty = collisionStopper(cols)
	dx = tx or (dx * (1 - math.min(dt*player.f, 1)))
	dy = ty or (dy * (1 - math.min(dt*player.f, 1)))
	
	player.cs = math.abs(math.sqrt(dx^2+dy^2))
	player.dx = dx
	player.dy = dy

	if player.dx ~= 0 then
		player.dtx = math.abs(player.dx) end
	if player.dy ~= 0 then
		player.dty = math.abs(player.dy) end
		
	collisionDamage()
end

function collisionDamage()
	t = math.max((t or 0) - love.timer.getDelta(), 0)
	if math.abs(player.dx) < 0.0001 and player.dtx > 5 then
		player.hp = player.hp - math.abs(player.dtx)^1.1
		player.dtx = 0
		player.heavyCollision = true
	elseif math.abs(player.dy) < 0.0001 and player.dty > 5 then
		player.hp = player.hp - math.abs(player.dty)^1.1
		player.dty = 0
		player.heavyCollision = true
	else player.heavyCollision = false end
	
	if player.heavyCollision == true then
		t = 1
	end
	return shake(t)
end

function isDead()
	if player.hp < 0 then
		player.isDead = true
	else
		player.isDead = false
	end
end

return player

-- Attack List
-- Melee Hold + Direction: Sweep Slash (Front sweep is default)
-- Melee 3x: Combo 1
-- Melee 2x + Melee: Combo 2
-- Melee + Front: Stinger
-- Melee + Back: Backslash
-- Melee + Front + Back: Defensive Offense