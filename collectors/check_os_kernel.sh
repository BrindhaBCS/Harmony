#!/bin/bash
Kernel_Version=$(uname -r)
if [[ -z "$Kernel_Version" ]]; then
    printf 'Kernel_Version="Unknown"\n'
else
    printf 'Kernel_Version="%s"\n' "$Kernel_Version"
fi