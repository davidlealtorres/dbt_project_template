# Snowflake setup

We use these scripts to [set up our clients' Snowflake accounts in a standardized way](https://brooklyndata.atlassian.net/wiki/spaces/BI/pages/159875209/Provisioning+Snowflake#Set-up-users,-roles,-databases,-etc.).


## Instructions

1. Run the `admin_utils.sql` script in the client's Snowflake account.
2. The `setup.sql` will be pre-populated with the first client user. Edit the `setup.sql` script to add statements to create additional client users if necessary, keeping the statements organized in alphabetical order by username.
3. Run the `setup.sql` script in the client's Snowflake account.
4. Edit the `setup_bdc.sql` script to add statements to create additional BDC users if necessary, keeping the statements organized in alphabetical order by username.
5. If an initial Snowflake account admin user was created for us, rename it to match one of our account admin users from the `setup_bdc.sql` script (including its `LOGIN_NAME`, `FIRST_NAME`, `LAST_NAME`, and `EMAIL` properties).
6. Run the `setup_bdc.sql` script in the client's Snowflake account.
7. Set passwords for all users and save the credentials in a password vault or distribute the credentials as necessary.
    - For users that are for people, enable the option to force them to change their password the first time they log in: `alter user USER set password = '<REDACTED>' must_change_password = true;`
8. All BDC admin users must have a network policy.
9. Have all account admin users verify their email address and enable all notifications in the Snowflake web console's preferences. You can verify that they have logged in by running `show users;` and seeing if they have a `last_success_login` that isn't null.
10. Drop any previously existing databases and warehouses that aren't needed (e.g. `DEMO_DB` database, `COMPUTE_WH` warehouse).
11. Delete this file.
