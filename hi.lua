local prefix = ';'
 
repeat wait() until game.Loaded
local plrs = game:GetService'Players'
local plr = plrs.LocalPlayer
local loopall = false
local whitelist = {}
local loopKill = {}
local function findplr(Target)
    if game:GetService'Players':FindFirstChild(Target) then
        return game:GetService'Players':FindFirstChild(Target)
    else
        if Target ~= nil and Target ~= "" and Target ~= " " and Target then
            local name = Target
            local found = false
            for _,v in pairs(game:GetService'Players':GetPlayers()) do 
                if not found and (v.Name:lower():sub(1,#name) == name:lower() or v.DisplayName:lower():sub(1,#name) == name:lower()) then
                    name = v
                    found = true
                end
            end
            if name ~= nil and name ~= Target then
                return name
            end
        end
    end
end
plr.Chatted:connect(function(msg)
    msg = msg:lower():split(' ')
    if msg[1] == '/e' then
        for i,v in next,msg do
            msg[i] = msg[i+1]
        end
    end
    if msg[1] == prefix..'lka' or (msg[1] == prefix..'loop' and msg[2] == 'all') then
        loopall = true
    elseif msg[1] == prefix..'kill' and findplr(msg[2]) and not table.find(loopKill,findplr(msg[2]).Name) then
        table.insert(loopKill,findplr(msg[2]).Name)
    elseif msg[1] == prefix..'wl' and findplr(msg[2]) and not table.find(whitelist,findplr(msg[2]).Name) then
        table.insert(whitelist,findplr(msg[2]).Name)
    elseif msg[1] == prefix..'bl' and findplr(msg[2]) and table.find(whitelist,findplr(msg[2]).Name) then
        table.remove(whitelist,findplr(msg[2]).Name)
    elseif msg[1] == prefix..'resurrect' then
        table.clear(loopKill)
        loopall = false
        pcall(function()
            plr.Character.PuttingDown:FireServer()
        end)
    elseif msg[1] == prefix..'unarm' and findplr(msg[2]) and not table.find(whitelist,findplr(msg[2]).Name) then
        table.insert(loopKill,findplr(msg[2]).Name)
        pcall(function()
            local arm = findplr(msg[2]).Character:FindFirstChild('Right Arm')
            if arm then
                plr.Character.Picking:FireServer(arm,Vector3.new(math.huge,-math.huge,math.huge))
            end
        end)
    elseif msg[1] == prefix..'unarm' and msg[2] == 'all' then
        loopall = true
        pcall(function()
            for _,v in next,plrs:GetPlayers() do
                if v~=plr and not table.find(whitelist,v.Name) then
                    local arm = v.Character:FindFirstChild('Right Arm')
                    if arm then
                        plr.Character.Picking:FireServer(arm,Vector3.new(math.huge,-math.huge,math.huge))
                    end
                end
            end
        end)
    elseif msg[1] == prefix..'unhand' and findplr(msg[2]) and table.find(loopKill,findplr(msg[2]).Name) then
        table.remove(loopKill,findplr(msg[2]).Name)
    end
end)
spawn(function()
    while true do wait()
        pcall(function()
            if plr.Character.Ragdoll.Value then
                plr.Character.GetUpEvent:FireServer()
            end
        end)
        pcall(function()
            for _,_2 in next,plr.Character:GetChildren() do
                pcall(function()
                    if _2:IsA'Accessory' and _2.Name ~= 'FakeAccessory' and _2:FindFirstChild'Handle' and _2.Handle:FindFirstChildOfClass'Weld' then
                        local clone = _2:Clone()
                        _2:Destroy()
                        clone.Name = 'FakeAccessory'
                        clone.Parent = plr.Character
                    end
                end)
                pcall(function()
                    if _2:IsA'BasePart' and _2.Name == 'Head' then
                        _2.Parent = nil
                    end
                end)
                pcall(function()
                    if _2.Name == 'VelocityDamage' or _2.Name == 'GetPicked' then
                        _2:Destroy()
                    end
                end)
            end
        end) 
    end
end)
while true do wait(0.1)
    if loopall then
        for _,v in next,plrs:GetPlayers() do
            if v~=plr and not table.find(whitelist,v.Name) then
                pcall(function()
                    plr.Character.Picking:FireServer(v.Character.HumanoidRootPart,Vector3.new(math.huge,-math.huge,math.huge))
                    wait(0.05)
                    plr.Character.PuttingDown:FireServer()
                end)
            end
        end
    end
    if loopKill ~= {} then
        for _,v in next,plrs:GetPlayers() do
            if table.find(loopKill,v.Name) then
                pcall(function()
                    local accs = v.Character:FindFirstChildOfClass'Accessory'
                    if accs then
                        if accs:FindFirstChild'Handle' then
                            plr.Character.Picking:FireServer(accs.Handle,Vector3.new(math.huge,-math.huge,math.huge))
                        elseif accs:IsA'BasePart' then
                            plr.Character.Picking:FireServer(accs,Vector3.new(math.huge,-math.huge,math.huge))
                        end
                    else
                        plr.Character.Picking:FireServer(v.Character.HumanoidRootPart,Vector3.new(math.huge,-math.huge,math.huge))
                        wait(0.1)
                        plr.Character.PuttingDown:FireServer()
                    end
                end)
            end
        end
    end
end
