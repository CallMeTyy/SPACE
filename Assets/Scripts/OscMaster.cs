using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using UnityEngine;
using extOSC;
using TMPro;
using UnityEngine.Rendering.VirtualTexturing;
using UnityEngine.UI;

public class OscMaster : MonoBehaviour
{
    private OSCTransmitter _transmitter;
    private OSCReceiver _receiver;
    private List<string> ips;
    private List<string> phones;
    private List<int> ports;

    [SerializeField] private Text _players;
    [SerializeField] private Text ip;


    // Start is called before the first frame update
    void Start()
    {
        phones = new List<string>();
        ips = new List<string>();
        ports = new List<int>();
        _transmitter = gameObject.AddComponent<OSCTransmitter>();

        // Set remote host address.
        _transmitter.RemoteHost = "127.0.0.1";

        // Set remote port;
        _transmitter.RemotePort = 6969;

        _receiver = gameObject.AddComponent<OSCReceiver>();

        // Set local port.
        _receiver.LocalPort = 7204;

        // Bind "MessageReceived" method to special address.
        _receiver.Bind("/init", Init);

        _receiver.Bind("/player/*", PlayerRecieved);

        ip.text = "Local IP: " + GetLocalIPv4();
    }

    void Init(OSCMessage message)
    {
        _transmitter.RemoteHost = message.Values[0].StringValue;
        _transmitter.RemotePort = 6969;

        ips.Add(message.Values[0].StringValue);
        ports.Add(6960 + phones.Count);
        phones.Add("/player/" + message.Values[1].StringValue);

        var newMessage = new OSCMessage("/init");
        newMessage.AddValue(OSCValue.String(message.Values[1].StringValue));
        newMessage.AddValue(OSCValue.Int(phones.Count));
        _transmitter.Send(newMessage);

        Debug.Log(message.Values[0].StringValue);
        Debug.Log(phones.Count);
    }
    
    public string GetLocalIPv4()
    {
        return Dns.GetHostEntry(Dns.GetHostName())
            .AddressList.First(
                f => f.AddressFamily == System.Net.Sockets.AddressFamily.InterNetwork)
            .ToString();
    }

    void PlayerRecieved(OSCMessage message)
    {
        //Debug.Log(message);
        string text = "Players\n\n";
        foreach (string pname in phones)
        {
            text += "- " + pname + "\n";
        }

        _players.text = text;
        //if (message.Address.Contains("accel")) handleAccel(message);
        if (message.Address.Contains("quat")) handleQuat(message);
    }

    void handleAccel(OSCMessage message)
    {
        foreach (string p in phones)
        {
            if (message.Address.Contains(p))
            {
                Debug.Log(p + " sent " + message);
            }
        }
    }

    void handleQuat(OSCMessage message)
    {
        foreach (string p in phones)
        {
            if (message.Address.Contains(p))
            {
                Debug.Log(p + " sent " + message);
            }
        }
    }
}