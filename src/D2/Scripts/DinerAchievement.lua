gameEventTag = Symbol()
function NotifyChallengeMgr()
  if _T.gPromptHit then
    return
  end
  local humans = gRegion:GetHumanPlayers()
  for i = 1, #humans do
    gChallengeMgr:NotifyTag(humans[i], gameEventTag)
  end
end
function PromptHit()
  _T.gPromptHit = true
end
