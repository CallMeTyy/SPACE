using UnityEngine.Audio;
using UnityEngine;
using System;
using UnityEngine.SceneManagement;

public class AudioManager : MonoBehaviour
{

    public Sound[] sounds;
    private AudioSource[] allAudioSources;
    public static AudioManager instance;

    public float playTime;
    void Awake()
    {
        if (instance == null)
        {
            instance = this;
        }
        else
        {
            Destroy(gameObject);
            return;
        }
        DontDestroyOnLoad(gameObject);
        foreach (Sound s in sounds)
        {
            s.source = gameObject.AddComponent<AudioSource>();
            s.source.clip = s.clip;

            s.source.volume = s.volume;
            
            s.source.pitch = s.pitch;
            s.source.loop = s.loop;
            s.source.panStereo = s.panning;
            s.source.outputAudioMixerGroup = s.outputAudioMixerGroup;
        }
        SceneManager.activeSceneChanged += SceneManagerOnactiveSceneChanged;
    }
    private void SceneManagerOnactiveSceneChanged(Scene arg0, Scene arg1)
    {
        switch (arg1.name)
        {
            case "Hub":
                stopSound();
                Play("Lobby");
                Play("Engine");
                break;
            case "SpaceHub":
                stopSound();
                GetComponents<AudioSource>()[7].time = playTime;
                Play("SpaceHub");
            break;
            case "Fire":
                stopSound();
                Play("Fire");
                Play("FireSC");
                break;
            case "Lazer":
                stopSound();
                Play("LaserBattle");
                break;
            case "MiniValve":
                stopSound();
                Play("Valve");
                break;
            case "Win":
                stopSound();
                Play("Lobby");
                break;
            case "Volcano":
                stopSound();
                Play("LavaTheme");
                Play("Lava");
                break;
            case "WaterPlanet":
                stopSound();
                Play("WaterPlanetSC");
                Play("WaterPlanet");
                break;
            case "Window":
                stopSound();
                Play("Window");
                break;

        }
    }

    public void Play(string name)
    {
        Sound s = Array.Find(sounds, sound => sound.name == name);
        if (s == null) 
        {
            Debug.LogWarning("Sound: " + name + "not found");
            return;
        }
        s.source.Play();
    }

    public void StopPlaying(string sound)
    {
        Sound s = Array.Find(sounds, item => item.name == sound);
        if (s == null)
        {
            return;
        }
        s.source.Stop();
    }
    
    void stopSound()
    {
        allAudioSources = FindObjectsOfType(typeof(AudioSource)) as AudioSource[];
        foreach (AudioSource audioS in allAudioSources)
        {
            audioS.Stop();
        }
    }
}
    
