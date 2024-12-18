
if callType == LuaCallType.Init then
    rotDegrees = 175
    animationDuration = 1
    state = {}
    element = {}
    animating = {}
    switchActive = {}
    animationTimer = {}
    
    cover = {}
    back = {}
    
    lastCoverRot = {}
    lastBackRot = {}
    lastCoverPos = {}
    lastBackPos = {}
    
    newCoverRot = {}
    newBackRot = {}
    newCoverPos = {}
    newBackPos = {}
    
    camera = g_folder[1].gameObject.Find('MainCamera')
    mainCamera = g_folder[1].gameObject.FindGameObjectWithTag('MainCamera')
    if camera ~= mainCamera then VRMode=true
    else VRMode=false
    end
    
    for i, folder in pairs(g_folder) do
        state[i]="open"
        element[i]=api.getElement(folder)
        animating[i]=false
        switchActive[i]=true
        animationTimer[i]=0
        element[i].boundsUpdate = 3
        --element[i].eulerAnglesHandEnabled=true
        --element[i].eulerAnglesHand=api.vector3(180,0,90) --angle in hand
        element[i].eulerAnglesInventory=api.vector3(0,90,270) --angle in inventory when initially picking item up, rotates and updates to match eulerAnglesInventoryTarget
        element[i].eulerAnglesZoom=api.vector3(0,90,270) --angle in main inventory view (start of animation)
        element[i].eulerAnglesInventoryTarget=api.vector3(0,90,270) --angle in inventory
        element[i].eulerAnglesTarget=api.vector3(0,90,270) --angle in main inventory view
        element[i].groundEulerAngles=api.vector3(0,90,180) --angle when placed
        
        cover[i]=folder.transform.GetChild(0).Find('FolderCover')
        back[i]=folder.transform.GetChild(0).Find('FolderBack')
        
        if VRMode then
            g_folderSwitchFront[i].transform.parent=cover[i]
            --g_folderSwitchFront[i].pivot = g_folderSwitchFront[i].transform
            --g_folderSwitchFront[i].originalTransform = g_folderSwitchFront[i].transform
            g_folderSwitchBack[i].transform.parent=back[i]
            
        else
            folder.remoteOnly = false --allows to click when picked up
            g_folderSwitchFront[i].gameObject.SetActive(false)
            g_folderSwitchBack[i].gameObject.SetActive(false)
        end
        
        
        
        lastCoverRot[i]={Quaternion.identity}
        lastBackRot[i]={Quaternion.identity}
        lastCoverPos[i]={Vector3.zero}
        lastBackPos[i]={Vector3.zero}
        
        newCoverRot[i]={Quaternion.identity}
        newBackRot[i]={Quaternion.identity}
        newCoverPos[i]={Vector3.zero}
        newBackPos[i]={Vector3.zero}
    end
    
    -- Helper functions
    function getIndex(context)
        local element = context.gameObject.GetComponent('Element')
        local index = string.match(element.playerVariableName, "{(%d+)}")
        return tonumber(index)
    end
end

if callType == LuaCallType.SwitchDone then
    --Start movement
    if api.contains(g_folder, context) and context.isOn then
        local index = getIndex(context)
        if animating[index] or not switchActive[index] then return end
        local targetRotation = rotDegrees
        switchActive[index] = false
        if state[index]=="open" then
            state[index]="closed"
            --[[element[index].eulerAnglesTarget=api.vector3(0,270,270)
            element[index].eulerAnglesInventoryTarget=api.vector3(0,270,270)
            element[index].groundEulerAngles=api.vector3(0,90,180)]]
        elseif state[index]=="closed" then
            state[index]="open"
            --targetRotation=-targetRotation --for some reason coordinates invert after going more than 90 degrees? very weird.
            --[[element[index].eulerAnglesTarget=api.vector3(0,270,270)
            element[index].eulerAnglesInventoryTarget=api.vector3(0,270,270)
            element[index].groundEulerAngles=api.vector3(0,90,180)]]
        end
        
        animationTimer[index]=0
        animating[index]=true
        lastCoverRot[index]=cover[index].transform.localRotation
        newCoverRot[index]= Quaternion.Euler(cover[index].transform.localEulerAngles.x-targetRotation, cover[index].transform.localEulerAngles.y, cover[index].transform.localEulerAngles.z)
        lastBackRot[index]=back[index].transform.localRotation
        newBackRot[index]= Quaternion.Euler(back[index].transform.localEulerAngles.x+targetRotation, back[index].transform.localEulerAngles.y, back[index].transform.localEulerAngles.z)
    end
end
if callType == LuaCallType.Update then
    --Continuous movement code
    for i, folder in pairs(g_folder) do
        if animating[i] then
            animationTimer[i]=animationTimer[i]+Time.deltaTime
            local progress = animationTimer[i]/animationDuration
            if (animationTimer[i]>animationDuration) then
                animationTimer[i]=animationDuration
                animating[i]=false
                switchActive[i]=true
            end
            cover[i].transform.localRotation=Quaternion.Slerp(lastCoverRot[i],newCoverRot[i],progress)
            --back[i].transform.localRotation=Quaternion.Slerp(lastBackRot[i],newBackRot[i],progress)
        end
    end
end