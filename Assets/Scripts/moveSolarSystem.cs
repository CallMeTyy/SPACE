using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class moveSolarSystem : MonoBehaviour
{
    public float speed;
    [SerializeField] private bool useX;
    [SerializeField] private bool useY;
    [SerializeField] private bool useZ;
    public List<TrailRenderer> _rend;
    float timer;
    int solarCount = 8;
    OscMaster _master;

    public int ID;
    bool yeet;
    bool init;

    // Start is called before the first frame update
    void Start()
    {
        _rend = new List<TrailRenderer>();
        foreach(Transform t in transform)
        {
            TrailRenderer r = t.gameObject.GetComponentInChildren<TrailRenderer>();
            if (r != null)
            {
                _rend.Add(r);
                r.enabled = false;
            }
        }
        for (int i = 0; i < solarCount + 1; i++)
        {
            if (gameObject.name.Contains(i.ToString())) ID = i;
        }
        _master = GameObject.FindWithTag("Master")?.GetComponent<OscMaster>();
        if (_master != null)
        {
            if (_master.starX.Count == 0)
                for (int i = 0; i < solarCount; i++)
                    _master.starX.Add(0);
            if (_master.starX[0] != 0)
            {
                transform.position = new Vector3(_master.starX[ID - 1], transform.position.y, transform.position.z);
                
            }
        }
        
        
    }

    // Update is called once per frame
    void Update()
    {
        timer += Time.deltaTime;
        if (timer > 0.2f && !yeet)
        {
            foreach (TrailRenderer r in _rend)
            {
                r.enabled = true;
            }
            yeet = true;
        }
        if (useX)
        transform.position = new Vector3((speed * Time.deltaTime) + transform.position.x, transform.position.y,transform.position.z);

        if (useY)
            transform.position = new Vector3(transform.position.x, (speed * Time.deltaTime) + transform.position.y, transform.position.z);

        if (useZ)
            transform.position = new Vector3(transform.position.x, transform.position.y, (speed * Time.deltaTime) + transform.position.z);

        if (_master != null)
        {
            _master.starX[ID-1] = transform.position.x;
        }
    }
}
