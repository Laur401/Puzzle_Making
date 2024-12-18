--[[
    Author: GG3L (@GGӡL)
    Script: Book
    Description: This script adds the possibility to create a book that can be opened.
    
    Permission is granted to use this script in custom rooms for Escape Simulator, provided that:
    - Credit is given to the author.
    - Neither this header nor the code is modified.

    Unauthorized distribution or modification is prohibited.
    All rights reserved by the author.
]]
if callType == LuaCallType.Init then
	flatCamera = book[1].gameObject.Find('MainCamera')
	mainCamera = book[1].gameObject.FindGameObjectWithTag('MainCamera')
	isPlayerVR = false
	if flatCamera ~= mainCamera then
		isPlayerVR = true
	end
	rotAmount = 85
	posOffset = .024
	animDuration = 1
	spine = {}
	coverFront = {}
	coverBack = {}
	pagesFront = {}
	pagesBack = {}
	bookElm = {}
	bookState = {}
	bookAnimating = {}
	switchActive = {}
	bookStart = {}
	lastCoverRotation = {}
	lastPaperRotation = {}
	lastPaperPosition = {}
	newCoverRotation = {}
	newPaperRotation = {}
	newPaperPosition = {}
	animTimer = {}
	for i, b in pairs(book) do
		spine[i] = b.transform.GetChild(0).transform.Find('Spine')
		coverFront[i] = b.transform.GetChild(0).transform.Find('CoverFront')
		coverBack[i] = b.transform.GetChild(0).transform.Find('CoverBack')
		pagesFront[i] = b.transform.GetChild(0).transform.Find('PagesFront')
		pagesBack[i] = b.transform.GetChild(0).transform.Find('PagesBack')
		bookElm[i] = api.getElement(b)
		bookElm[i].soundPickup = 'event:/SFX/VICTORIAN/VICTORIAN1/Book/bookPickUp'
		bookElm[i].soundPlace = 'event:/SFX/VICTORIAN/VICTORIAN1/Book/bookDrop'
		bookElm[i].soundThrowOrDrop = 'event:/SFX/VICTORIAN/VICTORIAN1/Book/bookDrop'
		bookElm[i].soundOrbit = 'event:/SFX/VICTORIAN/VICTORIAN1/Book/bookOrbit'
		bookElm[i].soundHit = 'event:/SFX/VICTORIAN/VICTORIAN1/Book/bookHit'
		bookElm[i].pinScaleModifier = .7
		bookElm[i].boundsUpdate = 3
		bookElm[i].groundEulerAngles = api.vector3(90, 180, 0)
		bookElm[i].eulerAnglesHandEnabled = true
		b.pivot = b.transform
		b.originalTransform = b.transform
		bookState[i] = 0
		bookAnimating[i] = false
		switchActive[i] = true
		bookStart[i] = 0
		if not isPlayerVR then
			b.remoteOnly = false
			bookSwitchFront[i].gameObject.SetActive(false)
			bookSwitchBack[i].gameObject.SetActive(false)
		else
			bookSwitchFront[i].transform.parent = coverFront[i]
			bookSwitchBack[i].transform.parent = coverBack[i]
			bookSwitchFront[i].pivot = bookSwitchFront[i].transform
			bookSwitchFront[i].originalTransform = bookSwitchFront[i].transform
			bookSwitchBack[i].pivot = bookSwitchBack[i].transform
			bookSwitchBack[i].originalTransform = bookSwitchBack[i].transform
		end
		lastCoverRotation[i] = {
			Quaternion.identity,
			Quaternion.identity
		}
		lastPaperRotation[i] = {
			Quaternion.identity,
			Quaternion.identity
		}
		lastPaperPosition[i] = {
			Vector3.zero,
			Vector3.zero
		}
		newCoverRotation[i] = {
			Quaternion.identity,
			Quaternion.identity
		}
		newPaperRotation[i] = {
			Quaternion.identity,
			Quaternion.identity
		}
		newPaperPosition[i] = {
			Vector3.zero,
			Vector3.zero
		}
		animTimer[i] = 0
	end
	function lerp(start, stop, t)
		return start + (stop - start) * t
	end
	function easeInOut(t)
		if t < 0.5 then
			return 2 * t * t
		end
		return -1 + (4 - 2 * t) * t
    end
	function getIndex(context)
        local element = context.gameObject.GetComponent('Element')
        local index = string.match(element.playerVariableName, "{(%d+)}")
        return tonumber(index)
    end
end
if callType == LuaCallType.SwitchDone then
	if api.contains(book, context) or api.contains(bookSwitchFront, context) or api.contains(bookSwitchBack, context) and context.isOn then
		local index = getIndex(context)
		if bookAnimating[index] or not switchActive[index] then return end
		bookStart[index] = Time.time
		switchActive[index] = false
		local targetRotation = rotAmount
		local targetPosition = posOffset
		if bookState[index] == 1 then
			bookState[index] = 0
			targetRotation = -targetRotation
			targetPosition = -targetPosition
			bookElm[index].eulerAnglesTarget = Vector3.zero
			bookElm[index].groundEulerAngles = api.vector3(90, 180, 0)
			bookElm[index].eulerAnglesHand = api.vector3(0, 0, 0)
		else
			bookState[index] = 1
			bookElm[index].eulerAnglesTarget = api.vector3(0, 90, 0)
			bookElm[index].groundEulerAngles = api.vector3(0, 270, 90)
			bookElm[index].eulerAnglesHand = api.vector3(0, 90, 0)
		end
		newCoverRotation[index][1] = Quaternion.Euler(
			coverFront[index].transform.localEulerAngles.x,
			coverFront[index].transform.localEulerAngles.y + targetRotation,
			coverFront[index].transform.localEulerAngles.z
		)
		lastCoverRotation[index][1] = coverFront[index].transform.localRotation
		newCoverRotation[index][2] = Quaternion.Euler(
			coverBack[index].transform.localEulerAngles.x,
			coverBack[index].transform.localEulerAngles.y - targetRotation,
			coverBack[index].transform.localEulerAngles.z
		)
		lastCoverRotation[index][2] = coverBack[index].transform.localRotation
		newPaperRotation[index][1] = Quaternion.Euler(
			pagesFront[index].transform.localEulerAngles.x,
			pagesFront[index].transform.localEulerAngles.y + targetRotation,
			pagesFront[index].transform.localEulerAngles.z
		)
		lastPaperRotation[index][1] = pagesFront[index].transform.localRotation
		newPaperRotation[index][2] = Quaternion.Euler(
			pagesBack[index].transform.localEulerAngles.x,
			pagesBack[index].transform.localEulerAngles.y - targetRotation,
			pagesBack[index].transform.localEulerAngles.z
		)
		lastPaperRotation[index][2] = pagesBack[index].transform.localRotation
		newPaperPosition[index][1] = api.vector3(
			pagesFront[index].transform.localPosition.x + targetPosition,
			pagesFront[index].transform.localPosition.y,
			pagesFront[index].transform.localPosition.z
		)
		lastPaperPosition[index][1] = pagesFront[index].transform.localPosition
		newPaperPosition[index][2] = api.vector3(
			pagesBack[index].transform.localPosition.x + targetPosition,
			pagesBack[index].transform.localPosition.y,
			pagesBack[index].transform.localPosition.z
		)
		lastPaperPosition[index][2] = pagesBack[index].transform.localPosition
		api.setLockValue(bookOpen[index], 1, 1)
		animTimer[index] = 0
		bookAnimating[index] = true
	end
end
if callType == LuaCallType.Update then
	for i, b in pairs(book) do
		if bookAnimating[i] then
			animTimer[i] = animTimer[i] + Time.deltaTime
			local t = animTimer[i] / animDuration
			t = easeInOut(t)
			if animTimer[i] > animDuration then
				animTimer[i] = animDuration
				bookAnimating[i] = false
				switchActive[i] = true
			end
			if bookState[i] == 1 then
				bookElm[i].zoomScaleModifier = lerp(1, 1.4, t)
			else
				bookElm[i].zoomScaleModifier = lerp(1.4, 1, t)
			end
			coverFront[i].transform.localRotation = Quaternion.Slerp(
				lastCoverRotation[i][1],
				newCoverRotation[i][1],
				t
			)
			coverBack[i].transform.localRotation = Quaternion.Slerp(
				lastCoverRotation[i][2],
				newCoverRotation[i][2],
				t
			)
			pagesFront[i].transform.localRotation = Quaternion.Slerp(
				lastPaperRotation[i][1],
				newPaperRotation[i][1],
				t
			)
			pagesBack[i].transform.localRotation = Quaternion.Slerp(
				lastPaperRotation[i][2],
				newPaperRotation[i][2],
				t
			)
			pagesFront[i].transform.localPosition = Vector3.Lerp(
				lastPaperPosition[i][1],
				newPaperPosition[i][1],
				t
			)
			pagesBack[i].transform.localPosition = Vector3.Lerp(
				lastPaperPosition[i][2],
				newPaperPosition[i][2],
				t
			)
		end
	end
end
