function ParseImagesFromFile()
    fileID as integer
    tString as string
    count as integer
    count = 1

    fileID = openToRead("imageList.txt")
    tString = readline(fileID)

    while fileEOF(fileID) <> 1
        tString = readline(fileID)

            dim imageData[count]
            imageData[count - 1].imageID = val(GetStringToken(tString, ",", 1))
            imageData[count - 1].imagePath = GetStringToken(tString, ",", 2)
            imageData[count - 1].imageAtlas = val(GetStringToken(tString, ",", 4))
            imageData[count - 1].magFilter = val(GetStringToken(tString, ",", 5))
            imageData[count - 1].minFilter = val(GetStringToken(tString, ",", 6))
            imageData[count - 1].keepDelete = val(GetStringToken(tString, ",", 7))

            if imageData[count - 1].imageAtlas = -1
                loadimage(imageData[count - 1].imageID, imageData[count - 1].imagePath)
                setImageMagfilter(imageData[count - 1].imageID, imageData[count - 1].magFilter)
                setImageMinfilter(imageData[count - 1].imageID, imageData[count - 1].minFilter)
            endif

             if imageData[count - 1].imageAtlas > -1
                if getImageExists(imageData[count - 1].imageAtlas)
                    loadsubimage(imageData[count - 1].imageID, imageData[count - 1].imageAtlas, imageData[count - 1].imagePath)
                endif
            endif

            count = count + 1
    endwhile

    closefile(fileID)

    imageDataCount = count
endfunction

rem load in a parsed image into memory
function LoadParsedImage(pValue)
  i as integer

    for i = 0 to imageDataCount - 1
        if imageData[i].imageID = pValue

                rem don't load in an image if it already exists
                if (GetImageExists(pValue) = 0)
                    if imageData[count - 1].imageAtlas = -1
                        loadimage(imageData[count - 1].imageID, imageData[count - 1].imagePath)
                        setImageMagfilter(imageData[count - 1].imageID, imageData[count - 1].magFilter)
                        setImageMinfilter(imageData[count - 1].imageID, imageData[count - 1].minFilter)
                        exit
                    endif
                endif

        endif
    next
endfunction

rem delete all parsed images from memory if they're
rem not tagged to keep
function DeleteParsedImages()
    i as integer

    for i = 0 to imageDataCount - 1
        if imageData[i].keepDelete = 0 and imageData[i].imageAtlas = -1
            deleteimage(imageData[i].imageID)
        endif
    next
endfunction
