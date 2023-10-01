#!/usr/bin/env bash
killall -9 swhks
nohup swhks & pkexec swhkd &
