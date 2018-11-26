-- Manage users and permissions

// Create a new user
create user USERNAME password = 'abc123' default_role = public must_change_password = true DAYS_TO_EXPIRY = 150;

// Give them the appropriate permissions (sysadmin, accountadmin, etc)
grant role sysadmin to user USERNAME;

// Re-set password
alter user pc_fivetran_user set password = 'abc123';

// Enable or disable Multi-factor authentication
ALTER USER userName SET DISABLE_MFA = TRUE;

// Create a user and grant a role
create role if not exists looker_role;
alter user pc_fivetran_user set default_role = PC_FIVETRAN_ROLE;
grant role PC_FIVETRAN_ROLE to user pc_fivetran_user;

// Grant to role to user
// Note that we are not making the looker_role a SYSADMIN,
// but rather granting users with the SYSADMIN role to modify the looker_role
grant role looker_role to role SYSADMIN;

// Grant all privileges to role

grant all privileges on database PC_FIVETRAN_DB to role PC_FIVETRAN_ROLE;
grant all privileges on schema looker_scratch to role looker_role;

// Change ownership of looker_scratch table or schema to pc_fivetran_role
grant ownership on schema looker_scratch to role pc_fivetran_role REVOKE CURRENT GRANTS;

// These commands were suggested by Fivetran but they DON'T RUN. 
// Instead, grant role to user and all privileges to role.
GRANT CREATE ON SCHEMA salesforce TO fivetran;
GRANT CREATE ON SCHEMA pos_inventory TO fivetran;

// Original Fivetran connector settings
PC_FIVETRAN_DB
Warehouse :PC_FIVETRAN_WH (X-Small)
System User :PC_FIVETRAN_USER
System Password :Autogenerated & Randomized
System Role :PC_FIVETRAN_ROLE
Role PUBLIC will be granted to the PC_FIVETRAN_ROLE
Role PC_FIVETRAN_ROLE will be granted to the SYSADMIN role

// Full Fivetran setup script (check user and role names, etc before running)
-- change role to ACCOUNTADMIN for user / role steps
use role ACCOUNTADMIN;

-- create role for fivetran
create role if not exists fivetran_role;
grant role fivetran_role to role SYSADMIN;

-- create a user for fivetran
create user if not exists fivetran;
alter user fivetran set
default_role = fivetran_role
default_warehouse = PC_FIVETRAN_WH
password = 'abc123';
grant role fivetran_role to user fivetran;

-- change role to SYSADMIN for warehouse / database steps
use role SYSADMIN;

-- create a warehouse for fivetran
create warehouse if not exists PC_FIVETRAN_WH
warehouse_size = xsmall
warehouse_type = standard
auto_suspend = 60
auto_resume = true
initially_suspended = true;

-- change role to ACCOUNTADMIN for user / role steps
use role ACCOUNTADMIN;

-- grant fivetran access to warehouse
grant all privileges
on warehouse PC_FIVETRAN_WH
to role fivetran_role;

-- create database for fivetran
create database if not exists PC_FIVETRAN_DB;

-- grant fivetran access to database
grant all privileges
on database PC_FIVETRAN_DB
to role fivetran_role;
