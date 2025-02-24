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
# Description: Cleanup project directory
#
# Last update: 2024-12-15
#
#---------------------------------------------------------------------------------
echo "> Cleanup project directory..."

PRJ_DIR=..

# Remove generated temporary directory
rm -rf .Xil/ 2> /dev/null

# Remove generated project directory
rm -rf ${PRJ_DIR}/pong/ 2> /dev/null

echo "> Done"

