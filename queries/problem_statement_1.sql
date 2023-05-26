with transfer_ins_transformed as (
    select
        id,
        account_id,
        amount,
        to_timestamp(transaction_requested_at),
        to_timestamp(transaction_completed_at),
        status,
        'NON PIX' as transaction_type,
        'IN' as in_or_out
    from transfer_ins
),

    transfer_outs_transformed as (
    select
        id,
        account_id,
        amount,
        to_timestamp(transaction_requested_at),
        to_timestamp(transaction_completed_at),
        status,
        'NON PIX' as transaction_type,
        'OUT' as in_or_out
    from transfer_outs
),

    pix_transformed as (
        select
            id,
            account_id,
            pix_amount as amount,
            to_timestamp(pix_requested_at) as transaction_requested_at,
            to_timestamp(pix_completed_at) as transaction_completed_at,
            status,
            'PIX' as transaction_type,
            case
                when in_or_out = 'pix_out' then 'OUT'
                when in_or_out = 'pix_in' then 'IN'
            end as in_or_out
        from pix_movements
    ),

    investments_transformed as (
        select
            transaction_id as id,
            account_id,
            amount,
            to_timestamp(investment_requested_at) as transaction_requested_at,
            to_timestamp(investment_completed_at) as transaction_completed_at,
            status,
            'NON PIX' as transaction_type,
            case
                when type = 'investment_transfer_out' then 'OUT'
                when type = 'investment_transfer_in' then 'IN'
            end as in_or_out
        from investments
    ),
    transactions as (select *
                     from transfer_ins_transformed
                     union all
                     select *
                     from transfer_outs_transformed
                     union all
                     select *
                     from pix_transformed
                     union all
                     select *
                     from investments_transformed
)

select
    in_or_out,
    count(*)
from transactions
group by in_or_out;