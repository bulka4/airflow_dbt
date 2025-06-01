with unioned as (
    select
        clientID
        ,clientName
        ,clientCountry
    from
        {{ source('system_1', 'clients') }}

    union all

    select
        clientID
        ,clientName
        ,clientCountry
    from
        {{ source('system_2', 'clients') }}
)

,unioned_distinct as (
    select distinct
        clientID
        ,clientName
        ,clientCountry
    from
        unioned
)

select
    dense_rank() over (order by clientID) as clientID
    ,clientName
    ,clientCountry
from
    unioned_distinct