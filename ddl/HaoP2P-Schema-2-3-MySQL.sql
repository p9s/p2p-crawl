-- Convert schema '/Users/cheungmc/codes/perl_code/haop2p/script/../ddl/HaoP2P-Schema-2-MySQL.sql' to 'HaoP2P::Schema v3':;

BEGIN;

ALTER TABLE p2p_site ADD COLUMN site_index varchar(32) NOT NULL DEFAULT '',
                     ADD INDEX p2p_site_site_index (site_index);


COMMIT;

