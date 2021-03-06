waypoint = Instance()
cowerAnim = Resource()
cowerAnimIdleLoop = Resource()
makeGrabbable = true
blockVoiceBox = true
soundArray = {
  Resource()
}
function Cower(agent)
  if not agent:InScriptedMode() then
    local avatar = agent:GetAvatar()
    agent:SetAllExits(false)
    if IsNull(waypoint) == false then
      agent:MoveTo(waypoint, true, false, false)
    end
    if avatar:GetHealth() >= 1 then
      agent:InterruptSpeech()
      agent:PlayAnimation(cowerAnim, false)
      agent:SetIdleAnimation(cowerAnimIdleLoop)
      agent:SetBlockVoiceBarks(blockVoiceBox, Engine.BLOCK_SOLO)
      if makeGrabbable then
        avatar:SetHealth(10)
      end
      if #soundArray ~= 0 then
        agent:PlaySpeech(soundArray[RandomInt(1, #soundArray)], true)
      end
    end
    agent:ReturnToScriptControl()
  end
end
