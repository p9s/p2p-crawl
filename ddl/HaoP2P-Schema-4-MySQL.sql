-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Tue Sep 13 23:49:24 2016
-- 
SET foreign_key_checks=0;

DROP TABLE IF EXISTS p2p_site;

--
-- Table: p2p_site
--
CREATE TABLE p2p_site (
  id integer NOT NULL auto_increment,
  name varchar(255) NOT NULL,
  url varchar(255) NOT NULL,
  enabled integer NOT NULL DEFAULT 0,
  created_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  site_index varchar(32) NOT NULL DEFAULT '',
  INDEX p2p_site_site_index (site_index),
  PRIMARY KEY (id),
  UNIQUE unique_name (name)
);

DROP TABLE IF EXISTS product;

--
-- Table: product
--
CREATE TABLE product (
  id integer NOT NULL auto_increment,
  p2p_site_id integer NOT NULL,
  title varchar(255) NULL,
  uniq_id varchar(255) NOT NULL,
  url varchar(255) NOT NULL,
  tags varchar(255) NOT NULL,
  progress varchar(32) NULL,
  properties text NULL,
  status varchar(16) NOT NULL DEFAULT 'on',
  created_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at datetime NULL,
  PRIMARY KEY (id),
  UNIQUE p2p_site_id_uniq_id (p2p_site_id, uniq_id)
);

SET foreign_key_checks=1;

