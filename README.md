# LYWSD03MMC UART flasher

Flashes pvvx's ZigbeeTLc firmware (`firmware/Z03MMC_v0139.bin`) onto Xiaomi LYWSD03MMC thermometers over a USB-UART adapter, using
[TLSR825xComFlasher.py](https://github.com/pvvx/TlsrComSwireWriter) (commit `042613b`).

## Adapter

Set the adapter to 3.3 V. Its RX line must not have an LED on it (known not to work, per pvvx).

**FTDI adapters: set the latency timer to 1 ms first.** pvvx lists FTDI as unsupported, but an FT232R works fine once this
is changed. With the default 16 ms, every command waits for the timer, so flashing is very slow and most attempts fail.

Device Manager → Ports → USB Serial Port (COMx) → Properties → Port Settings → Advanced → Latency Timer (msec) = **1**.
Close anything using the port before changing it. The setting is per adapter, so repeat it for each FTDI adapter you use.

## Wiring

```
Adapter TX --[1k..1.8k]--+-- SWS pad (marked P14 on the PCB)
Adapter RX --------------+
Adapter RTS ---------------- Reset pad          (optional, enables auto-reset)
Adapter 3.3V --------------- battery +
Adapter GND ---------------- battery -
```

Pinout photos: https://github.com/pvvx/ATC_MiThermometer/tree/master/BoardPinout

## Flashing

```
flash.cmd COM5
```

It loops: wire up a device, press a key, it flashes and reboots the device, then waits for the next one.
After flashing, the thermometer is in Zigbee pairing mode.

- With RTS wired to Reset, activation is automatic.
- Without it, press the key with GND disconnected, then connect GND (battery -) within the 2 s activation window.
  Use `set TACT=5000` first for a longer window.
- Any firmware can be passed as the second argument: `flash.cmd COM5 firmware\other.bin`.

Do **not** use the flasher's `ea` (erase all) command: it wipes the device's MAC address at `0x76000`.
`wf` only erases the sectors it writes (`0x00000`-`0x20FFF` for this firmware).

Optional per-device backup of the original flash (512 KB, slow):

```
.venv\Scripts\python.exe TLSR825xComFlasher.py -p COM5 -t 2000 rf 0 0x80000 backup.bin
```
