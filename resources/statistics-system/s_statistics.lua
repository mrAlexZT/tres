local tick = getTickCount()

-- /astats
function getAdminStats(thePlayer, commandName)
	if (exports.global:isPlayerAdmin(thePlayer)) then
		outputChatBox("-=-=-=-=-=-=-=-=-= STATISTICS =-=-=-=-=-=-=-=-=-", thePlayer, 255, 194, 14)
		
		-- CURRENT PLAYERS
		local playerCount = getPlayerCount()
		local maxCount = getMaxPlayers()
		outputChatBox("     Current Players: " .. playerCount .. "/" .. maxCount , thePlayer, 255, 194, 14)
		
		-- UPTIME
		local currTick = getTickCount()
		local uptimeMilliseconds = currTick - tick
		
		local minutes = math.floor((uptimeMilliseconds/1000)/60)
		
		if (minutes==1) then
			outputChatBox("     Uptime: 1 Minute", thePlayer, 255, 194, 14)
		else
			outputChatBox("     Uptime: " .. minutes .. " Minutes", thePlayer, 255, 194, 14)
		end
		
		-- Queries:
		local queries = exports.mysql:returnQueryStats()
		outputChatBox("     SQL Queries: " .. queries ,  thePlayer, 255, 194, 14)  
		
		-- VEHICLES
		outputChatBox("     Vehicles: " .. #exports.pool:getPoolElementsByType("vehicle") , thePlayer, 255, 194, 14)
	end
end
addCommandHandler("astats", getAdminStats)