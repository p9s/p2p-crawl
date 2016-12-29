-- Convert schema '/Users/mc/codes/perl_code/haop2p/script/../ddl/HaoP2P-Schema-8-MySQL.sql' to 'HaoP2P::Schema v9':;

BEGIN;

SET foreign_key_checks=0;

CREATE TABLE `news` (
  `id` integer NOT NULL auto_increment,
  `title` varchar(255) NULL,
  `uniq_id` varchar(255) NOT NULL,
  `url` varchar(255) NOT NULL,
  `tags` varchar(255) NOT NULL,
  `descript` text NOT NULL,
  `content` text NOT NULL,
  `is_public` integer NOT NULL DEFAULT 0,
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
);

SET foreign_key_checks=1;


COMMIT;

