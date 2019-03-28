# Administrative Commands                                

## NAME
_Clean_Homedir.cmd: Home directory orphaned user finder & archive utillity.
     
## SYNOPSIS

 The syntax of this command is:
	_Clean_Homedir.cmd [-dryrun] [-debug]

NOTE: The shell script expects your Present Working Directory to be the home folder to check

## DESCRIPTION
_Clean_Homedir.cmd is a simple shell script that parses the Present Working Directory (PWD) and queries Active Directory to find a username that matches the name of each folder. If there is no match, the folder will be compressed in to a *.ZIP file and moved to a staging location defined in the settings. 


## OPTIONS

The operations of the script can be modified in the header of the file in the “Settings” section as follows:
```
**********   Settings *************

_WINDOMAIN    = The NetBIOS domain that the permissions will reference
_ERR_HANDLER  = The action to take after a critical un-resolvable error has occurred 
_dependencies = Files that this script relies on
_default_exe_store = is the network location that executables can be downloaded from if required
_STAGE-ROOT= the folder to contain all logs and compressed archives by date
_STAGE-FOLDER= the unique location of each days compressed archives and logs
_LOGDIR= the location where log files are to be stored
_LOG= the full path to the log file
_ERROR_LOG= the full path to the error log file (optional)
```

The default critical error handler is a value where you can enter the commands that you want to run if a critical error occurs. For example if you want to run a script in case of an error then enter it here, escaping any reserved characters with the caret symbol "^". Syntax: command ^& command2 ^& command…n.

 

## EXAMPLES

Examples for settings:
```
    1. set _ERR_HANDLER=pause ^& exit
    2. set _dependencies=7Z.exe dfscmd.exe
    3. set _default_exe_store=\\server\root\files\Corp\IS\Dept\Scripts\Shell Programs\bin
```

Examples of how to call the script:
```
    1. _Clean_Homedir.cmd –debug (logs lots!)
    2. _Clean_Homedir.cmd –dryrun (pretends to run)
    3. _Clean_Homedir.cmd –dryrun –debug (both)
```

## EXIT STATUS

_Clean_Homedir.cmd does not return exit codes. 

Internally the compression tool uses the following return codes:

```
Code	Meaning
0	No error
1 	Warning (Non fatal error(s)). For example, some files were locked by other application during compressing. 
	So they were not compressed.
2	Fatal error
7 	Command line error
8	Not enough memory for operation
255	User stopped the process
```



## FILES

_Clean_Homedir.cmd depends on the following executables:
```
    1. dfscmd.exe  (used for Active Directory queries)
    2. 7z.exe (used for large files size compression)
```

SEE ALSO



NOTES

It is recommended to schedule a task to run the utility. For example; use the AT command can be used to schedule the task. 
