-- Table: public.address

-- DROP TABLE public.address;

CREATE TABLE public.address
(
    address_id integer NOT NULL DEFAULT nextval('address_address_id_seq'::regclass),
    address character varying(50) COLLATE pg_catalog."default" NOT NULL,
    CONSTRAINT address_pkey PRIMARY KEY (address_id)
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;

-- Index: address_address_idx

-- DROP INDEX public.address_address_idx;

CREATE INDEX address_address_idx
    ON public.address USING hash
    (address COLLATE pg_catalog."default" varchar_ops)
    TABLESPACE pg_default;



-- Table: public.message

-- DROP TABLE public.message;

CREATE TABLE public.message
(
    message_id integer NOT NULL DEFAULT nextval('message_message_id_seq'::regclass),
    from_address integer NOT NULL,
    subject character varying(500) COLLATE pg_catalog."default" NOT NULL,
    body character varying(8000) COLLATE pg_catalog."default",
    CONSTRAINT message_pkey PRIMARY KEY (message_id),
    CONSTRAINT "from_address_id_FK" FOREIGN KEY (from_address)
        REFERENCES public.address (address_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;



-- Table: public.message_recipient

-- DROP TABLE public.message_recipient;

CREATE TABLE public.message_recipient
(
    message_id integer NOT NULL,
    address_id integer NOT NULL,
    CONSTRAINT message_recipient_pkey PRIMARY KEY (message_id, address_id),
    CONSTRAINT "message_recipient_address_id_FK" FOREIGN KEY (address_id)
        REFERENCES public.address (address_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION,
    CONSTRAINT "message_recipient_message_id_FK" FOREIGN KEY (message_id)
        REFERENCES public.message (message_id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE NO ACTION
)
WITH (
    OIDS = FALSE
)
TABLESPACE pg_default;



CREATE OR REPLACE FUNCTION truncate_tables(username IN VARCHAR) RETURNS void AS $$
DECLARE
    statements CURSOR FOR
        SELECT tablename FROM pg_tables
        WHERE tableowner = username AND schemaname = 'public';
BEGIN
    FOR stmt IN statements LOOP
        EXECUTE 'TRUNCATE TABLE ' || quote_ident(stmt.tablename) || ' CASCADE;';
    END LOOP;
END;
$$ LANGUAGE plpgsql;