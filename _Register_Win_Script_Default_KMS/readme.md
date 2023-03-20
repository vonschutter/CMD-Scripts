# Administrative Commands                                         _Remote_List_Software.cmd

## NAME

_Register_Win_Script_Default_KMS.cmd: a utility to register Windows for 180 days.

## SYNOPSIS

 The syntax of this command is:
 ```
 _Register_Win_Script_Default_KMS.cmd auto
```

## DESCRIPTION

_Register_Win_Script_Default_KMS.cmd  is a simple shell script that will register your computer so that you will have full usability for 180 days. Unless you register your copy of windows you will lack som functionality like the ability to customize your desktop.



## OPTIONS

There are no configurable parameters for this shell script.

## EXAMPLES
```
_Register_Win_Script_Default_KMS.cmd auto
```
The above command would automatically register your computer. You could use this to register a VM using unattended build scripts.  

Example Extract From Autounattend.xml:
```
<FirstLogonCommands>
<SynchronousCommand wcm:action="add">
        <CommandLine>a:\_Register_Win_Script_Default_KMS.cmd auto</CommandLine>
<Description>Run Software install</Description>
 <Order>1</Order>
</SynchronousCommand>
</FirstLogonCommands>
```


## EXIT STATUS

Standard error only


## FILES

_Register_Win_Script_Default_KMS.cmd

## SEE ALSO



## NOTES

