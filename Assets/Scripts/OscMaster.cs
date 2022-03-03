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
    public List<string> ips;
    public List<string> phones;
    public List<string> names;
    private List<int> ports;
    public List<int> scores;

    public List<float> starX;
    public int GetSceneIndex = 0;

    [SerializeField] private Text _players;
    [SerializeField] private TextMeshProUGUI ip;
    [SerializeField] private TextMeshProUGUI[] playernames;
    
    void Start()
    {
        DontDestroyOnLoad(gameObject);
        phones = new List<string>();
        ips = new List<string>();
        ports = new List<int>();
        starX = new List<float>();
        //scores = new List<int>(4);
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
        
        _receiver.Bind("/name", Name);

        _receiver.Bind("/player/*", PlayerRecieved);

        if (ip != null) ip.text = "IP: " + GetLocalIPv4();
        
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
            print(_transmitter.RemoteHost);
            _transmitter.Send(message);
        }
    }

    public string[] GetNames()
    {
        return names.ToArray();
    }

    public int GetPlayerCount()
    {
        return ips.Count;
    }

    public void AddScore(int firstP, int secondP, int thirdP, int fourthP)
    {
        for (int i = 0; i < scores.Count; i++)
        {
            if (i == firstP - 1) scores[i] += 5;
            else if (i == secondP - 1) scores[i] += 3;
            else if (i == thirdP - 1) scores[i] += 1;
        }
        //scores.Sort((a,b)=>a.CompareTo(b));
    }

    public void AddScore(int Won1, int Won2)
    {
        for (int i = 0; i < scores.Count; i++)
        {
            if (i == Won1 - 1) scores[i] += 3;
            else if (i == Won2 - 1) scores[i] += 3;
        }
    }

    public List<int> GetScores()
    {
        return scores;
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
    
    void Name(OSCMessage message)
    {
        print(message);
        names[message.Values[0].IntValue - 1] = message.Values[1].StringValue;
        playernames[message.Values[0].IntValue - 1].text = message.Values[1].StringValue;
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