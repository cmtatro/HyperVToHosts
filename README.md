# HyperVToHosts
Short Bat and shell script to read the notes of your VM's and add them to your hosts file

## What does it do?
Run the bat script as adminastrator, It will generate a copy of the existing host file to hosts.base. Host.base should now be used if you want to persist any hosts input
on an ongoing basis. A current back up of the existing hosts file will be generated as well and placed in the same directory with the current date. There is no cleanup in the script so you will have to manually remove them.
It will generate a few entries: The full vmname in lowercase with a local extension, All caps only with .dev extension, then all the entries between the `###domains##` tag
### example
```
MyLocalMachine
##domains## mytest.site myvm.dev ##domains##
```
Would input an entry in your hosts file like
```
###.###.###.###  mylocalmachine.local mlm.dev mytest.site myvm.dev
```

## How to use
In hyperV under your VM Settings -> Management -> Name there is a notes section. The only requirements are that you have `##domain##` then a list of domains, with a close domain tag, and your vm has vmtools installed so that the ip address is accessable to the host machine. You can validate that by viewing the networking tab on your vm, if there is an ip address it will work.

All versions below are valid, but only one can be used per vm
``` 
##domains##
example.test
test.test
##domains##

##domains##
example.dev test.example
##domains##

##domains## test-example.dev test.test ##domains##

##domains## test-example.dev
test.test ##domains##

##domains## test-example.dev test.test
##domains##
```

