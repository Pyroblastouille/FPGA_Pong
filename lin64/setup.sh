#!/bin/sh

#---------------------------------------------------------------------------------
#                                 _             _
#                                | |_  ___ _ __(_)__ _
#                                | ' \/ -_) '_ \ / _` |
#                                |_||_\___| .__/_\__,_|
#                                         |_|
#
#---------------------------------------------------------------------------------
#
# Company: HEPIA // HES-SO
# Author: Laurent Gantel <laurent.gantel@hesge.ch>
#
# Project Name: microblaze_uart
#
# Target Device: digilentinc.com:nexys_video:part0:1.2 xc7a200tsbg484-1
# Tool version: 2024.1
# Description: TCL script creating aliases for Vivado project management scripts
#
# Last update: 2024-12-15
#
#---------------------------------------------------------------------------------

# Create aliases
alias create_project='cd .scripts && ./create_project.sh && cd ..'
alias clean_project='cd .scripts && ./clean_project.sh && cd ..'
alias open_project='cd .scripts && ./open_project.sh && cd ..'