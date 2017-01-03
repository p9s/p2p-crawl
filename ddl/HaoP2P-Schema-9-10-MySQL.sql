-- Convert schema '/Users/mc/codes/perl_code/haop2p/script/../ddl/HaoP2P-Schema-9-MySQL.sql' to 'HaoP2P::Schema v10':;

BEGIN;

ALTER TABLE news CHANGE COLUMN tags tags text NOT NULL;


COMMIT;

