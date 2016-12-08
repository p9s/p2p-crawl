-- Convert schema '/Users/cheungmc/codes/perl_code/haop2p/script/../ddl/HaoP2P-Schema-5-MySQL.sql' to 'HaoP2P::Schema v6':;

BEGIN;

ALTER TABLE p2p_site ADD COLUMN aff_url varchar(255) NULL;


COMMIT;

