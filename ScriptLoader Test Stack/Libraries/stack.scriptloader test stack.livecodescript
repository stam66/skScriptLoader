script "stack.scriptloader test stack"

after openStack
   answer "Stack script loaded!"
end openStack

command sayHelloFromStack
   answer "Hello World! -- from stack script ;)"
end sayHelloFromStack

function getLoadedLibraries
   return the stacksInUse
end getLoadedLibraries

command checkLibraries
   answer "Is black a dark colour?" with ("tinyColor says: " && isDark("black"))
end checkLibraries

command goNextCard
   go to next card
end goNextCard

command goPrevCard
   go to previous card
end goPrevCard