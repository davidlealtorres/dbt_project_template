# Admin Utils Stored Procedures

## Introduction

`admin_utils.sql` contains a suite of [Snowflake stored procedures](https://docs.snowflake.com/en/sql-reference/stored-procedures.html) which provide an abstraction for performing common administrative tasks, including:

- User, role, and warehouse creation
- Database and schema creation
- Granting write/read access to databases and schemas

## Usage

### Initial setup

Before calling the stored procedures, the contents of `admin_utils.sql` must be executed in its entirety in the Snowflake account from the ACCOUNTADMIN role.

### Calling the procedures

All the procedures can be executed from the ACCOUNTADMIN role, with some accessible to (or owned by) the USERADMIN, SYSADMIN or SECURITYADMIN role.

To run a procedure, use `call` function:
```
call ADMIN.UTILS.CREATE_NORMAL_USER('NAME', 'Description');
```

Snowflake allows for multiple stored procedures with the same name, provided they have different arguments. We use this feature to maintain multiple versions of the same procedure with different levels of customization. Snowflake determines which procedure is being used from the arguments passed.

## Usage examples

### Databases

To create a database with associated reader and writer roles, run the `ADMIN.UTILS.CREATE_DATABASE` procedure. This procedure has two arguments:
- DATABASE - name of the database
- DESCRIPTION - description for the database

Example:
```
call ADMIN.UTILS.CREATE_DATABASE('MY_DATABASE', 'Destination database for data loader.')
```

The result of running the above is a database named 'MY_DATABASE', a writer role named 'MY_DATABASE_DB_WRITER', and a reader role named 'MY_DATABASE_DB_READER'. Writer roles are granted all grants on all existing and future objects within a database. The reader role can select from all existing and future tables, views and materialized views. These access roles can then be granted to any functional roles as needed.

### Schemas

To create a schema with associated schema reader role, run the `ADMIN.UTILS.CREATE_DATABASE_SCHEMA` procedure. This procedure requires that the parent database already exists. The procedure has three arguments:
- DATABASE - name of the database
- SCHEMA - name of the schema to create
- DESCRIPTION - description for the schema

Example:
```
call ADMIN.UTILS.CREATE_DATABASE_SCHEMA('MY_DATABASE', 'MY_SCHEMA', 'Schema containing data.')
```

The result of running the above is a schema inside 'MY_DATABASE' named 'MY_SCHEMA', and a schema reader role named 'MY_DATABASE_MY_SCHEMA_READER'. This access roles can then be granted to any functional roles needed.

### Users

Users can be viewed as one of the following (though they are all just user objects to Snowflake):
- Admin users - full access over the database.
- Normal users - for human users, typically granted functional roles like Developer or Analyst
- Service users - for applications like Fivetran, Stitch, Tableau, or Looker.


#### Admin users

To create an Admin user and individual warehouse, run the `ADMIN.UTILS.CREATE_ADMIN_USER` procedure. This will create the user, grant the requested role, and create and grant a warehouse with the same name as the user. This procedure has three arguments:
- USERNAME - name of the user
- ADMIN_ROLE - role to grant the user
- DESCRIPTION - attached to the user

Example:
```
call ADMIN.UTILS.CREATE_ADMIN_USER('USERNAME', 'ACCOUNTADMIN', 'For use by COMPANY_NAME');
```

It's recommended to add a network policy:
```
alter user USER_NAME set network_policy = 'COMPANY_NAME';
```

Set a temporary password with forced reset if the user is for another person:
```
alter user USERNAME set password = 'RANDOM_PASSWORD', must_change_password = TRUE;
```

Finally, request that the user configure Multi-Factor Authentication (MFA) (per [Snowflake's own recommendation](https://docs.snowflake.com/en/user-guide/security-mfa.html#multi-factor-authentication-mfa).

#### Normal users

Use the `ADMIN.UTILS.CREATE_NORMAL_USER` procedure.

##### 1. Create a user, role and warehouse

A common task is integrating a new platform with Snowflake, such as a BI tool or data loader. In this case, a new user, role and warehouse should be created. The required `ADMIN.UTILS.CREATE_NORMAL_USER` takes just two arguments:
- USERNAME
- DESCRIPTION

Example:
```
call ADMIN.UTILS.CREATE_NORMAL_USER('USERNAME', 'For use by USERNAME');
```

Once complete, grant any access roles to the functional role that was just created.

It's recommended to add a network policy:
```
alter user USERNAME set network_policy = 'TOOL_NAME';
```

Set a password for the user:
```
alter user USERNAME set password = 'RANDOM_PASSWORD';
```

##### 2. Create a user and warehouse, granting an existing role as the default

New team members need a user, their own warehouse, but can often use an existing role for their function. An example would be an analytics engineer, who may just need access to an existing 'ANALYTICS_DEVELOPER' functional role. The required `ADMIN.UTILS.CREATE_NORMAL_USER` takes three arguments:
- USERNAME
- DEFAULT_ROLE
- DESCRIPTION

Example:
```
call ADMIN.UTILS.CREATE_NORMAL_USER('USERNAME', 'ANALYICS_DEVELOPER', 'For use by USERNAME');
```

It's recommended to add a network policy:
```
alter user USERNAME set network_policy = 'COMPANY_NAME';
```

Set a password for the user:
```
alter user USERNAME set password = 'RANDOM_PASSWORD', must_change_password = TRUE;
```
### Network Policies

One common maintenance task is to allowlist IPs for a VPN, or service which needs to access Snowflake. This is not managed by a stored procedure, and just requires the creation (or replacement) of a network policy.

```
create or replace network policy COMPANY_NAME
    allowed_ip_list = (
        /* Main Office */
        'X.X.X.X'
        /* Second Office */
        , 'X.X.X.X'
    );
```

### Databases

To create a database, run the `ADMIN.UTILS.CREATE_DATABASE` command. This script has two arguments:
- DATABASE - name of the database
- DESCRIPTION - a  what the database is. For example: `'A database to hold SOME data.'`

When you run this call, it creates the database if it doesn't already exist. It also creates and grants use to two different roles: `${DATABASE}_DB_READER` and `${DATABASE}_DB_WRITER`. The first allows read only access and the second is both read and write access.

This does not delete a database that already exists if you run it more than once. It does, however, erase any role grants you have previously made. To re-grant these roles, either run the entire `setup.sql` file or look for and run these role grants specifically.

## Creating a Schema

To create a schema, run the `ADMIN.UTILS.CREATE_DATABASE_SCHEMA` command. This script has three arguments:
- `DATABASE_NAME`
- `SCHEMA_NAME`
- Description of what the database is. For example: `'A schema to hold SOME data.'`

When you run this call, it creates the schema if it doesn't already exist. It also creates and grants use to one role: `${DATABASE}_${SCHEMA}_SCHEMA_READER`.

This does not delete a schema that already exists if you run it more than once. It does, however, erase any role grants you have previously made. To re-grant these roles, either run the entire `setup.sql` file or look and run for these role grants specifically.

## Implementation details

### Roles

The stored procedures are designed in alignment with [Snowflake's recommendation](https://docs.snowflake.com/en/user-guide/security-access-control-considerations.html#aligning-object-access-with-business-functions) to separate roles into 'access roles' and 'functional roles'. Access roles are created automatically when using the `ADMIN.UTILS.CREATE_DATABASE` or `ADMIN.UTILS.CREATE_DATABASE_SCHEMA` procedures.

Access roles are those which enable a user to perform an action on an object in the account, such as a database. These roles are granted to functional roles. A functional role enables a user to fulfill a function, with one or more access roles granted.

For example an 'analyst' functional role could be granted to all members of an analyst team. The analyst role might be granted a reader access role to a raw database and a writer access role to a development and testing database. A 'BI' functional role granted to a BI user might be a granted a reader access role to a dbt production database.

### Reader and writer roles for databases, schemas and tables

For a role to be able to select from a table, it must have both the `select` grant on the table, and `usage` grants on the parent schema and database. The `ADMIN.UTILS.CREATE_DATABASE` stored procedure grants `select` on all tables, views and materialized views to the public role, which is granted to all other roles automatically. The access to databases and schemas is then governed purely by the 'usage' grant.

### Idempotency

The stored procedures are imdepotent; once executed, subsequent calls with the same arguments will not alter the existing infrastructure.

### Resource ownership

Snowflake [recommend](https://docs.snowflake.com/en/user-guide/security-access-control-considerations.html#avoid-using-the-accountadmin-role-to-create-objects) that the ACCOUNTADMIN role is not used to create objects. As such, the stored procedures use a combination of `execute as caller`, `execute as owner` and `use role` statements to switch to an appropriate [system-defined role](https://docs.snowflake.com/en/user-guide/security-access-control-overview.html#system-defined-roles) before creating objects.

## Usage notes

### Removing resources created with the stored procedures

These procedures do not have the ability to delete the objects they create. Regular Snowflake drop and revoke grant statements must be used.

### Tracking created infrastructure in version control

In the main folder under `database` is a file called `setup.sql`. It's recommended to keep a record of all executed DDL and stored procedures in this version-controlled file. When resources are deleted, remove the commands that created them from the `setup.sql` file.
