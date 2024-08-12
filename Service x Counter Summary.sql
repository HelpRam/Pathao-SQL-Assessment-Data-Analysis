SELECT 
    s.id AS service_id,
    q.letter,  -- the letter column is in the queues table
    c.id AS counter_id,
    SUM(CASE WHEN q.id IS NOT NULL THEN 1 ELSE 0 END) AS visitor,
    SUM(CASE WHEN cs.name = 'queues' THEN 1 ELSE 0 END) AS queued,
    SUM(CASE WHEN q.called = 1 THEN 1 ELSE 0 END) AS called,
    SUM(CASE WHEN cs.name = 'serving' THEN 1 ELSE 0 END) AS serving,
    SUM(CASE WHEN cs.name = 'served' THEN 1 ELSE 0 END) AS served,
    SUM(CASE 
        WHEN cs.name IS NULL 
             OR (cs.name NOT IN ('serving', 'served') AND DATE(cl.created_at) = '2024-02-14') 
        THEN 1 ELSE 0 
    END) AS no_show
FROM 
    services s
LEFT JOIN 
    calls cl ON s.id = cl.service_id
LEFT JOIN 
    counters c ON cl.counter_id = c.id
LEFT JOIN 
    call_statuses cs ON cl.call_status_id = cs.id
LEFT JOIN 
    queues q ON cl.queue_id = q.id
WHERE 
    DATE(cl.created_at) = '2024-02-14'
GROUP BY 
    s.id, c.id, q.letter
ORDER BY 
    s.id, c.id;
