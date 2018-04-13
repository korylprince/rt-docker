#!/bin/bash

# wait for db
while ! mysqladmin ping -h "$RT_DB_HOST" -P "$RT_DB_PORT" -u "$RT_DB_USER" -p="$RT_DB_PASS" --silent; do
    echo "database not ready yet. Waiting..."
    sleep 1
done

# run indexer
exec /run-every "$RT_INDEX_INTERVAL" rt-fulltext-indexer
