delay = 0
loopDelay = 10
targetObject = Instance()
nameOfPortToFire = String()
function firePortLoop()
  Sleep(delay)
  while not IsNull(targetObject) do
    targetObject:FirePort(nameOfPortToFire)
    Sleep(loopDelay)
  end
end
