using System;
using System.Collections;
using System.Collections.Generic;
using extOSC;
using UnityEngine;
using Random = UnityEngine.Random;

public class WaterPlayer : MonoBehaviour
{
    private OSCReceiver _receiver;
    private Rigidbody _rigidbody;
    private int ID;
    private bool jump = false;

    private bool isBot;
    public ScoreMaster _master;
    private float CPUInput = 0f;
    private float timeCheck;
    private Vector3 targetPos;

    private SpriteRenderer _rend;

    public bool ready = false;
    private bool grounded;
    private bool cpuGrounded = false;
    public bool dead;
    [SerializeField] private float jumpHeight;
    [SerializeField] private float gravity = 9.81f;
    [SerializeField] private float pushBack = 5f;
    [SerializeField] private Sprite[] sheet;
    [SerializeField] private GameObject shadowCube;

    private bool hitWater;

    private float timeBeforeWalk;
    // Start is called before the first frame update
    void Start()
    {
        _master = GameObject.FindWithTag("Score")?.GetComponent<ScoreMaster>();
        _rigidbody = GetComponent<Rigidbody>();
        _rend = GetComponent<SpriteRenderer>();
        
        _receiver = gameObject.AddComponent<OSCReceiver>();
        _receiver.LocalPort = 7204;
        _receiver.Bind("/player/*/water", MessageRecieved);

        for (int i = 0; i < 5; i++)
        {
            if (gameObject.name.Contains(i.ToString())) ID = i;
        }
        CPU();
    }

    void MessageRecieved(OSCMessage message)
    {
        print(message);
        if (message.Values[0].IntValue == ID)
        {
            if (new Vector3(message.Values[1].FloatValue, message.Values[2].FloatValue, message.Values[3].FloatValue)
                .magnitude > 1.5f && grounded)
            {
                jump = true;
                grounded = false;
            }
        }
    }

    public int GetID()
    {
        return ID;
    }

    private void FixedUpdate()
    {
        if (dead) return;
        if (_master != null) if (!_master.isReady()) return;
        _rigidbody.velocity =
            new Vector3(_rigidbody.velocity.x * 0.9f, _rigidbody.velocity.y, _rigidbody.velocity.z * 0.9f);
        float v = _rigidbody.velocity.y;
        if (Mathf.Abs(v) > 7)
        {
            if (v > 0 && v < 10) _rend.sprite = sheet[2];
            else if (v < -12) _rend.sprite = sheet[4];
            shadowCube.SetActive(false);
        }
        else if (!grounded)
        {
            _rend.sprite = sheet[3];
        }
        else
        {
            _rend.sprite = sheet[0];
            shadowCube.SetActive(true);
        }
        _rigidbody.AddForce(Vector3.down * gravity, ForceMode.Acceleration);
        if (jump)
        {
            _rigidbody.AddForce(Vector3.up * jumpHeight, ForceMode.Impulse);
            jump = false;
            grounded = false;
            _rend.sprite = sheet[1];
        }
    }

    private void Update()
    {
        //CPU();
        if (timeCheck > -1) timeCheck += Time.deltaTime;
        if (Input.GetKeyDown(KeyCode.W) && ID == 1 && grounded)
        {
            jump = true;
            grounded = false;
        }
        if (timeCheck > timeBeforeWalk)
        {
            jump = true;
            timeCheck = -1;
        }
        if (transform.position.z < -85 && !dead)
        {
            dead = true;
            GetComponent<SpriteRenderer>().color = Color.gray;
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.CompareTag("Water") && !hitWater)
        {
            _rigidbody.AddForce(Vector3.back * pushBack, ForceMode.Impulse);
            GetComponent<AudioSource>().Play();
            hitWater = true;
        }

        if (other.gameObject.CompareTag("CPU") && isBot && cpuGrounded)
        {
            cpuGrounded = false;
            timeCheck = 0;
            timeBeforeWalk = Random.value;
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.gameObject.CompareTag("Water"))
        {
            hitWater = false;
        }
    }

    void CPU()
    {
        if (_master != null)
        {
            if (_master.GetPlayerCount() < 4)
            {
                if (ID > _master.GetPlayerCount())
                {
                    isBot = true;
                }
            }
        }
        else
        {
            if (ID > 1)
            {
                isBot = true;
            }
        }
    }

    private void OnCollisionEnter(Collision other)
    {
        if (other.gameObject.CompareTag("Ground"))
        {
            grounded = true;
            cpuGrounded = true;
        }
    }
}