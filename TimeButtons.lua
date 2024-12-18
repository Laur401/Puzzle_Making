if callType == LuaCallType.Init then
    
    
    
    
    function getVariables(elementName)
        local name, var1 = elementName.match("(.-)%[set:%s*([%l]+)%]") --<name>[set: <open/closed>]
        return {name, var1}
    end
end

if callType == LuaCallType.SwitchDone then
    if api.contains(g_timeButton,context) and context.isOn then
        for i, lock in pairs(g_barLock) do
            api.setLockValue(lock, lock.values[1]+1,1)
        end
    end
end