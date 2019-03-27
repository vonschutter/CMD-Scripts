# Administrative Commands                                       		              _Check_Homedir_Sec_Config.cmd

## NAME
_Check_Homedir_Sec_Config.cmd: Home directory security configuration checker.
     
## SYNOPSIS

 The syntax of this command is:
```
	_Check_Homedir_Sec_Config.cmd
```

NOTE: The shell script expects your Present Working Directory to be the home folder to check

## DESCRIPTION
_Check_Homedir_Sec_Config is a simple shell script that parses the Present Working Directory (PWD) and tries to assign a user with the same name as each folder and give that user the defined permissions. The permission and other setting can be tweaked in the setting section in the header of the shell script as described in the OPTIONS section.


## OPTIONS

The operations of the script can be modified in the header of the file in the “Settings” section as follows:

**********   Settings *************

             Perm can be: 
R Read
C  Change (write)
F  Full control
P  Change Permissions (Special access)
O  Take Ownership (Special access)
X  Execute (Special access)
E  Read (Special access)
W  Write (Special access)
D  Delete (Special access)

 _WINDOMAIN    = The NetBIOS domain that the permissions will reference
 _ERR_HANDLER  = The action to take after a critical un-resolvable error has occurred 
 _dependencies = Files that this script relies on
 _default_exe_store = is the network location that executables can be downloaded from if required
		
The default critical error handler is a value where you can enter the commands that you want to run if a critical error occurs. For example if you want to run a script in case of an error then enter it here, escaping any reserved characters with the caret symbol "^". Syntax: command ^& command2 ^& command…n.

set _ERR_HANDLER=pause ^& exit
set _dependencies=xcacls.exe fileacl.exe
set _default_exe_store=\\cs01corp\root\files\corp\IS\Dept\InfrastructureSystems\FilePrint\BIN
 
. 

## EXAMPLES

Set _ERR_HANDLER=pause ^& exit
Set _dependencies=xcacls.exe fileacl.exe
Set _default_exe_store=\\MyFileSserver\root\files\corp\IS\Dept\InfrastructureSystems\FilePrint\BIN


## EXIT STATUS

_Check_Homedir_Sec_Config does not return exit codes. 


## FILES

_Check_Homedir_Sec_Config depends on the following executables:
    1. xcacls.exe
    2. fileacl.exe

## SEE ALSO



## NOTES
