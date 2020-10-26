alarmFx = Type()
alarmSound = Resource()
local alarmStarted = false
local alarmChance = math.random(0, 1)
local t = 0
function AlarmStarted(entity)
  if alarmStarted == false and alarmChance < 0.6 then
    while t < 8 do
      entity:Attach(alarmFx, Symbol(), Vector(), Rotation())
      t = t + 1
      Sleep(1)
    end
    if IsNull(alarmSound) == false then
      entity:PlaySound(alarmSound, false)
    end
    alarmStarted = true
  end
end
