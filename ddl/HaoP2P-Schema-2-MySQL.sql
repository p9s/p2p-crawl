-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Tue Sep 13 15:56:02 2016
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
  PRIMARY KEY (id),
  UNIQUE unique_name (name)
);

SET foreign_key_checks=1;

