local g_throwingPlayerData = {} -- Player throwing other player
local g_carriedPlayerData = {} -- Player being carried

local function getClosestPlayer(source)
  local closestPlayer = 0
  local playerCoords = GetEntityCoords(GetPlayerPed(source))

  for _, player in pairs(GetPlayers()) do
    if player ~= source then

      if closestPlayer == 0 then
        closestPlayer = player
      end

      local currentTargetCoords = GetEntityCoords(GetPlayerPed(player))
      local closestTargetCoords = GetEntityCoords(GetPlayerPed(closestPlayer))

      local currentDistance = #(currentTargetCoords - playerCoords)
      local closestDistance = #(currentTargetCoords - closestTargetCoords)
      
      if currentDistance <= cfg.minRadius and currentDistance < closestDistance then
        closestPlayer = player
      end
    end
  end

  return closestPlayer
end

local function notifyClient(target, text)
  if target and text then
    TriggerClientEvent("Radon:notifyClient", target, text)  
  end
end

local function isThrowingPed(source)
  return g_throwingPlayerData[source] ~= nil
end

local function isBeingCarried(source)
  return g_carriedPlayerData[source] ~= nil
end

function ThrowPlayer(source, target)
  if not target then
    return notifyClient(source, "~r~You aren't close to any player!")
  end

  if isThrowingPed(source) or isBeingCarried(source) then
    return notifyClient(source, "~r~You can't do that")
  end

  if isThrowingPed(target) or isBeingCarried(target) then
    return notifyClient(source, "~r~You can't do that")
  end
  
  -- Players passed all checks
  TriggerClientEvent("Radon:attachEntities", source, target)
end

RegisterCommand("throw", function(source, args, rawCommand)
  ThrowPlayer(source, getClosestPlayer(source))
end)

AddEventHandler('playerDropped', function()
  local source = source

  local carryTarget = g_carriedPlayerData[source]
  local throwTarget = g_throwingPlayerData[source]

  if carryTarget then
    TriggerClientEvent("Radon:resetSelf", carryTarget)
    g_carriedPlayerData[source] = nil
  end
  
  if throwTarget then
    TriggerClientEvent("Radon:resetSelf", throwTarget)
    g_throwingPlayerData[source] = nil
  end
end)