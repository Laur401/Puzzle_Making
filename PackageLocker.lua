
if callType == LuaCallType.Init then
    rotDegrees = 60
    animationDuration = 1
    state = "closed"
    animating = false
    animationTimer = 0
    
    lockerDoor = g_Locker.transform.GetChild(0).Find('OpenableDoor')
    
    initialRot = lockerDoor.transform.localRotation
    newRot = Quaternion.Euler(lockerDoor.transform.localEulerAngles.x, lockerDoor.transform.localEulerAngles.y+rotDegrees, lockerDoor.transform.localEulerAngles.z)
    
    
end
if callType == LuaCallType.SwitchDone and context == g_openLocker and context.isOn then
    animating = true
    animationTimer = 0
end
if callType == LuaCallType.Update and animating then
    animationTimer=animationTimer+Time.deltaTime
    local progress = animationTimer/animationDuration
    if (animationTimer>animationDuration) then
        animationTimer = animationDuration
        animating = false
    end
    lockerDoor.transform.localRotation=Quaternion.Slerp(initialRot,newRot,progress)
end