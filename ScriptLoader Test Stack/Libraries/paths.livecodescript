script "paths"

function libFolder
   if the environment is "development" then
      return "/Users/stam/Documents/Developer/ScriptLoader Test Stack/Libraries"
    else
      return specialFolderPath("resources")& "/Libraries"
   end if
end libFolder