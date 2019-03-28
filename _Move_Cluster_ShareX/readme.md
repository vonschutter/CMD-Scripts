# Administrative Commands                                       		               

## NAME

     _Move_Cluster_ShareX – Extended Cluster file share mover

## SYNOPSIS

 The syntax of this command is:
 ```
_Move_Cluster_ShareX.cmd <DFS path> <Destination Path> [-DEBUG] [-DRYRUN]
_Move_Cluster_ShareX.cmd <DFS path> <*…> [-DEBUG] [-DRYRUN] [-NODETECT]
_Move_Cluster_ShareX.cmd -Map-File=<FILE.CSV> [-DEBUG] [-DRYRUN] [-NODETECT]
_Move_Cluster_ShareX.cmd -make detailed template
_Move_Cluster_ShareX.cmd -make simple template
 ```
NOTE: Brackets “[…]” indicate optional parameters and redirects “<…>” required parameters for the given scenario.  The * character means that all detailed options are provided: DFS Source URL, Destination Server (just the hostname), Destination Drive (e.g. C-Z$), Destination Cluster (Cluster name), Destination Cluster Resource, Destination Target Root Path. NODETECT only makes sense if all these parameters are provided either on the command line or in a detailed *.CSV file. 

## DESCRIPTION

The _Move_Cluster_ShareX is a utility that will move a file share in a clustered file server from one volume to another and re configure the cluster to point to the new share. The target volume may be on another cluster server. 

_Move_Cluster_ShareX uses two stages in its operation: prepare and execute. The task of moving a cluster file share resource is split in these stages so that the actual move can be executed quickly during a maintenance window. The initial “prepare” stage can be executed at any time prior to the “execute” stage. The time it takes for the prepare stage to complete depends on the amount of data to on the volume that is being moved.    

PREPARE: While processing a source and a path, _Move_Cluster_ShareX will copy all the data from the source location to the target location. This is the preparation stage of the process. 

EXECUTE: Once the copy is complete, _Move_Cluster_ShareX will pre-synchronize the source and target locations to capture any changes that have occurred subsequent to the copy completion. This is done to accommodate large changes to the files system that may have occurred since the “prepare” step was executed. Then the DFS pointers and the Cluster resource are deleted. During the synchronization process (could be over an hour) and while the DFS and cluster chares are being brought down (15 seconds) change may be written to the file system.  As a precautionary measure, _Move_Cluster_ShareX will do a second resynchronization of the source and destination to capture any final changes to the file system. Once _Move_Cluster_ShareX is sure that all the data is correct on the target resource, a new cluster share will be created and a matching DFS pointer mapped to the new share. The new DFS share will look identical to the end user. 


## OPTIONS

The following options are supported:
 ```
    • <DFS path>: indicated as the first parameter passed to _Move_Cluster_Share.
    • <Destination Path>: The UNC path to the target folder or drive to be shared.
    • Map-file:  There is also an option to provide a comma separated list of matching DFS and Destination paths. This map file can be either detailed or simple.  If the file is detailed, all elements of operation are specified in the comma separated file. Otherwise, simple layout is assumed. Simple layout only includes source DFS path and destination UNC path. 
    • DEBUG: the debug parameter can be included anywhere on the line to toggle on the debug mode.
    • DRYRUN: Causes the script to run in ‘dry run mode’, only displaying all the commands that would be executed, instead of actually executing them. 
    • NODETECT: Disables path detection (required for detailed mode)
    • Make detailed template: Generate a template *.CSV file for detailed mode.
    • Make simple template: Generate a template *.CSV file for simple mode.
 ```
## EXAMPLES

To move a single resource, the source and destination can be provided directly:
 ```
_Move_Cluster_ShareX.cmd \\CS01CORP\Root\Apps\Corp\RO\965180\APPS  \\dv03fc2i\i$\corp\123456
 ```
To move any number of resources a list containing the source and target can be provided as an argument instead:
 ```
_Move_Cluster_ShareX.cmd map-file=FILE.CSV
 ```
To move any number of resources with ultimate flexibility (detailed mode) a list containing the detailed source and target can be provided as an argument instead (the NODETECT option is required for this operation):
 ```
_Move_Cluster_ShareX.cmd map-file=FILE.CSV -NODETECT
 ```
To trouble shoot the _Move_Cluster_ShareX.cmd the –debug switch can be included in the parameters to display extremely verbose output. This is only useful if you encounter unexpected behavior. 

To run the mover and only show what commands would be executed if actually invoked:
 ```
_Move_Cluster_ShareX.cmd \\DFS\Root\Apps\CC   \\dv03fc2i\i$\corp\123456  -DRYRUN
 ```
Be sure to remove the registry entries that the script creates if you actually want to execute the script and move the resources. The move creates all keys in HKLM\Software\_aniara\_Move_Cluster_ShareX.cmd

## EXIT STATUS

There is no designed exit status for this application. However, the mover uses RET variables internally.
Enumerated meanings of the RET variables:
```
0 = SUCESS
1 = ERROR
2 = PRESENT
```



FILES
_Move_Cluster_ShareX.cmd depends on the following no-standard windows executables: 
 ```
    1. Cluster.exe: Cluster configuration utility
    2. robocopy.exe: Site mirroring utility
    3. dfscmd.exe: DFS configuration utility
 ```

SEE ALSO



NOTES
