# Administrative Commands                                       		_Local_Reset_Share.cmd

## NAME

_Local_Reset_Share.cmd: a utility to reset permissions on all file shares on a file server.
     
## SYNOPSIS

 The syntax of this command is:
 ```
	_Local_Reset_Share.cmd 
```
NOTE: the shell script expects to be executed on the file server where the share level permissions need to be reset.

## DESCRIPTION

_Local_Reset_Share.cmd  is a simple shell script that parses all the shares on a file server and resets the “everyone” permissions at the share level to a predefined value. 

		


## OPTIONS
The operations of the script can be modified in the header of the file in the “Settings” section as follows:
```
**********   Settings *************
Enter the setting that affects this shell scripts' operation.

_PERM = the permission to assign at the share level
Perm can be: 
Read
Change 
Full 
```

		


## EXAMPLES
```
	Set _PERM=F
```
## EXIT STATUS

_Local_Reset_Share.cmd does not return exit codes.


## FILES

_Local_Reset_Share.cmd depends on the following executables:
```
  1. SetACL.exe
```
SEE ALSO



NOTES
