# Administrative Commands                                       		 

## NAME

_Repath_AD_User_and_TS_Home.cmd: a utility to mass modify users’ home and Terminal Server home pointers. 
     
## SYNOPSIS

The syntax of this command is:
```
_Repath_AD_User_and_TS_Home.cmd <MapFile>
```
 Where "MapFile" is the name of a comma separated file containing
 User ID and Home Root Path. Example:
```
JoeSchmo, \\homeserver01\Home
JaneDoe,  \\homeserver02\Home
```
## DESCRIPTION

_Repath_AD_User_and_TS_Home.cmd is a utility that lets you provide a comma separated file listing user IDs to their respective UNC home root locations. 


## OPTIONS
You can change the options that determine how the script works by editing the settings section in the scrip as follows:
```
**********   Settings *************

_WINDOMAIN    = The netbios domain that the permissions will reference
_ERR_HANDLER  = The action to take after a critical un-resolvable error has occurred 
_dependencies = Files that this script relies on
_default_exe_store = is the network location that executables can be downloaded from if required

set _HomeDriveLetter=P:&		::Drive letter to use for home and terminal server home...
set _default_exe_store=\\server\ROOT\Shell Programs\bin
set _DS=dsp03na&			::Directory server to use to modify settings... 
set _PERM=C&				::Permissions to use for the home folder...
Perm can be: 
R  Read
C  Change (write)
F  Full control
P  Change Permissions (Special access)
O  Take Ownership (Special access)
X  EXecute (Special access)
E  REad (Special access)
W  Write (Special access)
D  Delete (Special access)

set _WINDOMAIN=NA&			::Name of the DOMAIN to look for users in...
set _ERR_HANDLER=pause ^& exit&	::What to do when something really bombs!
```

## EXAMPLES
```
_Repath_AD_User_and_TS_Home.cmd c:\mapfile.csv
```


## EXIT STATUS

There is no exit status.


## FILES
_Repath_AD_User_and_TS_Home depends on the following files:
```
    1. tscmd.exe 
    2. dsquery.exe 
    3. xcacls.exe
```

SEE ALSO



NOTES
