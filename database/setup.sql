/*** Overview ***/
/*
Network policies:
  - Separate network policies for each organization that will be accessing the Snowflake account.
  - Network policies are assigned directly to users as appropriate.

Warehouses:
  - Each user gets their own dedicated warehouse set as their default warehouse, so that no user should ever be blocked having to wait for other users' queries to finish.
  - All warehouses are initialized as X-Small (single server), and it's expected that warehouses will later be resized as needed.
  - All warehouses are set to auto-suspend after one minute of inactivity.

Databases:
  - Dedicated databases for each loader service to create schemas in and load data into.
  - `ANALYTICS` database for production analytics models.
  - `ANALYTICS_DEV` database for analytics developers to create schemas in and use as their dbt target.

Object access roles:
  - Roles for read-only access and write access to each database and certain reporting schemas in the `ANALYTICS` database.
  - No other roles are granted privileges on databases or the objects within them, so that privileges on such database objects should never need to be changed after they're created.

Functional roles:
  - `ANALYTICS_SOURCES_READER` can read analytics data sources.
  - `ANALYTICS_DEVELOPER` can read analytics data sources and write to the `ANALYTICS_DEV` database.
  - `ANALYTICS_TRANSFORMER` can read analytics data sources and write to the `ANALYTICS` database.
  - `ANALYTICS_REPORTER` can read certain reporting schemas in the `ANALYTICS` database.
  - `ANALYTICS_REPORT_DEVELOPER` can read the `ANALYTICS` and `ANALYTICS_DEV` databases.

Admin users:
  - Admin users for a limited number of staff, intended to only be used for administrative purposes.
  - All admins should have a network policy or use multi-factor authentication.
  - Account admins are set to use the `SYSADMIN` role by default, so they have to manually switch to the top-level `ACCOUNTADMIN` role only when necessary.
  - We recommend all account admins have an email address set and enable email notifications in the Snowflake web console's preferences (e.g. to receive Snowflake invoices).

Analytics developer users:
  - Analytics developers are granted the `ANALYTICS_DEVELOPER` role.

Service users:
  - Users for each loader service, which are granted the write access role for their dedicated database.
  - User for a dbt service, which is granted the `ANALYTICS_TRANSFORMER` role.
  - Users for a reporting service:
    - Main user for reporting using transformed analytics data, which is granted the `ANALYTICS_REPORTER` role.
    - "Dev" user for doing report development using dev/staging analytics data, which is granted the `ANALYTICS_REPORT_DEVELOPER` role.
    - "Raw" user for optionally reporting using raw analytics source data, which is granted the `ANALYTICS_SOURCES_READER` role.
*/


/*** Account ***/
use role ACCOUNTADMIN;

/* Set the timezone (Snowflake's default is 'America/Los_Angeles'). */
alter account set timezone = 'America/New_York';

/* Set the limit for how long queries are allowed to run (Snowflake's default is 2 days!). */
alter account set statement_timeout_in_seconds = 7200;  /* 2 hours */

/* Allow everyone to monitor credits and storage usage. */
grant monitor usage on account to role PUBLIC;


/*** Network Policies ***/
use role SECURITYADMIN;

/* Recommendation:  All users should have a network policy or use multi-factor authentication. */

create or replace network policy SUPERCLIENT
    allowed_ip_list = ('0.0.0.0/0');

create or replace network policy FIVETRAN
    comment = 'https://fivetran.com/docs/getting-started/ips'
    allowed_ip_list = (
        /* US regions */
        '35.227.135.0/29'
        , '35.234.176.144/29'
        , '52.0.2.4/32'
        , '35.80.36.104/29'
        , '3.239.194.48/29'
        /* EU regions */
        , '35.235.32.144/29'
        , '35.205.2.0/29'
        , '3.67.81.32/29'
        , '3.251.214.192/29'
        /* Australia regions */
        , '35.244.75.240/29'
        /* UK regions */
        , '35.246.19.240/29'
        /* Canada regions */
        , '35.203.91.200/29'
        /* Singapore regions */
        , '34.87.42.80/29'
    );

create or replace network policy DBT_CLOUD
    comment = 'https://docs.getdbt.com/docs/dbt-cloud/cloud-configuring-dbt-cloud/connecting-your-database/'
    allowed_ip_list = ('52.22.161.231', '52.45.144.63', '54.81.134.249');

create or replace network policy LOOKER
    allowed_ip_list = ('0.0.0.0/0');


/*** Warehouses ***/
use role SYSADMIN;

/* In the user sections the CREATE_ADMIN_USER and CREATE_NORMAL_USER procedure calls automatically create warehouses for those users. */

call ADMIN.UTILS.CREATE_WAREHOUSE('ADMIN', 'For admins.', array_construct('SYSADMIN', 'SECURITYADMIN', 'USERADMIN'));

use warehouse ADMIN;


/*** Databases ***/
use role SYSADMIN;

call ADMIN.UTILS.CREATE_DATABASE('FIVETRAN', 'For Fivetran to create schemas in and load data into.');
    drop schema if exists FIVETRAN.PUBLIC;

call ADMIN.UTILS.CREATE_DATABASE('ANALYTICS_DEV', 'For analytics developers to create schemas in and use as their dbt target.');
    drop schema if exists ANALYTICS_DEV.PUBLIC;

call ADMIN.UTILS.CREATE_DATABASE('ANALYTICS', 'Production analytics models.');
    drop schema if exists ANALYTICS.PUBLIC;
    call ADMIN.UTILS.CREATE_DATABASE_SCHEMA('ANALYTICS', 'CORE', 'Core analytics models.');
    call ADMIN.UTILS.CREATE_DATABASE_SCHEMA('ANALYTICS', 'UTILS', 'Utility analytics models.');


/*** Object Access Roles ***/
use role USERADMIN;

/* In the databases section the CREATE_DATABASE and CREATE_DATABASE_SCHEMA procedure calls automatically create certain object access roles for those databases and schemas. */

call ADMIN.UTILS.CREATE_ROLE('SNOWFLAKE_DB_READER', 'Read-only access to entire SNOWFLAKE shared database.');


/*** Functional Roles ***/
use role USERADMIN;

call ADMIN.UTILS.CREATE_ROLE('ANALYTICS_SOURCES_READER', 'Read access to analytics data sources.');
    grant role FIVETRAN_DB_READER to role ANALYTICS_SOURCES_READER;

call ADMIN.UTILS.CREATE_ROLE('ANALYTICS_DEVELOPER', 'Read access to analytics data sources, ANALYTICS_DEV database, ANALYTICS database, and SNOWFLAKE shared database.  Can create schemas in ANALYTICS_DEV database.  Can monitor warehouses for analytics loading, transforming, and reporting.');
    grant role SNOWFLAKE_DB_READER      to role ANALYTICS_DEVELOPER;
    grant role ANALYTICS_SOURCES_READER to role ANALYTICS_DEVELOPER;
    grant role ANALYTICS_DEV_DB_WRITER  to role ANALYTICS_DEVELOPER;
    grant role ANALYTICS_DB_READER      to role ANALYTICS_DEVELOPER;

call ADMIN.UTILS.CREATE_ROLE('ANALYTICS_TRANSFORMER', 'Read access to analytics data sources.  Write access to ANALYTICS database.');
    grant role ANALYTICS_SOURCES_READER to role ANALYTICS_TRANSFORMER;
    grant role ANALYTICS_DB_WRITER      to role ANALYTICS_TRANSFORMER;

call ADMIN.UTILS.CREATE_ROLE('ANALYTICS_REPORTER', 'Read access to reporting schemas in ANALYTICS database.');
    grant role ANALYTICS_CORE_SCHEMA_READER  to role ANALYTICS_REPORTER;
    grant role ANALYTICS_UTILS_SCHEMA_READER to role ANALYTICS_REPORTER;

call ADMIN.UTILS.CREATE_ROLE('ANALYTICS_REPORT_DEVELOPER', 'Read access to ANALYTICS database and ANALYTICS_DEV database.');
    grant role ANALYTICS_REPORTER      to role ANALYTICS_REPORT_DEVELOPER;
    grant role ANALYTICS_DB_READER     to role ANALYTICS_REPORT_DEVELOPER;
    grant role ANALYTICS_DEV_DB_READER to role ANALYTICS_REPORT_DEVELOPER;

call ADMIN.UTILS.CREATE_ROLE('FIVETRAN', 'Fivetran');
    grant role FIVETRAN_DB_WRITER to role FIVETRAN;


/*** Admin Users ***/
use role ACCOUNTADMIN;

/* Recommendations:
    - All admins should have a network policy or use multi-factor authentication.
    - Set email addresses for account admins to minimize the possibility of losing access to the account,
      and to allow for email notifications (e.g. Snowflake invoices).
        - The email address must be verified in the Snowflake web console's preferences.
        - After verification, email notifications can be enabled in the Snowflake web console's preferences.
    - Limit the number of account admins, but have at least two.
*/

call ADMIN.UTILS.CREATE_ADMIN_USER('DAVID_ADMIN', 'ACCOUNTADMIN', 'David Leal @ SuperClient');
    alter user DAVID_ADMIN set
        network_policy = 'SUPERCLIENT'
        email          = 'david.leal@brooklyndata.co';


/*** Analytics Developer Users ***/
use role USERADMIN;

call ADMIN.UTILS.CREATE_NORMAL_USER('DAVIDDEVELOPER', 'ANALYTICS_DEVELOPER', 'David Leal Developer @ SuperClient');
    alter user DAVIDDEVELOPER set
        network_policy = 'SUPERCLIENT';


/*** Service Users ***/
use role USERADMIN;

call ADMIN.UTILS.CREATE_NORMAL_USER('FIVETRAN', 'FIVETRAN', 'Fivetran');
    alter user FIVETRAN set
        network_policy    = 'FIVETRAN'
        default_namespace = 'FIVETRAN';

call ADMIN.UTILS.CREATE_NORMAL_USER('DBT_CLOUD', 'ANALYTICS_TRANSFORMER', array_construct('ANALYTICS_DEVELOPER'), 'dbt Cloud');
    alter user DBT_CLOUD set
        network_policy = 'DBT_CLOUD';

call ADMIN.UTILS.CREATE_NORMAL_USER('LOOKER', 'ANALYTICS_REPORTER', 'Looker');
    alter user LOOKER set
        network_policy    = 'LOOKER'
        default_namespace = 'ANALYTICS';

call ADMIN.UTILS.CREATE_NORMAL_USER('LOOKER_DEV', 'ANALYTICS_REPORT_DEVELOPER', 'For Looker report development using dev/staging analytics data.');
    alter user LOOKER_DEV set
        network_policy = 'LOOKER';

call ADMIN.UTILS.CREATE_NORMAL_USER('LOOKER_RAW', 'ANALYTICS_SOURCES_READER', 'For Looker reporting using raw analytics source data.');
    alter user LOOKER_RAW set
        network_policy = 'LOOKER';


/*** Warehouse Permissions ***/
use role SECURITYADMIN;

grant monitor on warehouse FIVETRAN to role ANALYTICS_DEVELOPER;

grant monitor on warehouse DBT_CLOUD to role ANALYTICS_DEVELOPER;

grant monitor on warehouse LOOKER     to role ANALYTICS_DEVELOPER;
grant monitor on warehouse LOOKER_DEV to role ANALYTICS_DEVELOPER;
grant monitor on warehouse LOOKER_RAW to role ANALYTICS_DEVELOPER;


/*** Shared Database Permissions ***/
use role ACCOUNTADMIN;

/* SNOWFLAKE */
grant imported privileges on database SNOWFLAKE to role SNOWFLAKE_DB_READER;
