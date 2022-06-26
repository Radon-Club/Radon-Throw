function LoadAnimDict(dict)
  RequestAnimDict(dict)
  
  while not HasAnimDictLoaded(dict) do
    Wait(500)
  end
end

function DrawNativeText(text)
  SetNotificationTextEntry("STRING")
  AddTextComponentString(text)
  DrawNotification(false, true)
end