failureMessage = Symbol("PLACEHOLDER MISSION FAILURE MESSAGE")
delay = 5
function FailMission()
  gRegion:GetGameRules():FailMission(failureMessage, delay)
end
