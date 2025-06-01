select
    date
    ,po.clientID
    ,pod.productID
    ,pod.quantity
    ,pod.quantity * pr.price as totalPrice
from
    {{ source('system_1', 'purchase_orders') }} as po

    left join {{ source('system_1', 'purchase_orders_details') }} as pod
        on pod.orderID = po.orderID

    left join {{ source('system_1', 'products') }} as pr
        on pr.productID = pod.productID

union all

select
    date
    ,po.clientID
    ,pod.productID
    ,pod.quantity
    ,pod.quantity * pr.price as totalPrice
from
    {{ source('system_2', 'purchase_orders') }} as po

    left join {{ source('system_2', 'purchase_orders_details') }} as pod
        on pod.orderID = po.orderID

    left join {{ source('system_2', 'products') }} as pr
        on pr.productID = pod.productID