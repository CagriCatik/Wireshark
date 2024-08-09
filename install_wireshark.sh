#!/bin/bash

# Update package list
echo "Updating package list..."
sudo apt update

# Install Wireshark
echo "Installing Wireshark..."
sudo apt install -y wireshark

# Configure Wireshark to allow non-root users to capture packets
echo "Configuring Wireshark..."
sudo dpkg-reconfigure wireshark-common

# Add current user to the wireshark group
echo "Adding user $USER to the Wireshark group..."
sudo usermod -aG wireshark $USER

# Inform the user about the need to log out and back in
echo "Installation complete!"
echo "Please log out and log back in for the group changes to take effect."

# Optionally launch Wireshark (commented out)
# echo "Launching Wireshark..."
# wireshark &
