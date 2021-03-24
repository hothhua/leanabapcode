Events

![SAP Selection Screens](http://www.saptraininghq.com/wp-content/uploads/2014/02/clip_image002_thumb.gif)



At the top level is the SAP Presentation Server (Usually the SAP GUI), seen by the end user, with its selection screen and list output. When a program starts, from the left, with the declaration of global variables, the system will check to see if any processing blocks are included and will follow the sequence of events detailed above to execute these.

The initialization event block of code will only be run once, and will include things like the setting up of initial values for fields in the selection screen. It will then check whether a selection screen is included in the program. If at least one input field is present, control will be passed to the selection screen processor.

This will display the screen to the user, and it can then be interacted with. Once this is complete, the ‘at selection screen’ event block will process the information, and this is where one can write code to check the entries which have been made. If incorrect values have been entered, the code can catch these and can force the selection screen to be displayed again until correct values are entered. Error messages can be included so that the user then knows where corrections must be made.

The ‘start of selection’ event block then takes control once the selection screen is filled correctly. This can contain code for, for example, setting up the values of internal tables or fields. There are other event blocks, which are visible in the diagram and there could be a number of others. The ones discussed here though, tend to be the main ones which would be used when working with selection screens to capture user input, which will then be used to process the rest of the program.

Once all of these event blocks have been processed, control is handed to the list processor, which will output the report to the screen for the user to see. The list screen occasionally can be interactive itself, and the code in the event block ‘at line selection’ visible in the diagram takes responsibility for this.

This article will focus on creating the selection screen and making sure the user enters the correct values for the report, as well as ensuring the selection screen has a good interface.