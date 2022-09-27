script "card.card1.scriptloader test stack"

after openCard
   answer "Script for card1 loaded!"
end openCard

command sayHelloFromCard1
   answer "Hello from Card1!"
end sayHelloFromCard1

on preOpenCard
   put getLoadedLibraries() into field "librariesInUse"
end preOpenCard