-- 
-- Created by SQL::Translator::Producer::MySQL
-- Created on Thu Dec 29 12:43:38 2016
-- 
SET foreign_key_checks=0;

DROP TABLE IF EXISTS news;

--
-- Table: news
--
CREATE TABLE news (
  id integer NOT NULL auto_increment,
  title varchar(255) NULL,
  uniq_id varchar(255) NOT NULL,
  url varchar(255) NOT NULL,
  tags varchar(255) NOT NULL,
  descript text NOT NULL,
  content text NOT NULL,
  is_public integer NOT NULL DEFAULT 0,
  created_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id)
);

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
  aff_url varchar(255) NULL,
  about text NOT NULL,
  description varchar(255) NOT NULL,
  keywords varchar(254) NOT NULL,
  INDEX p2p_site_site_index (site_index),
  PRIMARY KEY (id),
  UNIQUE unique_name (name)
) ENGINE=InnoDB;

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
  interest varchar(32) NULL,
  days integer NULL,
  pay_method varchar(255) NULL,
  min_amount integer NULL,
  properties text NULL,
  status varchar(16) NOT NULL DEFAULT 'on',
  created_at datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at datetime NULL,
  INDEX product_idx_p2p_site_id (p2p_site_id),
  PRIMARY KEY (id),
  UNIQUE p2p_site_id_uniq_id (p2p_site_id, uniq_id),
  CONSTRAINT product_fk_p2p_site_id FOREIGN KEY (p2p_site_id) REFERENCES p2p_site (id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

SET foreign_key_checks=1;

