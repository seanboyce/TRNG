from machine import Pin
import network
from time import sleep
from umqtt.simple import MQTTClient

# Setup LED, so we know it's on
led = machine.Pin("LED", machine.Pin.OUT)
led.toggle()

# Wi-Fi credentials
ssid = 'your_wifi_ssid'
password = 'your_wifi_password'

# A function to connect to Wi-Fi
def connect():
    #Connect to WLAN
    wlan = network.WLAN(network.STA_IF)
    wlan.active(True)
    wlan.connect(ssid, password)
    while wlan.isconnected() == False:
        print('Waiting for connection...')
        sleep(1)
    print(wlan.ifconfig())

# MQTT Server credentials
MQTT_SERVER = "your_mqtt_server"
MQTT_PORT = your_mqtt_port
MQTT_USER = "your_mqtt_username"
MQTT_PASSWORD = "your_mqtt_password"
MQTT_CLIENT_ID = ""
MQTT_KEEPALIVE = 7200
MQTT_SSL = False

#Initial states for data
data = 0
freshData = False

# A function to connect to MQTT
def connect_mqtt():
    try:
        client = MQTTClient(client_id=MQTT_CLIENT_ID,
                            server=MQTT_SERVER,
                            port=MQTT_PORT,
                            user=MQTT_USER,
                            password=MQTT_PASSWORD,
                            keepalive=MQTT_KEEPALIVE,
                            ssl=MQTT_SSL)
        client.connect()
        return client
    except Exception as e:
        print('Error connecting to MQTT:', e)
        raise  # Re-raise the exception to see the full traceback

# A function to publish to MQTT once connected
def publish_mqtt(topic, value):
    client.publish(topic, value)
    #print(topic)
    #print(value)
    #print("Publish Done")

# No Ports on raspberry pi, so we fake one with 8 pins
def readByte(newData):
    global data
    data = bit0.value() + 2*bit1.value() + 4* bit2.value() + 8*bit3.value() + 16*bit4.value() + 32*bit5.value() + 64*bit6.value() + 128*bit7.value()
    global freshData
    freshData = True


# Driver code on startup
connect()
client = connect_mqtt()

# Turn off LED once connected
led.toggle()


# Configure input pins
bit0 = Pin(0, Pin.IN, Pin.PULL_DOWN)
bit1 = Pin(1, Pin.IN, Pin.PULL_DOWN)
bit2 = Pin(2, Pin.IN, Pin.PULL_DOWN)
bit3 = Pin(3, Pin.IN, Pin.PULL_DOWN)
bit4 = Pin(4, Pin.IN, Pin.PULL_DOWN)
bit5 = Pin(5, Pin.IN, Pin.PULL_DOWN)
bit6 = Pin(6, Pin.IN, Pin.PULL_DOWN)
bit7 = Pin(7, Pin.IN, Pin.PULL_DOWN)
newData = Pin(8, mode=Pin.IN, pull=Pin.PULL_DOWN)
newData.irq(trigger=Pin.IRQ_RISING,handler=readByte)

print("Starting")

# Main loop. Basically fire off a byte out MQTT every time the interrupt triggers.

while True:
    if freshData:
        newData.irq(handler=None) # Don't interrupt sending data
        publish_mqtt("entropy", str(data))
        led.toggle() # LED will flicker if it's sending data
        newData.irq(trigger=Pin.IRQ_RISING,handler=readByte)
        freshData = False


