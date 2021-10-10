#!/bin/bash

WSL_DIR=$1
DIR=$(wslpath -w $WSL_DIR)
POWERSHELL=/mnt/c/Windows/System32/WindowsPowerShell/v1.0/powershell.exe

$POWERSHELL $DIR\\Compiler.ps1 $DIR\\src\\main.mq4