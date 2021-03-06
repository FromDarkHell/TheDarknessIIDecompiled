delay = 0
duration = 0
desiredHealth = 100
timeToWait = 6
jackieModifier = Instance()
jumpTrigger = Instance()
eatHeartTrigger = Instance()
function DamagePlayer()
  Sleep(delay)
  eatHeartTrigger:FirePort("Open")
  local player = gRegion:GetPlayerAvatar()
  player:SetHealth(desiredHealth)
  local currentHealth = player:GetHealth()
  local waitTime = 0
  while player:GetHealth() == desiredHealth and waitTime < timeToWait do
    Sleep(0)
    waitTime = waitTime + DeltaTime()
  end
  eatHeartTrigger:FirePort("Close")
  Sleep(3)
  jackieModifier:FirePort("Activate")
  jumpTrigger:FirePort("Enable")
end
