-- Convert schema '/Users/mc/codes/perl_code/haop2p/script/../ddl/HaoP2P-Schema-7-MySQL.sql' to 'HaoP2P::Schema v8':;

BEGIN;

ALTER TABLE p2p_site ADD COLUMN description varchar(255) NOT NULL,
                     ADD COLUMN keywords varchar(254) NOT NULL;


COMMIT;

