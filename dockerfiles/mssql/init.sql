create database source_systems;
create database dwh;
go

use dwh;
go
create schema fact;
go

use source_systems;
go
create schema system_1;
go
create schema system_2;
go

-- === Source system 1 data ===

-- fact table 1
create table system_1.purchase_orders(
    orderID int
    ,date date
    ,clientID int
);

insert into system_1.purchase_orders (orderID, date, clientID)
values
    (1, '2022-01-01', 1)
    ,(2, '2022-01-02', 1)
    ,(3, '2022-01-03', 2)
;

-- fact table 2
create table system_1.purchase_orders_details(
    orderDetailID int
    ,orderID int
    ,productID int
    ,quantity int
);

insert into system_1.purchase_orders_details (orderDetailID, orderID, productID, quantity)
values
    (1, 1, 1, 1)
    ,(2, 1, 2, 1)
    ,(3, 2, 2, 1)
    ,(4, 2, 3, 1)
    ,(5, 3, 3, 1)
;

-- dim table 1
create table system_1.products(
    productID int
    ,price int
    ,productName varchar(50)
    ,productCategory varchar(50)
);

insert into system_1.products (productID, price, productName, productCategory)
values
    (1, 5, 'trousers', 'clothes')
    ,(2, 100, 'laptop', 'electronics')
    ,(3, 1, 'bread', 'food')
;

-- dim table 2
create table system_1.clients(
    clientID int
    ,clientName varchar(50)
    ,clientCountry varchar(50)
);

insert into system_1.clients (clientID, clientName, clientCountry)
values
    (1, 'A', 'Poland')
    ,(2, 'B', 'UK')
    ,(3, 'C', 'India')
;


-- === Source system 2 data ===

-- fact table 1
create table system_2.purchase_orders(
    orderID int
    ,date date
    ,clientID int
);

insert into system_2.purchase_orders (orderID, date, clientID)
values
    (1, '2022-01-01', 1)
    ,(2, '2022-01-02', 1)
    ,(3, '2022-01-03', 2)
;

-- fact table 2
create table system_2.purchase_orders_details(
    orderDetailID int
    ,orderID int
    ,productID int
    ,quantity int
);

insert into system_2.purchase_orders_details (orderDetailID, orderID, productID, quantity)
values
    (1, 1, 1, 1)
    ,(2, 1, 2, 1)
    ,(3, 2, 2, 1)
    ,(4, 2, 3, 1)
    ,(5, 3, 3, 1)
;

-- dim table 1
create table system_2.products(
    productID int
    ,price int
    ,productName varchar(50)
    ,productCategory varchar(50)
);

insert into system_2.products (productID, price, productName, productCategory)
values
    (1, 5, 'trousers', 'clothes')
    ,(2, 100, 'laptop', 'electronics')
    ,(3, 1, 'bread', 'food')
;

-- dim table 2
create table system_2.clients(
    clientID int
    ,clientName varchar(50)
    ,clientCountry varchar(50)
);

insert into system_1.clients (clientID, clientName, clientCountry)
values
    (1, 'A', 'Poland')
    ,(2, 'B', 'UK')
    ,(3, 'C', 'India')
;