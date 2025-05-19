#!/bin/sh
sleep 30
uci show passwall | grep '=nodes' | cut -d'.' -f2 | awk -F'=' '{print $1}' | while read node_id; do
    remark=$(uci get passwall.$node_id.remarks 2>/dev/null | sed 's/-[0-9]\+ms$//;s/-error$//')
    result=""
    (
        # 让 test.sh 作为新进程组 leader
        exec /usr/share/passwall/test.sh url_test_node $node_id urltest_node 2>/dev/null
    ) > /tmp/pw_test_${node_id}.txt 2>&1 &
    test_pid=$!
    # 通过 /proc 获取 PGID
    if [ -f /proc/$test_pid/status ]; then
        pgid=$(awk '/^Pgid:/ {print $2}' /proc/$test_pid/status)
    else
        pgid=$test_pid
    fi
    (
        sleep 5
        kill -TERM -$pgid 2>/dev/null
    ) &
    killer_pid=$!
    wait $test_pid 2>/dev/null
    kill $killer_pid 2>/dev/null

    result=$(cat /tmp/pw_test_${node_id}.txt 2>/dev/null | awk -F ':' '{print $2}' | tr -d '\r\n')
    rm -f /tmp/pw_test_${node_id}.txt

    ms=$(echo $result | awk '{printf "%d", $1 * 1000}')
    if [ -n "$result" ] && [ "$ms" -gt 0 ]; then
        new_remark="${remark}-${ms}ms"
        uci set passwall.$node_id.remarks="$new_remark"
        echo "Node: $remark ($node_id) - Test result: ${ms}ms"
    else
        uci set passwall.$node_id.remarks="${remark}-error"
        echo "Node: $remark ($node_id) - Test timeout or failed"
    fi
done
rm -f /tmp/pw_test_*.txt
uci commit passwall