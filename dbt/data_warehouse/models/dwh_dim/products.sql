with unioned as (
    select
        productID
        ,price
        ,productName
        ,productCategory
    from
        {{ source('system_1', 'products') }}

    union all

    select
        productID
        ,price
        ,productName
        ,productCategory
    from
        {{ source('system_2', 'products') }}
)

,unioned_distinct as (
    select distinct
        productID
        ,price
        ,productName
        ,productCategory
    from
        unioned
)

select
    dense_rank() over (order by productID) as productID
    ,price
    ,productName
    ,productCategory
from
    unioned_distinct