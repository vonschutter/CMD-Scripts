# Administrative Commands                                       		 

## NAME

_Remote_List_Software.cmd: a utility to list installed software on a computer.
     
## SYNOPSIS

 The syntax of this command is:
 ``` 
	_Remote_List_Software.cmd <HOSTNAME>
```
NOTE: To list installed software on the local computer, pass the local computer name to the script.

## DESCRIPTION

_Remote_List_Software.cmd  is a simple shell script that lists out any software and patches installed on a remote computer. 
		


## OPTIONS

There are no configurable parameters for this shell script.

## EXAMPLES
```
_Remote_List_Software.cmd dc1.hades.mydomain.com
```	
The above command would list out all the software and patches installed on the server dc1.hades.mydomain.com. 
```
_Remote_List_Software.cmd %COMPUTERNAME%
```
The above command would list out all the software and patches installed on the local computer.
```
_Remote_List_Software.cmd dc1.hades.mydomain.com |find /V “KB”
```	
The above command would list out all the software and patches installed on the server dc1.hades.mydomain.com excluding all the knowledge base articles installed.
```
_Remote_List_Software.cmd dc1.hades.mydomain.com |find /I “WinZip”
```
The above command would quickly check to see if WinZip was installed on the server dc1.hades.mydomain.com.


## EXIT STATUS

_Remote_List_Software.cmd does not return exit codes.


## FILES

_Remote_List_Software.cmd depends on the following executables:

SEE ALSO



NOTES
