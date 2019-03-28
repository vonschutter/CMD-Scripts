# Administrative Commands                                       		

## NAME

_Cluster_Share_Reset.cmd: a utility to reset permissions on all cluster file shares.
     
## SYNOPSIS

 The syntax of this command is:
```
	_Cluster_Share_Reset.cmd
```

NOTE: _Cluster_Share_Reset.cmd expects to be run on the cluster node containing the Cluster resource file shares. 

## DESCRIPTION

_Cluster_Share_Reset.cmd  is a simple shell script that parses all the shares on a cluster node and resets the “everyone” permissions at the share level to a predefined value. 

		


## OPTIONS
The operations of the script can be modified in the header of the file in the “Settings” section as follows:
```
**********   Settings *************
Enter the setting that affects this shell scripts' operation.

_PERM = the permission to assign at the share level
          Perm can be: 
R  Read
C  Change (write)
F  Full control
P  Change Permissions (Special access)
W  Write (Special access)

_WINDOMAIN    = the NetBIOS domain that the permissions will reference
_ERR_HANDLER = the action to take after a critical un-resolvable error has occurred 
_dependencies = Files that this script relies on
```		


## EXAMPLES
```
	Set _PERM=F
	Set _WINDOMAIN=%COMPUTERNAME%
	Set _UserOrGroup=everyone
	Set _ERR_HANDLER=pause ^& exit
	Set _dependencies=cluster.exe
	Set _default_exe_store=\\cs01corp\root\files\corp\IS\Dept\InfrastructureSystems\FilePrint\BIN
```
## EXIT STATUS

_Cluster_Share_Reset.cmd does not return exit codes.


## FILES

_Cluster_Share_Reset.cmd depends on the following executables:
```
  1. cluster.exe
```
SEE ALSO



NOTES
