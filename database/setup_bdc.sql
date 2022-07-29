/*** Network Policies ***/
use role SECURITYADMIN;

create or replace network policy BROOKLYN_DATA_CO
    allowed_ip_list = (
        /* Primary VPN (vpn.brooklyndata.co) */
        '3.15.92.136'
        /* Europe/Middle East/Africa VPN (vpn.eu-west-2.brooklyndata.co) */
        , '18.135.177.95'
        /* Asia-Pacific VPN (vpn.ap-southeast-2.brooklyndata.co) */
        , '54.253.114.16'
        /* US-only VPN (vpn.us-gov-east-1.brooklyndata.co) */
        , '18.252.47.9'
    );


/*** Admin Users ***/
use role ACCOUNTADMIN;

call ADMIN.UTILS.CREATE_ADMIN_USER('BDC_ADMIN', 'ACCOUNTADMIN', 'Brooklyn Data Co.');
    alter user BDC_ADMIN set
        network_policy = 'BROOKLYN_DATA_CO'
        email          = 'david.leal@brooklyndata.co'
        display_name   = 'SC::BDC_ADMIN';


/*** Analytics Developer Users ***/
use role USERADMIN;

call ADMIN.UTILS.CREATE_NORMAL_USER('BDC', 'ANALYTICS_DEVELOPER', 'Brooklyn Data Co.');
    alter user BDC set
        network_policy = 'BROOKLYN_DATA_CO'
        display_name   = 'SC::BDC';
