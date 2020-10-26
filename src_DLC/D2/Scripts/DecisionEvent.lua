local LIB = require("D2.Menus.SharedLibrary")
qteMovie = Resource()
maxTime = 3
function Start()
  Sleep(0)
  _T.decision = ""
  _T.popupMode = "DECISION"
  local movieInstance = gFlashMgr:GotoMovie(qteMovie)
  movieInstance:Execute("SetMaxTime", maxTime)
end
