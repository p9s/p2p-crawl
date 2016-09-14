-- Convert schema '/Users/cheungmc/codes/perl_code/haop2p/script/../ddl/HaoP2P-Schema-4-MySQL.sql' to 'HaoP2P::Schema v5':;

BEGIN;

ALTER TABLE p2p_site ENGINE=InnoDB;

ALTER TABLE product ADD COLUMN interest varchar(32) NULL,
                    ADD COLUMN days integer NULL,
                    ADD COLUMN pay_method varchar(255) NULL,
                    ADD COLUMN min_amount integer NULL,
                    ADD INDEX product_idx_p2p_site_id (p2p_site_id),
                    ADD CONSTRAINT product_fk_p2p_site_id FOREIGN KEY (p2p_site_id) REFERENCES p2p_site (id) ON DELETE CASCADE ON UPDATE CASCADE,
                    ENGINE=InnoDB;


COMMIT;

