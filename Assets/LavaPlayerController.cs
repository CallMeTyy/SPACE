using System;
using System.Collections;
using System.Collections.Generic;
using extOSC;
using UnityEngine;
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

    public bool ready = false;

    private float timeBeforeWalk;
    // Start is called before the first frame update
    void Start()
    {
        _master = GameObject.FindWithTag("Score")?.GetComponent<ScoreMaster>();
        _animator = GetComponent<Animator>();
        _rigidbody = GetComponent<Rigidbody>();
        _rend = GetComponent<SpriteRenderer>();
        
        _receiver = gameObject.AddComponent<OSCReceiver>();
        _receiver.LocalPort = 7204;
        _receiver.Bind("/player/*/gyro", MessageRecieved);

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
            ready = true;
            horizontalValue = msg.Values[2].FloatValue;
            verticalValue = msg.Values[1].FloatValue;
        }
    }

    public int GetID()
    {
        return ID;
    }

    private void FixedUpdate()
    {
        if (_master != null) if (!_master.isReady()) return;
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
        if (Mathf.Abs(horizontalValue) > 0.2f)
        {
            _rigidbody.AddForce(Vector3.right * speed * Mathf.Sign(horizontalValue), ForceMode.VelocityChange);

        }
        if (Mathf.Abs(verticalValue) > 0.2f)
        {
            _rigidbody.AddForce(Vector3.back * speed * Mathf.Sign(verticalValue), ForceMode.VelocityChange);
        }
    }

    private void Update()
    {
        CPU();
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.CompareTag("Lava")) gameObject.SetActive(false);
    }

    void CPU()
    {
        if (_master != null)
        {
            if (_master.GetPlayerCount() < 4)
            {
                if (ID > _master.GetPlayerCount())
                {
                    ready = true;
                    isBot = true;
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
                ready = true;
                isBot = true;
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
