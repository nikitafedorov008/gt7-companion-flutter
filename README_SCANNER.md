# PlayStation Network Scanner

## Overview
The GT7 Telemetry Flutter app now includes automatic PlayStation device discovery on your local network.

## Features

### 1. **Quick Scan (ARP Table)**
- Fast scan using the system's ARP cache
- Instantly shows devices that have recently communicated on your network
- Best for finding active PlayStation devices

### 2. **Deep Scan (Ping Sweep)**
- Comprehensive network scan using ICMP ping
- Takes longer but discovers all devices on the subnet
- Useful if Quick Scan doesn't find your PlayStation

## How to Use

1. Click the **search icon** (🔍) in the IP address field
2. The scanner will automatically perform a Quick Scan
3. If your PlayStation is not found, click **"Deep Scan (Ping)"**
4. Select your PlayStation from the list
5. The IP address will be automatically filled in

## Identification Method

The scanner identifies PlayStation devices by their MAC address vendor prefix:

### Sony Interactive Entertainment Prefixes
- `00:D9:D1`, `FC:0F:E6`, `C0:56:27`, `E4:A7:A0`
- These are official Sony network cards

### Hon Hai Precision (Foxconn) Prefixes
- `E8:9E:B4`, `04:33:C2`, `90:60:F1`
- Foxconn manufactures network hardware for PS4/PS5
- **Example**: Your PlayStation at `192.168.0.177` uses `E8:9E:B4`

## Troubleshooting

### PlayStation Not Detected

1. **Make sure PlayStation is ON**
   - The device must be powered on and connected to the network

2. **Check Network Connection**
   - Ensure both Mac and PlayStation are on the same network
   - Verify PlayStation network settings: Settings → Network → View Connection Status

3. **Try Deep Scan**
   - Quick Scan only sees devices in ARP cache
   - Deep Scan actively probes all IPs on the subnet

4. **Manual Entry**
   - You can still manually enter the IP address
   - Find IP on PlayStation: Settings → System → Console Information

### macOS Permissions

The scanner requires network access permissions:
- **Incoming**: `com.apple.security.network.server` ✓
- **Outgoing**: `com.apple.security.network.client` ✓

These are already configured in the app's entitlements.

## Technical Details

### Quick Scan
```bash
# The scanner runs:
arp -a
```
- Parses ARP table entries
- Matches MAC addresses against known PlayStation vendors
- Instant results (< 1 second)

### Deep Scan
```bash
# The scanner runs (for each IP in subnet):
ping -c 1 -W 1000 192.168.0.X
```
- Pings all IPs in subnet (192.168.0.1-254)
- Populates ARP table with responses
- Then reads ARP table
- Takes 10-30 seconds depending on network

## Supported Devices

- ✅ PlayStation 4 (all models)
- ✅ PlayStation 5 (all models)
- ✅ PS4 Pro
- ✅ PS5 Digital Edition

All devices running GT7 with telemetry enabled.
