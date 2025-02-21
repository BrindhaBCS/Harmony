#!/bin/bash
#crm config params
parameter_value=$(crm configure show | grep -oP "pcmk_delay_max=\K\d+")
if [ -n "$parameter_value" ]; then
    printf 'pcmk_delay_max = %s\n' "$parameter_value"
else
    printf 'pcmk_delay_max = "Parameter not found"\n'
fi
#expected value 15