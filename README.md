# skScriptLoader
A liveCode IDE tool to reload script-only stacks automatically after editing these externally, in for example VSCode


For those wanting to edit liveCodeScript externally in a mainstream code editor such as Sublime, Atom or VSCode, there are  addons that provide code formatting, syntax colouring and syntax checking/linting but there is no automated integration between LiveCode IDE and these tools making this an arduous affair.

I created and use skScriptLoader to replace as much of the code in a project as possible using **script-only stacks**, which are directly editable in external code editor. It is intended to be used as a plugin; it is a palette which during setup takes a fair amount of screen real estate but during use is minimised to a small palette top-right of the screen with 2 buttons to reaload all SO stacks and to enter setup again.



## Basics
1. When editing in an external code editor it is conventient to have all SO stacks in a single folder, whereas in the standalone app these may reside in different locations (depending on whether these need to be in a writeable location or not for example). skScriptLoader creates a 'paths' stack which is loaded first, into the backscripts, and abstracts the folder paths used for both IDE and runtime so that a funciton call returns the correct path depending on whether in the IDE or runtime.
2. The first folder path created is the root folder containing all SO stacks in the IDE. Others can be added as needed. The paths stack should be saved to the folder containing the mainstack, ideally in subfolder.
3. Once the root folder is identified, skScriptLoader will load all SO stacks in that folder to a list, so the developer can assign a role and folder path to each. 
4. Once that's done, click a button to create load/unload scripts for all automatically and use the copy button to paste into the script of the mainstack. 
5. skScriptLoader can then be 'iconified' to just proviede a button on the screen in the IDE to reload all SO stacks in the IDE, once edited and saved externally



## How to use: In a nutshell
1. Declare a location for SO stacks for the project in IDE and declare any other locations to be used, and then create the 'paths' stack.
2. Assign a role and location (from the declared locations in the paths stack)
3. Generate the scripts and copy these. 
4. Past the scripts into the mainstack (add a preOpenStack handler to call 'loadScripts' to load all SO stacks when opening said mainstack"

<b>Note:</b> Use the minimise button to iconfiy the stack and show the 'reloader' as a floating palette top-right.



## How SO stacks are used
Script-only stacks are intended to replace stack/card/library/backsripts.
#### Stack scripts
Stack scripts can be replaced by SO stacks by being assigned these the behavior of the stack in question. 
If a stack/substack doesn't exist, nothing happens. As a behavior, this means you can still add code to the stack script if desired - this will be executed before the behavior script of the stack

For a script to be recognised as a stack behavior and loaded correctly, it ***must*** follow the naming convention: 
**stack.*stackName*.livecodescript**

#### Card scripts
The same applies to card scripts - SO stacks for these are assigned as card behaviors; any cardscript will be executed before the script in the card, if that functionality is needed.
If a card doesn't exist **it is created based on the name of the SO stack file**. This means you can create the scripts externally in for example VSCode and when you reload it will create the cards in the stack which is also noted in the file name.
For a script to recognised as a card script, it ***must*** follow the naming convention: <br>**card._cardName_._stackName_.livecodescript**

#### Libraries
These are loaded with the 'start using' command. 
Naming convention isn't mandated but using it automates role allocation.  <br>
The convention is: **lib._stackName_.livecodescript**

#### Backscripts
For libraries that need to be accessible from anywhere regardless of the message path, these should be loaded into the backScripts. A good example of this would be the 'paths' stack.
Naming convention isn't mandated but using it automates role allocation. <br>The convention is: **back._stackName_.livecodescript**

#### The _paths_ stack
This should be a unique file which abstracts folder paths for the SO stacks, and is automatically loaded first and into the backscripts.
Naming convention isn't mandated but using it automates role allocation. <br>
The convention is: to **include the string *paths* in the file name** (eg paths.livecodescript)


  
## Workflow
The main/home menu stores settings for all projects you use skScriptLoader on. 
Create a new with the + button at the top of the data grid, or close an existing entry with the button at the bottom.
To delete an entry, select it and a bin icon will appear
The right arrow load the stored data into stack file managent screen

If no central repository is defined, at this point you will be prompted to create a path to the central repostory - it is **imperative** that all the SO stacks to be used reside there in the IDE as this location is hard-coded (required when realoading all scripts and the 'paths' stack won't be in memory).

Once a central repo is created it will load all it's stacks into the stack file managment screen in the background. Hou can add more locations if needed and can return to this step at any point. **Note** if you delete the central repo ALL data for that project is removed.

Save the output as a script-only stack using the 'download' button. This **must** be in the central repository defined in the first step.

Dismissing the Paths section brings the stack managment into focus - each stack file will have been automatically assigned a role depending on it's file name - for unknown file name structures, these are assigned as 'libraries'. The correct roles should be assigned with the popup menu. If a stack file isn't relevant it can be marked as such and will be ignored.
Avaiable roles are: stackScript, cardScript, library, backscript, pathsScript and 'Not applicable'

Each stack file also has a 'folder path' which is drawn from the folder locations in the paths management section. By default no folder locations are assigned - these juse show as 'select folder...'. 
If left unchanged (ie showing 'select folder...') this will be ignored in the script generation.

Once all roles and folder locations have been designated as needed, use the copy button to copy both the load and unload scripts and paste this into the mainstack's script. This is the final step.

Once this is done, skScriptLoader can be iconified to leave 2 small buttons top right of the screen (reload all SO scripts and re-enter setup).
Clicking the reload button refreshes any changes made to stacks when saved external to the IDE.



## How to use: more detail
#### Paths Stack
The first task for a new proejct is to create it's paths stack. If no locations have already been declared, the dialog for declaring locations and creating the paths stack will launch automatically - if already done, this can be revisited using the 'paths' button at the top.

The first locations to be declared is the folder that contains all the SO stacks for the project:
1. Name the paths stack as you wish (note the Caveats/Issues section)
2. Name the location that will be used as a function to return the central folder that will house most of the SO stacks in the IDE
3. use the 'choose' button to add the absolue filepath to this folder - this is used only in the IDE, so the paths stack can be lauched after being unloaded from memory. In standalones, this is abstracted as defined.
4. Add any other locations where SO stacks may reside when running as standalone
5. Generate the script and save the stack as an SO stack inside the folder that houses all SO stacks

Declaring the central repository folder will load all SO stacks in a list for processing (as below).

#### Load/Unload scripts
Dismiss the Paths dialog if open.
1. for each stack select a role as above, or 'Not Applicable' if not to be included in any scripts of the project.
2. Select a folder for each stack (as declared in the 'paths' section)
3. Generate the scripts to load and unload all SO stacks; copy both with the 'copy' button and paste into hte mainstack

#### How to use once set up
1. Minimse skScriptLoader with the minimise button - this will 'iconify' the stack to a small palette top-right with a 'reload' button and a 'edit' button.
2. After editing and saving scripts externally, click the 'reload' button to remove all SO stacks frome memory and relaod them, which is currently the only way external edits are refreshed in the IDE.
3. If you want to make changes to the load/unload scripts, click the edit button (eg if you want to add new locations or SO stacks)</p>



## Caveats/Issues
LiveCode chokes on multiple stacks with the same name. Therefore avoid using a central repository for all your proejcts if possible - if these are in memory (either because another stack is also active, or because they're left overs after closing a stack) you will encounter errors.
It is safest to just copy the stack and rename it (eg original name + project name).
Any problems please raise an issue in github or pm 'stam' in the LiveCode forums.



## Using the test stack
Settings for an example stack and a test stack are included.  The example stack is a project i'm currently working on - the data included have no value as it's just the setitngs for this stack.

The test stack settings are accompanied by a test stack. In the same folder that contains the test stack there is a "Libraries" folder that contains the SO stacks included for testing purposes.
As the central repository for SO stacks in the IDE is hard-coded, it is specific to the developer (this is required to permit loading and unloading of all SO stacks, including the paths stack, when edited/saved externally).

If you open the test stack, nothing should work as at this point, the stack has no awareness of the script only stacks.
Start by editing the settings for the test stack and creating a 'paths' stack in it's "Libraries" folder, and as above, setting roles and locations (in this case just the 1 location exists) for the SO stacks in it's 'Libraries' folder and then generating the scrips. Copy the scripts using the the copy button and minimise skScriptLoader; paste these in the test stack's stack script.
To ensure the stack functions normally at startup, include a preOpenStack handler that calls the loadScripts hanlder pasted into the stack script. Click the 'reload' button in the minimised icon top right and the stack should now function normaly.

To test live editing, open an SO stack from the 'libraries' folder and edit it externally, making sure to save. Then return to the test stack, hit the reload button in the top right palette and the edited scripts should be live.
