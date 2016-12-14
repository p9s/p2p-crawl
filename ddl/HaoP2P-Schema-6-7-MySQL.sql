-- Convert schema '/Users/mc/codes/perl_code/haop2p/script/../ddl/HaoP2P-Schema-6-MySQL.sql' to 'HaoP2P::Schema v7':;

BEGIN;

ALTER TABLE p2p_site ADD COLUMN about text NOT NULL;


COMMIT;

