using System;
using System.Collections;
using System.Collections.Generic;
using System.Threading;
using UnityEngine;
using extOSC;
using UnityEngine.SceneManagement;

public class MovementSystem : MonoBehaviour
{
    private Quaternion currentRotation;
    private OSCReceiver _receiver;

    public float verticalInputAcceleration = 1;
    public float horizontalInputAcceleration = 20;

    public float maxSpeed = 10;
    public float maxRotationSpeed = 100;

    public float velocityDrag = 1;
    public float rotationDrag = 1;

    private Vector3 velocity;
    private float zRotationVelocity;

    private bool hasShakenPlayer1;
    private bool hasShakenPlayer2;
    [SerializeField] private GameObject bullet;
    private float shotTimer;

    private float timer = 10;
    // Start is called before the first frame update
    void Start()
    {
        // Creating a receiver.
        _receiver = gameObject.AddComponent<OSCReceiver>();

        // Set local port.
        _receiver.LocalPort = 7204;

        // Bind "MessageReceived" method to special address.
        _receiver.Bind("/player/*/space1", MessageReceived1);
        _receiver.Bind("/player/*/space2", MessageReceived2);
        _receiver.Bind("/player/*/spaceshake", ShakeReceived);
    }

    private void Update()
    {
        if (timer > 0) timer -= Time.deltaTime;
        else SceneManager.LoadScene("SpaceHub");
    }


    protected void MessageReceived1(OSCMessage message)
    {
        if (message.Values[0].IntValue == 1)
        {
            currentRotation = new Quaternion(message.Values[1].FloatValue, message.Values[2].FloatValue, 
                message.Values[3].FloatValue, message.Values[4].FloatValue);
            
            if (Mathf.Abs(currentRotation.x) > 0.2f)
            {
                zRotationVelocity -= Mathf.Sign(currentRotation.x) * horizontalInputAcceleration;
            }
        }

        //print(currentRotation);
    }
    protected void MessageReceived2(OSCMessage message)
    {
        Debug.Log(message);
        if (message.Values[0].IntValue == 2)
        {
            Vector3 acceleration = message.Values[1].FloatValue * verticalInputAcceleration * transform.forward;
            velocity += acceleration * Time.deltaTime;
        }
    }
    protected void ShakeReceived(OSCMessage message)
    {

        if (message.Values[0].IntValue == 1)
        {
            Vector3 shakeStrengthP1 = new Vector3(message.Values[1].FloatValue, message.Values[2].FloatValue, message.Values[3].FloatValue);
            //print(shakeStrengthP1.magnitude);
            if (shakeStrengthP1.magnitude > 2)
                StartCoroutine(ShakePlayer1());
         
        }
        if (message.Values[0].IntValue == 2)
        {
          
            Vector3 shakeStrengthP2 = new Vector3(message.Values[1].FloatValue, message.Values[2].FloatValue, message.Values[3].FloatValue);
            //print(shakeStrengthP2.magnitude);
            if (shakeStrengthP2.magnitude > 2)
                StartCoroutine(ShakePlayer2());
        }
    }
    IEnumerator ShakePlayer1()
    {
        if (hasShakenPlayer1 == false)
        {
            hasShakenPlayer1 = true;
            yield return new WaitForSeconds(0.3f);
            hasShakenPlayer1 = false;
        }
    }
    IEnumerator ShakePlayer2()
    {
        if (hasShakenPlayer2 == false)
        {
            hasShakenPlayer2 = true;
            yield return new WaitForSeconds(0.3f);
            hasShakenPlayer2 = false;
        }
    }

    private void FixedUpdate()
    {
        shotTimer =shotTimer + Time.deltaTime;
        //print(shotTimer);
        if (hasShakenPlayer1 == true && hasShakenPlayer2 == true)
        {
            if (shotTimer > 1f) {
                print("shoot!");
                GameObject newBullet = Instantiate(bullet, transform.position, Quaternion.identity);
                newBullet.GetComponent<bullet>().player = transform;
                shotTimer = 0;
            }
        }
        // apply velocity drag
        velocity = velocity * (1 - Time.deltaTime * velocityDrag);

        // clamp to maxSpeed
        velocity = Vector3.ClampMagnitude(velocity, maxSpeed);

        // apply rotation drag
        zRotationVelocity = zRotationVelocity * (1 - Time.deltaTime * rotationDrag);

        // clamp to maxRotationSpeed
        zRotationVelocity = Mathf.Clamp(zRotationVelocity, -maxRotationSpeed, maxRotationSpeed);

        // update transform
        transform.position += velocity * Time.deltaTime;
        transform.Rotate(0, zRotationVelocity * Time.deltaTime, 0);
        //print(zRotationVelocity);
    }
}
