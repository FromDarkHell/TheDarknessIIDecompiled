minTimeBetweenStrikes = 20
maxTimeBetweenStrikes = 40
minTimeThunderAfterStrike = 2
maxTimeThunderAfterStrike = 5
lights = Instance()
trigger = Instance()
thunder = {
  Resource()
}
numberOfStrikes = 3
local randomizeLightPosition = function()
  local playerAvatar = gRegion:GetPlayerAvatar()
  local lightPosition, direction
  local minLightDistanceFromPlayer = lights:GetRadius() / 5
  local maxLightDistanceFromPlayer = lights:GetRadius() / 2
  lightPosition = playerAvatar:GetPosition()
  lightPosition.x = lightPosition.x + math.random(maxLightDistanceFromPlayer * 2) - maxLightDistanceFromPlayer
  lightPosition.z = lightPosition.z + math.random(maxLightDistanceFromPlayer * 2) - maxLightDistanceFromPlayer
  if lightPosition.x > 0 - minLightDistanceFromPlayer and lightPosition.x <= 0 then
    lightPosition.x = 0 - minLightDistanceFromPlayer
  elseif minLightDistanceFromPlayer > lightPosition.x and lightPosition.x > 0 then
    lightPosition.x = minLightDistanceFromPlayer
  end
  if lightPosition.z > 0 - minLightDistanceFromPlayer and lightPosition.z <= 0 then
    lightPosition.z = 0 - minLightDistanceFromPlayer
  elseif minLightDistanceFromPlayer > lightPosition.z and lightPosition.z > 0 then
    lightPosition.z = minLightDistanceFromPlayer
  end
  lightPosition.y = lightPosition.y + 20
  lights:SetPosition(lightPosition)
end
local lerpOverTime = function(value1, value2, totalTime)
  local rate
  if totalTime <= 0 then
    rate = 0
  else
    rate = math.abs(value2 - value1) / totalTime
  end
  return rate
end
function Lightning()
  local timeUntilNextStrike, timeUntilThunder, numberOfStrobes
  local postProcess = gRegion:GetLevelInfo().postProcess
  local t = 0
  local rate, thunderAudio, brightness, minBrightness
  while trigger:IsEnabled() do
    timeUntilNextStrike = math.random(minTimeBetweenStrikes, maxTimeBetweenStrikes)
    timeUntilThunder = math.random(minTimeThunderAfterStrike, maxTimeThunderAfterStrike)
    numberOfStrobes = math.random(3, 7)
    Sleep(timeUntilNextStrike)
    if not IsNull(lights) then
      randomizeLightPosition()
      brightness = lights:GetBrightness()
      lights:SetBrightness(0)
      minBrightness = 0
    end
    for i = 0, numberOfStrobes do
      postProcess.bloom = 4
      if not IsNull(lights) then
        t = 0
        rate = lerpOverTime(brightness, minBrightness, 50)
        lights:FirePort("TurnOn")
        while t < 0.05 do
          t = t + DeltaTime()
          lights:SetBrightness(lights:GetBrightness() + DeltaTime() * rate * 1000)
          Sleep(0)
        end
      end
      postProcess.bloom = 1
      if not IsNull(lights) then
        t = 0
        minBrightness = 0.25 * brightness
        rate = lerpOverTime(brightness, minBrightness, 50)
        while t < 0.05 do
          t = t + DeltaTime()
          lights:SetBrightness(lights:GetBrightness() - DeltaTime() * rate * 1000)
          Sleep(0)
        end
      end
    end
    if not IsNull(lights) then
      t = 0
      rate = lerpOverTime(brightness * 0.25, 0, 50)
      while t < 0.05 do
        t = t + DeltaTime()
        lights:SetBrightness(lights:GetBrightness() - DeltaTime() * rate * 1000)
        Sleep(0)
      end
      lights:FirePort("TurnOff")
    end
    Sleep(timeUntilThunder)
    if not IsNull(lights) and 0 < #thunder then
      thunderAudio = math.random(#thunder)
      lights:PlaySound(thunder[thunderAudio], false)
    end
  end
end
function CallLightningStrike()
  local thunderAudio
  local postProcess = gRegion:GetLevelInfo().postProcess
  local brightness, minBrightness, t, rate
  if IsNull(lights) then
    Broadcast("No light specified for lightning")
    return
  end
  brightness = lights:GetBrightness()
  lights:SetBrightness(0)
  minBrightness = 0
  for i = 0, numberOfStrikes do
    postProcess.bloom = 4
    lights:FirePort("TurnOn")
    t = 0
    rate = lerpOverTime(brightness, minBrightness, 50)
    lights:FirePort("TurnOn")
    while t < 0.05 do
      t = t + DeltaTime()
      lights:SetBrightness(lights:GetBrightness() + DeltaTime() * rate * 1000)
      Sleep(0)
    end
    postProcess.bloom = 1
    t = 0
    rate = lerpOverTime(brightness, brightness * 0.25, 50)
    while t < 0.05 do
      t = t + DeltaTime()
      lights:SetBrightness(lights:GetBrightness() - DeltaTime() * rate * 1000)
      minBrightness = 0.25 * brightness
      Sleep(0)
    end
    lights:FirePort("TurnOff")
  end
  thunderAudio = math.random(#thunder)
  lights:PlaySound(thunder[thunderAudio], false)
end
