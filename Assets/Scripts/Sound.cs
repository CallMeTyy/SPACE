using UnityEngine.Audio;
using UnityEngine;

[System.Serializable]
public class Sound
{
    public string name;
    public AudioClip clip;
    public AudioMixerGroup outputAudioMixerGroup;

    [Range(0f, 1f)]
    public float volume;
    [Range(0.1f, 3f)]
    public float pitch;
    [Range(-1f,1f)]
    public float panning;

    public bool loop;
    [HideInInspector]
    public AudioSource source;
}
