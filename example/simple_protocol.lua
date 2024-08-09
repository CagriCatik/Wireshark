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
