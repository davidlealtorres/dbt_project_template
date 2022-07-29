
use role ACCOUNTADMIN;


create database if not exists ADMIN
    comment = 'For admins.';

    create schema if not exists ADMIN.UTILS
        comment = 'For admin utility procedures.';

    drop schema if exists ADMIN.PUBLIC;

grant usage on database ADMIN to role SYSADMIN;
grant usage on database ADMIN to role SECURITYADMIN;
grant usage on database ADMIN to role USERADMIN;

grant usage on schema ADMIN.UTILS to role SYSADMIN;
grant usage on schema ADMIN.UTILS to role SECURITYADMIN;
grant usage on schema ADMIN.UTILS to role USERADMIN;


create or replace procedure ADMIN.UTILS.CREATE_ROLE(ROLE string, DESCRIPTION string)
    returns string
    language javascript
    comment = 'Creates the specified role and grants it to the SYSADMIN role.'
    execute as owner
    as $$
        snowflake.execute({sqlText: "create role if not exists identifier(:1)", binds: [ROLE]});
        snowflake.execute({sqlText: "alter role identifier(:1) set comment = :2", binds: [ROLE, DESCRIPTION]});
        snowflake.execute({sqlText: "grant role identifier(:1) to role SYSADMIN", binds: [ROLE]});

        return `Created role ${ROLE}.`;
    $$;

    grant ownership on procedure ADMIN.UTILS.CREATE_ROLE(string, string) to role USERADMIN;
    grant usage     on procedure ADMIN.UTILS.CREATE_ROLE(string, string) to role SYSADMIN;


create or replace procedure ADMIN.UTILS.GRANT_ALL_IN_DATABASE(DATABASE string, ROLE string)
    returns string
    language javascript
    comment = 'Grants all privileges on all existing and future objects within the database to the role.'
    execute as owner
    as $$
        snowflake.execute({sqlText: "grant usage, create schema on database identifier(:1) to role identifier(:2)", binds: [DATABASE, ROLE]});

        snowflake.execute({sqlText: "grant all on all    schemas in database identifier(:1) to role identifier(:2)", binds: [DATABASE, ROLE]});
        snowflake.execute({sqlText: "grant all on future schemas in database identifier(:1) to role identifier(:2)", binds: [DATABASE, ROLE]});

        snowflake.execute({sqlText: "grant all on all    tables in database identifier(:1) to role identifier(:2)", binds: [DATABASE, ROLE]});
        snowflake.execute({sqlText: "grant all on future tables in database identifier(:1) to role identifier(:2)", binds: [DATABASE, ROLE]});

        snowflake.execute({sqlText: "grant all on all    views in database identifier(:1) to role identifier(:2)", binds: [DATABASE, ROLE]});
        snowflake.execute({sqlText: "grant all on future views in database identifier(:1) to role identifier(:2)", binds: [DATABASE, ROLE]});

        snowflake.execute({sqlText: "grant all on all    materialized views in database identifier(:1) to role identifier(:2)", binds: [DATABASE, ROLE]});
        snowflake.execute({sqlText: "grant all on future materialized views in database identifier(:1) to role identifier(:2)", binds: [DATABASE, ROLE]});

        snowflake.execute({sqlText: "grant all on all    stages in database identifier(:1) to role identifier(:2)", binds: [DATABASE, ROLE]});
        snowflake.execute({sqlText: "grant all on future stages in database identifier(:1) to role identifier(:2)", binds: [DATABASE, ROLE]});

        snowflake.execute({sqlText: "grant all on all    file formats in database identifier(:1) to role identifier(:2)", binds: [DATABASE, ROLE]});
        snowflake.execute({sqlText: "grant all on future file formats in database identifier(:1) to role identifier(:2)", binds: [DATABASE, ROLE]});

        snowflake.execute({sqlText: "grant all on all    streams in database identifier(:1) to role identifier(:2)", binds: [DATABASE, ROLE]});
        snowflake.execute({sqlText: "grant all on future streams in database identifier(:1) to role identifier(:2)", binds: [DATABASE, ROLE]});

        return `Granted all in database ${DATABASE} to role ${ROLE}.`;
    $$;

    grant ownership on procedure ADMIN.UTILS.GRANT_ALL_IN_DATABASE(string, string) to role SECURITYADMIN;
    grant usage     on procedure ADMIN.UTILS.GRANT_ALL_IN_DATABASE(string, string) to role SYSADMIN;


create or replace procedure ADMIN.UTILS.GRANT_SELECT_IN_DATABASE(DATABASE string, ROLE string)
    returns string
    language javascript
    comment = 'Grants select privileges on all existing and future tables/views within the database to the role.'
    execute as owner
    as $$
        snowflake.execute({sqlText: "grant select on all    tables in database identifier(:1) to role identifier(:2)", binds: [DATABASE, ROLE]});
        snowflake.execute({sqlText: "grant select on future tables in database identifier(:1) to role identifier(:2)", binds: [DATABASE, ROLE]});

        snowflake.execute({sqlText: "grant select on all    views in database identifier(:1) to role identifier(:2)", binds: [DATABASE, ROLE]});
        snowflake.execute({sqlText: "grant select on future views in database identifier(:1) to role identifier(:2)", binds: [DATABASE, ROLE]});

        snowflake.execute({sqlText: "grant select on all    materialized views in database identifier(:1) to role identifier(:2)", binds: [DATABASE, ROLE]});
        snowflake.execute({sqlText: "grant select on future materialized views in database identifier(:1) to role identifier(:2)", binds: [DATABASE, ROLE]});

        return `Granted select in database ${DATABASE} to role ${ROLE}.`;
    $$;

    grant ownership on procedure ADMIN.UTILS.GRANT_SELECT_IN_DATABASE(string, string) to role SECURITYADMIN;
    grant usage     on procedure ADMIN.UTILS.GRANT_SELECT_IN_DATABASE(string, string) to role SYSADMIN;


create or replace procedure ADMIN.UTILS.GRANT_USAGE_ON_ALL_SCHEMAS_IN_DATABASE(DATABASE string, ROLE string)
    returns string
    language javascript
    comment = 'Grants usage privileges on the database and all existing and future schemas within it to the role.'
    execute as owner
    as $$
        snowflake.execute({sqlText: "grant usage on database identifier(:1) to role identifier(:2)", binds: [DATABASE, ROLE]});

        snowflake.execute({sqlText: "grant usage on all    schemas in database identifier(:1) to role identifier(:2)", binds: [DATABASE, ROLE]});
        snowflake.execute({sqlText: "grant usage on future schemas in database identifier(:1) to role identifier(:2)", binds: [DATABASE, ROLE]});

        return `Granted usage on database ${DATABASE} and all its schemas to role ${ROLE}.`;
    $$;

    grant ownership on procedure ADMIN.UTILS.GRANT_USAGE_ON_ALL_SCHEMAS_IN_DATABASE(string, string) to role SECURITYADMIN;
    grant usage     on procedure ADMIN.UTILS.GRANT_USAGE_ON_ALL_SCHEMAS_IN_DATABASE(string, string) to role SYSADMIN;


create or replace procedure ADMIN.UTILS.GRANT_USAGE_ON_DATABASE_SCHEMA(DATABASE string, SCHEMA string, ROLE string)
    returns string
    language javascript
    comment = 'Grants usage privileges on the database and schema to the role.'
    execute as owner
    as $$
        snowflake.execute({sqlText: "grant usage on database identifier(:1) to role identifier(:2)", binds: [DATABASE, ROLE]});

        snowflake.execute({sqlText: "grant usage on schema identifier(:1) to role identifier(:2)", binds: [`${DATABASE}.${SCHEMA}`, ROLE]});

        return `Granted usage on database ${DATABASE} and schema ${DATABASE}.${SCHEMA} to role ${ROLE}.`;
    $$;

    grant ownership on procedure ADMIN.UTILS.GRANT_USAGE_ON_DATABASE_SCHEMA(string, string, string) to role SECURITYADMIN;
    grant usage     on procedure ADMIN.UTILS.GRANT_USAGE_ON_DATABASE_SCHEMA(string, string, string) to role SYSADMIN;


create or replace procedure ADMIN.UTILS.CREATE_DATABASE(DATABASE string, DESCRIPTION string)
    returns string
    language javascript
    comment = 'Creates the specified database and associated reader and writer roles.'
    execute as caller
    as $$
        snowflake.execute({sqlText: "use role SYSADMIN"});

        snowflake.execute({sqlText: "create database if not exists identifier(:1)", binds: [DATABASE]});
        snowflake.execute({sqlText: "alter database identifier(:1) set comment = :2", binds: [DATABASE, DESCRIPTION]});

        var reader_role = `${DATABASE}_DB_READER`;
        var writer_role = `${DATABASE}_DB_WRITER`;
        snowflake.execute({sqlText: "call ADMIN.UTILS.CREATE_ROLE(:1, :2)", binds: [reader_role, `Read-only access to entire ${DATABASE} database.`]});
        snowflake.execute({sqlText: "call ADMIN.UTILS.CREATE_ROLE(:1, :2)", binds: [writer_role, `Full access to entire ${DATABASE} database.`]});

        /* Read access will be controlled at the schema level. */
        snowflake.execute({sqlText: "call ADMIN.UTILS.GRANT_SELECT_IN_DATABASE(:1, 'PUBLIC')", binds: [DATABASE]});
        snowflake.execute({sqlText: "call ADMIN.UTILS.GRANT_USAGE_ON_ALL_SCHEMAS_IN_DATABASE(:1, :2)", binds: [DATABASE, reader_role]});

        snowflake.execute({sqlText: "call ADMIN.UTILS.GRANT_ALL_IN_DATABASE(:1, :2)", binds: [DATABASE, writer_role]});

        return `Created database ${DATABASE} and associated ${reader_role} and ${writer_role} roles.`;
    $$;

    grant usage on procedure ADMIN.UTILS.CREATE_DATABASE(string, string) to role SYSADMIN;

create or replace procedure ADMIN.UTILS.CREATE_DATABASE_FROM_SHARE(SHARE string, DATABASE string, DESCRIPTION string)
    returns string
    language javascript
    comment = 'Creates the specified shared database and associated reader role.'
    execute as owner
    as $$
        snowflake.execute({sqlText: "create database if not exists identifier(:1) from share identifier(:2)", binds: [DATABASE, SHARE]});
        snowflake.execute({sqlText: "alter database identifier(:1) set comment = :2", binds: [DATABASE, DESCRIPTION]});

        var READER_ROLE = `${DATABASE}_DB_READER`;

        snowflake.execute({sqlText: "call ADMIN.UTILS.CREATE_ROLE(:1, 'Read-only access to entire :2 share database.')", binds: [READER_ROLE, DATABASE]});

        snowflake.execute({sqlText: "grant imported privileges on database identifier(:1) to role identifier(:2)", binds: [DATABASE, READER_ROLE]});
        return `Created database ${DATABASE} and the reader role ${READER_ROLE} from the share ${SHARE}.`;
    $$;

    grant usage on procedure ADMIN.UTILS.CREATE_DATABASE_FROM_SHARE(string, string, string) to role SYSADMIN;


create or replace procedure ADMIN.UTILS.CREATE_DATABASE_SCHEMA(DATABASE string, SCHEMA string, DESCRIPTION string)
    returns string
    language javascript
    comment = 'Creates the specified database schema and associated reader role.'
    execute as caller
    as $$
        snowflake.execute({sqlText: "use role SYSADMIN"});

        var database_schema = `${DATABASE}.${SCHEMA}`;
        snowflake.execute({sqlText: "create schema if not exists identifier(:1)", binds: [database_schema]});
        snowflake.execute({sqlText: "alter schema identifier(:1) set comment = :2", binds: [database_schema, DESCRIPTION]});

        var reader_role = `${DATABASE}_${SCHEMA}_SCHEMA_READER`;
        snowflake.execute({sqlText: "call ADMIN.UTILS.CREATE_ROLE(:1, :2)", binds: [reader_role, `Read-only access to ${database_schema} schema.`]});

        snowflake.execute({sqlText: "call ADMIN.UTILS.GRANT_USAGE_ON_DATABASE_SCHEMA(:1, :2, :3)", binds: [DATABASE, SCHEMA, reader_role]});

        return `Created schema ${database_schema} and associated ${reader_role} role.`;
    $$;

    grant usage on procedure ADMIN.UTILS.CREATE_DATABASE_SCHEMA(string, string, string) to role SYSADMIN;


create or replace procedure ADMIN.UTILS.CREATE_WAREHOUSE_AS_SYSADMIN(WAREHOUSE string, DESCRIPTION string, USAGE_ROLES array)
    returns string
    language javascript
    comment = 'Creates the specified warehouse with usage granted to the specified roles.'
    execute as owner
    as $$
        snowflake.execute({
            sqlText: "create warehouse if not exists identifier(:1) warehouse_size=xsmall auto_suspend=60 initially_suspended=true",
            binds: [WAREHOUSE]
        });
        snowflake.execute({sqlText: "alter warehouse identifier(:1) set comment = :2", binds: [WAREHOUSE, DESCRIPTION]});

        for (var role_num = 0; role_num < USAGE_ROLES.length; role_num++) {
            snowflake.execute({
                sqlText: "grant monitor, operate, usage on warehouse identifier(:1) to role identifier(:2)",
                binds: [WAREHOUSE, USAGE_ROLES[role_num]]
            });
        }

        return `Created warehouse ${WAREHOUSE} with usage granted to role(s) ${USAGE_ROLES.join(' + ')}.`;
    $$;

    grant ownership on procedure ADMIN.UTILS.CREATE_WAREHOUSE_AS_SYSADMIN(string, string, array) to role SYSADMIN;
    grant usage     on procedure ADMIN.UTILS.CREATE_WAREHOUSE_AS_SYSADMIN(string, string, array) to role USERADMIN;


create or replace procedure ADMIN.UTILS.CREATE_WAREHOUSE(WAREHOUSE string, DESCRIPTION string, USAGE_ROLES array)
    returns string
    language javascript
    comment = 'Creates the specified warehouse with usage granted to the specified roles, and switches back to the currently active warehouse.'
    execute as caller
    as $$
        /*  Save the currently active warehouse so we can switch back to it after creating the new warehouse,
            because when you create a warehouse Snowflake automatically sets it as the active/current warehouse. */
        var current_warehouse_result = snowflake.execute({sqlText: "select current_warehouse()"});
        current_warehouse_result.next();
        var current_warehouse = current_warehouse_result.getColumnValue(1);

        /* Binding arrays as SQL parameters isn't supported, so we give each usage role its own placeholder. */
        var usage_role_placeholders = new Array(USAGE_ROLES.length).fill("?").join(", ");
        var create_result = snowflake.execute({
            sqlText: `call ADMIN.UTILS.CREATE_WAREHOUSE_AS_SYSADMIN(?, ?, array_construct(${usage_role_placeholders}))`,
            binds: [WAREHOUSE, DESCRIPTION].concat(USAGE_ROLES)
        });
        create_result.next();

        snowflake.execute({sqlText: "use warehouse identifier(:1)", binds: [current_warehouse]});

        return create_result.getColumnValue(1);
    $$;

    grant usage on procedure ADMIN.UTILS.CREATE_WAREHOUSE(string, string, array) to role SYSADMIN;
    grant usage on procedure ADMIN.UTILS.CREATE_WAREHOUSE(string, string, array) to role USERADMIN;


create or replace procedure ADMIN.UTILS.CREATE_NORMAL_USER(USERNAME string, DEFAULT_ROLE string, ADDITIONAL_ROLES array, DESCRIPTION string)
    returns string
    language javascript
    comment = 'Creates a normal user with a default, existing role passed as argument, creates a default warehouse for the user, grants any additional roles to the user and sets a description.'
    execute as caller
    as $$
        var current_role_result = snowflake.execute({sqlText: "select current_role()"});
        current_role_result.next();
        var current_role = current_role_result.getColumnValue(1);

        snowflake.execute({sqlText: "use role USERADMIN"});

        snowflake.execute({sqlText: "create user if not exists identifier(:1)", binds: [USERNAME]});

        snowflake.execute({sqlText: "grant role identifier(:1) to user identifier(:2)", binds: [DEFAULT_ROLE, USERNAME]});

        snowflake.execute({sqlText: "alter user identifier(:1) set login_name = :1, comment = :2, default_role = :3", binds: [USERNAME, DESCRIPTION, DEFAULT_ROLE]});

        for (var role_num = 0; role_num < ADDITIONAL_ROLES.length; role_num++) {
            snowflake.execute({sqlText: "grant role identifier(:1) to user identifier(:2)", binds: [ADDITIONAL_ROLES[role_num], USERNAME]});
        }

        /* Binding arrays as SQL parameters isn't supported, so we give each usage role its own placeholder. */
        var usage_roles = ADDITIONAL_ROLES.concat([DEFAULT_ROLE])
        var usage_role_placeholders = new Array(usage_roles.length).fill("?").join(", ");
        snowflake.execute({
            sqlText: `call ADMIN.UTILS.CREATE_WAREHOUSE(?, ?, array_construct(${usage_role_placeholders}))`,
            binds: [USERNAME, `For user ${USERNAME}.`].concat(usage_roles)
        });

        snowflake.execute({sqlText: "alter user identifier(:1) set default_warehouse = :2", binds: [USERNAME, USERNAME]});

        if (ADDITIONAL_ROLES.length == 0) {
            var response = `Created normal user ${USERNAME}, default individual warehouse ${USERNAME} and set default role to ${DEFAULT_ROLE}.`;
        } else {
            var response = `Created normal user ${USERNAME}, default individual warehouse ${USERNAME}, set default role to ${DEFAULT_ROLE}, and granted additional role(s) ${ADDITIONAL_ROLES.join(' + ')}.`;
        }

        snowflake.execute({sqlText: "use role identifier(:1)", binds: [current_role]});
        return response;
    $$;

    grant usage on procedure ADMIN.UTILS.CREATE_NORMAL_USER(string, string, array, string) to role USERADMIN;


/* As above without the additional_roles argument. */
/* This procedure is typically used for creating human users who can share a role with others in their team (e.g. ANALYTICS_DEVELOPER). */
create or replace procedure ADMIN.UTILS.CREATE_NORMAL_USER(USERNAME string, DEFAULT_ROLE string, DESCRIPTION string)
    returns string
    language javascript
    comment = 'Creates a normal user with a default, existing role passed as argument, creates a default warehouse for the user and sets a description.'
    execute as caller
    as $$
        var result = snowflake.execute({sqlText: "call ADMIN.UTILS.CREATE_NORMAL_USER(:1, :2, array_construct(), :3)", binds: [USERNAME, DEFAULT_ROLE, DESCRIPTION]});
        result.next()
        return result.getColumnValue(1)
    $$;

    grant usage on procedure ADMIN.UTILS.CREATE_NORMAL_USER(string, string, string) to role USERADMIN;


/* As above but creates a role for the user. */
/* This procedure is typically used for creating a non-human user (e.g. data loader or BI user), which has a unique set of permission requirements and therefore warrants its own role. */
create or replace procedure ADMIN.UTILS.CREATE_NORMAL_USER(USERNAME string, DESCRIPTION string)
    returns string
    language javascript
    comment = 'Creates a normal user, default role, default warehouse and sets a description.'
    execute as caller
    as $$
        var result = snowflake.execute({sqlText: "call ADMIN.UTILS.CREATE_ROLE(:1, :2)", binds: [USERNAME, `Functional role for user ${USERNAME}`]});
        var result = snowflake.execute({sqlText: "call ADMIN.UTILS.CREATE_NORMAL_USER(:1, :2, array_construct(), :3)", binds: [USERNAME, USERNAME, DESCRIPTION]});
        result.next()
        return `Created normal user ${USERNAME}, default role ${USERNAME} and default warehouse ${USERNAME}.`
    $$;

    grant usage on procedure ADMIN.UTILS.CREATE_NORMAL_USER(string, string) to role USERADMIN;


create or replace procedure ADMIN.UTILS.CREATE_ADMIN_USER(USERNAME string, ADMIN_ROLE string, DESCRIPTION string)
    returns string
    language javascript
    comment = 'Creates a user granted the specified admin role, and an individual warehouse for the user.'
    execute as caller
    as $$
        snowflake.execute({sqlText: "use role ACCOUNTADMIN"});

        var admin_role_uppercase = ADMIN_ROLE.toUpperCase();
        snowflake.execute({sqlText: "create user if not exists identifier(:1)", binds: [USERNAME]});
        snowflake.execute({sqlText: "alter user identifier(:1) set login_name = :1, comment = :2", binds: [USERNAME, `${admin_role_uppercase}: ${DESCRIPTION}`]});
        snowflake.execute({sqlText: "grant role identifier(:1) to user identifier(:2)", binds: [ADMIN_ROLE, USERNAME]});

        /* Account admins are set to use the SYSADMIN role by default, so they have to manually switch to the top-level ACCOUNTADMIN role only when necessary. */
        var default_role = admin_role_uppercase == 'ACCOUNTADMIN' ? 'SYSADMIN' : ADMIN_ROLE;
        snowflake.execute({sqlText: "alter user identifier(:1) set default_role = :2", binds: [USERNAME, default_role]});

        /* We're not creating individual roles for admin users, so we grant warehouse usage to all admin roles they might use. */
        snowflake.execute({sqlText: "call ADMIN.UTILS.CREATE_WAREHOUSE(:1, :2, array_construct('SYSADMIN', 'SECURITYADMIN', 'USERADMIN'))", binds: [USERNAME, `For user ${USERNAME}.`]});
        snowflake.execute({sqlText: "alter user identifier(:1) set default_warehouse = :2", binds: [USERNAME, USERNAME]});

        return `Created admin user ${USERNAME} granted role ${ADMIN_ROLE}, and individual warehouse ${USERNAME}.`;
    $$;

    /* There is intentionally no grant on the CREATE_ADMIN_USER procedure, as only account admins should be allowed to run it. */
