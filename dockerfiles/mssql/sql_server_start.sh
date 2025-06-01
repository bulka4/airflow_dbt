#!/bin/bash 

# start the MS SQL server
/opt/mssql/bin/sqlservr &

# wait for the MS SQL server to be ready
until sqlcmd -S localhost -U sa -P $SA_PASSWORD -Q 'SELECT 1' > /dev/null 2>&1
    do
        echo 'Waiting for SQL Server to start...'
        sleep 5
    done

echo 'SQL Server is ready!'


# execute the init.sql script to set up databases, schemas and tables
sqlcmd -S localhost -U sa -P $SA_PASSWORD -i /usr/config/init.sql

# we need to use 'wait' so the container doesn't shut down but it runs all the time.
wait