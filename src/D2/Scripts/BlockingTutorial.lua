tutorialText = String("")
movieRes = Resource()
message = String("")
effect = Type()
local movieInstance
function Start()
  movieInstance = gFlashMgr:GotoMovie(movieRes)
  if not IsNull(movieInstance) then
    movieInstance:Execute("SetMessage", message)
  end
  local levelInfo = gRegion:GetLevelInfo()
end
function End()
  if not IsNull(movieInstance) then
    movieInstance:Execute("Close", "")
    movieInstance = nil
  end
  local levelInfo = gRegion:GetLevelInfo()
end
