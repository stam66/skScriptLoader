script "back.paths"

function libPath
   if the environment is "development" then
      return specialFolderPath("resources") & "/Libraries"
    else
      return specialFolderPath("resources") & "/Libraries"
   end if
end libPath