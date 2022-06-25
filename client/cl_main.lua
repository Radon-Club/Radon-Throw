local g_targetPed = 0

local function loadModel(modelName)
  local modelHash = GetHashKey(modelName)

  if IsModelInCdimage(modelHash) then
    if not HasModelLoaded(modelHash) then
      RequestModel(modelHash)

      while not HasModelLoaded(modelHash) do
        Wait(0)
      end
    end
    return modelHash
  else
    return
  end

  SetModelAsNoLongerNeeded(modelHash)
end

local function loadAnimDict(dict)
  RequestAnimDict(dict)
  
  while not HasAnimDictLoaded(dict) do
    Wait(500)
  end
end

local function drawNativeText(text)
  SetNotificationTextEntry("STRING")
  AddTextComponentString(text)
  DrawNotification(false, true)
end

local function resetSelf()
  ClearPedTasks(PlayerPedId())

  if DoesEntityExist(g_targetPed) then
    DetachEntity(g_targetPed, true, true)
  end
end

RegisterNetEvent("Radon:notifyClient", function(text)
  if text and text ~= "" then drawNativeText(text) end
end)

RegisterNetEvent("Radon:attachEntities", function(targetServerId)
  local playerPed = PlayerPedId()
  local targetPed = GetPlayerPed(targetServerId)

  if DoesEntityExist(targetPed) then
    g_targetPed = targetPed

    loadAnimDict("mp_missheist_countrybank@lift_hands") 
    TaskPlayAnim(playerPed, "mp_missheist_countrybank@lift_hands", "lift_hands_in_air_loop", 8.0, -8.0, -1, 50, 0, false, false, false)
  end
end)

RegisterNetEvent("Radon:resetSelf", function()
  resetSelf()
end)  

RegisterCommand("+throwPlayer", function(source, args, rawCommand)
  if DoesEntityExist(g_targetPed) then
    local _, rightVector, _, _ = GetEntityMatrix(g_targetPed)

    ClearPedTasks(PlayerPedId())
    DetachEntity(g_targetPed)
    ApplyForceToEntity(g_targetPed, 3, rightVector.x * cfg.forceOffsetX, rightVector.y * cfg.forceOffsetY, rightVector.z * cfg.forceOffsetZ, 0.0, 0.0, 0.0, 0, 0, 1, 1, 0, 1)
  end
end)

TriggerEvent('chat:removeSuggestion', "+throwPlayer")
TriggerEvent('chat:removeSuggestion', "-throwPlayer")

RegisterKeyMapping("+throwPlayer", "Throw a player", 'keyboard', cfg.throwKey)