# ArchS
Almost reasonably Secure

## WiP, don't use this repo yet!!

### The Idea:
One hypervisor which will do nothing but store VMs.

There'll be "major VMs" which will be for my daily driver, gaming, etc.

There's also "minor VMs" which will do only one thing (or two at max): Browsing, Password Manager, FAFO'ing, etc.

I don't use Qubes OS be cause I don't have the hardware needed for what I want to do yet.
## Hypervisor
Self-explanatory
## Major VMs
"Major VMs" will be able to run "minor VMs"
### Daily Driver VM
Where I'll spend most of my time.
### Gaming VM
Windows 10 VM for games that doesn't run on Linux.
## Minor VMs
### Browser VMs
Casual: Youtube, social media, Discord. Stores information*.

Work: Work-related stuff. Will also have ONLY/Libre Office. Non work-related stuff are blocked and/or firewalled. Stores information*, deletes after it's closed.

Restrict: Hardened browser. For banking, working with sensitive data. Doesn't store information*.

Unsafe: Same as restrict but this VM will be deleted as soon as it's shut off. Doesn't store information*. For FAFO'ing

*: Cookies, cache, browser/download history, auto-fill forms, login credentials, sessions, etc
### Password Manager VM
Always offline, not even NIC attached. Will reattach NIC on occasionally for updates and deattach after it's done.
### FAFO VMs
Self explanatory
