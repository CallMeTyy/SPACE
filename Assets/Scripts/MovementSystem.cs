using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using extOSC;

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
    // Start is called before the first frame update
    void Start()
    {
        // Creating a receiver.
        _receiver = gameObject.AddComponent<OSCReceiver>();

        // Set local port.
        _receiver.LocalPort = 7001;

        // Bind "MessageReceived" method to special address.
        _receiver.Bind("/player1/quaternion", MessageReceived1);
        _receiver.Bind("/player2/touch0", MessageReceived2);
        _receiver.Bind("/player1/accel", ShakeReceived);
        _receiver.Bind("/player2/accel", ShakeReceived);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
    protected void MessageReceived1(OSCMessage message)
    {
        
        
        currentRotation = new Quaternion(0, -message.Values[2].FloatValue, 0, -message.Values[3].FloatValue);
        //currentRotation.eulerAngles = rotationAmount;
        print(currentRotation.eulerAngles.y);
        if ((currentRotation.eulerAngles.y < 80 && currentRotation.eulerAngles.y > 20 )|| (currentRotation.eulerAngles.y < 250 && currentRotation.eulerAngles.y > 190))
        {
            //rotationAmount = (rotationAmount - 250) * Time.deltaTime;
            //transform.Rotate(0, 0, rotationAmount);

            float zTurnAcceleration = -1 * -1 * horizontalInputAcceleration;
            zRotationVelocity += zTurnAcceleration * Time.deltaTime;
        }
        if ((currentRotation.eulerAngles.y > 100 && currentRotation.eulerAngles.y < 160) || (currentRotation.eulerAngles.y < 330 && currentRotation.eulerAngles.y > 270))
        {
            //rotationAmount = (rotationAmount + 250) * Time.deltaTime;
            //transform.Rotate(0, 0, rotationAmount);
            float zTurnAcceleration = -1 * 1 * horizontalInputAcceleration;
            zRotationVelocity += zTurnAcceleration * Time.deltaTime;
        }
    }
    protected void MessageReceived2(OSCMessage message)
    {
        //Debug.Log(message.Values[1].DoubleValue);
        Vector3 acceleration = (float)message.Values[1].DoubleValue * verticalInputAcceleration * transform.forward;
        velocity += acceleration * Time.deltaTime;
    }
    protected void ShakeReceived(OSCMessage message)
    {
        
        if (message.Address.Contains("player1"))
        {
            Vector3 shakeStrengthP1 = new Vector3(message.Values[0].FloatValue, message.Values[1].FloatValue, message.Values[2].FloatValue);
            //print(shakeStrengthP1.magnitude);
            if (shakeStrengthP1.magnitude > 2)
                StartCoroutine(ShakePlayer1());
         
        }
        if (message.Address.Contains("player2"))
        {
          
            Vector3 shakeStrengthP2 = new Vector3(message.Values[0].FloatValue, message.Values[1].FloatValue, message.Values[2].FloatValue);
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
