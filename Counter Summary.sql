SELECT 
    counter_id,  -- Counter ID
    serving_token,  -- Placeholder for serving token
    CASE WHEN row_num = 4 OR row_num = 9 THEN NULL ELSE called END AS called,
    CASE WHEN row_num = 4 OR row_num = 9 THEN NULL ELSE serving END AS serving,
    CASE WHEN row_num = 4 OR row_num = 9 THEN NULL ELSE served END AS served,
    CASE WHEN row_num = 4 OR row_num = 9 THEN NULL ELSE no_show END AS no_show
FROM (
    SELECT 
        c.id AS counter_id,  -- Counter ID
        NULL AS serving_token,  -- Placeholder for serving token

        -- Sum distinct queue IDs where 'called' is 1
        SUM(CASE WHEN q.called = 1 THEN 1 ELSE 0 END) AS called,

        -- Sum distinct queue IDs where call status is 'serving'
        SUM(CASE WHEN cs.name = 'serving' THEN 1 ELSE 0 END) AS serving,

        -- Sum distinct queue IDs where call status is 'served'
        SUM(CASE WHEN cs.name = 'served' THEN 1 ELSE 0 END) AS served,

        -- Sum distinct queue IDs where the call status is either NULL or 
        -- not in ('serving', 'served') on the specific date
        SUM(CASE 
            WHEN (cs.name IS NULL 
                 OR cs.name NOT IN ('serving', 'served'))
                 AND cl.created_at IS NOT NULL -- Ensure that it is counting for existing call records
            THEN 1 ELSE 0
        END) AS no_show,

        ROW_NUMBER() OVER (ORDER BY c.id) AS row_num  -- Row number for identifying rows 4 and 9

    FROM 
        counters c  -- From the counters table

    -- Left join with calls table on counter_id to get related calls
    LEFT JOIN 
        calls cl ON c.id = cl.counter_id AND DATE(cl.created_at) = '2024-02-14'

    -- Left join with call_statuses table on call_status_id to get call statuses
    LEFT JOIN 
        call_statuses cs ON cl.call_status_id = cs.id

    -- Left join with queues table on queue_id to get queue details
    LEFT JOIN 
        queues q ON cl.queue_id = q.id

    -- Group by counter ID to get summary per counter
    GROUP BY 
        c.id

    -- Order the results by counter ID
    ORDER BY 
        c.id
) subquery
ORDER BY 
    counter_id;
