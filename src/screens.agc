Function CreatePuzzleSelect()
    i as integer
    j as integer


    //black screen
    CreateSprite(101, 102)
    SetSpriteSize(101, virtMax, virtMin)
    FixSpriteToScreen(101, 1)
    SetSpriteDepth(101, 11)
    SetSpriteVisible(101, 0)
    SetSpriteColor(101, 0, 0, 0, 128)

    //create back button icon
        CreateSprite(199, 217)
        SetSpriteSize(199, VirtMinSize(96), VirtMinSize(96))
        SetSpriteOffset(199, VirtMinSize(48), VirtMinSize(48))
        SetSpritePositionByOffset(199, VirtMinSize(64), virtMin - VirtMinSize(64))
        FixSpriteToScreen(199, 1)
        SetSpriteVisible(199, 0)

    //create level selection icons + text
    iconStart as integer
    iconStart = 200
    hCount as integer
    vCount as integer

    hCount = floor(virtMax / VirtMinSize(128))
    vCount = floor(virtMin / VirtMinSize(128))

    hSize as integer
    hSize = (virtMax / hCount) * .5
    vSize as integer
    vSize = (virtMin / vCount) * .5

    vCount = vCount - 1

    //rem we only want three rows of levels
    if vCount >= 4
        vCount = 3
    endif

    for i = 0 to vCount - 1
        for j = 0 to hCount - 1
            CreateSprite(iconStart, 220)
            SetSpriteSize(iconStart,  VirtMinSize(96),  VirtMinSize(96))
            SetSpriteOffset(iconStart, GetSpriteWidth(iconStart) * .5, GetSpriteHeight(iconStart) * .5)
            SetSpritePositionByOffset(iconStart, (hSize * 2 * j) + hSize, (vSize * 2 * i) + vSize)
            FixSpriteToScreen(iconStart, 1)
            SetSpriteDepth(iconStart, 13)
            CreateText(iconStart, "123")
            SetTextSize(iconStart, 32)
            FixTextToScreen(iconStart, 1)
            SetTextAlignment(iconStart, 1)
            SetTextDepth(iconStart, 12)
            SetTextPosition(iconStart, GetSpriteXByOffset(iconStart), GetSpriteY(iconStart) + 16 )
            iconStart = iconStart + 1
            puzzleSelectItems = puzzleSelectItems + 1
        next
    next

    puzzleSelectPages = floor(levelCount / puzzleSelectItems) + 1
endfunction

function UpdatePuzzleSelect()
    i as integer
    j as integer

    currentCount as integer
    currentCount = 0

    puzzleSelectIndex = puzzleSelectActivePage *puzzleSelectItems
    for i = 200 to (200 + puzzleSelectItems - 1)

         if currentCount + puzzleSelectIndex < levelCount
            SetSpriteVisible(i, 1)
            SetTextVisible(i, 1)
             SetTextString(i, str(levelList[currentCount + puzzleSelectIndex].id + 1))
            UpdatePuzzleSelectSprite(i, levelList[currentCount + puzzleSelectIndex].id)
              currentCount = currentCount + 1
         else
            SetSpriteVisible(i, 0)
            SetTextVisible(i, 0)
         endif

    next
endfunction

function UpdatePuzzleSelectSprite(pSpriteID, pLevelID)
    i as integer
    j as integer
 SetSpriteImage(pSpriteID, 220 )
    for i = 0 to levelCount - 1

        if scoreList[i].id = pLevelID
            SetSpriteImage(pSpriteID, 220 +  scoreList[i].rank)
            exit
        endif
    next
endfunction
function SetPuzzleSelectVisible(pVisible)
    i as integer

    SetSpriteVisible(199, pVisible)
    for i =  200 to (200 + puzzleSelectItems - 1)
        SetSpriteVisible(i, pVisible)
        SetTextVisible(i, pVisible)
    next

SetScrollIconsVisible(pVisible)
    if pVisible = 1
        UpdatePuzzleSelect()
    endif
endfunction

function RenderPuzzleSelect()
    i as integer
    stayInMenu as integer
    stayInMenu = 1
    CreateScrollIcons(puzzleSelectPages)
    SetScrollIconActive(0)

    while stayInMenu = 1
        UpdateCursor()
        UpdateScreenResolution()

        if CheckSpritePointerCollision(199) = 1
            stayInMenu = 0
        endif

        if GetCursorSwipeX(25) = -1
            if puzzleSelectActivePage > 0
                puzzleSelectActivePage = puzzleSelectActivePage - 1
            endif

            UpdatePuzzleSelect()
        endif

        if GetCursorSwipeX(25) = 1
            if puzzleSelectActivePage < puzzleSelectPages - 1
                puzzleSelectActivePage = puzzleSelectActivePage + 1
            endif

            UpdatePuzzleSelect()

        endif


            for i = 200 to (200 + puzzleSelectItems - 1)
                if CheckSpritePointerCollision(i) >= 1
                    if GetCursorPress() = 1
                        levelSelectPress = puzzleSelectIndex + (i - 200)
                        levelSelectRelease = -1
                   endif

                   if GetCursorRelease() = 1
                        levelSelectRelease = puzzleSelectIndex + (i - 200)
                    endif


                endif


            next

            if GetCursorState() = 0 and levelSelectPress >= 0 and levelSelectRelease >= 0
                        if levelSelectPress = levelSelectRelease
                            levelActive =levelSelectRelease
                            levelSelectPress = -1
                            RenderGameplay()
                            StopMusicPref()
                            PlayMusicPref(10, 1)
                        endif
                    endif


        sync()
            SetScrollIconActive(puzzleSelectActivePage)
    endwhile
endfunction


Function CreateGameplayScreen()
    //Create gameplay sprite
    CreateSprite(LEVEL_SPRITE, 0)
    SetSpriteDepth(LEVEL_SPRITE, 14)
    SetSpriteVisible(LEVEL_SPRITE, 0)
    FixSpriteToScreen(LEVEL_SPRITE, 0)

    //create gameplay icons
    //scroll
    CreateSprite(110, 200)
    SetSpriteDepth(110, 13)
    FixSpriteToScreen(110, 1)
    SetSpriteSize(110, VirtMinSize(96),  VirtMinSize(96))
    SetSpritePosition(110, VirtMinSize(16), VirtMinSize(16))

    CreateText(110, " ")
    SetTextDepth(110, 10)
    FixTextToScreen(110, 1)
    SetTextSize(110, VirtMinSize(64))
    SetTextAlignment(110, 1)
    SetTextPosition(110, virtMax * .5, virtMin * .5 - (GetTextTotalHeight(110) * .5))
    //bomb

    CreateSprite(111, 203)
    SetSpriteDepth(111, 13)
    FixSpriteToScreen(111, 1)
    SetSpriteSize(111, GetSpriteWidth(110), GetSpriteHeight(110))
    SetSpritePosition(111, VirtMinSize(16), VirtMinSize(32 + GetSpriteHeight(110)))

    CreateText(111, "999")
    SetTextSize(111, VirtMinSize(24))
    SetTextAlignment(111, 2)
    FixTextToScreen(111, 1)
    SetTextPosition(111, GetSpriteX(111) + GetSpriteWidth(111), GetSpriteY(111) + GetSpriteHeight(111) - GetTextTotalHeight(111))
    SetTextDepth(111, 12)
    //build
    CreateSprite(112, 205)
    SetSpriteDepth(112, 13)
    FixSpriteToScreen(112, 1)
    SetSpriteSize(112, GetSpriteWidth(110), GetSpriteHeight(110))
    SetSpritePosition(112, VirtMinSize(16), VirtMinSize(48 + (GetSpriteHeight(110) * 2)))

    CreateText(112, "999")
    SetTextSize(112, VirtMinSize(24))
    SetTextAlignment(112, 2)
    FixTextToScreen(112, 1)
    SetTextPosition(112, GetSpriteX(112) + GetSpriteWidth(112), GetSpriteY(112) + GetSpriteHeight(112) - GetTextTotalHeight(112))
    SetTextDepth(112, 12)

    //water
    CreateSprite(114, 207)
    SetSpriteDepth(114, 13)
    FixSpriteToScreen(114, 1)
    SetSpriteSize(114, GetSpriteWidth(110), GetSpriteHeight(110))
    SetSpritePosition(114, VirtMinSize(16), virtMin - VirtMinSize(16 + GetSpriteHeight(110)))

    CreateText(114, "999")
    SetTextSize(114, VirtMinSize(24))
    SetTextAlignment(114, 2)
    FixTextToScreen(114, 1)
    SetTextPosition(114, GetSpriteX(114) + GetSpriteWidth(114), GetSpriteY(114) + GetSpriteHeight(114) - GetTextTotalHeight(114))
    SetTextDepth(114, 12)

    //info
    CreateSprite(113, 209)
    SetSpriteDepth(113, 10)
    FixSpriteToScreen(113, 1)
    SetSpriteSize(113, GetSpriteWidth(110), GetSpriteHeight(110))
    SetSpritePosition(113, virtMax - VirtMinSize(16) - GetSpriteWidth(110), VirtMinSize(16))

    SetGameplayVisible(0)
endfunction

function SetGameplayVisible(pVisible)
    i as integer

    SetSpriteVisible(LEVEL_SPRITE, pVisible)
    for i = 110 to 114
        SetSpriteVisible(i, pVisible)

        if GetTextExists(i) = 1
            SetTextVisible(i, pVisible)
        endif
    next
endfunction

function PrepGameplayScreen()
    //rem water droplet
    SetSpriteImage(114, 207)
    //rem info
    SetSpriteDepth(113, 12)
    worldScrollX = virtMax * .5 - levelSize.X
    worldScrollY = virtMin * .5 - levelSize.Y
    levelWaterDropping = 1
    levelWaterDropTimer = 0

    ResetGameplayIcons(1, 0, 0, 0)
    gameplayInteraction = 0

    SetSpriteVisible(101, 1)
endfunction

function CreatePauseScreen()
    i as integer

    for i = 300 to 302
        CreateSprite(i, 280)
        FixSpriteToScreen(i, 1)
        SetSpriteSize(i, VirtMinSize(512), VirtMinSize(512))
        SetSpriteOffset(i, VirtMinSize(256), VirtMinSize(256))
        SetSpritePositionByOffset(i, virtMax * .5, virtMin * .5)
        SetSpriteDepth(i, 10)
        SetSpriteVisible(i, 0)
    next

    SetSpriteDepth(301, 9)
    SetSpriteImage(301, 281)

    SetSpriteDepth(302, 8)
    SetSpriteImage(302, 281)

    for i = 300 to 302
        CreateText(i, str(i))
        SetTextAlignment(i, 1)
        SetTextDepth(i, 9)
        SetTextVisible(i, 0)
        SetTextSize(i, virtMinSize(64))
        FixTextToScreen(i, 1)
    next

    SetTextPosition(300, virtMax * .5, (virtMin * .5)  - virtMinSize(192) - (virtMinSize(GetTextTotalHeight(300) * .7)))
    SetTextPosition(301, virtMax * .5, (virtMin * .5) + (virtMinSize(64)) - (virtMinSize(GetTextTotalHeight(301) * .5)) )
    SetTextSize(301, VirtMinSize(64))
    SetTextPosition(302, virtMax * .5, (virtMin * .5) + (virtMinSize(96)))
    SetTextSize(302, VirtMinSize(48))

    for i = 303 to 306
        CreateSprite(i, 211)
        FixSpriteToScreen(i, 1)
        SetSpriteSize(i, VirtMinSize(96), VirtMinSize(96))
        SetSpriteOffset(i, VirtMinSize(48), VirtMinSize(48))
        SetSpriteDepth(i, 9)
        SetSpriteVisible(i, 0)
    next

        SetSpritePositionByOffset(303, VirtMax * .5 - VirtMinSize(192), (virtMin * .5) + (virtMinSize(192)))
        SetSpritePositionByOffset(304, VirtMax * .5, (virtMin * .5) + (virtMinSize(192)))
        SetSpritePositionByOffset(305, VirtMax * .5 +   VirtMinSize(96), (virtMin * .5) + (virtMinSize(192)))
        SetSpritePositionByOffset(306, VirtMax * .5 +  VirtMinSize(192), (virtMin * .5) + (virtMinSize(192)))

        SetSpriteImage(304, 213)
        SetSpriteImage(305, 212)
        SetSpriteImage(306, 216)
endfunction

function PrepareSuccessMenu()
    i as integer
    tImage as integer
    tImage = GetToggleMusicImage(214, 215)
    SetSpriteDepth(113, 10)
    SetSpriteVisible(101, 1)
    SetSpriteVisible(300, 1)
    SetSpriteVisible(301, 1)
    SetSpriteVisible(302, 1)
    SetSpriteDepth(113, 13)
    SetSpriteImage(302, 281)

    SetTextVisible(300, 1)
    SetTextVisible(301, 1)
    SetTextVisible(302, 1)
    SetTextString(300, GetTextLibraryString(9))
    SetTextString(302, GetTextLibraryString(6) + Str(scoreList[levelActive].score))
    SetSpriteImage(303, tImage)
    for i = 303 to 306
        SetSpriteVisible(i, 0)
    next


endfunction

function RenderSuccess()
    tTimer as float
    oldTimer as float

    i as integer
    active as integer
    active = 1
    selection as integer
    selection = 0

    tempScore as integer
    progressScore as integer
    progressAdd as integer

    progressScore = 0

    tempScore = dropletCollected * 50
    tempScore = tempScore + (levelBombCount * 20)
    tempScore = tempScore + (levelBuildCount * 20)
    tempScore = tempScore + (levelTimerCount * 150)
    progressAdd = tempScore * .5

    tempRank as integer

    PrepareSuccessMenu()

    if tempScore > levelScoreA
        tempRank = 3
    elseif tempScore > levelScoreB
        tempRank = 2
    else
        tempRank = 1
    endif

    StopMusicPref()
    PlaySoundPref(20 + tempRank)
    while tTimer <= 2.1
        oldTimer = tTimer
        tTimer = tTimer + GetFrameTime()
        progressScore = progressScore + (progressAdd * GetFrameTime() * .9)
        SetTextString(301, str((floor(progressScore))))

        if tempRank = 3 and tTimer >= 2.0
            SetSpriteImage(302, 284)
        endif

        if tempRank >= 2 and oldTimer <= 1.64 and tTimer >= 1.64
            SetSpriteImage(302, 283)
        endif

        if oldTimer <= 1.294 and tTimer >= 1.294
            SetSpriteImage(302, 282)
        endif

        sync()
    endwhile


    SetTextString(301, str(tempScore))

    If tempScore > scoreList[levelActive].score
        SetTextString(302, GetTextLibraryString(7))
        PlaySoundPref(10)
    endif
        SetLevelScore(levelActive, tempScore, tempRank)
    for i = 303 to 306
        SetSpriteVisible(i, 1)
    next

    while active = 1

        UpdateCursor()
        UpdateScreenResolution()


        //rem sound check
        if CheckSpritePointerCollision(303) = 1
            ToggleMusicSFX(303, 214, 215)
            //SetSpriteImage(303, GetToggleMusicImage(214, 215))
        endif

        //rem main menu
        if CheckSpritePointerCollision(304) = 1
            gameplayInteraction = 0
            levelReload = 0
            levelLoop = 0
            active = 0
                SetGameplayVisible(0)
        endif

        //rem reload
        if CheckSpritePointerCollision(305) = 1
            levelReload = 1
            levelLoop = 0
            gameplayInteraction = 0
            active = 0
                SetGameplayVisible(0)
        endif

        //rem next
        if CheckSpritePointerCollision(306) = 1
            active = 0
            levelReload = 1
            levelLoop = 0
             SetGameplayVisible(0)
            ProgressNextLevel()
            gameplayInteraction = 0

        endif

        sync()
    endwhile

    HidePauseMenu()
endfunction


function PreparePauseMenu()
    i as integer
    tImage as integer
    tImage = GetToggleMusicImage(214, 215)
    SetSpriteDepth(113, 10)
    SetSpriteVisible(101, 1)
    SetSpriteVisible(300, 1)
    SetTextVisible(300, 1)
    SetTextVisible(302, 1)
    SetTextString(300, GetTextLibraryString(5))
    SetTextString(302, GetTextLibraryString(6) + Str(scoreList[levelActive].score))

    for i = 303 to 306
        SetSpriteVisible(i, 1)
    next

    SetSpriteImage(303, tImage)
endfunction

function RenderPause()
    i as integer
    active as integer
    active = 1
    selection as integer
    selection = 0

    PreparePauseMenu()

    while active = 1

        UpdateCursor()
        UpdateScreenResolution()

        //rem hide menu
        if CheckSpritePointerCollision(113) = 1
            gameplayInteraction = 0
            active = 0
            selection = 0
            ResetGameplayIcons(1, 0, 0, 0)
        endif

        //rem sound check
        if CheckSpritePointerCollision(303) = 1
            ToggleMusicSFX(303, 214, 215)
            //SetSpriteImage(303, GetToggleMusicImage(214, 215))
        endif

        //rem main menu
        if CheckSpritePointerCollision(304) = 1
            gameplayInteraction = 0
            levelReload = 0
            levelLoop = 0
            active = 0
                SetGameplayVisible(0)
        endif

        //rem reload
        if CheckSpritePointerCollision(305) = 1
            levelReload = 1
            levelLoop = 0
            gameplayInteraction = 0
            active = 0
            SetGameplayVisible(0)
        endif

        //rem next
        if CheckSpritePointerCollision(306) = 1
            active = 0
            levelReload = 1
            levelLoop = 0
             SetGameplayVisible(0)
            ProgressNextLevel()
            gameplayInteraction = 0

        endif

        sync()
    endwhile

    HidePauseMenu()
endfunction

function HidePauseMenu()
    i as integer
    SetspriteVisible(101, 0)
    for i = 300 to 306
        If GetSpriteExists(i) = 1
            SetSpriteVisible(i, 0)
        endif

        if GetTextExists(i) = 1
            SetTextVisible(i, 0)
        endif
    next
endfunction


function PrepareFailedMenu()
    i as integer
    tImage as integer
    tImage = GetToggleMusicImage(214, 215)
    SetSpriteDepth(113, 12)
    SetSpriteVisible(101, 1)
    SetSpriteVisible(300, 1)
    SetTextVisible(300, 1)
    SetTextVisible(302, 1)
    SetTextString(300, GetTextLibraryString(8))
    SetTextString(302, GetTextLibraryString(6) + Str(scoreList[levelActive].score))

    for i = 303 to 306
        SetSpriteVisible(i, 1)
    next

    SetSpriteImage(303, tImage)
endfunction

function RenderFailure()
    i as integer
    active as integer
    active = 1
    selection as integer
    selection = 0

    StopMusicPref()
    PlaySoundPref(12)
    PrepareFailedMenu()

    while active = 1

        UpdateCursor()
        UpdateScreenResolution()

        //rem sound check
        if CheckSpritePointerCollision(303) = 1
            ToggleMusicSFX(303, 214, 215)
            //SetSpriteImage(303, GetToggleMusicImage(214, 215))
        endif

        //rem main menu
        if CheckSpritePointerCollision(304) = 1
            gameplayInteraction = 0
            levelReload = 0
            levelLoop = 0
            active = 0
                SetGameplayVisible(0)
        endif

        //rem reload
        if CheckSpritePointerCollision(305) = 1
            levelReload = 1
            levelLoop = 0
            gameplayInteraction = 0
            active = 0
                SetGameplayVisible(0)
        endif

        //rem next
        if CheckSpritePointerCollision(306) = 1
            active = 0
            levelReload = 1
            levelLoop = 0
            SetGameplayVisible(0)
            ProgressNextLevel()
            gameplayInteraction = 0

        endif

        sync()
    endwhile

    HidePauseMenu()
endfunction

function CreateScrollIcons(pCount as integer)
    i as integer
    origin as float

    for i = 0 to scrollIconCount - 1
        DeleteSprite(i + 400)
    next
    scrollIconCount = pCount
 origin = VirtMinSize(16) * ((scrollIconCount - 1) * .5)

    for i = 0 to ScrollIconCount - 1
        CreateSprite(i + 400,  230 )
        SetSpriteSize(i + 400,  VirtMinSize(16),  VirtMinSize(16))
        FixSpriteToScreen(i + 400, 1)
        SetSpriteOffset(i + 400,  VirtMinSize(8),  VirtMinSize(8))
        SetSpritePosition(i + 400, (virtMax * .5) - origin + (VirtMinSize(16) * i), virtMin - VirtMinSize(32))
    next

endfunction

function SetScrollIconsVisible(pVisible as integer)
    i as integer
    origin as float

    for i = 0 to scrollIconCount - 1
        SetSpriteVisible(400 + i, pVisible)
    next
endfunction


function SetScrollIconActive(pIcon as integer)
    i as integer
    origin as float

    for i = 0 to scrollIconCount - 1
        SetSpriteImage(i + 400, 230)
    next

    SetSpriteImage(400 + pIcon, 231)
endfunction

function CreateMainMenu()
    //bg screen
    CreateSprite(100, 100)
    SetSpriteSize(100, virtMax, virtMin)
    FixSpriteToScreen(100, 1)
    SetSpriteDepth(100, 15)

    //logo
    CreateSprite(500, 103)
    SetSpriteSize(500, VirtMinSize(512), VirtMinSize(128))
    FixSpriteToScreen(500, 1)
    SetSpriteOffset(500, VirtMinSize(256), VirtMinSize(64))
    SetSpritePositionByOffset(500, VirtMinSize(virtMax * .5), VirtMinSize(virtMin * .2))

    //create text buttons

    CreateText(500, "Level Select")
    FixTextToScreen(500, 1)
    SetTextAlignment(500, 1)
    SetTextSize(500, 64)
    SetTextPosition(500,  VirtMinSize(virtMax * .5), VirtMinSize(virtMin * .75) - VirtMinSize(GetTextTotalHeight(500) * 2.5))

    CreateText(501, "How to Play")
    FixTextToScreen(501, 1)
    SetTextAlignment(501, 1)
    SetTextSize(501, 64)
    SetTextPosition(501,  VirtMinSize(virtMax * .5), VirtMinSize(virtMin * .75) - VirtMinSize(GetTextTotalHeight(501) * 1.5))

    CreateText(502, "About")
    FixTextToScreen(502, 1)
    SetTextAlignment(502, 1)
    SetTextSize(502, 64)
    SetTextPosition(502,  VirtMinSize(virtMax * .5), VirtMinSize(virtMin * .75) - VirtMinSize(GetTextTotalHeight(502) * .5))

 CreateText(503, "Language Select")
    FixTextToScreen(503, 1)
    SetTextAlignment(503, 1)
    SetTextSize(503, 64)
    SetTextPosition(503,  VirtMinSize(virtMax * .5), VirtMinSize(virtMin * .75) + VirtMinSize(GetTextTotalHeight(503) * .5))

endfunction

function SetMainMenuVisible(pVisible)
    i as integer
    SetSpriteVisible(500, pVisible)

    for i = 500 to 503
        SetTextVisible(i, pVisible)
    next

endfunction

function RenderMainMenu()
    i as integer
    SetMainMenuVisible(1)

    for i = 500 to 503

        if CheckTextClick(i, -1) = 1
            if i = 500
                SetMainMenuVisible(0)
                sync()
                                 UpdateCursor()
                 sync()
                SetPuzzleSelectVisible(1)
                RenderPuzzleSelect()
                SetPuzzleSelectVisible(0)
                SetMainMenuVisible(1)
            elseif i = 501
              SetMainMenuVisible(0)
                RenderImageScroll(240, 4)
              SetMainMenuVisible(1)

            elseif i = 502
                SetMainMenuVisible(0)
                RenderImageScroll(240, 4)
                SetMainMenuVisible(1)
            elseif i = 503
                SetMainMenuVisible(0)
                 sync()
                 UpdateCursor()
                 sync()
                RenderLanguageSelect()
                                 sync()
                 UpdateCursor()
                 sync()
                SetMainMenuVisible(1)
            endif
        endif
    next

endfunction

function CreateImageScroll()
        CreateSprite(600, 0)
        SetSpriteSize(600,  VirtMinSize(512),  VirtMinSize(512))
        FixSpriteToScreen(600, 1)
        SetSpriteOffset(600,  VirtMinSize(256),  VirtMinSize(256))
        SetSpritePositionByOffset(600, virtMax * .5, virtMin * .5)
        SetSpriteVisible(600, 0)

        CreateSprite(601, 211)
        SetSpriteSize(601, VirtMinSize(96), VirtMinSize(96))
        SetSpriteOffset(601, VirtMinSize(48), VirtMinSize(48))
        SetSpritePositionByOffset(601, virtMax - VirtMinSize(64), virtMin - VirtMinSize(64))
        FixSpriteToScreen(601, 1)
        SetSpriteVisible(601, 0)
endfunction

function SetImageScrollVisible(pVisible)
    SetSpriteVisible(600, pVisible)
    SetSpriteVisible(601, pVisible)
endfunction


function RenderImageScroll(pStart, pCount)
    looping as integer
    looping = 1
    currentCount as integer

    CreateScrollIcons(pCount)
    SetScrollIconActive(0)
    SetImageScrollVisible(1)

    while looping = 1
        UpdateCursor()
        UpdateScreenResolution()

        if GetCursorSwipeX(25) = -1
            if currentCount > 0
                currentCount = currentCount - 1
            endif
        endif

        if GetCursorSwipeX(25) = 1
            if currentCount < pCount - 1
                currentCount = currentCount + 1
            endif

        endif
        SetSpriteImage(600, pStart + currentCount)
        SetSpriteSize(600, GetImageWidth(pStart + currentCount), GetImageHeight(pStart + currentCount))
        SetSpriteOffset(600, GetSpriteWidth(600) * .5, GetSpriteHeight(600) * .5)
        SetSpritePositionByOffset(600, virtMax * .5, virtMin * .5)

        SetScrollIconActive(currentCount)

        if CheckSpritePointerCollision(601) = 1
            looping = 0
        endif

        sync()
    endwhile

    SetScrollIconsVisible(0)
    SetImageScrollVisible(0)
endfunction

function CreateLanguageSelect()
    i as integer

    for i = 700 to 703
        CreateSprite(i, 0)
        SetSpriteSize(i,  VirtMinSize(virtMin * .4),  VirtMinSize(virtMin * .4))
        FixSpriteToScreen(i, 1)
        SetSpriteOffset(i,  VirtMinSize(virtMin * .2),  VirtMinSize(virtMin * .2))
        SetSpriteVisible(i, 0)
    next

    SetSpriteImage(700, 104)
    SetSpriteImage(701, 105)
    SetSpriteImage(702, 106)
    SetSpriteImage(703, 107)
    SetSpritePositionByOffset(700, VirtMinSize(virtMax * .25), VirtMinSize(virtMin * .25))
    SetSpritePositionByOffset(701, VirtMinSize(virtMax * .75), VirtMinSize(virtMin * .25))
    SetSpritePositionByOffset(702, VirtMinSize(virtMax * .25), VirtMinSize(virtMin * .75))
    SetSpritePositionByOffset(703, VirtMinSize(virtMax * .75), VirtMinSize(virtMin * .75))
endfunction

function SetLanguageSelectVisible(pVisible)
    for i = 700 to 703
        SetSpriteVisible(i, pVisible)
    next

endfunction

function RenderLanguageSelect()
    didSelectLanguage = -1

    SetLanguageSelectVisible(1)

    while didSelectLanguage = -1
        for i = 700 to 703
            if (CheckSpritePointerCollision(i) = 1)
                didSelectLanguage = i - 700
            endif
        next

        UpdateCursor()
        UpdateScreenResolution()
        sync()
    endwhile

        sync()
        UpdateCursor()
        UpdateScreenResolution()
        sync()

    SetLanguageSelectVisible(0)
    languageSelect = didSelectLanguage
    WriteLanguageFile()
    UpdateMenuText()
     sync()
      UpdateCursor()
 sync()

endfunction

function UpdateMenuText()
    if languageSelect = 0
        LoadTextFromCSV("lang/eng.txt")
    elseif languageSelect = 1
        LoadTextFromCSV("lang/french.txt")
    elseif languageSelect = 2
        LoadTextFromCSV("lang/german.txt")
    elseif languageSelect = 3
        LoadTextFromCSV("lang/spanish.txt")
    endif

    SetTextString(500, GetTextLibraryString(1))
    SetTextString(501, GetTextLibraryString(2))
    SetTextString(502, GetTextLibraryString(3))
        SetTextString(503, GetTextLibraryString(4))
    SetTextString(110,  GetTextLibraryString(10))
endfunction
