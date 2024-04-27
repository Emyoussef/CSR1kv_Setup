from ncclient import manager
import xml.dom.minidom

m = manager.connect(
host="192.168.56.101",
port=830,
username="cisco",
password="cisco123!",
hostkey_verify=False
)
'''
print("#Supported Capabilities (YANG models):")
for capability in m.server_capabilities:
 print(capability)
'''
#netconf_reply = m.get_config(source="running")

netconf_filter = """
<filter>
<native xmlns="http://cisco.com/ns/yang/Cisco-IOS-XE-native" />
</filter>
"""
netconf_reply = m.get_config(source="running", filter=netconf_filter)

netconf_hostname = """
<config>
<native xmlns="http://cisco.com/ns/yang/Cisco-IOS-XE-native">
<hostname>R1</hostname>
</native>
</config>
"""
netconf_reply = m.edit_config(target="running", config=netconf_hostname)

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



