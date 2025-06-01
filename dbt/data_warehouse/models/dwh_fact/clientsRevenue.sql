select
    clientID
    ,sum(totalPrice) as revenue
from
    {{ ref('orders') }}
where
    -- Get date of the first day of the financial year 5 years ago.
    date >= '{{ date_x_fy_ago(5) }}'
group by
    clientID