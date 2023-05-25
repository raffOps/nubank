create table d_year
(
    year_id     int primary key,
    action_year int
);

create table d_month
(
    month_id     int primary key,
    action_month int
);

create table d_week
(
    week_id     int primary key,
    action_week int
);

create table d_weekday
(
    weekday_id     int primary key,
    action_weekday int
);

drop table d_time;
create table d_time
(
    time_id          int primary key,
    action_timestamp timestamp,
    week_id          int,
    month_id         int,
    year_id          int,
    weekday_id       int,

    constraint fk_week_id
        foreign key (week_id)
            references d_week (week_id),
    constraint fk_month_id
        foreign key (month_id)
            references d_month (month_id),
    constraint fk_year_id
        foreign key (year_id)
            references d_year (year_id),
    constraint fk_weekday_id
    foreign key (weekday_id)
        references d_weekday (weekday_id)
);

create table country
(
    country_id varchar(16) primary key,
    contry_id  varchar(128)
);

create table state
(
    state_id   varchar(16) primary key,
    state      varchar(128),
    country_id varchar(16),

    constraint fk_year_id
        foreign key (country_id)
            references country (country_id)
);

create table city
(
    city_id  int primary key,
    city     varchar(256),
    state_id varchar(16),

    constraint fk_year_id
        foreign key (state_id)
            references state (state_id)
);

create table customers
(
    customer_id   varchar(16) primary key,
    first_name    varchar(128),
    last_name     varchar(128),
    customer_city int,
    country_name  varchar(128), -- ?
    cpf           int,

    constraint fk_customer_city
        foreign key (customer_city)
            references city (city_id)
);

create table accounts
(
    account_id          varchar(16) primary key,
    customer_id         varchar(16),
    created_at          timestamp,
    account_branch      varchar(128),
    account_check_digit varchar(128),
    account_number      varchar(128),

    constraint fk_customer_id
        foreign key (customer_id)
            references customers (customer_id)
);

drop table if exists transfer_ins;
create table transfer_ins
(
    id                       varchar(16) primary key,
    account_id               varchar(16),
    amount                   float,
    transaction_requested_at int,
    transaction_completed_at int,
    status                   varchar(128),

    constraint fk_account_id
        foreign key (account_id)
            references accounts (account_id),
    constraint fk_transaction_requested_at
        foreign key (transaction_requested_at)
            references d_time (time_id),

    constraint fk_transaction_completed_at
        foreign key (transaction_completed_at)
            references d_time (time_id)
);

drop table if exists transfer_outs;
create table transfer_outs
(
    id                       varchar(16) primary key,
    account_id               varchar(16),
    amount                   float,
    transaction_requested_at int,
    transaction_completed_at int,
    status                   varchar(128),

    constraint fk_account_id
        foreign key (account_id)
            references accounts (account_id),
    constraint fk_transaction_requested_at
        foreign key (transaction_requested_at)
            references d_time (time_id),

    constraint fk_transaction_completed_at
        foreign key (transaction_completed_at)
            references d_time (time_id)
);

drop table if exists pix_movements;
create table pix_movements
(
    id               varchar(16) primary key,
    account_id       varchar(16),
    in_or_out        varchar(128),
    pix_amount       float,
    pix_requested_at int,
    pix_completed_at int,
    status           varchar(128),

    constraint fk_account_id
        foreign key (account_id)
            references accounts (account_id),
    constraint fk_pix_requested_at
        foreign key (pix_requested_at)
            references d_time (time_id),

    constraint fk_pix_completed_at
        foreign key (pix_completed_at)
            references d_time (time_id)
);

drop table if exists investments;
create table investments
(
    transaction_id          varchar(16) primary key,
    account_id              varchar(16),
    type                    varchar(128),
    amount                  float,
    investment_requested_at int,
    investment_completed_at int,
    status                  varchar(128),

    constraint fk_account_id
        foreign key (account_id)
            references accounts (account_id),
    constraint fk_investment_requested_at
        foreign key (investment_requested_at)
            references d_time (time_id),

    constraint fk_investment_completed_at
        foreign key (investment_completed_at)
            references d_time (time_id)
);

