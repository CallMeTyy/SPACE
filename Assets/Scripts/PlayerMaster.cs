using System.Collections;
using System.Collections.Generic;
using System.Timers;
using UnityEngine;

public class PlayerMaster : MonoBehaviour
{
    private OscMaster _master;
    [SerializeField] private Transform[] _players;
    [SerializeField] float[] targetX = new float[4];
    [SerializeField] float[] targetY = new float[4];
    [SerializeField] float[] deftargetY = new float[4];
    private float changeTime;

    // Start is called before the first frame update
    void Start()
    {
        _master = GameObject.FindWithTag("Master")?.GetComponent<OscMaster>();
        for (int i = 0; i < 4; i++)
        {
            targetX[i] = _players[i].position.x + _master.GetScores()[i] / 28f * 7f;
            //targetY[i] = _players[i].position.y;
            //deftargetY[i] = _players[i].position.y;
            //print(targetX[i]);
        }
    }

    // Update is called once per frame
    void Update()
    {
        changeTime += Time.deltaTime;
        for(int i = 0; i < 4; i++)
        {
            Vector3 pos = _players[i].position;
            if (changeTime > 0.5f)
            {
                changeTime = 0;
                targetY[i] = deftargetY[i] + Random.Range(-0.1f, 0.1f);
            }
            pos.x = targetX[i];
            //pos.y = targetY[i];
            _players[i].position = _players[i].position * 0.98f + 0.02f * pos;
        }
    }
}
