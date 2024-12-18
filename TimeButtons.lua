
if callType == LuaCallType.Init then
    function getVars(elementName)
        local name, var1 = elementName.match(elementName,"(.-)%[set:%s*([%l]+)%]") --<name>[set: <forward/back>]
        return {name, var1}
    end
    buttonSetting={}
    for i, button in pairs(g_timeButton) do
        local element = api.getElement(button)
        local vars = getVars(element.elementName)
        element.elementName=vars[1]
        buttonSetting[i]=vars[2]
    end
    function getIndex(context)
        local element = context.gameObject.GetComponent('Element')
        local index = string.match(element.playerVariableName, "{(%d+)}")
        return tonumber(index)
    end
end

if callType == LuaCallType.SwitchDone then
    if api.contains(g_timeButton,context) and context.isOn then
        local index = getIndex(context)
        for _, lock in pairs(g_barLock) do
            local adjustment=0
            if (buttonSetting[index]=="forward") and lock.values[1]<1439 then adjustment=1
            elseif (buttonSetting[index]=="back") and lock.values[1]>0 then adjustment=-1 end
            api.setLockValue(lock, lock.values[1]+adjustment, 1)
        end
    end
end