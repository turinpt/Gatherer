GATHERER_ADDON_MESSAGE_PREFIX = "GATHERER";
GATHERER_TOKEN_SEPARATOR = ";";

function Gatherer_BroadcastGather(gather, gatherType, gatherC, gatherZ, gatherX, gatherY, gatherIcon, gatherEventType, startTimer)
    local message = Gatherer_EncodeGather(GetUnitName("player"), gather, gatherType, gatherC, gatherZ, gatherX, gatherY, gatherIcon, gatherEventType, startTimer);
    Gatherer_SendRawMessage(message);
end

function Gatherer_AddonMessageEvent(prefix, message, type)
    if prefix == GATHERER_ADDON_MESSAGE_PREFIX then
        Gatherer_ReceiveBroadcast(message);
    end
end

function Gatherer_EncodeGather(sender, gather, gatherType, gatherC, gatherZ, gatherX, gatherY, gatherIcon, gatherEventType, startTimer)
    return sender .. GATHERER_TOKEN_SEPARATOR ..
           gather .. GATHERER_TOKEN_SEPARATOR ..
           gatherType .. GATHERER_TOKEN_SEPARATOR ..
           gatherC .. GATHERER_TOKEN_SEPARATOR ..
           gatherZ .. GATHERER_TOKEN_SEPARATOR ..
           gatherX .. GATHERER_TOKEN_SEPARATOR ..
           gatherY .. GATHERER_TOKEN_SEPARATOR ..
           gatherIcon .. GATHERER_TOKEN_SEPARATOR ..
           gatherEventType .. GATHERER_TOKEN_SEPARATOR ..
           startTimer .. GATHERER_TOKEN_SEPARATOR;
end

function Gatherer_DecodeGather(message)
    local function eatToken(str)
        local sep = string.find(str, GATHERER_TOKEN_SEPARATOR);
        if (not sep) then return; end
        local arg = string.sub(str, 1, sep-1);
        local rest = string.sub(str, sep+1);
        return arg, rest
    end

    local sender, rest = eatToken(message);
    local gather, rest = eatToken(rest);
    local gatherType, rest = eatToken(rest);
    local gatherC, rest = eatToken(rest);
    local gatherZ, rest = eatToken(rest);
    local gatherX, rest = eatToken(rest);
    local gatherY, rest = eatToken(rest);
    local gatherIcon, rest = eatToken(rest);
    local gatherEventType, rest = eatToken(rest);
    local startTimer, rest = eatToken(rest);

    -- correct types
    gatherType = tonumber(gatherType);
    gatherC = tonumber(gatherC);
    gatherZ = tonumber(gatherZ);
    gatherX = tonumber(gatherX);
    gatherY = tonumber(gatherY);
    gatherEventType = tonumber(gatherEventType);
    startTimer = tonumber(startTimer);

    return sender, gather, gatherType, gatherC, gatherZ, gatherX, gatherY, gatherIcon, gatherEventType, startTimer;
end

function Gatherer_ReceiveBroadcast(message)
    local sender, gather, gatherType, gatherC, gatherZ, gatherX, gatherY, gatherIcon, gatherEventType, startTimer = Gatherer_DecodeGather(message);

    
    if sender ~= GetUnitName("player") then
        local prettyNodeName = gather;
        local prettyZoneName = GatherRegionData[gatherC][gatherZ].name;
        Gatherer_ChatPrint("Gatherer: " .. sender .. " discovered a new " .. prettyNodeName .. " node in " .. prettyZoneName .. ".");

        if (startTimer == 1) then
            Gatherer_AddGatherToBase(gather, gatherType, gatherC, gatherZ, gatherX, gatherY, gatherIcon, gatherEventType, time());
        elseif (startTimer > 1) then
            Gatherer_AddGatherToBase(gather, gatherType, gatherC, gatherZ, gatherX, gatherY, gatherIcon, gatherEventType, startTimer);
        else
            Gatherer_AddGatherToBase(gather, gatherType, gatherC, gatherZ, gatherX, gatherY, gatherIcon, gatherEventType);
        end
    end
end

function Gatherer_SendRawMessage(message)
    SendAddonMessage(GATHERER_ADDON_MESSAGE_PREFIX, message, "GUILD");
end

function AddHerb(herb)
    Gatherer_AddGatherHere(herb, 1, herb, 0);
end

function ShareAll()
    Gatherer_ChatPrint("Gatherer: Sharing all the nodes.")
    for mapContinent = 1,table.getn(GatherRegionData) do
        for mapZone = 1,table.getn(GatherRegionData[mapContinent]) do
            if (GatherItems[mapContinent][mapZone]) then
                for gatherName, gatherData in GatherItems[mapContinent][mapZone] do
                    for hPos, gatherInfo in gatherData do
                        local startTimer = 0
                        if (gatherInfo.lastpick and (time() - gatherInfo.lastpick) < 2700) then
                            startTimer = gatherInfo.lastpick
                        end
                        Gatherer_BroadcastGather(gatherName, gatherInfo.gtype, mapContinent, mapZone, gatherInfo.x, gatherInfo.y, gatherName, 0, startTimer)
                    end
                end
            end
        end
    end
    
end