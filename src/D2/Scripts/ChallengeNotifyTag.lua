gameEventTag = Symbol()
function NotifyChallengeMgr()
  local humans = gRegion:GetHumanPlayers()
  for i = 1, #humans do
    gChallengeMgr:NotifyTag(humans[i], gameEventTag)
  end
end
