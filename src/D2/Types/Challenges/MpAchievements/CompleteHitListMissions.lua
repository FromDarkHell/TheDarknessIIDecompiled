numMissions = 6
campaignStructure = Resource()
local IsCampaignMission = function(region, mission)
  if not IsNull(campaignStructure) then
    local numMissions = campaignStructure:GetNumMaps()
    for i = 0, numMissions - 1 do
      local campaignRegion = campaignStructure:GetRegionName(i)
      local campaignMission = campaignStructure:GetMissionName(i)
      if region == campaignRegion and "Campaign" .. mission == campaignMission then
        return true
      end
    end
  end
  return false
end
function MatchTagEvent(player, tag)
  local gameRules = gRegion:GetGameRules()
  local playerProfile = Engine.GetPlayerProfileMgr():GetPlayerProfile(0)
  local d2profileData = playerProfile:GetGameSpecificData()
  local numCampaignMissionsCompleted = 0
  local numHitListExclusiveMissionsCompleted = 0
  print("Made My Hit List: ")
  local numRegions = gameRules:NumRegions()
  for i = 0, numRegions - 1 do
    local thisRegion = gameRules:GetRegion(i)
    local numMissions = thisRegion:NumMissions()
    for j = 0, numMissions - 1 do
      local thisMission = thisRegion:GetMission(j)
      local mpProgression = d2profileData:GetMPProgression(thisRegion.regionName, thisMission.missionName)
      if 0 < mpProgression.grade then
        if IsCampaignMission(thisRegion.regionName, thisMission.missionName) then
          numCampaignMissionsCompleted = numCampaignMissionsCompleted + 1
        else
          print(thisRegion.regionName .. "/" .. thisMission.missionName .. " completed")
          numHitListExclusiveMissionsCompleted = numHitListExclusiveMissionsCompleted + 1
        end
      end
    end
  end
  return numHitListExclusiveMissionsCompleted >= numMissions
end
