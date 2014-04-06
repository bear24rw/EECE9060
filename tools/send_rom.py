import os
import sys
import serial
import time

s = serial.Serial('/dev/ttyS0', 115200)

rom_file = sys.argv[1]
rom_size = os.path.getsize(rom_file)

print "Rom size: %d" % rom_size

rom = open(sys.argv[1], 'rb')

bytes_sent = 0
percent_sent = 0.0

print "Waiting for FPGA to request bytes..."

for sent_byte in rom.read():

    s.write(sent_byte)

    recv_byte = s.read()

    bytes_sent += 1
    percent_sent = float(bytes_sent)/float(rom_size)*100.0

    # we should receive back the last byte we sent as an ACK
    if (recv_byte != sent_byte):
        print "RECIEVED BYTE DOES NOT MATCH!"
        print "Recv: %2X | Sent: %2X" % (ord(recv_byte), ord(sent_byte))
        sys.exit()

    print "[%.2f] %d / %d (sent: %2X | recv: %2X)" % \
            (percent_sent, bytes_sent, rom_size, ord(sent_byte), ord(recv_byte) )

