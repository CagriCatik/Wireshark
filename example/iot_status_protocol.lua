-- Define the protocol
iot_status_protocol = Proto("IoTStatusProtocol", "IoT Status Protocol")

-- Define protocol fields
local f_version = ProtoField.uint8("iot_status_protocol.version", "Protocol Version", base.HEX)
local f_device_id = ProtoField.uint32("iot_status_protocol.device_id", "Device ID", base.HEX)
local f_timestamp = ProtoField.uint32("iot_status_protocol.timestamp", "Timestamp", base.DEC)
local f_status_type = ProtoField.uint8("iot_status_protocol.status_type", "Status Type", base.HEX, {
    [0x01] = "Temperature",
    [0x02] = "Humidity",
    [0x03] = "Battery Level"
})
local f_status_value = ProtoField.uint16("iot_status_protocol.status_value", "Status Value", base.DEC)

-- Add fields to the protocol
iot_status_protocol.fields = {f_version, f_device_id, f_timestamp, f_status_type, f_status_value}

-- Helper function to convert Unix timestamp to readable date
local function format_timestamp(timestamp)
    return os.date("%Y-%m-%d %H:%M:%S", timestamp)
end

-- Dissector function
function iot_status_protocol.dissector(buffer, pinfo, tree)
    -- Ensure packet is large enough for the protocol
    if buffer:len() < 12 then
        return -- not enough data, so stop dissecting
    end
    
    -- Set the protocol name in the protocol column
    pinfo.cols.protocol = "IoTStatusProtocol"
    
    -- Create a subtree for the protocol
    local subtree = tree:add(iot_status_protocol, buffer(), "IoT Status Protocol Data")
    
    -- Protocol Version (1 byte)
    subtree:add(f_version, buffer(0, 1))
    
    -- Device ID (4 bytes)
    local device_id = buffer(1, 4):uint()
    subtree:add(f_device_id, buffer(1, 4))
    
    -- Timestamp (4 bytes)
    local timestamp = buffer(5, 4):uint()
    subtree:add(f_timestamp, buffer(5, 4)):append_text(" (" .. format_timestamp(timestamp) .. ")")
    
    -- Status Type (1 byte)
    local status_type = buffer(9, 1):uint()
    subtree:add(f_status_type, buffer(9, 1))
    
    -- Status Value (2 bytes)
    local status_value = buffer(10, 2):uint()
    local status_text = ""
    
    if status_type == 0x01 then
        status_text = string.format("%.2f °C", status_value / 100)
    elseif status_type == 0x02 then
        status_text = string.format("%.2f %%", status_value / 100)
    elseif status_type == 0x03 then
        status_text = string.format("%.3f V", status_value / 1000)
    end
    
    subtree:add(f_status_value, buffer(10, 2)):append_text(" (" .. status_text .. ")")
    
    -- Update the info column with a summary
    pinfo.cols.info = string.format("Device %08X, %s: %s", device_id, buffer(9, 1):description(), status_text)
end

-- Register the dissector to a specific TCP port (e.g., TCP port 6789)
tcp_table = DissectorTable.get("tcp.port")
tcp_table:add(6789, iot_status_protocol)
