
function CreateGameplayMemblock(pWidth as integer, pHeight as integer)
    size as integer
    levelSize.X = pWidth
    levelSize.Y = pHeight

    //rem 12 bytes + (width * height) * 4
    size = (pWidth * pHeight * 4) + 12
    //rem create image memblock
    If GetMemblockExists(MEMBLOCK_GAMEPLAY) = 1
        DeleteMemblock(MEMBLOCK_GAMEPLAY)
    endif
    CreateMemblock(MEMBLOCK_GAMEPLAY, size)
    //rem set image data?
    SetMemblockInt(MEMBLOCK_GAMEPLAY, 0, pWidth)
    SetMemblockInt(MEMBLOCK_GAMEPLAY, 4, pHeight)
    SetMemblockInt(MEMBLOCK_GAMEPLAY, 8, 32)

    i as integer
    j as integer
    for i = 0 to pWidth - 1
        for j = 0 to pHeight - 1
            ResetLevelAtPoint(i, j)
        next
    next

    If GetImageExists(LEVEL_GAMEPLAY)
        DeleteImage(LEVEL_GAMEPLAY)
    endif
    CreateImageFromMemblock(LEVEL_GAMEPLAY, MEMBLOCK_GAMEPLAY)
endfunction

function LoadLevelImages(pSourceImage as string, pMaskImage as string, pBG as string)
    ResetWaterSources()

    //rem load in gameplay image
    SafetyDeleteImage(LEVEL_IMAGE)
    LoadImage(LEVEL_IMAGE, pSourceImage)
    If GetMemblockExists(MEMBLOCK_IMAGE_SOURCE) = 1
        DeleteMemblock(MEMBLOCK_IMAGE_SOURCE)
    endif
    CreateMemblockFromImage(MEMBLOCK_IMAGE_SOURCE, LEVEL_IMAGE)
    levelSize.X = GetImageWidth(LEVEL_IMAGE)
    levelSize.Y = GetImageHeight(LEVEL_IMAGE)

    //background image
    SafetyDeleteImage(LEVEL_IMAGE_BG)
    LoadImage(LEVEL_IMAGE_BG, pBG)
    If GetMemblockExists(MEMBLOCK_IMAGE_BG) = 1
        DeleteMemblock(MEMBLOCK_IMAGE_BG)
    endif
    CreateMemblockFromImage(MEMBLOCK_IMAGE_BG, LEVEL_IMAGE_BG)

    //rem load in map data image
    SafetyDeleteImage(LEVEL_IMAGE_MASK)
    LoadImage(LEVEL_IMAGE_MASK, pMaskImage)
    If GetMemblockExists(MEMBLOCK_IMAGE_MASK) = 1
        DeleteMemblock(MEMBLOCK_IMAGE_MASK)
    endif

    CreateMemblockFromImage(MEMBLOCK_IMAGE_MASK, LEVEL_IMAGE_MASK)
    ParseLevelMaskMemblock()
    CreateGameplayMemblock(levelSize.X, levelSize.y)

endfunction

function ParseLevelMaskMemblock()
    x as integer
    y as integer

    for x = 0 to MAX_DIMENS_X - 1
        for y = 0 to MAX_DIMENS_Y -1

            if x < levelSize.X
                if y < levelSize.Y
                   levelData[x, y] = ParseLevelMaskMemblockColors(x, y)
                else
                    levelData[x, y] = -1
                endif
            else
                 levelData[x, y] = -1
            endif
        next
    next
endfunction

function ResetWaterSources()
    i as integer
    for i = 0 to MAX_SOURCE - 1
        levelSource[i].X = -1
        levelSource[i].Y = -1
    next
endfunction

function AddWaterSource(pX, pY)
    i as integer
    for i = 0 to MAX_SOURCE - 1
        if levelSource[i].X = -1
            levelSource[i].X = pX
            levelSource[i].Y = pY
            exitfunction
        endif
    next
endfunction

function ParseLevelMaskMemblockColors(pX, pY) as integer
    offset as integer
    myReturn as integer

    tR as integer
    tG as integer
    tB as integer
    tA as integer

    offset = 12 + ( pX + ( pY * levelSize.X)) *4

    // RGBA values :

    tR = GetMemblockByte(MEMBLOCK_IMAGE_MASK, offset+0)
    tG = GetMemblockByte(MEMBLOCK_IMAGE_MASK, offset+1)
    tB = GetMemblockByte(MEMBLOCK_IMAGE_MASK, offset+2)
    tA = GetMemblockByte(MEMBLOCK_IMAGE_MASK, offset+3)

    rem blank space
    if tR = 255 and tG = 255 and tB = 255
        myReturn = 0
    rem solid
    elseif tR = 0 and tG = 0 and tB = 0
        myReturn = 1
    rem start
    elseif tR = 111 and tG = 49 and tB = 152
        //message(str(pX) + "," + str(pY))
        myReturn = 5
        AddWaterSource(pX, pY)
    rem nondestroyable
    elseif tR = 70 and tG = 70 and tb = 70
        myReturn = 4
    rem goal
    else
        //
        myReturn = 3
    endif

endfunction myReturn

function ResetLevelAtPoint(pX, pY)
    offset as integer

    tR as integer
    tG as integer
    tB as integer
    tA as integer

    offset = 12 + ( pX + ( pY * levelSize.X)) *4

    tR = GetMemblockByte(MEMBLOCK_IMAGE_MASK, offset+0)
    tG = GetMemblockByte(MEMBLOCK_IMAGE_MASK, offset+1)
    tB = GetMemblockByte(MEMBLOCK_IMAGE_MASK, offset+2)
    tA = GetMemblockByte(MEMBLOCK_IMAGE_MASK, offset+3)

    if tR = 255 and tG = 255 and tB = 255
        tR = GetMemblockByte(MEMBLOCK_IMAGE_BG, offset+0)
        tG = GetMemblockByte(MEMBLOCK_IMAGE_BG, offset+1)
        tB = GetMemblockByte(MEMBLOCK_IMAGE_BG, offset+2)
        tA = GetMemblockByte(MEMBLOCK_IMAGE_BG, offset+3)
    else
        tR = GetMemblockByte(MEMBLOCK_IMAGE_SOURCE, offset+0)
        tG = GetMemblockByte(MEMBLOCK_IMAGE_SOURCE, offset+1)
        tB = GetMemblockByte(MEMBLOCK_IMAGE_SOURCE, offset+2)
        tA = GetMemblockByte(MEMBLOCK_IMAGE_SOURCE, offset+3)
    endif

     SetImagePoint(pX, pY, tR, tG, tB, tA)
endfunction


function ClearImagePoint(pX, pY)
    offset as integer

    tR as integer
    tG as integer
    tB as integer
    tA as integer

    offset = 12 + ( pX + ( pY * levelSize.X)) *4

    // RGBA values :
    tR = GetMemblockByte(MEMBLOCK_IMAGE_BG, offset+0)
    tG = GetMemblockByte(MEMBLOCK_IMAGE_BG, offset+1)
    tB = GetMemblockByte(MEMBLOCK_IMAGE_BG, offset+2)
    tA = GetMemblockByte(MEMBLOCK_IMAGE_BG, offset+3)
    SetImagePoint(pX, pY, tR, tG, tB, tA)
endfunction

function SetImagePoint(pX, pY, pR, pG, pB, pA)
    offset = 12 + ((pX + (py * levelSize.x)) * 4)

    SetMemBlockByte(MEMBLOCK_GAMEPLAY, offset + 0, pR)
    SetMemBlockByte(MEMBLOCK_GAMEPLAY, offset + 1, pG)
    SetMemBlockByte(MEMBLOCK_GAMEPLAY, offset + 2, pB)
    SetMemBlockByte(MEMBLOCK_GAMEPLAY, offset + 3, pA)
endfunction

function SafetyDeleteImage(pImageID as integer)
    if GetImageExists(pImageID) = 1
        DeleteImage(pImageID)
    endif
endfunction
