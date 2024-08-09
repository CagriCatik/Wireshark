Certainly! Wireshark allows for the extension of its functionality using the Lua scripting language. Lua scripts can be used to create custom dissectors for protocols, analyze packets, and perform other tasks within Wireshark. Below is an example of a simple Lua script that implements a custom dissector for a hypothetical protocol.

### Example: Simple Lua Dissector for a Custom Protocol

Let’s create a Lua script for a custom protocol named `SimpleProtocol`. This protocol will have the following structure:

- **Header (1 byte):** Indicates the type of message (0x01 = "Request", 0x02 = "Response").
- **Payload Length (1 byte):** Indicates the length of the payload.
- **Payload (variable length):** The actual data.

#### Lua Script: `simple_protocol.lua`

```lua
-- Create a new dissector
simple_protocol = Proto("SimpleProtocol", "Simple Protocol")

-- Define the protocol fields
local f_header = ProtoField.uint8("simple_protocol.header", "Header", base.HEX)
local f_length = ProtoField.uint8("simple_protocol.length", "Payload Length", base.DEC)
local f_payload = ProtoField.string("simple_protocol.payload", "Payload")

-- Add the fields to the protocol
simple_protocol.fields = {f_header, f_length, f_payload}

-- Dissector function
function simple_protocol.dissector(buffer, pinfo, tree)
    -- Set the protocol name in the protocol column
    pinfo.cols.protocol = "SimpleProtocol"
    
    -- Create a subtree for the protocol
    local subtree = tree:add(simple_protocol, buffer(), "Simple Protocol Data")
    
    -- Header (1 byte)
    local header = buffer(0, 1):uint()
    subtree:add(f_header, buffer(0, 1))
    
    -- Payload Length (1 byte)
    local length = buffer(1, 1):uint()
    subtree:add(f_length, buffer(1, 1))
    
    -- Payload (variable length)
    local payload = buffer(2, length)
    subtree:add(f_payload, payload)
    
    -- Determine message type from header
    if header == 0x01 then
        pinfo.cols.info = "SimpleProtocol Request"
    elseif header == 0x02 then
        pinfo.cols.info = "SimpleProtocol Response"
    else
        pinfo.cols.info = "SimpleProtocol Unknown"
    end
end

-- Register the dissector to a specific port (for example, UDP port 1234)
udp_table = DissectorTable.get("udp.port")
udp_table:add(1234, simple_protocol)
```

### How the Script Works:

1. **Protocol Definition:**
   - `Proto("SimpleProtocol", "Simple Protocol")` defines a new protocol with a name and description.
   - `ProtoField` defines the different fields in the protocol (header, length, and payload).

2. **Dissector Function:**
   - The dissector function extracts the header, length, and payload from the packet.
   - It adds these fields to the protocol tree in Wireshark.
   - Depending on the header value, the protocol column (`pinfo.cols.protocol`) and info column (`pinfo.cols.info`) are updated to show relevant information.

3. **Port Registration:**
   - The script registers the dissector to UDP port 1234. This means any traffic on UDP port 1234 will be dissected using this script.

### Using the Script in Wireshark:

1. Save the script as `simple_protocol.lua`.
2. Place the script in the appropriate directory:
   - For Unix/Linux: `~/.local/lib/wireshark/plugins/`
   - For Windows: `%APPDATA%\Wireshark\plugins\`
3. Start Wireshark and capture or load traffic on UDP port 1234. The `SimpleProtocol` dissector will automatically analyze the packets.

This script is a basic example to get started with Lua dissectors in Wireshark. You can expand it by adding more fields, handling different protocol scenarios, or creating more complex dissectors.