with transfer_ins_transformed as (
        select
            id,
            account_id,
            amount,
            to_timestamp(transaction_requested_at) as transaction_requested_at,
            to_timestamp(transaction_completed_at) as transaction_completed_at,
            status,
            'NON PIX'                              as transaction_type,
            'IN'                                   as in_or_out
        from transfer_ins
    ),

     transfer_outs_transformed as (
        select
            id,
            account_id,
            amount,
            to_timestamp(transaction_requested_at) as transaction_requested_at,
            to_timestamp(transaction_completed_at) as transaction_completed_at,
            status,
            'NON PIX'                              as transaction_type,
            'OUT'                                  as in_or_out
          from transfer_outs
    ),

     pix_transformed as (
        select
            id,
            account_id,
            pix_amount                     as amount,
            to_timestamp(pix_requested_at) as transaction_requested_at,
            to_timestamp(pix_completed_at) as transaction_completed_at,
            status,
            'PIX'                          as transaction_type,
            case
                when in_or_out = 'pix_out' then 'OUT'
                when in_or_out = 'pix_in' then 'IN'
            end                        as in_or_out
          from pix_movements
    ),

     investments_transformed as (
        select
            transaction_id                        as id,
            account_id,
            amount,
            to_timestamp(investment_requested_at) as transaction_requested_at,
            to_timestamp(investment_completed_at) as transaction_completed_at,
            status,
            'NON PIX'                             as transaction_type,
            case
                when type = 'investment_transfer_out' then 'OUT'
                when type = 'investment_transfer_in' then 'IN'
            end                               as in_or_out
          from investments),

     transactions as (
        select * from transfer_ins_transformed
        union all
        select * from transfer_outs_transformed
        union all
        select * from pix_transformed
        union all
        select * from investments_transformed
    ),

    montly_balance_temp as (
        select
            account_id,
            cast(date_trunc('month', transaction_completed_at) as date) as year_month,
            coalesce(sum(amount) filter (where in_or_out = 'IN' ), 0)   as total_transactions_in,
            coalesce(sum(amount) filter (where in_or_out = 'OUT' ), 0)  as total_transactions_out
        from transactions
        where transaction_completed_at >= '2020-01-01'
          and transaction_completed_at <= '2020-12-31'
        group by account_id, date_trunc('month', transaction_completed_at)
    )

select
    *,
    total_transactions_in - total_transactions_out as account_monthly_balance
from montly_balance_temp;