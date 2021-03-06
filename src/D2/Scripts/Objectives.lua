completeObjective = false
completeObjectiveSound = Resource()
objectiveRem = Symbol()
addObjective = false
objectiveSound = Resource()
objective = Symbol()
checkItem = false
item = Type()
typeobjectiveSound = Resource()
objectiveitem = Symbol()
checkObjective = false
objectiveChk = Symbol()
giveAltObjective = false
AltobjectiveSound = Resource()
altObjective = Symbol()
waitForSound = false
addToken = false
UniqueToken = Symbol()
initialDelay = 0
trackedObjects = {
  Instance()
}
function objectives()
  Sleep(initialDelay)
  local localPlayers = gRegion:ScriptGetLocalPlayers()
  if IsNull(localPlayers) then
    print("No local players found")
    return
  end
  local player = localPlayers[1]
  local teamId = player:GetTeam()
  local playerAvatar = player:GetAvatar()
  gameState = gRegion:GetGameRules():GetGameState(teamId)
  if IsNull(gameState) then
    print("No game state")
    return
  end
  if checkItem == true then
    if not playerAvatar:HasItem(item) then
      if typeobjectiveSound ~= nil then
        playerAvatar:PlaySound(typeobjectiveSound, waitForSound)
      end
      gameState:AddObjective(objectiveitem)
      print("player didn't have item -adding objective ")
      return
    end
    print("player has the item")
  end
  if giveAltObjective == true and gameState:HasCompletedObjective(objectiveChk) then
    print("Team has the objective but we are giving him a different one")
    if AltobjectiveSound ~= nil then
      playerAvatar:PlaySound(AltobjectiveSound, waitForSound)
    end
    gameState:AddObjective(altObjective)
    return
  end
  if completeObjective == true then
    if completeObjectiveSound ~= nil then
      playerAvatar:PlaySound(completeObjectiveSound, waitForSound)
    end
    gameState:CompleteObjective(objectiveRem)
    print("Removed objective " .. tostring(objectiveRem))
  end
  if addObjective == true then
    if completeObjective == true then
      Sleep(0.5)
    end
    if objectiveSound ~= nil then
      playerAvatar:PlaySound(objectiveSound, waitForSound)
    end
    gameState:AddObjective(objective, trackedObjects[1])
    print("Added objective " .. tostring(objective))
  end
  if addToken == true then
    local token = UniqueToken
    local sym = Symbol("token")
    playerAvatar:SetQuestToken(sym, Engine.QTS_COMPLETE)
  end
  if 1 < #trackedObjects then
    for i = 2, #trackedObjects do
      gameState:AddTrackedObject(objective, trackedObjects[i])
    end
  end
end
