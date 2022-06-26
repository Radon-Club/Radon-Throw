local g_targetPed = 0
local g_isCarried = false

local function isPedThrowing()
  return g_targetPed ~= 0 and DoesEntityExist(g_targetPed)
end

local function isPedCarried()
  return g_isCarried
end

local function resetSelf()
  ClearPedTasks(PlayerPedId())

  if DoesEntityExist(g_targetPed) then
    DetachEntity(g_targetPed, true, true)
  end

  g_targetPed = 0
end

function handleControlThread()
  local playerPed = PlayerPedId()

  while isPedThrowing() or isPedCarried() do
    Wait(0)

    DisableControlAction(0, 21, true) 
    DisableControlAction(0, 25, true) 
    DisableControlAction(0, 47, true) 
    DisableControlAction(0, 58, true) 
    DisableControlAction(0, 24, true)
    DisablePlayerFiring(playerPed, true)

  end 
end

RegisterNetEvent("Radon:notifyClient", function(text)
  if text and text ~= "" then DrawNativeText(text) end
end)

RegisterNetEvent("Radon:attachEntities", function(targetServerId)
  local playerPed = PlayerPedId()
  local targetPed = GetPlayerPed(GetPlayerFromServerId(targetServerId))

  if DoesEntityExist(targetPed) then
    g_targetPed = targetPed

    CreateThread(handleControlThread)
    LoadAnimDict("mp_missheist_countrybank@lift_hands") 
    TriggerServerEvent("Radon:carryPlayer", targetServerId)

    while GetEntityAttachedTo(targetPed) ~= playerPed do
      Wait(0)
    end

    TaskPlayAnim(playerPed, "mp_missheist_countrybank@lift_hands", "lift_hands_in_air_loop", 8.0, -8.0, -1, 50, 0, false, false, false)
  end
end)

RegisterNetEvent("Radon:syncCarriedPlayer", function(target)
  local fingerBoneId = GetEntityBoneIndexByName(PlayerPedId(), "BONETAG_R_FINGER11")
  local targetPed = GetPlayerPed(GetPlayerFromServerId(target))

  if DoesEntityExist(targetPed) then
    g_isCarried = true
    
    CreateThread(handleControlThread)
    AttachEntityToEntity(PlayerPedId(), targetPed, fingerBoneId, 0.2, 0.2, 0.3, 5.0, 10.0, 50.0, false, false, false, true, 0, true)
  end
end)

RegisterNetEvent("Radon:resetSelf", function()
  resetSelf()
end)  

RegisterCommand("+throwPlayer", function(source, args, rawCommand)
  if DoesEntityExist(g_targetPed) then

    local _, rightVector, _, _ = GetEntityMatrix(g_targetPed)
    TriggerServerEvent("Radon:throwPlayer", GetPlayerServerId(NetworkGetPlayerIndexFromPed(g_targetPed)), rightVector)

    while GetEntityAttachedTo(targetPed) == playerPed do
      Wait(0)
    end
    
    resetSelf()
  end
end)

RegisterNetEvent("Radon:getThrown", function(rightVector)
  local playerPed = PlayerPedId()
  g_isCarried = false

  DetachEntity(playerPed, true, true)
  ApplyForceToEntity(playerPed, 3, rightVector.x * cfg.forceOffsetX, rightVector.y * cfg.forceOffsetY, cfg.forceOffsetZ, 0.0, 0.0, 0.0, 0, 0, 1, 1, 0, 1)
end)

TriggerEvent('chat:removeSuggestion', "+throwPlayer")
TriggerEvent('chat:removeSuggestion', "-throwPlayer")

RegisterKeyMapping("+throwPlayer", "Throw a player", 'keyboard', cfg.throwKey)