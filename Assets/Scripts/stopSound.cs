using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class stopSound : MonoBehaviour
{
    private AudioSource[] allAudioSources;
    void Awake()
    {
        allAudioSources = FindObjectsOfType(typeof(AudioSource)) as AudioSource[];
        foreach (AudioSource audioS in allAudioSources)
        {
            audioS.Stop();
        }
    }
}



