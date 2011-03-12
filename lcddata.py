#!/usr/bin/python
import serial
import mpd
import time
import os

ser = serial.Serial("/dev/UART",57600)
mpdInfo = mpd.MPDClient()
mpdInfo.connect("localhost","6600")


def read():
    a = ser.read()
    if a == '\x20':
        print "got -> 0x20"
        os.system("mpc toggle")
        write(" Play/Pause")
        time.sleep(0.5)
        clear()
    elif a == '\x30':
        print "got -> 0x30"
        mpdInfo.__getattr__("previous")()
        write(" Previous Song")
        time.sleep(0.5)
        clear()
    elif a == '\x40':
        print "got -> 0x40"
        mpdInfo.__getattr__("next")()
        write(" Next Song")
        time.sleep(0.5)
        clear()
    elif a == '\x60':
        print "got -> 0x60"
        os.system("mpc volume +4")
        write(" Volume Up")
        time.sleep(0.5)
        clear()
    elif a == '\x70':
        print "got -> 0x70"
        os.system("mpc volume -4")
        write(" Volume Dowm")
        time.sleep(0.5)
        clear()
    elif a != '\xff':
        print a

def write(s):
    for i in s[:16]:
        ser.write(i)
        read()

def clear():
    ser.write("\x00")
    read()

def lcd_init():
    ser.write("\xff")
    read()

def name():
    return mpdInfo.__getattr__("currentsong")()['title']

def update_new2():
    while True:
        n = " * " + name()
        old = n
        song_name = old
        num = len(old)
        while old == n:
            song_name = song_name[1:] + song_name[0]
            clear()
            write(song_name)
            time.sleep(0.35)
            n = " * " + name()

update_new2()
