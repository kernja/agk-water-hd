function UpdateDroplets()
    i as integer
    tX as integer
    tY as integer
    tXO as integer

    sortDroplets as integer
    sortDroplets = 0

    if dropletMade = 0
        exitfunction
    endif

    levelWaterDropping = 0

    for i = 0 to dropletMade
        if droplets[i].active = 1

            tX = droplets[i].X
            tY = droplets[i].Y

            if levelData[tX, tY] = 3
                rem remove droplet goal
                ClearImagePoint(tX, tY)
                droplets[i].active = 0
                levelWaterDropping = 1
                dropletCollected = dropletCollected + 1
            elseif tY + 1 >= levelSize.Y
                rem remove droplet as it fell off of the screen
                ClearImagePoint(tX, tY)
                levelData[tX, tY] = 0
                droplets[i].active = 0
                 sortDroplets = 1
                  levelWaterDropping = 1
                  dropletLost = dropletLost + 1
            elseif levelData[tX, tY + 1] = 0
                rem droplet is falling, empty out prior space to empty
                ClearImagePoint(tX, tY)
                levelData[tX, tY] = 0
                rem set new space to water
                droplets[i].Y = tY + 1
                levelData[tX, tY + 1] = 2
                SetImagePoint(tX, tY + 1, waterColor.R, waterColor.G, waterColor.B, waterColor.A)
                levelWaterDropping = 1
            elseif levelData[tX, tY + 1] = 3
                rem droplet is falling towards the goal
                rem droplet is falling, empty out prior space to empty
                ClearImagePoint(tX, tY)
                levelData[tX, tY] = 0
                rem set new space to water
                droplets[i].Y = tY + 1
                rem don't set level data to water though!
                  //ClearImagePoint(tX, tY)
                //SetImagePoint(tX, tY + 1, waterColor.R, waterColor.G, waterColor.B, waterColor.A)
                rem update simulation so that
                rem we don''t cancel out from inactivity
                levelWaterDropping = 1
            elseif levelData[tX, tY + 1] = 1 or levelData[tX, tY + 1] = 2
                rem droplet is on solid land
                rem decide to move left or right

                if random(1, 5) <= 4
                    if levelData[tX + 1, tY] = 1 or levelData[tX + 1, tY] = 2
                        rem go left
                            tXO = -1
                    else
                        rem go right
                            tXO = 1
                    endif
                else
                    if random(1, 2) = 1
                        rem go left
                            tXO = -1
                    else
                        rem go right
                            tXO = 1
                    endif
                endif

                if (tX + tXO < 0) or (tX + tXO = levelSize.X)
                    rem remove droplet as it fell off of the screen
                    ClearImagePoint(tX, tY)
                    levelData[tX, tY] = 0
                    droplets[i].active = 0
                    sortDroplets = 1
                    dropletLost = dropletLost + 1
                elseif levelData[tX + tXO, tY] = 0
                    rem droplet is falling, empty out prior space to empty
                    ClearImagePoint(tX, tY)
                    levelData[tX, tY] = 0
                    rem set new space to water
                    droplets[i].X = tX + tXO
                    levelData[tX + tXO, tY] = 2
                    SetImagePoint(tX + tXO, tY, waterColor.R, waterColor.G, waterColor.B, waterColor.A)
                elseif levelData[tX + tXO, tY] = 3
                    rem droplet is falling towards the goal
                    rem droplet is falling, empty out prior space to empty
                    ClearImagePoint(tX, tY)
                    levelData[tX, tY] = 0
                    rem set new space to water
                    droplets[i].X = tX + tXO
                    rem don't set level data to water though!
                   // SetImagePoint(tX + tXO, tY, waterColor.R, waterColor.G, waterColor.B, waterColor.A)
                endif

            endif
        else
            swapdroplets(i + 1)

            if droplets[i].active = 1
                i = i - 1
            endif
        endif
    next

    if levelWaterDropping = 0
        levelWaterDropTimer = levelWaterDropTimer + GetModifiedFrameTime()
    else
        levelWaterDropTimer = 0
    endif
   //if  sortDroplets = 1
     //   if random(1, 5) = 1
        //SortWaterDroplets()
       // endif
    //endif
endfunction

function CreateDroplets()
    i as integer

    if levelstartCount > 0
        levelstartCount = levelstartCount - GetModifiedFrameTime()
        exitFunction
    elseif levelStartCount < 0
        levelstartCount = 0
        SetSpriteImage(114, 210)
    endif

    for i = 0 to MAX_SOURCE - 1
        if levelSource[i].X >= 0

            if dropletMade < dropletCountMax
                if levelData[levelSource[i].X, levelSource[i].Y] = 0 or levelData[levelSource[i].X, levelSource[i].Y] = 5
                    levelData[levelSource[i].X, levelSource[i].Y] = 2
                    dropletMade = dropletMade + 1
                    AddDroplet(levelSource[i].X, levelSource[i].Y)
                    SetImagePoint(levelSource[i].X, levelSource[i].Y, waterColor.R, waterColor.G, waterColor.B, waterColor.A)
                endif
            else
                dropletStop = 1
            endif
        else
            exitfunction
        endif
    next
endfunction

function AddDroplet(pX, pY)
    i as integer

    if dropletStop = 0
        for i = 0 to MAX_DROPLETS - 1
            if droplets[i].active = 0
                droplets[i].active = 1
                droplets[i].X = pX
                droplets[i].Y = pY
                exit
            endif
        next
    endif
endfunction

function ClearDroplets()
    i as integer

    for i = 0 to MAX_DROPLETS - 1
        droplets[i].active = 0
    next

dropletMade = 0
dropletLost = 0
dropletCollected = 0

endfunction

function SortWaterDroplets()
    swapped as integer
    i as integer

    repeat
        swapped = 0

        for i = 1 to dropletMade

              if droplets[i - 1].active = 1 and droplets[i].active = 1
                    if droplets[i - 1].Y < droplets[i].Y
                        SwapDroplets(i)
                        swapped = 1
                    elseif droplets[i - 1].Y = droplets[i].Y
                        if droplets[i - 1].X < droplets[i].X
                            SwapDroplets(i)
                            swapped = 1
                        endif
                    endif
                elseif droplets[i - 1].active = 0 and droplets[i].active = 1
                    SwapDroplets(i)
                    swapped = 1
                endif
            `endif
        next

        for i =  dropletMade to 1 step - 1

                if droplets[i - 1].active = 1 and droplets[i].active = 1
                    if droplets[i - 1].Y < droplets[i].Y
                        SwapDroplets(i)
                        swapped = 1
                    elseif droplets[i - 1].Y = droplets[i].Y
                        if droplets[i - 1].X < droplets[i].X
                            SwapDroplets(i)
                            swapped = 1
                        endif
                    endif
                elseif droplets[i - 1].active = 0 and droplets[i].active = 1
                    SwapDroplets(i)
                    swapped = 1
                endif

        next
    until swapped = 0
endfunction

function SwapDroplets(i as integer)
    tX as integer
    tY as integer
    tActive as integer

    tX = droplets[i - 1].X
    tY = droplets[i - 1].Y
    tActive = droplets[i - 1].active

    droplets[i - 1].X = droplets[i].X
    droplets[i - 1].Y = droplets[i].Y
    droplets[i - 1].active = droplets[i].active

    droplets[i].X = tX
    droplets[i].Y = tY
    droplets[i].active = tActive
endfunction

function DisplayLoading()
    SetTextString(110, GetTextLibraryString(11))
    SetSpriteVisible(101, 1)
    SetTextVisible(110,1)
    sync()

endfunction

function RenderPressStart()
 SetTextString(110, GetTextLibraryString(10))
    GameplayUpdate()
          sync()
            UpdateCursor()


    PlaySoundPref(11)

    while GetCursorPress() = 0
        UpdateCursor()
        UpdateScreenResolution()
            ScrollScreen()
              UpdateScrollBounds()
        sync()
    endwhile
        SetSpriteVisible(101, 0)
    SetTextVisible(110,0)

endfunction


function RenderGameplay()

    levelReload = 1
    levelFinished = 0
    SetPuzzleSelectVisible(0)
SetScrollIconsVisible(0)
    DisplayLoading()

    while levelReload = 1
    SetGameplayVisible(0)
    DisplayLoading()
    ClearDroplets()
    ParseLevelData()


    StopMusicPref()
    PlayMusicPref(random(11, 15), 2)

        SetGameplayVisible(1)
    RenderPressStart()
    levelReload = 0
    levelLoop = 1
    levelFinished = 0
        while levelLoop = 1
            UpdateCursor()
            UpdateScreenResolution()

            HandleGameplayInput()
            CreateDroplets()
            UpdateDroplets()
            GameplayUpdate()
            CheckPuzzleFinished()
            sync()
        endwhile

        if levelFinished = 1
            RenderSuccess()
        elseif levelFinished = 2
            RenderFailure()
        endif
    endwhile

    SetGameplayVisible(0)
    SetPuzzleSelectVisible(1)
endfunction

function CheckPuzzleFinished()
    if dropletCollected = dropletCountMax
        levelFinished = 1
        levelLoop = 0
    endif

    if dropletCollected + dropletLost = dropletCountMax
        levelFinished = 1
        levelLoop = 0
    endif

    if dropletLost = dropletCountMax
        levelFinished = 2
        levelLoop = 0
    endif

    if levelTimerCount < 0.0
        levelTimerCount = 0

        if dropletCollected = 0
            levelFinished = 2
        else
            levelFinished = 1
        endif

        levelLoop = 0
    endif


    if levelWaterDropTimer >= 1.0 and dropletMade = dropletCountMax and (dropletLost > 0 or dropletCollected > 0)
        levelWaterDropTimer = 0


        if dropletCollected = 0
            levelFinished = 2
        else
            levelFinished = 1
        endif

        levelLoop = 0
    endif

endfunction


function GameplayUpdate()

        SetTextString(111, str(levelbombCount))
        SetTextString(112, str(levelbuildCount))

        if levelstartCount > 0
            SetTextString(114, str(floor(levelstartCount)))
        else
            levelTimerCount = levelTimerCount - GetModifiedFrameTime()
            if levelTimerCount >= 0
                SetTextString(114, str(floor(levelTimerCount)))
            endif

        endif

        SetSpriteImage(LEVEL_SPRITE, 0)
        DeleteImage(LEVEL_GAMEPLAY)
        CreateImageFromMemblock(LEVEL_GAMEPLAY, MEMBLOCK_GAMEPLAY)
        SetSpriteImage(LEVEL_SPRITE, LEVEL_GAMEPLAY)
        SetSpriteImage(LEVEL_SPRITE, LEVEL_GAMEPLAY)
        //SetSpriteVisible(LEVEL_SPRITE, 1)
        SetSpriteSize(LEVEL_SPRITE, levelSize.X * 2, levelSize.Y * 2)
endfunction

function HandleGameplayInput()

    if gameplayInteraction = 0
        ScrollScreen()
          UpdateScrollBounds()
        endif

    if HandleGamplayIconInput() = 1
       if gameplayInteraction = 1
            EditMap(ScreenToWorldX(GetCursorX()), ScreenToWorldY(GetCursorY()),0)
        elseif gameplayInteraction = 2
            EditMap(ScreenToWorldX(GetCursorX()), ScreenToWorldY(GetCursorY()), 1)
        elseif gameplayInteraction = 3
            rem pause
            RenderPause()
        endif

    endif

endfunction

function HandleGamplayIconInput()
    myReturn as integer
    myReturn = 1
    i as integer

    for i = 110 to 113
        if CheckSpritePointerCollision(i) = 1
            myReturn = 0

            if i = 110
                ResetGameplayIcons(1, 0, 0, 0)
                gameplayInteraction = 0
            elseif i = 111
                ResetGameplayIcons(0, 1, 0, 0)
                gameplayInteraction = 1
            elseif i = 112
                ResetGameplayIcons(0, 0, 1, 0)
               gameplayInteraction = 2
            elseif i = 113
                ResetGameplayIcons(0, 0, 0, 1)
                gameplayInteraction = 3
            endif
        endif
    next

endfunction myReturn

function ResetGameplayIcons(pA, pB, pC, pD)
    SetSpriteImage(110, 201 - pA)
    SetSpriteImage(111, 203 - pB)
    SetSpriteImage(112, 205 - pC)
    SetSpriteImage(113, 209 - pD)
endfunction

function EditMap(pX as integer, pY as integer, pMode as integer)
    distA as float
    distB as float
    tX as integer
    tY as integer
    x as integer
    y as integer

    sX as integer
    sY as integer
    eX as integer
    eY as integer

    i as integer
    j as integer
    weightA as integer
    weightB as integer
    tPoint as Type_Point2D

    if GetCursorPressCount() = 1
        tX = pX * .5
        tY = pY * .5

        if editPoint.X = -320
            editPoint.X = tX
            editPoint.Y = tY
            editPointOld.X = tX
            editPointOld.Y = tY
                exitfunction
        else
            editPoint.X = tX
            editPoint.Y = tY

            if CheckSpritePointerCollision(111) = 0 and CheckSpritePointerCollision(112) = 0
                if tx >= 0 and tx <= levelSize.X - 1
                    if ty >= 0 and ty <= levelSize.Y - 1
                    if Distance2D(editPoint.X, editPoint.Y, editPointOld.X, editPointOld.Y) >= (editDiameter * .1)

                        weightA = (floor(Distance2D(editPointOld.X, editPointOld.Y, editPoint.X, editPoint.y)) / 4 ) + 1
                            weightB = weightA

                                for i = 0 to weightA
                                    if (pMode = 0 and levelBombCount > 0) or (pMode = 1 and levelbuildCount > 0)


                                            if pMode = 0
                                                levelbombCount = levelbombCount - 1
                                            else
                                                levelbuildCount = levelbuildCount - 1
                                            endif

                                            tX = AveragePoints(editPointOld.X, i, editPoint.X, weightB)
                                            tY = AveragePoints(editPointOld.Y, i, editPoint.Y, weightB)
                                            sX = tX - editDiameter * .5
                                            eX = sX + editDiameter
                                            sY = tY - editDiameter * .5
                                            eY = sY + editDiameter


                                            weightB = weightB - 1
                                            for x = sX to eX
                                                for y = sY to eY


                                                        if x >= 0 and x <= levelSize.X - 1
                                                            if y >= 0 and y <= levelSize.Y - 1
                                                                if levelData[x, y] = 1 or levelData[x, y] = 0
                                                                    distB = Distance2D(x, y, tX, tY)

                                                                    if distB <= editDiameter * .5
                                                                        if pMode = 0
                                                                            //if bombCount > 0
                                                                                 if levelData[x, y] = 1
                                                                                        levelData[x, y] = 0
                                                                                       // bombCount = bombCount - 1
                                                                                          //SetImagePoint(x, y, buildColor.R, buildColor.G, buildColor.B, buildColor.A)
                                                                                        ClearImagePoint(x, y)
                                                                                endif
                                                                            //endif
                                                                        elseif pMode = 1
                                                                          //  if buildCount > 0
                                                                                 if levelData[x, y] = 0
                                                                                // buildCount = buildCount - 1
                                                                                levelData[x, y] = 1
                                                                                SetImagePoint(x, y, buildColor.R, buildColor.G, buildColor.B, buildColor.A)
                                                                                endif
                                                                            endif
                                                                        //endif
                                                                    endif
                                                                endif
                                                        endif
                                                    endif

                                                next
                                            next

                        endif
                                next
                            editPointOld.x = editPoint.x
                            editPointOld.y = editPoint.y
                        endif
                        endif
                    ENDIF
                endif
        endif
    else
        editPoint.X = -320
    endif
endfunction

function AveragePoints(pPointA , pWeightA, pPointB, pWeightB)
    myReturn as integer
    myReturn = ((pPointA * pWeightA) + (pPointB * pWeightB))// / (pWeightA + pWeightB)
    myReturn = myReturn / (pWeightA + pWeightB)
endfunction myReturn

function UpdateScrollBounds()
    if worldScrollX < virtMax * .5 - (levelSize.X * 2 )
        worldScrollX = virtMax * .5 - (levelSize.X * 2 )
   endif

    if worldScrollX > virtMax * .5
        worldScrollX = virtMax * .5
   endif

    if worldScrollY < virtMin * .5 - (levelSize.Y * 2 )
        worldScrollY = virtMin * .5 - (levelSize.Y * 2 )
   endif

    if worldScrollY > virtMin * .5
        worldScrollY = virtMin * .5
   endif
endfunction
