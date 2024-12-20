if callType == LuaCallType.Init then
    function changeMinute()
        minute = os.date("%M")
        minuteDig2 = minute % 10
        minuteDig1 = math.floor(minute / 10)
        for i, minuteLock in pairs(g_IRLMinute) do
            api.setLockValue(minuteLock, minuteDig1, 1)
            api.setLockValue(minuteLock, minuteDig2, 2)
        end
    end
    function changeHour()
        hour = os.date("%H")
        hourDig2 = hour % 10
        hourDig1 = math.floor(hour / 10)
        for i, hourLock in pairs(g_IRLHour) do
            api.setLockValue(hourLock, hourDig1, 1)
            api.setLockValue(hourLock, hourDig2, 2)
        end
    end
    
    hour = os.date("%H")
    minute = os.date("%M")
    changeHour()
    changeMinute()
end

if callType == LuaCallType.Update then
    if minute ~= os.date("%M") then
        changeMinute()
        if hour ~= os.date("%H") then --don't need to check hour all the time, as hour changes only when minute changes
            changeHour()
        end
    end
end