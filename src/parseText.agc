function LoadTextFromCSV(pFileName as string)
    myCount as integer
    REM MYRETURN VALUE
    REM TO STORE WHETHER OR NOT EVERYTHING COMPLETED SUCCESSFULLY
    REM 0 MEANS NO, 1 MEANS YES
    REM SET IT TO 1 INITIALLY, IF SOME ERROR OCCURS SET IT TO 0
    REM IF IT MAKES IT THROUGH THE ENTIRE FUNCTION NORMALLY, IT HAS COMPLETED SUCCESSFULLY!
    myReturn as integer
    myReturn = 1
	REM FILE ID THAT WE WORK WITH WHEN MANIPULATING THE FILE
	tFileID as integer
	i as integer

	REM VARIABLE TO HOLD DATA BEING READ FROM THE CSV
	tString as string
    myCount = 0

    REM MAKE SURE FILE PASSED IN EXISTS
	if GetFileExists(pFileName) = 1

	REM GET FILE NAME AND FILE ID
	tFileID = opentoread(pFileName)

		REM READ FIRST LINE OF FILE
		REM AS IT CONTAINS HEADER INFO
		tString = readline(tFileID)

        while fileeof(tFileID) = 0

		REM READ IN LINE FROM FILE
		tString = readline(tFileID)

		   REM MAKE SURE THAT LINE IS NOT EMPTY
         	   if tString <> ""

                    myCount = myCount + 1
                    if textLoaded = 0
                        dim TextList[myCount] as TYPE_TEXT_LIBRARY
                    endif

                    TextList[myCount - 1].id = val(GetStringToken(tString, "]", 1))
                    TextList[myCount - 1].english = GetStringToken(tString, "]", 2)
                endif
        endwhile

		REM CLOSE FILE
        closefile(tFileID)
        textCount = myCount
        textLoaded = 1
    else
        REM CSV NOT FOUND. RETURN 0
        myReturn = 0
	endif

endfunction myReturn

function GetTextLibraryString(pID as integer)
    myReturn as string
    i as integer
    pLanguage as integer

    myReturn = " "

    for i = 0 to textCount - 1
        if TextList[i].id = pID
            //if pLanguage = 0
                myReturn = TextList[i].english
            //endif

            exitfunction myReturn
        endif
    next
endfunction myReturn

