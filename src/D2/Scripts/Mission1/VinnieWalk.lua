vinnie = Instance()
heyThere = Instance()
heyThereSound = Resource()
enricoSound = Resource()
waiter = Instance()
waiterSound = Resource()
mrGalvanni = Instance()
mrGalvanniSound = Resource()
frankie = Instance()
frankieSound = Resource()
swifty = Instance()
swiftySound = Resource()
angryLady = Instance()
angryLadySound = Resource()
angryWaiter = Instance()
angryHusband = Instance()
lookTutorialTrigger = Instance()
LeaveTable = Instance()
JoinTable = Instance()
TableGuy = Instance()
WaiterWalk = Instance()
function HeyTherePlay()
  heyThere:FirePort("PlayTriggeredAnim")
end
function Enrico()
end
function Swifty()
  swifty:FirePort("PlayTriggeredAnim")
  swifty:PlaySpeech(swiftySound, false)
end
function WaiterPlay()
  waiter:FirePort("PlayTriggeredAnim")
end
function MrGalvanniPlay()
  mrGalvanni:FirePort("PlayTriggeredAnim")
end
function FrankiePlay()
  frankie:FirePort("PlayTriggeredAnim")
end
function AngryLadyPlay()
  angryLady:FirePort("PlayTriggeredAnim")
  Sleep(1.9)
  angryHusband:FirePort("PlayTriggeredAnim")
  angryWaiter:FirePort("PlayTriggeredAnim")
end
function LookTutorial()
  lookTutorialTrigger:FirePort("Execute")
end
function GirlLeave()
  LeaveTable:FirePort("PlayTriggeredAnim")
end
function GirlJoin()
  JoinTable:FirePort("PlayTriggeredAnim")
end
function FadeScreen()
  local levelInfo = gRegion:GetLevelInfo()
  Sleep(2)
end
function GuyJoinsTable()
  TableGuy:FirePort("PlayTriggeredAnim")
end
function WaiterWalkDown()
  WaiterWalk:FirePort("PlayTriggeredAnim")
end
