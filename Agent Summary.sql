SELECT 
    u.name,  -- Assuming there is a name column in the users table
    q.letter,
    SUM(CASE WHEN q.id IS NOT NULL THEN 1 ELSE 0 END) AS visitor,
    SUM(CASE WHEN q.called = 0 THEN 1 ELSE 0 END) AS queued,
    SUM(CASE WHEN q.called = 1 THEN 1 ELSE 0 END) AS called,
    SUM(CASE WHEN cs.name = 'serving' THEN 1 ELSE 0 END) AS serving,
    SUM(CASE WHEN cs.name = 'served' THEN 1 ELSE 0 END) AS served
FROM 
    users u
LEFT JOIN 
    calls cl ON u.id = cl.user_id
LEFT JOIN 
    queues q ON cl.queue_id = q.id
LEFT JOIN 
    call_statuses cs ON cl.call_status_id = cs.id
WHERE 
    DATE(cl.created_at) = '2024-02-14'  -- Replace with the desired date
GROUP BY 
    u.name, q.letter  -- Group by user name and letter
ORDER BY 
    u.name;  -- Order by user name
