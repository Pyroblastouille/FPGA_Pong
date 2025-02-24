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
# Project Name: pong
# Target Device: digilentinc.com:nexys_video:part0:1.2 xc7a200tsbg484-1
# Tool version: 2024.1
# Description: Open Vivado project GUI
#
# Last update: 2024-12-15
#
#---------------------------------------------------------------------------------

echo "> Open Vivado GUI..."
vivado -nojournal -nolog -notrace ../pong/pong.xpr
