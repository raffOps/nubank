drop table if exists d_year;
create table d_year
(
    year_id     int primary key,
    action_year int
);
copy d_year (year_id, action_year)
    from '/data/Tables/d_year/part-00000-tid-5440254676189819830-69d9a28f-dbd2-48ca-9eca-66f1ddb276df-10961064-1-c000.csv'
    delimiter ','
    csv header;

drop table if exists d_month;
create table d_month
(
    month_id     int primary key,
    action_month int
);
copy d_month (month_id, action_month)
    from '/data/Tables/d_month/part-00000-tid-1411108534556725179-0fbf435f-dd8b-411e-ae97-11e74b345b4f-10859988-1-c000.csv'
    delimiter ','
    csv header;

drop table d_week;
create table d_week
(
    week_id     int primary key,
    action_week int
);
copy d_week (week_id, action_week)
    from '/data/Tables/d_week/part-00000-tid-8944900144231406848-ea4ff673-508c-46e0-ac10-e488037f37c5-10733320-1-c000.csv'
    delimiter ','
    csv header;

drop table if exists d_weekday;
create table d_weekday
(
    weekday_id     int primary key,
    action_weekday int
);
copy d_weekday (weekday_id, action_weekday)
    from '/data/Tables/d_weekday/part-00000-tid-1198883628307677355-d7f0c6f5-b5f5-40c6-9537-2951b88849eb-10926413-1-c000.csv'
    delimiter ','
    csv header;



drop table if exists d_time;
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
copy d_time (time_id, action_timestamp, week_id, month_id, year_id, weekday_id)
    from '/data/Tables/d_time/part-00000-tid-2902183611695287462-3111e3e9-023d-4533-a7e5-d0b87fb1a808-10662337-1-c000.csv'
    delimiter ','
    csv header;

drop table if exists country;
create table country
(
    country_id varchar(36) primary key,
    country    varchar(128)
);
copy country (country, country_id)
    from '/data/Tables/country/part-00000-tid-5054581782199228501-41100236-b09c-46a7-8442-8d968c697e9a-11286346-1-c000.csv'
    delimiter ','
    csv header;

drop table if exists state;
create table state
(
    state_id   varchar(36) primary key,
    state      varchar(128),
    country_id varchar(36),

    constraint fk_year_id
        foreign key (country_id)
            references country (country_id)
);
copy state (state, country_id, state_id)
    from '/data/Tables/state/part-00000-tid-2467726635302089596-e4fdd6ee-8624-4658-af6a-6098bc1c0825-11243350-1-c000.csv'
    delimiter ','
    csv header;

drop table if exists city;
create table city
(
    city_id  bigint primary key,
    city     varchar(256),
    state_id varchar(36),

    constraint fk_year_id
        foreign key (state_id)
            references state (state_id)
);
copy city (city, state_id, city_id)
    from '/data/Tables/city/part-00000-tid-7257851286237664629-906ff0c6-51c7-4cdd-97cd-dc0aa92a92f1-11185485-1-c000.csv'
    delimiter ','
    csv header;

drop table if exists customers;
create table customers
(
    customer_id   varchar(36) primary key,
    first_name    varchar(128),
    last_name     varchar(128),
    customer_city bigint,
    country_name  varchar(128), -- ?
    cpf           bigint,

    constraint fk_customer_city
        foreign key (customer_city)
            references city (city_id)
);
copy customers (customer_id, first_name, last_name, customer_city, cpf, country_name)
    from '/data/Tables/customers/part-00000-tid-2581180368179082894-038c4dab-1615-444a-994f-5a2107c4d9a8-11135734-1-c000.csv'
    delimiter ','
    csv header;

drop table if exists accounts;
create table accounts
(
    account_id          varchar(36) primary key,
    customer_id         varchar(36),
    created_at          timestamp,
    status              varchar(128),
    account_branch      varchar(128),
    account_check_digit varchar(128),
    account_number      varchar(128),

    constraint fk_customer_id
        foreign key (customer_id)
            references customers (customer_id)
);
copy accounts (account_id, customer_id, created_at, status, account_branch, account_check_digit, account_number)
    from '/data/Tables/accounts/part-00000-tid-2834924781296170616-a9b7a53c-b8f1-417c-876b-22ce8ab4c825-11024507-1-c000.csv'
    delimiter ','
    csv header;

drop table if exists transfer_ins;
create table transfer_ins
(
    id                       varchar(36) primary key,
    account_id               varchar(36),
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
copy transfer_ins (id, account_id, amount, transaction_requested_at, transaction_completed_at, status)
    from '/data/Tables/transfer_ins/part-00000-tid-3939740088886661710-b68a1bdc-ca76-4934-b2fd-756b973d041f-10414417-1-c000.csv'
    delimiter ','
    null as 'None'
    csv header;

drop table if exists transfer_outs;
create table transfer_outs
(
    id                       varchar(36) primary key,
    account_id               varchar(36),
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
copy transfer_outs (id, account_id, amount, transaction_requested_at, transaction_completed_at, status)
    from '/data/Tables/transfer_outs/part-00000-tid-3880462020784336524-8a5c83e1-e1e4-471e-9dbf-1b37babaff47-10468383-1-c000.csv'
    delimiter ','
    null as 'None'
    csv header;

drop table if exists pix_movements;
create table pix_movements
(
    id               varchar(36) primary key,
    account_id       varchar(36),
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
copy pix_movements (id, account_id, pix_amount, pix_requested_at, pix_completed_at, status, in_or_out)
    from '/data/Tables/pix_movements/part-00000-tid-8322739320471544484-12382b61-f87b-4388-931d-ec1681d2aad1-10545794-1-c000.csv'
    delimiter ','
    null as 'None'
    csv header;


drop table if exists investments;
create table investments
(
    transaction_id                    varchar(36) primary key,
    account_id                        varchar(36),
    type                              varchar(128),
    amount                            float,
    investment_requested_at           int,
    investment_completed_at           int,
    investment_completed_at_timestamp timestamp,
    status                            varchar(128),

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
copy investments (account_id, transaction_id, status, amount, investment_requested_at, investment_completed_at,
                  investment_completed_at_timestamp, type)
    from '/data/Tables/investments/investments_transformed.csv'
    delimiter ','
    null as ''
    csv header;
