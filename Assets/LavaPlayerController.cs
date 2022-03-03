using System;
using System.Collections;
using System.Collections.Generic;
using extOSC;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.UI;
using Random = UnityEngine.Random;

public class LavaPlayerController : MonoBehaviour
{
    private OSCReceiver _receiver;
    private Animator _animator;
    public float speed = 0.5f;
    private Rigidbody _rigidbody;
    private int ID;
    private float horizontalValue;
    private float verticalValue;

    private bool isBot;
    public ScoreMaster _master;
    private float CPUInput = 0f;
    private float timeCheck;
    private Vector3 targetPos;
    

    private SpriteRenderer _rend;
    [SerializeField] private Text okText;
    [SerializeField] private GameObject canvas;
    [SerializeField] private GameObject head;
    [SerializeField] AudioSource[] _clip;

    Quaternion initRot;


    public bool ready = false;
    bool hahaha;
    private bool lesgo;
    float viezeTimer;
    float prevX;
    float prevV;

    private float timeBeforeWalk;
    public float timeOfDeath;
    // Start is called before the first frame update
    void Start()
    {
        _master = GameObject.FindWithTag("Score")?.GetComponent<ScoreMaster>();
        _animator = GetComponent<Animator>();
        _rigidbody = GetComponent<Rigidbody>();
        _rend = GetComponent<SpriteRenderer>();
        _rend.enabled = false;
        foreach (Transform child in transform)
        {
            child.gameObject.SetActive(false);
        }
        _receiver = gameObject.AddComponent<OSCReceiver>();
        _receiver.LocalPort = 7204;
        _receiver.Bind("/player/*/gyro", MessageRecieved);
        canvas.SetActive(true);
        targetPos = transform.position;

        for (int i = 0; i < 5; i++)
        {
            if (gameObject.name.Contains(i.ToString())) ID = i;
        }

        ready = false;
        timeBeforeWalk = Random.Range(3f, 5f);
    }

    void MessageRecieved(OSCMessage msg)
    {
        if (msg.Values[0].IntValue == ID)
        {
            if (!ready && !hahaha)
            {
                okText.text = "OK";
                ready = true;
                hahaha = true;
                initRot = new Quaternion(msg.Values[1].FloatValue, msg.Values[2].FloatValue, msg.Values[3].FloatValue, msg.Values[4].FloatValue);
            }
            
            Vector3 rot = new Quaternion(msg.Values[1].FloatValue, msg.Values[2].FloatValue, msg.Values[3].FloatValue, msg.Values[4].FloatValue).eulerAngles;
            Quaternion lerot = Quaternion.Inverse(initRot) * new Quaternion(msg.Values[1].FloatValue, msg.Values[2].FloatValue, msg.Values[3].FloatValue, msg.Values[4].FloatValue);
            horizontalValue = lerot.y;
            verticalValue = lerot.x;
            viezeTimer = 0.2f;
        }
    }

    public int GetID()
    {
        return ID;
    }

    private void FixedUpdate()
    {
        
        if (_master != null)
        {
            if (!_master.isReady()) return;
            else if (!lesgo)
            {
                foreach (Transform child in transform)
                {
                    child.gameObject.SetActive(false);
                }

                canvas.SetActive(false);
                _rend.enabled = true;
                lesgo = true;
            }
        }
        if (!_master.countReady) return;
        _rigidbody.velocity =
            new Vector3(_rigidbody.velocity.x * 0.9f, _rigidbody.velocity.y, _rigidbody.velocity.z * 0.9f);
        if (new Vector2(_rigidbody.velocity.x, _rigidbody.velocity.z).magnitude > 0.1f) _animator.SetBool("walking", true);
        else  _animator.SetBool("walking", false);
        if (Mathf.Sign(_rigidbody.velocity.x) == -1) _rend.flipX = true;
        else _rend.flipX = false;
        if (isBot && Vector3.Distance(targetPos, transform.position) > 0.5f)
        {
            _rigidbody.AddForce(new Vector3(targetPos.x - transform.position.x, 0,
                targetPos.z - transform.position.z).normalized * speed, ForceMode.VelocityChange);
            return;
        }
        if (Mathf.Abs(horizontalValue) > 0.1f)
        {
            _rigidbody.AddForce(Vector3.right * speed * -Mathf.Sign(horizontalValue), ForceMode.VelocityChange);

        }
        if (Mathf.Abs(verticalValue) > 0.1f)
        {
            _rigidbody.AddForce(Vector3.back * speed * -Mathf.Sign(verticalValue), ForceMode.VelocityChange);
        }
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.Space)) ready = true;
        CPU();
        viezeTimer -= Time.deltaTime;
        if (viezeTimer < 0)
        {
            horizontalValue = 0;
            verticalValue = 0;
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.CompareTag("Lava"))
        {
            _clip[ID-1].Play();
            head.SetActive(true);
            timeOfDeath = Time.time;
            gameObject.SetActive(false);
            
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
                    if (!ready)
                    {
                        okText.text = "OK";
                        ready = true;
                        isBot = true;
                    }
                    timeCheck += Time.deltaTime;
                    if (timeCheck > timeBeforeWalk)
                    {
                        timeBeforeWalk = Random.Range(3f, 5f);
                        timeCheck = 0;
                        targetPos = new Vector3(Random.Range(-6f, 6f), transform.position.y, Random.Range(-6f, 6f));
                    }
                }
            }
        }
        else
        {
            if (ID > 1)
            {
                if (!ready)
                {
                    okText.text = "OK";
                    ready = true;
                    isBot = true;
                }
                timeCheck += Time.deltaTime;
                if (timeCheck > timeBeforeWalk)
                {
                    timeBeforeWalk = Random.Range(3f, 5f);
                    timeCheck = 0;
                    targetPos = new Vector3(Random.Range(-6f, 6f), transform.position.y, Random.Range(-6f, 6f));
                }
            }
        }
    }
}
