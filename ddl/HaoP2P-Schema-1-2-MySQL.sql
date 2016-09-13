-- Convert schema '/Users/cheungmc/codes/perl_code/haop2p/script/../ddl/HaoP2P-Schema-1-MySQL.sql' to 'HaoP2P::Schema v2':;

BEGIN;

SET foreign_key_checks=0;

CREATE TABLE `p2p_site` (
  `id` integer NOT NULL auto_increment,
  `name` varchar(255) NOT NULL,
  `url` varchar(255) NOT NULL,
  `enabled` integer NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE `unique_name` (`name`)
);

SET foreign_key_checks=1;


COMMIT;

