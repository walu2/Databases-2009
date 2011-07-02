--
-- PostgreSQL database dump
--

-- Started on 2009-06-23 09:06:06 CEST

SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

--
-- TOC entry 318 (class 2612 OID 17731)
-- Name: plpgsql; Type: PROCEDURAL LANGUAGE; Schema: -; Owner: postgres
--

CREATE PROCEDURAL LANGUAGE plpgsql;


ALTER PROCEDURAL LANGUAGE plpgsql OWNER TO postgres;

SET search_path = public, pg_catalog;

--
-- TOC entry 304 (class 1247 OID 17717)
-- Dependencies: 3 1496
-- Name: para_os_wyd; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE para_os_wyd AS (
	osoba_id integer,
	wydarzenie_id integer
);


ALTER TYPE public.para_os_wyd OWNER TO postgres;

--
-- TOC entry 306 (class 1247 OID 17720)
-- Dependencies: 3 1497
-- Name: para_typ_prior; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE para_typ_prior AS (
	typ_wyd integer,
	prior_wyd integer
);


ALTER TYPE public.para_typ_prior OWNER TO postgres;

--
-- TOC entry 20 (class 1255 OID 17784)
-- Dependencies: 318 3
-- Name: aktualizuj_laczna_wartosc_spadku(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION aktualizuj_laczna_wartosc_spadku() RETURNS trigger
    AS $$  
DECLARE
 roznica bigint;
 
BEGIN
 IF(TG_OP = 'UPDATE') THEN
  roznica := NEW.wysokosc - OLD.wysokosc;
  UPDATE TESTAMENT SET wysokosc_spadku = wysokosc_spadku - roznica WHERE id = NEW.id_testamentu;
  RETURN NEW;
 ELSEIF(TG_OP = 'INSERT') THEN 
  UPDATE TESTAMENT SET wysokosc_spadku = wysokosc_spadku + NEW.wysokosc WHERE id = NEW.id_testamentu;
  RETURN NEW;
 ELSE -- operacja delete
  UPDATE TESTAMENT SET wysokosc_spadku = wysokosc_spadku - OLD.wysokosc WHERE id = OLD.id_testamentu;
  RETURN OLD;
 END IF;
END;
$$
    LANGUAGE plpgsql;


ALTER FUNCTION public.aktualizuj_laczna_wartosc_spadku() OWNER TO postgres;

--
-- TOC entry 25 (class 1255 OID 17782)
-- Dependencies: 318 3
-- Name: aktualizuj_wiek_ludzi(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION aktualizuj_wiek_ludzi() RETURNS void
    AS $$
DECLARE 
cur CURSOR FOR SELECT * FROM DANE_OSOBOWE WHERE data_smierci IS NULL;
pom DANE_OSOBOWE%ROWTYPE;

BEGIN
  OPEN cur;
  
  LOOP 
   FETCH cur INTO pom;

   EXIT WHEN NOT FOUND;
  
   UPDATE DANE_OSOBOWE SET aktualny_wiek = (date_part('year', age(current_timestamp, pom.data_urodzenia)))
   WHERE DANE_OSOBOWE.id_osoba = pom.id_osoba;    
   
  END LOOP;
   
  CLOSE cur;
  
END;
$$
    LANGUAGE plpgsql;


ALTER FUNCTION public.aktualizuj_wiek_ludzi() OWNER TO postgres;

--
-- TOC entry 23 (class 1255 OID 17780)
-- Dependencies: 3 318
-- Name: czy_nadal_zyje(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION czy_nadal_zyje(id_uzytkownika integer) RETURNS boolean
    AS $$
BEGIN
 IF(SELECT data_smierci FROM DANE_OSOBOWE WHERE id_osoba = id_uzytkownika) IS NULL THEN RETURN TRUE;
  RETURN FALSE;
 END IF;
 
END;$$
    LANGUAGE plpgsql;


ALTER FUNCTION public.czy_nadal_zyje(id_uzytkownika integer) OWNER TO postgres;

--
-- TOC entry 21 (class 1255 OID 17777)
-- Dependencies: 3 318
-- Name: kasuj_dane_niezyjacego(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION kasuj_dane_niezyjacego() RETURNS trigger
    AS $$
BEGIN
  IF (NEW.data_smierci IS NOT NULL) THEN -- ktos wpisal jakas date
    NEW.aktualny_wiek := NULL;
    NEW.aktualny_adres := NULL; 
  END IF;
  RETURN NEW;
END;
$$
    LANGUAGE plpgsql;


ALTER FUNCTION public.kasuj_dane_niezyjacego() OWNER TO postgres;

--
-- TOC entry 22 (class 1255 OID 17778)
-- Dependencies: 3 318
-- Name: okresl_plec(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION okresl_plec(id_uzytkownika integer) RETURNS character
    AS $$
DECLARE
 cyfra_plci integer;
 literka character(1);
 
BEGIN
   cyfra_plci := (SELECT substring(PESEL, 10, 1)
                  FROM OSOBA
				  WHERE id = id_uzytkownika)::integer;
  
   EXIT WHEN NOT FOUND;
	 
   IF (cyfra_plci IS NOT NULL) THEN
     IF (cyfra_plci % 2) = 1 THEN RETURN 'm'; --  w przypadku mezczyzn daje zawsze parzysta cyferke
 	  ELSE RETURN 'k';
	 END IF;
   ELSE  -- uzytkownik nie posiada peselu
     literka := (SELECT substring(imie, LENGTH(imie)-1, 1)
                 FROM OSOBA
				 WHERE id = id_uzytkownika);
					
     IF(literka == 'a' )THEN RETURN 'k';
	                             ELSE RETURN 'm';
	 END IF;  
   END IF;
END;$$
    LANGUAGE plpgsql;


ALTER FUNCTION public.okresl_plec(id_uzytkownika integer) OWNER TO postgres;

--
-- TOC entry 24 (class 1255 OID 17781)
-- Dependencies: 318 3
-- Name: zlicz_osoby_obecne(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION zlicz_osoby_obecne(id_wyd integer) RETURNS integer
    AS $$
DECLARE
 wynik INT;
BEGIN
 wynik := (SELECT count(DISTINCT id_osoby) -- gdyby ktos wystapil kilka razy w roznym charakterze np
           FROM OSOBA_WYDARZENIE
		   WHERE id_wydarzenia = id_wyd);
		   
 RETURN wynik;
END;$$
    LANGUAGE plpgsql;


ALTER FUNCTION public.zlicz_osoby_obecne(id_wyd integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- TOC entry 1502 (class 1259 OID 17796)
-- Dependencies: 1779 1780 1781 3
-- Name: dane_osobowe; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE dane_osobowe (
    osoba_id integer NOT NULL,
    miejsce_urodzenia character varying(30),
    data_urodzenia date,
    plec character(1) DEFAULT 'm'::bpchar,
    aktualny_wiek integer,
    aktualny_adres character varying(30),
    powod_zgonu character varying(255) DEFAULT NULL::character varying,
    data_smierci date,
    CONSTRAINT plec_stale CHECK ((plec = ANY (ARRAY['k'::bpchar, 'm'::bpchar])))
);


ALTER TABLE public.dane_osobowe OWNER TO postgres;

--
-- TOC entry 1499 (class 1259 OID 17748)
-- Dependencies: 1778 3
-- Name: dokumenty; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE dokumenty (
    id integer DEFAULT nextval(('DOKUMENTY_id_seq'::text)::regclass) NOT NULL,
    id_wydarzenia integer NOT NULL,
    opis text,
    data_zrobienia timestamp without time zone,
    sciezka_do_zdjecia character varying(30)
);


ALTER TABLE public.dokumenty OWNER TO postgres;

--
-- TOC entry 1493 (class 1259 OID 17683)
-- Dependencies: 3
-- Name: dokumenty_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE dokumenty_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.dokumenty_id_seq OWNER TO postgres;

--
-- TOC entry 1490 (class 1259 OID 17623)
-- Dependencies: 1769 1770 1771 3
-- Name: osoba; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE osoba (
    id integer DEFAULT nextval(('OSOBA_id_seq'::text)::regclass) NOT NULL,
    imie character varying(30) NOT NULL,
    nazwisko character varying(30) NOT NULL,
    pesel character varying(11),
    id_ojca integer,
    id_matki integer,
    testament boolean DEFAULT false NOT NULL,
    CONSTRAINT dlugosc_peselu CHECK (((pesel IS NULL) OR (length((pesel)::text) = 11)))
);


ALTER TABLE public.osoba OWNER TO postgres;

--
-- TOC entry 1501 (class 1259 OID 17794)
-- Dependencies: 3
-- Name: osoba_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE osoba_id_seq
    INCREMENT BY 1
    MAXVALUE 2147483647
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.osoba_id_seq OWNER TO postgres;

--
-- TOC entry 1498 (class 1259 OID 17732)
-- Dependencies: 1777 3
-- Name: osoba_wydarzenie; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE osoba_wydarzenie (
    id_osoby integer NOT NULL,
    id_wydarzenia integer NOT NULL,
    rola_priorytet smallint NOT NULL,
    rola_pelna_nazwa character varying(30),
    CONSTRAINT priorytet_stale CHECK ((rola_priorytet = ANY (ARRAY[0, 1, 2])))
);


ALTER TABLE public.osoba_wydarzenie OWNER TO postgres;

--
-- TOC entry 1494 (class 1259 OID 17685)
-- Dependencies: 1774 1775 1776 3
-- Name: testament; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE testament (
    id integer DEFAULT nextval(('TESTAMENT_id_seq'::text)::regclass) NOT NULL,
    id_osoba integer,
    wykonano boolean DEFAULT false,
    wysokosc_spadku bigint DEFAULT 0 NOT NULL,
    data_wykonania date,
    sciezka_tresc character varying(30)
);


ALTER TABLE public.testament OWNER TO postgres;

--
-- TOC entry 1495 (class 1259 OID 17698)
-- Dependencies: 3
-- Name: testament_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE testament_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.testament_id_seq OWNER TO postgres;

--
-- TOC entry 1500 (class 1259 OID 17762)
-- Dependencies: 3
-- Name: testament_spadek; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE testament_spadek (
    id_testamentu integer NOT NULL,
    id_osoby_otrzymujacej integer NOT NULL,
    wysokosc bigint
);


ALTER TABLE public.testament_spadek OWNER TO postgres;

--
-- TOC entry 1491 (class 1259 OID 17644)
-- Dependencies: 1772 1773 3
-- Name: wydarzenie; Type: TABLE; Schema: public; Owner: postgres; Tablespace: 
--

CREATE TABLE wydarzenie (
    id integer DEFAULT nextval(('WYDARZENIE_id_seq'::text)::regclass) NOT NULL,
    miejsce character varying(30) NOT NULL,
    typ smallint,
    data timestamp without time zone,
    CONSTRAINT typ_stale CHECK ((typ = ANY (ARRAY[0, 1, 2])))
);


ALTER TABLE public.wydarzenie OWNER TO postgres;

--
-- TOC entry 1492 (class 1259 OID 17651)
-- Dependencies: 3
-- Name: wydarzenie_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE wydarzenie_id_seq
    INCREMENT BY 1
    NO MAXVALUE
    NO MINVALUE
    CACHE 1;


ALTER TABLE public.wydarzenie_id_seq OWNER TO postgres;

--
-- TOC entry 1791 (class 2606 OID 17756)
-- Dependencies: 1499 1499
-- Name: dokumenty_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY dokumenty
    ADD CONSTRAINT dokumenty_key PRIMARY KEY (id);


--
-- TOC entry 1783 (class 2606 OID 17630)
-- Dependencies: 1490 1490
-- Name: osoba_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY osoba
    ADD CONSTRAINT osoba_key PRIMARY KEY (id);


--
-- TOC entry 1795 (class 2606 OID 17803)
-- Dependencies: 1502 1502
-- Name: pk_osoba_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY dane_osobowe
    ADD CONSTRAINT pk_osoba_key PRIMARY KEY (osoba_id);


--
-- TOC entry 1787 (class 2606 OID 17692)
-- Dependencies: 1494 1494
-- Name: testament_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY testament
    ADD CONSTRAINT testament_key PRIMARY KEY (id);


--
-- TOC entry 1793 (class 2606 OID 17766)
-- Dependencies: 1500 1500 1500
-- Name: testament_spadek_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY testament_spadek
    ADD CONSTRAINT testament_spadek_key PRIMARY KEY (id_testamentu, id_osoby_otrzymujacej);


--
-- TOC entry 1789 (class 2606 OID 17737)
-- Dependencies: 1498 1498 1498
-- Name: wybor_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY osoba_wydarzenie
    ADD CONSTRAINT wybor_key PRIMARY KEY (id_osoby, id_wydarzenia);


--
-- TOC entry 1785 (class 2606 OID 17650)
-- Dependencies: 1491 1491
-- Name: wydarzenie_key; Type: CONSTRAINT; Schema: public; Owner: postgres; Tablespace: 
--

ALTER TABLE ONLY wydarzenie
    ADD CONSTRAINT wydarzenie_key PRIMARY KEY (id);


--
-- TOC entry 1803 (class 2620 OID 17786)
-- Dependencies: 20 1500
-- Name: akt_wysokosc_spadku; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER akt_wysokosc_spadku
    AFTER INSERT OR DELETE OR UPDATE ON testament_spadek
    FOR EACH ROW
    EXECUTE PROCEDURE aktualizuj_laczna_wartosc_spadku();


--
-- TOC entry 1799 (class 2606 OID 17757)
-- Dependencies: 1491 1499 1784
-- Name: dokumenty_wydarzenie; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY dokumenty
    ADD CONSTRAINT dokumenty_wydarzenie FOREIGN KEY (id_wydarzenia) REFERENCES wydarzenie(id) DEFERRABLE;


--
-- TOC entry 1802 (class 2606 OID 17804)
-- Dependencies: 1502 1782 1490
-- Name: fk_osoba_dane_osoby; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY dane_osobowe
    ADD CONSTRAINT fk_osoba_dane_osoby FOREIGN KEY (osoba_id) REFERENCES osoba(id) DEFERRABLE;


--
-- TOC entry 1797 (class 2606 OID 17738)
-- Dependencies: 1498 1490 1782
-- Name: fk_osoba_wydarzenie_profil; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY osoba_wydarzenie
    ADD CONSTRAINT fk_osoba_wydarzenie_profil FOREIGN KEY (id_osoby) REFERENCES osoba(id) DEFERRABLE;


--
-- TOC entry 1798 (class 2606 OID 17743)
-- Dependencies: 1784 1491 1498
-- Name: fk_osoba_wydarzenie_wydarzenie; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY osoba_wydarzenie
    ADD CONSTRAINT fk_osoba_wydarzenie_wydarzenie FOREIGN KEY (id_wydarzenia) REFERENCES wydarzenie(id) DEFERRABLE;


--
-- TOC entry 1801 (class 2606 OID 17772)
-- Dependencies: 1500 1782 1490
-- Name: spadkobierca_spadek; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY testament_spadek
    ADD CONSTRAINT spadkobierca_spadek FOREIGN KEY (id_osoby_otrzymujacej) REFERENCES osoba(id) DEFERRABLE;


--
-- TOC entry 1796 (class 2606 OID 17693)
-- Dependencies: 1494 1490 1782
-- Name: testament_osoba; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY testament
    ADD CONSTRAINT testament_osoba FOREIGN KEY (id_osoba) REFERENCES osoba(id) DEFERRABLE;


--
-- TOC entry 1800 (class 2606 OID 17767)
-- Dependencies: 1786 1494 1500
-- Name: testament_spadek; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY testament_spadek
    ADD CONSTRAINT testament_spadek FOREIGN KEY (id_testamentu) REFERENCES testament(id) DEFERRABLE;


--
-- TOC entry 1808 (class 0 OID 0)
-- Dependencies: 3
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


-- Completed on 2009-06-23 09:06:06 CEST

--
-- PostgreSQL database dump complete
--

