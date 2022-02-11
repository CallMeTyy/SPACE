using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using UnityEngine;
using extOSC;
using TMPro;
using UnityEngine.Rendering.VirtualTexturing;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class OscMaster : MonoBehaviour
{
    private OSCTransmitter _transmitter;
    private OSCReceiver _receiver;
    private List<string> ips;
    private List<string> phones;
    private List<int> ports;

    public int GetSceneIndex = 0;

    [SerializeField] private Text _players;
    [SerializeField] private Text ip;
    
    void Start()
    {
        DontDestroyOnLoad(gameObject);
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
        
        SceneManager.activeSceneChanged += SceneManagerOnactiveSceneChanged;
    }

    private void SceneManagerOnactiveSceneChanged(Scene arg0, Scene arg1)
    {
        print("Scene Changed to: " + arg1.name);
        if (SceneManager.GetActiveScene().name != "Hub") _receiver.LocalPort = 7205;
        for (int i = 0; i < ips.Count; i++)
        {
            OSCMessage message = new OSCMessage("/scene");
            message.AddValue(OSCValue.String(arg1.name));
            _transmitter.RemoteHost = ips[i];
            _transmitter.RemotePort = ports[i];
            print(message);
            _transmitter.Send(message);
        }
    }


    void Init(OSCMessage message)
    {
        _transmitter.RemoteHost = message.Values[0].StringValue;
        _transmitter.RemotePort = 6969;
        if (!phones.Contains("/player/" + message.Values[1].StringValue))
        {
            ips.Add(message.Values[0].StringValue);
            ports.Add(6961 + phones.Count);
            phones.Add("/player/" + message.Values[1].StringValue);
        }

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
        if (message.Address.Contains("disc"))
        {
            for(int i = 0; i < phones.Count; i++)
            {
                if (phones[i] == message.Values[0].StringValue)
                {
                    phones.RemoveAt(i);
                    ips.RemoveAt(i);
                    ports.RemoveAt(i);
                }
            }
        }
        string text = "Players\n\n";
        foreach (string pname in phones)
        {
            text += "- " + pname + "\n";
        }

        _players.text = text;
    }
}