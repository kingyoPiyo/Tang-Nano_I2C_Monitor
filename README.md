# Tang-Nano_I2C_Monitor
I2C Bus monitor on Tang-Nano FPGA !!  
<img src="doc/top.png" width="400">  

## Usage
1. Update the CH552T firmware to enable UART communication.  (See here : [Tang NanoのFPGAとPC間でUART通信をする](https://qiita.com/ciniml/items/05ac7fd2515ceed3f88d))
2. Write [BitStream](impl/pnr/i2c_moni.fs) file to FPGA.
3. Connect the Tang-Nano 'I2C_SCL' and 'I2C_SDA' pin to I2C Bus line.
4. Connect to a PC and open the serial terminal. Baud rate is 1Mbps.

## Output Example

```
## Timestamp Disable (default)
S 78 A 00 A AE A D5 A 80 A A8 A P
S 78 A 00 A 3F A P
S 78 A 00 A D3 A 00 A 40 A 8D A P
S 78 A 00 A 14 A P
S 78 A 00 A 20 A 00 A A1 A C8 A P
S 78 A 00 A DA A 12 A 81 A P
S 78 A 00 A CF A P
S 78 A 00 A D9 A P
S 78 A 00 A F1 A P
S 78 A 00 A DB A 40 A A4 A A6 A 2E A AF A P
S 78 A 00 A 22 A 00 A FF A 21 A 00 A P
S 78 A 00 A 7F A P
^ ------------------- Start condition
  ^^ ---------------- Data (hexadecimal)
     ^ -------------- ACK
                 ^ -- Stop condition


## Timestamp Enable
00000000 S 78 A 00 A AE A D5 A 80 A A8 A P
00000483 S 78 A 00 A 3F A P
000006B2 S 78 A 00 A D3 A 00 A 40 A 8D A P
00000AD1 S 78 A 00 A 14 A P
00000CFB S 78 A 00 A 20 A 00 A A1 A C8 A P
00001126 S 78 A 00 A DA A 12 A 81 A P
0000149A S 78 A 00 A CF A P
000016C5 S 78 A 00 A D9 A P
000018EF S 78 A 00 A F1 A P
00001B1C S 78 A 00 A DB A 40 A A4 A A6 A 2E A AF A P
00002275 S 78 A 00 A 22 A 00 A FF A 21 A 00 A P
0000273B S 78 A 00 A 7F A P
^^^^^^^^ ------------ Timestamp (hexadecimal, max : FFFFFFFF) [us]
                      (Start counting from the first start bit detection.)
         ^ ---------- Start condition
           ^^ ------- Data (hexadecimal)
              ^ ----- ACK
```

|  Symbol  |  Description |
| -------- | ------ |
| S | Start condition |
| P | Stop condition 
| A | ACK |
| N | NACK |

|  LED  |  Description |
| -------- | ------ |
| Red | UART Tx FIFO Overflow (Press button A to reset) |
| Green | UART Tx busy | 
| Blue | ON : Timestamp enabled / OFF : Timestamp disabled |

|  Button  |  Description |
| -------- | ------ |
| A | Global reset |
| B | Short (<1000ms) press : Toggle Timestamp Enable / Long (>= 1000ms) press : Reset Timestamp counter | 

## Schematic
![Schematic](doc/Schematic.png)  

## IDE
- GOWIN FPGA Designer Version 1.9.7.02 Beta build(44900)

## Resource Usage Summary
|  Resource  |  Usage |  Utilization  |
| ---------- | ------ | ------------- |
|  Logics  |  465/1152  | 40% |
|  --LUTs,ALUs,ROM16s  |  465(440 LUT, 25 ALU, 0 ROM16)  | - |
|  --SSRAMs(RAM16s)  |  0  | - |
|  Registers  |  227/945  | 24% |
|  --logic Registers  |  225/864  | 26% |
|  --I/O Registers  |  2/81  | 2% |
|  BSRAMs  |  4 SDPB | 100% |
