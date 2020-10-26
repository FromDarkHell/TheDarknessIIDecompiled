local LIB = require("D2.Menus.SharedLibrary")
qteMovie = Resource()
successCinematic = Instance()
failCinematic = Instance()
finalCinematic = Instance()
failThreshold = 3
maxTime = 3
requiredButtonPressCount = 15
initialRateMultiplier = 0.3
rateIncreaseDelta = 0.03
rateDecreaseDelta = 0.1
function Start()
  Sleep(0)
  _T.successCinematic = successCinematic
  _T.failCinematic = failCinematic
  _T.finalCinematic = finalCinematic
  _T.popupMode = "QTE"
  local movieInstance = gFlashMgr:GotoMovie(qteMovie)
  movieInstance:Execute("SetMaxTime", maxTime)
  movieInstance:Execute("SetFailThreshold", failThreshold)
  movieInstance:Execute("SetRequiredButtonPressCount", requiredButtonPressCount)
  movieInstance:Execute("SetInitialRateMultiplier", initialRateMultiplier)
  movieInstance:Execute("SetRateIncreaseDelta", rateIncreaseDelta)
  movieInstance:Execute("SetRateDecreaseDelta", rateDecreaseDelta)
end
