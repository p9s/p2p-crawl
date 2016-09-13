-- Convert schema '/Users/cheungmc/codes/perl_code/haop2p/script/../ddl/HaoP2P-Schema-3-MySQL.sql' to 'HaoP2P::Schema v4':;

BEGIN;

SET foreign_key_checks=0;

CREATE TABLE `product` (
  `id` integer NOT NULL auto_increment,
  `p2p_site_id` integer NOT NULL,
  `title` varchar(255) NULL,
  `uniq_id` varchar(255) NOT NULL,
  `url` varchar(255) NOT NULL,
  `tags` varchar(255) NOT NULL,
  `progress` varchar(32) NULL,
  `properties` text NULL,
  `status` varchar(16) NOT NULL DEFAULT 'on',
  `created_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` datetime NULL,
  PRIMARY KEY (`id`),
  UNIQUE `p2p_site_id_uniq_id` (`p2p_site_id`, `uniq_id`)
);

SET foreign_key_checks=1;


COMMIT;

