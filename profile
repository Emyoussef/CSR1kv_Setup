#!/usr/bin/python3

from ncclient import manager
import xml.dom.minidom
import getpass
import re
import json
import os

# Function to save the credential profile to a JSON file
def save_profile(profile_name, dev_addr, dev_port, dev_name):
    profile = {
        "dev_addr": dev_addr,
        "dev_port": dev_port,
        "dev_name": dev_name
    }
    try:
        # Create the profiles directory if it doesn't exist
        if not os.path.exists("profiles"):
            os.makedirs("profiles")

        with open(f"profiles/{profile_name}.json", "w") as file:
            json.dump(profile, file)
        if os.path.exists(f"profiles/{profile_name}.json"):
            print(f"Profile '{profile_name}' saved successfully.")
        else:
            print(f"Error: Profile '{profile_name}' was not saved.")
    except Exception as e:
        print(f"Error occurred while saving profile '{profile_name}': {str(e)}")

# Function to load a credential profile from a JSON file
def load_profile(profile_name):
    try:
        with open(f"profiles/{profile_name}.json", "r") as file:
            profile = json.load(file)
            return profile["dev_addr"], profile["dev_port"], profile["dev_name"]
    except FileNotFoundError:
        print(f"Profile '{profile_name}' not found.")
        return None, None, None

# Function to create a new profile or load an existing one
def create_or_load_profile():
    choice = input("Would you like to load a profile, create a new one, or exit? (load/create/exit): ")
    if choice.lower() == 'load':
        profile_name = input("Enter the name of the profile you want to load: ")
        dev_addr, dev_port, dev_name = load_profile(profile_name)
        if dev_addr is not None:
            dev_pass = str(getpass.getpass(prompt="Please provide the password: "))
            return profile_name, dev_addr, dev_port, dev_name, dev_pass
        else:
            print("Profile does not exist.")
            return None, None, None, None, None
    elif choice.lower() == 'create':
        profile_name = input("Enter a name for this profile: ")
        dev_addr = input("Provide the name or IP address for the target device: ")
        dev_port = input("Please provide the port [830]: ") or 830
        dev_name = str(input("Please provide the username [cisco]: ") or 'cisco')
        dev_pass = str(getpass.getpass(prompt="Please provide the password [cisco123!]: ", stream=None) or 'cisco123!')
        save = input("Would you like to save this profile? (yes/no): ")
        if save.lower() == 'yes':
            save_profile(profile_name, dev_addr, dev_port, dev_name)
        return profile_name, dev_addr, dev_port, dev_name, dev_pass
    elif choice.lower() == 'exit':
        exit()

# Allow the user to define credentials and verify they appear valid
def credential_valid():
    confirm = 'n'
    print("Provide host information and credentials, default values are []s, press enter to accept")
    while confirm == 'n':
        profile_name = input("Enter a name for this profile: ")
        dev_addr = input("Provide the name or IP address for the target device: ")
        dev_port = input("Please provide the port [830]: ") or 830
        dev_name = str(input("Please provide the username [cisco]: ") or 'cisco')
        dev_pass = str(getpass.getpass(prompt="Please provide the password [cisco123!]: ", stream=None) or 'cisco123!')
        check = str(input(f"Please confirm you wish to connect to {dev_addr} on port {dev_port} as user {dev_name} (Y to confirm)? "))
        if check.lower()[0] == 'y':
            confirm = 'y'
    return profile_name, dev_addr, dev_port, dev_name, dev_pass

# Ask user for credentials and connection information
profile_name, dev_addr, dev_port, dev_name, dev_pass = create_or_load_profile()

# Check if profile loading was successful before attempting to connect
if dev_addr is not None:
    print("...Connecting to", dev_addr, "as", dev_name)
    m = manager.connect(
        host=dev_addr,
        port=dev_port,
        username=dev_name,
        password=dev_pass,
        hostkey_verify=False
    )

    # store the available running configuration in the netconf_config string
    netconf_filter = """
    <filter>
    <native xmlns="http://cisco.com/ns/yang/Cisco-IOS-XE-native" />
    </filter>
    """
    netconf_config = str(m.get_config(source="running", filter=netconf_filter))

    # Pull the current hostname from the netconf_config and present it to the user
    cur_hostname = re.search('(?<=<hostname>)(.*)(?=</hostname>)', netconf_config)
    print("The current hostname is:", cur_hostname.group())

    # Ask the user if they want to change it to the stored hostname
    name_select = str(input("Do you want to change it to 'super.router'? "))
    if name_select.lower()[0] == 'y':
        netconf_hostname = """
        <config>
        <native xmlns="http://cisco.com/ns/yang/Cisco-IOS-XE-native">
        <hostname>super.router</hostname>
        </native></config>
        """
        netconf_reply = m.edit_config(target="running", config=netconf_hostname)
    else:
        print("Leaving hostname", cur_hostname.group())

    netconf_loopback = """
    <config>
    <native xmlns="http://cisco.com/ns/yang/Cisco-IOS-XE-native">
    <interface>
    <Loopback>
    <name>1</name>
    <description>My NETCONF loopback</description>
    <ip>
    <address>
    <primary>
    <address>10.1.1.1</address>
    <mask>255.255.255.0</mask>
    </primary>
    </address>
    </ip>
    </Loopback>
    </interface>
    </native>
    </config>
    """
    netconf_reply = m.edit_config(target="running", config=netconf_loopback)

    netconf_loopback2 = """
    <config>
    <native xmlns="http://cisco.com/ns/yang/Cisco-IOS-XE-native">
    <interface>
    <Loopback>
    <name>2</name>
    <description>My second NETCONF loopback</description>
    <ip>
    <address>
    <primary>
    <address>172.16.1.1</address>
    <mask>255.255.255.0</mask>
    </primary>
    </address>
    </ip>
    </Loopback>
    </interface>
    </native>
    </config>
    """
    netconf_reply = m.edit_config(target="running", config=netconf_loopback2)

    netconf_loopback3 = """
    <config>
    <native xmlns="http://cisco.com/ns/yang/Cisco-IOS-XE-native">
    <interface>
    <Loopback>
    <name>3</name>
    <description>My third NETCONF loopback</description>
    <ip>
    <address>
    <primary>
    <address>209.165.200.65</address>
    <mask>255.255.255.252</mask>
    </primary>
    </address>
    </ip>
    </Loopback>
    </interface>
    </native>
    </config>
    """
    netconf_reply = m.edit_config(target="running", config=netconf_loopback3)
    print(xml.dom.minidom.parseString(netconf_reply.xml).toprettyxml())
else:
    print("Exiting program.")
