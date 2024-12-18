if callType == LuaCallType.Init then
    animationDelay=1/60
    animationCounter={}
    animating={}
    for i, circle in pairs(g_circle) do
        animating[i]=false
        animationCounter[i]=0
    end
end

if callType == LuaCallType.SwitchDone then
    for i, circle in pairs(g_circle) do
        --[[if circle.values[1]==1 then
            animating[i]=true
        end]] --apparently game calls SwitchDone first and only after assigns the value to Lock.values[] :(
        --api.log(circle.values[1])
    end
end

if callType == LuaCallType.Update then
    for i, circle in pairs(g_circle) do
        
        if circle.values[1]==1 then
            animating[i]=true
        end
        if animating[i] then
            animationCounter[i] = animationCounter[i] + Time.deltaTime
            if animationCounter[i]>=animationDelay then
                framesToAdvance=math.floor(animationCounter[i]/animationDelay)
                api.setLockValue(circle, circle.values[1]+framesToAdvance,1)
                animationCounter[i]=animationCounter[i]-(framesToAdvance*animationDelay)
            end
            if circle.values[1]>=60 then
                animating[i]=false
                animationCounter[i]=0
                if circle.values[1]>60 then
                    api.setLockValue(circle, 60, 1)
                end
            end
        end
    end
end