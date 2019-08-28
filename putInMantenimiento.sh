#!/bin/bash
hostname=`hostname`
./mantenimiento.py start $hostname $1
