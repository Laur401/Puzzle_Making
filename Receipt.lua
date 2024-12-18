---
--- Created by deck.
--- DateTime: 2024-12-12 15:01
---

if callType == LuaCallType.Init then
    for i, obj in pairs(g_receipt) do
        object=api.getElement(obj)
        object.zoomScaleModifier = .7
        object.pinScaleModifier = .3
        object.groundEulerAngles = api.vector3(0, 180, 270)
    end
end