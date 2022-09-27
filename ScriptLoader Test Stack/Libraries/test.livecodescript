script "test"

global gSettings//, gData
# gSettings are the local app settings stored as a custom prop for now
# gData is an array that contains all data for all the app/projects

command readSettings
   # PURPOSE : get mainstack properties, used as script local settings
   # idea is to emulate the target app; settings that will affect scripts to be stored as custom props
   put the customProperties of this stack into gSettings
end readSettings

function recursiveFilesWithPattern pFolder, pPattern
   Local tPaths
   filter lines of files(pFolder) with pPattern
   repeat for each line tFile in it
      wait 0 with messages
      put pFolder & slash & tFile & cr after tPaths
   end repeat
   filter folders(pFolder) without ".."
   repeat for each line tFolder in it
      wait 0 with messages
      put recursiveFilesWithPattern(pFolder & slash & tFolder, pPattern) after tPaths
   end repeat
   return tPaths
end recursiveFilesWithPattern

function returnNumberedArray pArray
   # PURPOSE : returns a numerically keyed version of the array provided
   local x, tArray
   repeat for each element tElement in pArray
      add 1 to x
      put tElement into tArray[x]
   end repeat
   return tArray
end returnNumberedArray

function sortArray pArray, pDirection, pSortType, pKey, pUseSystemDate
   # PURPOSE : Returns a numerical indexed array with with the sort order requested. See notes below.
   /*
   - only pArray is mandatory, other params can be passed as ‘empty’ or “”
   - permissible values for pDirection are: ascending, descending or empty
   - permissible values for pSortType are: international, numeric, datetime, text, binary or empty
   - if pDirection is passed as “” or ‘empty’, it will default to ascending
   - if pSortType is passed as “” or ‘empty’ it will default to text
   - passing pKey as “” or empty will treat the array as a 1-dimensional array, passing the name of the key will sort it as a multidimensional array
   - passing empty pUseSystemDate will default to false / / US date format
   */
   local tNextIndex, tSortedArray, tSortText
   get the keys of pArray
   if pUseSystemDate is not empty then set the useSystemDate to pUseSystemDate
   put "sort lines of it [[pDirection]] [[pSortType]] by pArray[each]" into tSortText //1-dimensional array
   if pKey is not empty then put "[pKey]" after tSortText //multidimensional array
   do merge(tSortText)
   repeat for each line tKey in it
      add 1 to tNextIndex
      put pArray[tKey] into tSortedArray[tNextIndex]
   end repeat
   return tSortedArray
end sortArray

function arrayFromGridData pNumericArray, pPrimaryKey // replaces the numerical index of a grid array with a chosen subKey, abstraction of the above for any numericallly indexed array
   local tKeys, tArray
   put the keys of pNumericArray[1] into tKeys
   filter tKeys without pPrimaryKey
   repeat for each element tElement in pNumericArray
      repeat for each line tKey in tKeys
         put tElement[tKey] into tArray[tElement[pPrimaryKey]][tKey]
      end repeat
   end repeat
   return tArray
end arrayFromGridData

function gridDataFromNonNumericArray pArray, pName
   # reconstruct a numerical array which is the opposite of arrayFromGridData - take non-numeric array with and add the key of it as subkey to numeric one, along the others.
   local tKeys, tArray, x
   put the keys of pArray into tKeys
   repeat for each line tKey in tKeys
      add 1 to x
      put pArray[tKey] into tArray[x]
      put tKey into tArray[x][pName]
   end repeat
   return tArray
end gridDataFromNonNumericArray

function getDataToStore // create an array with data to save
   local tArray, tProject
   put field "project" of card "pathsScriptDG" into tArray["project"]
   put the dgData of group "paths" of card "pathsScriptDG" into tArray["paths"]
   put the dgNumberOfLines of group "paths" of card "pathsScriptDG" into tArray["pathsCount"]
   put the htmltext of field "pathsScript" of card "pathsScriptDG" into tArray["pathsScript"]
   put the dgData of group "stackFiles" of card "loadFilesScriptDG" into tArray["stackFiles"]
   put the dgNumberOfLines of group "stackFiles" of card "loadFilesScriptDG" into tArray["stackFilesCount"]
   put the htmltext of field "script" of card "loadFilesScriptDG" into tArray["loadScript"]
   put the htmltext of field "script" of card "unloadFilesScriptDG" into tArray["unloadScript"]
   put field "pathsStackFilePath" into tArray["pathsStackFilePath"]
   put field "pathsStack" into tArray["pathsStack"]
   put field "libFolder" into tArray ["libFolder"]
   return tArray
end getDataToStore

command addStoreToGlobal pArray // if exists  (by project name) replace existing data subarray in global gData, otherwise add this to global gData
   local tData, tKey, tArray
   put the dgData of group "projects" of card "home" into tArray
   filter elements of tArray where each ["project"] = pArray["project"] into tData
   if tData is empty then // add new project since one with this name doesn't exist
      dispatch "addData" to group "projects" of card "home" with pArray
      --          put pArray into gData[the last line of the keys of gData + 1]
    else // replace existing
      dispatch "setDataOfIndex" to group "projects" of card "home" of me with the keys of tData, empty,  pArray
      --          put pArray into gData[the keys of tData]
   end if
   dispatch "refreshLIst" to group "projects" of card "home"
end addStoreToGlobal

command saveCurrentData // save to projects DG as permanent storage
   addStoreToGlobal getDataToStore()
   --     set the dgData of group "projects" of card "home" to gData
   send "resetList" to group "projects" of card "home"
end saveCurrentData

command loadData pArray
   set the text of field "project" of card "pathsScriptDG" to pArray["project"]
   set the dgData of group "paths" of card "pathsScriptDG" to pArray["paths"]
   set the htmlText of field "pathsScript" of card "pathsScriptDG" to pArray["pathsScript"]
   set the text of field "pathsStackFilePath" of card "pathsScriptDG" to pArray["pathsStackFilePath"]
   set the text of field "pathsStack" of card "pathsScriptDG" to pArray["pathsStack"]
   set the text of field "libFolder" of card "pathsScriptDG" to pArray["libFolder"]
   set the dgData of group "stackFiles" of card "loadFilesScriptDG" to pArray["stackFiles"]
   set the htmltext of field "script" of card "loadFilesScriptDG" to pArray["loadScript"]
   set the htmltext of field "script" of card "unloadFilesScriptDG" to pArray["unloadScript"]
   go to card "pathsScriptDG"
end loadData

command hideMainStack
   show stack "reloader"
   hide stack "scriptLoader"
end hideMainStack

function loadAllScripts pNumericalArray
   # Param passes numerically keyed array from a grid, eg <the dataContent of widget "stackFiles"> or <the dgData of group "stackFiles">
   local tScript, tempA, tStack, tCard, tFolder
   set the itemDelimiter to "."
   # start
   put "command loadScripts" & return into tScript
   put "local tCurrentCard" & return after tScript

   # paths stack
   put "-- Paths stack" & return after tScript
   --     put "insert script of stack (specialFolderPath(" & quote & "resources" & quote & ") & " & quote & "/" & field "libFolder" & "/" & field "pathsStack" & quote & ") into back" &  return after tScript
   put "insert script of stack" && quote & field "pathsStackFilePath" & quote && "into back" &  return after tScript

   # backscripts
   put return & "-- backScripts" & return after tScript
   filter elements of pNumericalArray where each ["role"] = "backScript" into tempA
   repeat for each element tElement in tempA
      put tElement["folder"] into tFolder
      if field "pathsStack" is not in tElement["file"]  then put "insert the script of stack ("  & tFolder & "() & "  & quote & "/" & tElement["file"] & quote & ") into back" & return after tScript
   end repeat

   # stack scripts
   put return & "-- Stack Scripts" & return after tScript
   filter elements of pNumericalArray where each ["role"] = "stackScript" into tempA
   repeat for each element tElement in tempA
      put tElement["file"] into tStack
      put tElement["folder"] into tFolder
      put "if there is a stack" && quote & item 2 of tStack & quote && "then" & return after tScript
      put "set the behavior of stack" && quote & item 2 of tStack & quote && "to the long id of stack ("  & tFolder & "() & "  & quote & "/" & tElement["file"] &  quote & ")" & return after tScript
      put "end if" & return after tScript
   end repeat

   # card scripts
   put return & "-- Card Scripts" & return after tScript
   filter elements of pNumericalArray where each ["role"] = "cardScript" into tempA
   repeat for each element tElement in tempA
      put item 2 of tElement["file"] into tCard
      put tElement["folder"] into tFolder
      put "if there is not a card" && quote & tCard & quote && "then" & return after tScript
      put "put the short name of this card into tCurrentCard" & return after tScript
      put "create card" && quote & tCard & quote & return after tScript
      put "go to card tCurrentCard" & return after tScript
      put "end if" & return after tScript
      put "set the behavior of card" && quote & tCard & quote && "to the long id of stack ("  & tFolder & "() & "  & quote  & "/" & tElement["file"] & quote & ")" & return after tScript
      put "--" & return after tScript
   end repeat
   if "-- Card Scripts" is not in the last line of tScript then delete the last line of tScript

   # library scripts
   put return & "-- library Scripts" & return after tScript
   filter elements of pNumericalArray where each ["role"] = "library" into tempA
   repeat for each element tElement in tempA
      put tElement["folder"] into tFolder
      put "start using stack ("  & tFolder & "() & "  & quote &  "/" & tElement["file"] & quote & ")" & return after tScript
   end repeat

   # end
   put "end loadScripts" after  tScript
   # return formatted script
   dispatch "scriptFormatSnippet" to stack "com.livecode.scripteditor.behavior.editorcommon" with tScript
   return the result
end loadAllScripts

function unLoadAllScripts pNumericalArray
   # Param passes numerically keyed array from a grid, eg <the dataContent of widget "stackFiles"> or <the dgData of group "stackFiles">
   local tScript, tempA, tStack, tCard, tFolder, tFilePath
   set the itemDelimiter to "."

   # start
   put "command unloadScripts" & return into tScript

   # backscripts
   put "-- backScripts" & return after tScript
   filter elements of pNumericalArray where each ["role"] = "backScript" into tempA
   repeat for each element tElement in tempA
      if field "pathsStack" is in tElement["filepath"] then next repeat
      put "if" && quote & tElement["filepath"] & quote && "is in the backscripts then"  & return after tScript
      put quote & tElement["filepath"] & quote into tStack
      put "remove the script of stack " && tStack && "from back" & return after tScript
      put "if the mode of stack" && tStack && "= 0 then delete stack" && tStack  & return after tScript
      put "end if" & return after tScript
      put "--" & return after tScript
   end repeat
   if "-- backScripts" is not in the last line of tScript then delete the last line of tScript

   # stack scripts
   put return & "-- Stack Scripts" & return after tScript
   filter elements of pNumericalArray where each ["role"] = "stackScript" into tempA
   repeat for each element tElement in tempA
      put quote & item 2 of tElement["file"] & quote into tStack
      put quote & tElement["filePath"] & quote into tFilePath
      put "set the behavior of stack" && tStack && "to empty" & return after tScript
      put "if the mode of stack" && tFilePath && "= 0 then delete stack" && tFilePath  & return after tScript
   end repeat
   --     delete the last line of tScript

   # card scripts
   put return & "-- Card Scripts" & return after tScript
   filter elements of pNumericalArray where each ["role"] = "cardScript" into tempA
   repeat for each element tElement in tempA
      put quote & item 2 of tElement["file"] & quote into tCard
      put quote & item 3 of tElement["file"] & quote into tStack
      put quote & tElement["filePath"] & quote into tFilePath
      put "set the behavior of card" && tCard && "of stack" && tStack && "to empty" & return after tScript
      put "if the mode of stack" && tFilePath && "= 0 then delete stack" && tFilePath  & return after tScript
   end repeat
   --     delete the last line of tScript

   # library scripts
   put return & "-- library Scripts" & return after tScript
   filter elements of pNumericalArray where each ["role"] = "library" into tempA
   repeat for each element tElement in tempA
      put quote & item 1 to - 2 of tElement["file"] & quote into tStack
      put "stop using stack" && tStack & return after tScript
      put "if the mode of stack" && tStack && "= 0 then delete stack" && tStack & return after tScript
   end repeat

   # paths stack
   put return & "-- Paths stack" & return after tScript
   put "if" && quote & field "pathsStack"  & quote && "is in the backscripts then" & return after tScript
   put "remove script of stack" && quote & item 1 to -2 of field "pathsStack" & quote && "from back" &  return after tScript
   put "delete stack" && quote & item 1 to -2 of field "pathsStack" & quote & return after tScript
   put "end if" & return after tScript

   # end
   put "end unloadScripts" after  tScript
   # return formatted script
   dispatch "scriptFormatSnippet" to stack "com.livecode.scripteditor.behavior.editorcommon" with tScript
   return the result
end unLoadAllScripts
