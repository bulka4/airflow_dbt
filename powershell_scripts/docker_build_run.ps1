docker build -t mssql .
docker run -d -p 1433:1433 --name mssql mssql