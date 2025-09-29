import board
import busio
import sdcardio
import storage

# sd card
spi = busio.SPI(board.GP18, MOSI=board.GP19, MISO=board.GP16)
cs = board.GP17

sdcard = sdcardio.SDCard(spi, cs)
vfs = storage.VfsFat(sdcard)

storage.mount(vfs, "/sd")

with open("/sd/thing.csv", "w") as f:
    f.write("hello dude\n")

with open("/sd/thing.csv", "r") as f:
    print("read 1:")
    print(f.read())

with open("/sd/thing.csv", "a") as f:
    f.write("hello part 2 get ready baby")

with open("/sd/thing.csv", "r") as f:
    print("read 2 append:")
    print(f.read())


