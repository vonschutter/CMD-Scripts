# Administrative Commands                                       		             

## NAME

     _Move_Cluster_Share – Cluster file share mover

## SYNOPSIS

 The syntax of this command is:
 ```
 _Move_Cluster_Share.cmd <DFS path> <Destination Path> [-DEBUG] [-DRYRUN]
 ```
## DESCRIPTION

The _Move_Cluster_Share is a utility that will move a file share in a clustered file server from one volume to another and re configure the cluster to point to the new share. The target volume may be on another cluster server. 

_Move_Cluster_Share uses two stages in its operation: prepare and execute. The task of moving a cluster file share resource is split in these stages so that the actual move can be executed quickly during a maintenance window. The initial “prepare” stage can be executed at any time prior to the “execute” stage. The time it takes for the prepare stage to complete depends on the amount of data to on the volume that is being moved.    

PREPARE: While processing a source and a path, _Move_Cluster_Share will copy all the data from the source location to the target location. This is the preparation stage of the process. 

EXECUTE: Once the copy is complete, _Move_Cluster_Share will pre-synchronize the source and target locations to capture any changes that have occurred subsequent to the copy completion. This is done to accommodate large changes to the files system that may have occurred since the “prepare” step was executed. Then the DFS pointers and the Cluster resource are deleted. During the synchronization process (could be over an hour) and while the DFS and cluster chares are being brought down (15 seconds) change may be written to the file system.  As a precautionary measure, _Move_Cluster_Share will do a second resynchronization of the source and destination to capture any final changes to the file system. Once _Move_Cluster_Share is sure that all the data is correct on the target resource, a new cluster share will be created and a matching DFS pointer mapped to the new share. The new DFS share will look identical to the end user. 


## OPTIONS

The following options are supported:
```
    • <DFS path>: indicated as the first parameter passed to _Move_Cluster_Share.
    • <Destination Path>: The UNC path to the target folder or drive to be shared.
    • -DRYRUN:  Execute but only show what commands would be executed. 
    • -Debug: the debug parameter can be included anywhere on the line to toggle on the debug mode.
```
## EXAMPLES

To move a single resource, the source and destination can be provided directly:
```
_Move_Cluster_Share.cmd \\srv1\Root\Apps\Corp\RO\965180\APPS  \\srv2\i$\corp\123456
```
To trouble shoot the _Move_Cluster_Share.cmd the –debug switch can be included in the parameters to display extremely verbose output. This is only useful if you encounter unexpected behavior. 

## EXIT STATUS

There is no designed exit status for this application. However, the mover uses RET variables internally.
Enumerated meanings of the RET variables:
```
0 = SUCESS
1 = ERROR
2 = PRESENT
```



## FILES
_Move_Cluster_Share.cmd depends on the following non-standard windows executables: 
```
    1. Cluster.exe: Cluster configuration utility
    2. robocopy.exe: Site mirroring utility
    3. dfscmd.exe: DFS configuration utility
```

SEE ALSO



NOTES
