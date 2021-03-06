using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class IdleWalk : MonoBehaviour
{
    private float targetX;
    private float timer;
    private float scale;
    private Animator _animator;
    private OscMaster _master;
    private SpriteRenderer _renderer;
    private TextMeshProUGUI _playerName;
    private int ID;
    bool hasPlayed;
    AudioSource source;
    
    // Start is called before the first frame update
    void Start()
    {
        ID = int.Parse(gameObject.name);
        _renderer = GetComponent<SpriteRenderer>();
        _renderer.enabled = false;
        targetX = Random.Range(-5, 3);
        scale = transform.localScale.x;
        _animator = GetComponent<Animator>();
        _master = GameObject.FindWithTag("Master").GetComponent<OscMaster>();
        _playerName = GetComponentInChildren<TextMeshProUGUI>();
        source = GetComponent<AudioSource>();
    }

    // Update is called once per frame
    void Update()
    {
        if (_master.GetPlayerCount() >= ID)
        {
            _renderer.enabled = true;           
            if (!hasPlayed) source.Play();
            hasPlayed = true;
        }
        else return;
        
        if (Mathf.Abs(transform.position.x - targetX) > 0.1f && targetX != 10)
        {
            _animator.SetBool("walking", true);
            float dir;
            if (targetX > transform.position.x) dir = 1;
            else{ dir = -1;}
            transform.Translate( dir * Time.deltaTime, 0, 0);
            transform.localScale = new Vector3(scale * dir, scale, 1);
            _playerName.rectTransform.localScale = new Vector3(dir, 1, 1);
        }
            
        else if (targetX != 10)
        {
            _animator.SetBool("walking", false);
            targetX = 10;
            timer = Random.Range(2.0f, 7.0f);
        }
        else if (timer > 0) timer -= Time.deltaTime;
        else targetX = Random.Range(-1.5f, 3.0f);
    }
}
