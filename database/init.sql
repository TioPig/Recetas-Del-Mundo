--
-- PostgreSQL database dump
--

\restrict QjOblnNyCu2vWqJS2YdUrsIes5UbuPto4dtHzP6DHxU2yWOgdHuEITQkE7eEBka
-- SELECT pg_catalog.setval('public.carrusel_id_carrusel_seq', 1, false); -- removed (carrusel table eliminated)
-- Dumped from database version 15.14
-- Dumped by pg_dump version 15.14

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


--
-- Name: _pick_image(bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public._pick_image(id_in bigint) RETURNS text
    LANGUAGE sql IMMUTABLE
    AS $$
  SELECT url FROM _pool_imagenes ORDER BY idx LIMIT 1 OFFSET ((id_in - 1) % (SELECT count(*) FROM _pool_imagenes));
$$;


ALTER FUNCTION public._pick_image(id_in bigint) OWNER TO postgres;

--
-- Name: trg_update_fecha_actualizacion(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.trg_update_fecha_actualizacion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.fecha_actualizacion = now();
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_update_fecha_actualizacion() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

-- Carrusel table removed: functionality replaced by dynamic selection
-- The original DDL is kept commented below for reference and possible rollback.
--
-- -- Name: carrusel; Type: TABLE; Schema: public; Owner: postgres
-- --
-- CREATE TABLE public.carrusel (
--     id_carrusel integer NOT NULL,
--     titulo character varying(200) NOT NULL,
--     descripcion text,
--     url_imagen character varying(300),
--     estado smallint DEFAULT 1 NOT NULL,
--     fecha_creacion timestamp without time zone DEFAULT now() NOT NULL,
--     comentario text,
--     id_usr integer
-- );
--
-- ALTER TABLE public.carrusel OWNER TO postgres;
--
-- -- Name: carrusel_id_carrusel_seq; Type: SEQUENCE; Schema: public; Owner: postgres
-- --
-- CREATE SEQUENCE public.carrusel_id_carrusel_seq
--     AS integer
--     START WITH 1
--     INCREMENT BY 1
--     NO MINVALUE
--     NO MAXVALUE
--     CACHE 1;
--
-- ALTER TABLE public.carrusel_id_carrusel_seq OWNER TO postgres;
--
-- -- Name: carrusel_id_carrusel_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
-- --
-- ALTER SEQUENCE public.carrusel_id_carrusel_seq OWNED BY public.carrusel.id_carrusel;


--
-- Name: categoria; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categoria (
    id_cat integer NOT NULL,
    nombre character varying(100) NOT NULL,
    url_imagen character varying(500),
    estado smallint DEFAULT 1 NOT NULL,
    fecha_creacion timestamp(6) without time zone DEFAULT now() NOT NULL,
    comentario character varying(500),
    id_usr integer
);


ALTER TABLE public.categoria OWNER TO postgres;

--
-- Name: categoria_id_cat_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.categoria_id_cat_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.categoria_id_cat_seq OWNER TO postgres;

--
-- Name: categoria_id_cat_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.categoria_id_cat_seq OWNED BY public.categoria.id_cat;


--
-- Name: comentario_id_comentario_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.comentario_id_comentario_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.comentario_id_comentario_seq OWNER TO postgres;

--
-- Name: comentario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comentario (
    id_comentario integer DEFAULT nextval('public.comentario_id_comentario_seq'::regclass) NOT NULL,
    fecha_creacion timestamp(6) without time zone DEFAULT now() NOT NULL,
    id_receta integer NOT NULL,
    texto character varying(255),
    id_usr integer
);


ALTER TABLE public.comentario OWNER TO postgres;

--
-- Name: donacion; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.donacion (
    id_donacion integer NOT NULL,
    amount integer,
    currency character varying(255),
    fecha_actualizacion timestamp(6) without time zone,
    fecha_creacion timestamp(6) without time zone DEFAULT now(),
    id_receta integer,
    id_usr integer,
    status character varying(255),
    stripe_payment_intent character varying(255),
    stripe_session_id character varying(255)
);


ALTER TABLE public.donacion OWNER TO postgres;

--
-- Name: donacion_id_donacion_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.donacion_id_donacion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.donacion_id_donacion_seq OWNER TO postgres;

--
-- Name: donacion_id_donacion_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.donacion_id_donacion_seq OWNED BY public.donacion.id_donacion;


--
-- Name: estrella; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.estrella (
    id_estrella integer NOT NULL,
    fecha_creacion timestamp(6) without time zone DEFAULT now(),
    valor smallint NOT NULL,
    id_receta integer NOT NULL,
    id_usr integer NOT NULL
);


ALTER TABLE public.estrella OWNER TO postgres;

--
-- Name: estrella_id_estrella_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.estrella_id_estrella_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.estrella_id_estrella_seq OWNER TO postgres;

--
-- Name: estrella_id_estrella_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.estrella_id_estrella_seq OWNED BY public.estrella.id_estrella;


--
-- Name: favorito; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.favorito (
    id_fav integer NOT NULL,
    fecha_creacion timestamp(6) without time zone DEFAULT now() NOT NULL,
    id_receta integer NOT NULL,
    id_usr integer NOT NULL
);


ALTER TABLE public.favorito OWNER TO postgres;

--
-- Name: favorito_id_fav_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.favorito_id_fav_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.favorito_id_fav_seq OWNER TO postgres;

--
-- Name: favorito_id_fav_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.favorito_id_fav_seq OWNED BY public.favorito.id_fav;


--
-- Name: ingrediente; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ingrediente (
    id_ingrediente integer NOT NULL,
    nombre character varying(500) NOT NULL,
    id_receta integer NOT NULL
);


ALTER TABLE public.ingrediente OWNER TO postgres;

--
-- Name: ingrediente_new_id_ingrediente_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.ingrediente_new_id_ingrediente_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ingrediente_new_id_ingrediente_seq OWNER TO postgres;

--
-- Name: ingrediente_new_id_ingrediente_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.ingrediente_new_id_ingrediente_seq OWNED BY public.ingrediente.id_ingrediente;


--
-- Name: me_gusta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.me_gusta (
    id_megusta integer NOT NULL,
    fecha_creacion timestamp(6) without time zone DEFAULT now(),
    id_receta integer NOT NULL,
    id_usr integer NOT NULL
);


ALTER TABLE public.me_gusta OWNER TO postgres;

--
-- Name: me_gusta_id_megusta_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.me_gusta_id_megusta_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.me_gusta_id_megusta_seq OWNER TO postgres;

--
-- Name: me_gusta_id_megusta_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.me_gusta_id_megusta_seq OWNED BY public.me_gusta.id_megusta;


--
-- Name: pais; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.pais (
    id_pais integer NOT NULL,
    nombre character varying(100) NOT NULL,
    url_imagen character varying(500),
    estado smallint DEFAULT 1 NOT NULL,
    fecha_creacion timestamp(6) without time zone DEFAULT now() NOT NULL,
    comentario character varying(500),
    id_usr integer
);


ALTER TABLE public.pais OWNER TO postgres;

--
-- Name: pais_id_pais_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.pais_id_pais_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.pais_id_pais_seq OWNER TO postgres;

--
-- Name: pais_id_pais_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.pais_id_pais_seq OWNED BY public.pais.id_pais;


--
-- Name: perfil; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.perfil (
    id_perfil integer NOT NULL,
    nombre character varying(50) NOT NULL
);


ALTER TABLE public.perfil OWNER TO postgres;

--
-- Name: perfil_id_perfil_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.perfil_id_perfil_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.perfil_id_perfil_seq OWNER TO postgres;

--
-- Name: perfil_id_perfil_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.perfil_id_perfil_seq OWNED BY public.perfil.id_perfil;


--
-- Name: receta; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.receta (
    id_receta integer NOT NULL,
    nombre character varying(200) NOT NULL,
    url_imagen character varying(300) NOT NULL,
    ingrediente text DEFAULT ''::text,
    preparacion character varying(255) NOT NULL,
    estado smallint DEFAULT 1 NOT NULL,
    id_cat integer NOT NULL,
    id_pais integer NOT NULL,
    fecha_creacion date DEFAULT now() NOT NULL,
    id_usr integer NOT NULL,
    visitas integer DEFAULT 0 NOT NULL
);


ALTER TABLE public.receta OWNER TO postgres;

--
-- Name: receta_del_dia; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.receta_del_dia (
    fecha date NOT NULL,
    id_receta integer NOT NULL
);


ALTER TABLE public.receta_del_dia OWNER TO postgres;

--
-- Name: receta_id_receta_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.receta_id_receta_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.receta_id_receta_seq OWNER TO postgres;

--
-- Name: receta_id_receta_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.receta_id_receta_seq OWNED BY public.receta.id_receta;


--
-- Name: sesion_pago; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sesion_pago (
    id_sesion integer NOT NULL,
    session_id character varying(255) NOT NULL,
    provider character varying(100) DEFAULT 'unknown'::character varying NOT NULL,
    status character varying(50) DEFAULT 'PENDING'::character varying NOT NULL,
    id_donacion integer,
    metadata jsonb,
    fecha_creacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_actualizacion timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.sesion_pago OWNER TO postgres;

--
-- Name: sesion_pago_id_sesion_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.sesion_pago_id_sesion_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.sesion_pago_id_sesion_seq OWNER TO postgres;

--
-- Name: sesion_pago_id_sesion_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.sesion_pago_id_sesion_seq OWNED BY public.sesion_pago.id_sesion;


--
-- Name: usuario; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.usuario (
    id_usr integer NOT NULL,
    nombre character varying(100) NOT NULL,
    apellido character varying(100) NOT NULL,
    email character varying(150) NOT NULL,
    password character varying(255) NOT NULL,
    estado smallint DEFAULT 1 NOT NULL,
    fecha_creacion timestamp(6) without time zone DEFAULT now() NOT NULL,
    comentario character varying(255),
    id_perfil integer NOT NULL
);


ALTER TABLE public.usuario OWNER TO postgres;

--
-- Name: usuario_id_usr_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.usuario_id_usr_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.usuario_id_usr_seq OWNER TO postgres;

--
-- Name: usuario_id_usr_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.usuario_id_usr_seq OWNED BY public.usuario.id_usr;


-- (carrusel defaults removed)


--
-- Name: categoria id_cat; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria ALTER COLUMN id_cat SET DEFAULT nextval('public.categoria_id_cat_seq'::regclass);


--
-- Name: donacion id_donacion; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.donacion ALTER COLUMN id_donacion SET DEFAULT nextval('public.donacion_id_donacion_seq'::regclass);


--
-- Name: estrella id_estrella; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estrella ALTER COLUMN id_estrella SET DEFAULT nextval('public.estrella_id_estrella_seq'::regclass);


--
-- Name: favorito id_fav; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favorito ALTER COLUMN id_fav SET DEFAULT nextval('public.favorito_id_fav_seq'::regclass);


--
-- Name: ingrediente id_ingrediente; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingrediente ALTER COLUMN id_ingrediente SET DEFAULT nextval('public.ingrediente_new_id_ingrediente_seq'::regclass);


--
-- Name: me_gusta id_megusta; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.me_gusta ALTER COLUMN id_megusta SET DEFAULT nextval('public.me_gusta_id_megusta_seq'::regclass);


--
-- Name: pais id_pais; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pais ALTER COLUMN id_pais SET DEFAULT nextval('public.pais_id_pais_seq'::regclass);


--
-- Name: perfil id_perfil; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.perfil ALTER COLUMN id_perfil SET DEFAULT nextval('public.perfil_id_perfil_seq'::regclass);


--
-- Name: receta id_receta; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.receta ALTER COLUMN id_receta SET DEFAULT nextval('public.receta_id_receta_seq'::regclass);


--
-- Name: sesion_pago id_sesion; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sesion_pago ALTER COLUMN id_sesion SET DEFAULT nextval('public.sesion_pago_id_sesion_seq'::regclass);


--
-- Name: usuario id_usr; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario ALTER COLUMN id_usr SET DEFAULT nextval('public.usuario_id_usr_seq'::regclass);


--
-- Data for Name: carrusel; Type: TABLE DATA; Schema: public; Owner: postgres
--

-- (carrusel data removed)

--
-- (carrusel sequence setval removed)
-- original statement removed: SELECT pg_catalog.setval('public.carrusel_id_carrusel_seq', 1, false);


--
-- Data for Name: categoria; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.categoria (id_cat, nombre, url_imagen, estado, fecha_creacion, comentario, id_usr) FROM stdin;
25	Desayuno	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg	1	2025-09-10 18:05:44.122787	\N	\N
26	Almuerzo	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg	1	2025-09-10 18:05:44.122787	\N	\N
27	Cena	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg	1	2025-09-10 18:05:44.122787	\N	\N
28	Postres	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg	1	2025-09-10 18:05:44.122787	\N	\N
29	Bebidas	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg	1	2025-09-10 18:05:44.122787	\N	\N
30	Ensaladas	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg	1	2025-09-10 18:05:44.122787	\N	\N
31	Sopas	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg	1	2025-09-10 18:05:44.122787	\N	\N
32	Vegetariana	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg	1	2025-09-10 18:05:44.122787	\N	\N
34	Bebidas Test API	https://example.com/bebidas.jpg	1	2025-10-08 03:56:29.317636	\N	3
35	Fusion Asiatica CRUD	\N	1	2025-10-08 11:46:48.120787	\N	3
36	Categoria Modificada Automatizada	\N	0	2025-10-10 01:42:43.484606	\N	\N
37	Categoria Modificada Automaticamente	https://example.com/category-test.png	0	2025-10-10 11:06:02.906225	Esta es una categoria creada automaticamente para pruebas	\N
38	Categoria de Pruebas Automatizadas	https://example.com/category-test.png	0	2025-10-10 11:37:07.845508	Esta es una categoria creada automaticamente para pruebas	\N
39	Categoria Test 782955005	\N	1	2025-10-10 12:22:53.505307	\N	\N
40	Categor├¡a Test 269048356	\N	1	2025-10-10 15:00:52.570013	\N	\N
41	Test Categoria	\N	1	2025-10-10 15:12:15.502098	\N	\N
43	Test Debug Cat	\N	1	2025-10-10 15:31:25.450142	\N	\N
45	Test Categoria Updated	\N	0	2025-10-10 15:50:04.846682	\N	\N
\.


--
-- Data for Name: comentario; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.comentario (id_comentario, fecha_creacion, id_receta, texto, id_usr) FROM stdin;
185	2025-09-15 17:56:55.742644	1	Muy buena receta!	1
186	2025-09-15 17:56:55.742644	2	Muy buena receta!	1
187	2025-09-15 17:56:55.742644	3	Muy buena receta!	1
188	2025-09-15 17:56:55.742644	4	Muy buena receta!	1
189	2025-09-15 17:56:55.742644	5	Muy buena receta!	1
190	2025-09-15 17:56:55.742644	6	Muy buena receta!	1
191	2025-09-15 17:56:55.742644	7	Muy buena receta!	1
192	2025-09-15 17:56:55.742644	8	Muy buena receta!	1
193	2025-09-15 17:56:55.742644	9	Muy buena receta!	1
194	2025-09-15 17:56:55.742644	10	Muy buena receta!	1
195	2025-09-15 17:56:55.742644	11	Muy buena receta!	1
196	2025-09-15 17:56:55.742644	12	Muy buena receta!	1
197	2025-09-15 17:56:55.742644	13	Muy buena receta!	1
198	2025-09-15 17:56:55.742644	14	Muy buena receta!	1
199	2025-09-15 17:56:55.742644	15	Muy buena receta!	1
200	2025-09-15 17:56:55.742644	16	Muy buena receta!	1
201	2025-09-15 17:56:55.742644	17	Muy buena receta!	1
202	2025-09-15 17:56:55.742644	18	Muy buena receta!	1
203	2025-09-15 17:56:55.742644	19	Muy buena receta!	1
204	2025-09-15 17:56:55.742644	20	Muy buena receta!	1
205	2025-09-15 17:56:55.742644	21	Muy buena receta!	1
206	2025-09-15 17:56:55.742644	22	Muy buena receta!	1
207	2025-09-15 17:56:55.742644	23	Muy buena receta!	1
208	2025-09-15 17:56:55.742644	24	Muy buena receta!	1
209	2025-09-15 17:56:55.742644	25	Muy buena receta!	1
210	2025-09-15 17:56:55.742644	26	Muy buena receta!	1
211	2025-09-15 17:56:55.742644	27	Muy buena receta!	1
212	2025-09-15 17:56:55.742644	28	Muy buena receta!	1
213	2025-09-15 17:56:55.742644	29	Muy buena receta!	1
214	2025-09-15 17:56:55.742644	30	Muy buena receta!	1
215	2025-09-15 17:56:55.742644	31	Muy buena receta!	1
216	2025-09-15 17:56:55.742644	32	Muy buena receta!	1
217	2025-09-15 17:56:55.742644	33	Muy buena receta!	1
218	2025-09-15 17:56:55.742644	34	Muy buena receta!	1
219	2025-09-15 17:56:55.742644	35	Muy buena receta!	1
220	2025-09-15 17:56:55.742644	36	Muy buena receta!	1
221	2025-09-15 17:56:55.742644	37	Muy buena receta!	1
222	2025-09-15 17:56:55.742644	38	Muy buena receta!	1
223	2025-09-15 17:56:55.742644	39	Muy buena receta!	1
224	2025-09-15 17:56:55.742644	40	Muy buena receta!	1
225	2025-09-15 17:56:55.742644	41	Muy buena receta!	1
226	2025-09-15 17:56:55.742644	42	Muy buena receta!	1
227	2025-09-15 17:56:55.742644	43	Muy buena receta!	1
228	2025-09-15 17:56:55.742644	44	Muy buena receta!	1
229	2025-09-15 17:56:55.742644	45	Muy buena receta!	1
230	2025-09-15 17:56:55.742644	46	Muy buena receta!	1
231	2025-09-15 17:56:55.742644	47	Muy buena receta!	1
232	2025-09-15 17:56:55.742644	48	Muy buena receta!	1
233	2025-09-15 17:56:55.742644	49	Muy buena receta!	1
234	2025-09-15 17:56:55.742644	50	Muy buena receta!	1
235	2025-09-15 17:56:55.742644	51	Muy buena receta!	1
236	2025-09-15 17:56:55.742644	52	Muy buena receta!	1
237	2025-09-15 17:56:55.742644	53	Muy buena receta!	1
238	2025-09-15 17:56:55.742644	54	Muy buena receta!	1
239	2025-09-15 17:56:55.742644	55	Muy buena receta!	1
240	2025-09-15 17:56:55.742644	56	Muy buena receta!	1
241	2025-09-15 17:56:55.742644	57	Muy buena receta!	1
242	2025-09-15 17:56:55.742644	58	Muy buena receta!	1
243	2025-09-15 17:56:55.742644	59	Muy buena receta!	1
244	2025-09-15 17:56:55.742644	60	Muy buena receta!	1
245	2025-09-15 17:56:55.742644	61	Muy buena receta!	1
246	2025-09-15 17:56:55.742644	62	Muy buena receta!	1
247	2025-09-15 17:56:55.742644	63	Muy buena receta!	1
248	2025-09-15 17:56:55.742644	64	Muy buena receta!	1
249	2025-09-15 17:56:55.742644	65	Muy buena receta!	1
250	2025-09-15 17:56:55.742644	66	Muy buena receta!	1
251	2025-09-15 17:56:55.742644	67	Muy buena receta!	1
252	2025-09-15 17:56:55.742644	68	Muy buena receta!	1
253	2025-09-15 17:56:55.742644	69	Muy buena receta!	1
254	2025-09-15 17:56:55.742644	70	Muy buena receta!	1
255	2025-09-15 17:56:55.742644	71	Muy buena receta!	1
256	2025-09-15 17:56:55.742644	72	Muy buena receta!	1
257	2025-09-15 17:56:55.742644	73	Muy buena receta!	1
258	2025-09-15 17:56:55.742644	74	Muy buena receta!	1
259	2025-09-15 17:56:55.742644	75	Muy buena receta!	1
260	2025-09-15 17:56:55.742644	76	Muy buena receta!	1
261	2025-09-15 17:56:55.742644	77	Muy buena receta!	1
262	2025-09-15 17:56:55.742644	78	Muy buena receta!	1
263	2025-09-15 17:56:55.742644	79	Muy buena receta!	1
264	2025-09-15 17:56:55.742644	80	Muy buena receta!	1
265	2025-09-15 17:56:55.742644	81	Muy buena receta!	1
266	2025-09-15 17:56:55.742644	82	Muy buena receta!	1
267	2025-09-15 17:56:55.742644	83	Muy buena receta!	1
268	2025-09-15 17:56:55.742644	84	Muy buena receta!	1
269	2025-09-15 17:56:55.742644	85	Muy buena receta!	1
270	2025-09-15 17:56:55.742644	86	Muy buena receta!	1
271	2025-09-15 17:56:55.742644	87	Muy buena receta!	1
272	2025-09-15 17:56:55.742644	88	Muy buena receta!	1
273	2025-09-15 17:56:55.742644	89	Muy buena receta!	1
274	2025-09-15 17:56:55.742644	90	Muy buena receta!	1
275	2025-09-15 17:56:55.742644	91	Muy buena receta!	1
276	2025-09-15 17:56:55.742644	92	Muy buena receta!	1
277	2025-09-15 17:56:55.742644	93	Muy buena receta!	1
278	2025-09-15 17:56:55.742644	94	Muy buena receta!	1
279	2025-09-15 17:56:55.742644	95	Muy buena receta!	1
280	2025-09-15 17:56:55.742644	96	Muy buena receta!	1
281	2025-09-15 17:56:55.742644	97	Muy buena receta!	1
282	2025-09-15 17:56:55.742644	98	Muy buena receta!	1
283	2025-09-15 17:56:55.742644	99	Muy buena receta!	1
284	2025-09-15 17:56:55.742644	100	Muy buena receta!	1
285	2025-09-15 17:56:55.742644	101	Muy buena receta!	1
286	2025-09-15 17:56:55.742644	102	Muy buena receta!	1
287	2025-09-15 17:56:55.742644	103	Muy buena receta!	1
288	2025-09-15 17:56:55.742644	104	Muy buena receta!	1
289	2025-09-15 17:56:55.742644	105	Muy buena receta!	1
290	2025-09-15 17:56:55.742644	106	Muy buena receta!	1
291	2025-09-15 17:56:55.742644	107	Muy buena receta!	1
292	2025-09-15 17:56:55.742644	108	Muy buena receta!	1
293	2025-09-15 17:56:55.742644	109	Muy buena receta!	1
294	2025-09-15 17:56:55.742644	110	Muy buena receta!	1
295	2025-09-15 17:56:55.742644	111	Muy buena receta!	1
296	2025-09-15 17:56:55.742644	112	Muy buena receta!	1
297	2025-09-15 17:56:55.742644	113	Muy buena receta!	1
298	2025-09-15 17:56:55.742644	114	Muy buena receta!	1
299	2025-09-15 17:56:55.742644	115	Muy buena receta!	1
300	2025-09-15 17:56:55.742644	116	Muy buena receta!	1
301	2025-09-15 17:56:55.742644	117	Muy buena receta!	1
302	2025-09-15 17:56:55.742644	118	Muy buena receta!	1
303	2025-09-15 17:56:55.742644	119	Muy buena receta!	1
304	2025-09-15 17:56:55.742644	120	Muy buena receta!	1
305	2025-09-15 17:56:55.742644	121	Muy buena receta!	1
306	2025-09-15 17:56:55.742644	122	Muy buena receta!	1
307	2025-09-15 17:56:55.742644	123	Muy buena receta!	1
308	2025-09-15 17:56:55.742644	124	Muy buena receta!	1
309	2025-09-15 17:56:55.742644	125	Muy buena receta!	1
310	2025-09-15 17:56:55.742644	126	Muy buena receta!	1
311	2025-09-15 17:56:55.742644	127	Muy buena receta!	1
312	2025-09-15 17:56:55.742644	128	Muy buena receta!	1
313	2025-09-15 17:56:55.742644	129	Muy buena receta!	1
314	2025-09-15 17:56:55.742644	130	Muy buena receta!	1
315	2025-09-15 17:56:55.742644	131	Muy buena receta!	1
316	2025-09-15 17:56:55.742644	132	Muy buena receta!	1
317	2025-09-15 17:56:55.742644	133	Muy buena receta!	1
318	2025-09-15 17:56:55.742644	134	Muy buena receta!	1
319	2025-09-15 17:56:55.742644	135	Muy buena receta!	1
320	2025-09-15 17:56:55.742644	136	Muy buena receta!	1
321	2025-09-15 17:56:55.742644	137	Muy buena receta!	1
322	2025-09-15 17:56:55.742644	138	Muy buena receta!	1
323	2025-09-15 17:56:55.742644	139	Muy buena receta!	1
324	2025-09-15 17:56:55.742644	140	Muy buena receta!	1
325	2025-09-15 17:56:55.742644	141	Muy buena receta!	1
326	2025-09-15 17:56:55.742644	142	Muy buena receta!	1
327	2025-09-15 17:56:55.742644	143	Muy buena receta!	1
328	2025-09-15 17:56:55.742644	144	Muy buena receta!	1
329	2025-09-15 17:56:55.742644	145	Muy buena receta!	1
330	2025-09-15 17:56:55.742644	146	Muy buena receta!	1
331	2025-09-15 17:56:55.742644	147	Muy buena receta!	1
332	2025-09-15 17:56:55.742644	148	Muy buena receta!	1
333	2025-09-15 17:56:55.742644	149	Muy buena receta!	1
334	2025-09-15 17:56:55.742644	150	Muy buena receta!	1
335	2025-09-15 17:56:55.742644	151	Muy buena receta!	1
336	2025-09-15 17:56:55.742644	152	Muy buena receta!	1
337	2025-09-15 17:56:55.742644	153	Muy buena receta!	1
338	2025-09-15 17:56:55.742644	154	Muy buena receta!	1
339	2025-09-15 17:56:55.742644	155	Muy buena receta!	1
340	2025-09-15 17:56:55.742644	156	Muy buena receta!	1
341	2025-09-15 17:56:55.742644	157	Muy buena receta!	1
342	2025-09-15 17:56:55.742644	158	Muy buena receta!	1
343	2025-09-15 17:56:55.742644	159	Muy buena receta!	1
344	2025-09-15 17:56:55.742644	160	Muy buena receta!	1
345	2025-09-15 17:56:55.742644	161	Muy buena receta!	1
346	2025-09-15 17:56:55.742644	162	Muy buena receta!	1
347	2025-09-15 17:56:55.742644	163	Muy buena receta!	1
348	2025-09-15 17:56:55.742644	164	Muy buena receta!	1
349	2025-09-15 17:56:55.742644	165	Muy buena receta!	1
350	2025-09-15 17:56:55.742644	166	Muy buena receta!	1
351	2025-09-15 17:56:55.742644	167	Muy buena receta!	1
352	2025-09-15 17:56:55.742644	168	Muy buena receta!	1
353	2025-09-15 17:56:55.742644	169	Muy buena receta!	1
354	2025-09-15 17:56:55.742644	170	Muy buena receta!	1
355	2025-09-15 17:56:55.742644	171	Muy buena receta!	1
356	2025-09-15 17:56:55.742644	172	Muy buena receta!	1
357	2025-09-15 17:56:55.742644	173	Muy buena receta!	1
358	2025-09-15 17:56:55.742644	174	Muy buena receta!	1
359	2025-09-15 17:56:55.742644	175	Muy buena receta!	1
360	2025-09-15 17:56:55.742644	176	Muy buena receta!	1
361	2025-09-15 17:56:55.742644	177	Muy buena receta!	1
362	2025-09-15 17:56:55.742644	178	Muy buena receta!	1
363	2025-09-15 17:56:55.742644	179	Muy buena receta!	1
364	2025-09-15 17:56:55.742644	180	Muy buena receta!	1
365	2025-09-15 17:56:55.742644	181	Muy buena receta!	1
366	2025-09-15 17:56:55.742644	182	Muy buena receta!	1
367	2025-09-15 17:56:55.742644	183	Muy buena receta!	1
368	2025-09-15 17:56:55.742644	184	Muy buena receta!	1
369	2025-09-15 17:56:55.742644	185	Muy buena receta!	1
370	2025-09-15 17:56:55.742644	186	Muy buena receta!	1
371	2025-09-15 17:56:55.742644	187	Muy buena receta!	1
372	2025-09-15 17:56:55.742644	188	Muy buena receta!	1
373	2025-09-15 17:56:55.742644	189	Muy buena receta!	1
374	2025-09-15 17:56:55.742644	190	Muy buena receta!	1
375	2025-09-15 17:56:55.742644	191	Muy buena receta!	1
376	2025-09-15 17:56:55.742644	192	Muy buena receta!	1
377	2025-09-15 17:56:55.742644	193	Muy buena receta!	1
378	2025-09-15 17:56:55.742644	194	Muy buena receta!	1
379	2025-09-15 17:56:55.742644	195	Muy buena receta!	1
380	2025-09-15 17:56:55.742644	196	Muy buena receta!	1
381	2025-09-15 17:56:55.742644	197	Muy buena receta!	1
382	2025-09-15 17:56:55.742644	198	Muy buena receta!	1
383	2025-09-15 17:56:55.742644	199	Muy buena receta!	1
384	2025-09-15 17:56:55.742644	200	Muy buena receta!	1
385	2025-09-15 17:56:55.742644	201	Muy buena receta!	1
386	2025-09-15 17:56:55.742644	202	Muy buena receta!	1
387	2025-09-15 17:56:55.742644	203	Muy buena receta!	1
388	2025-09-15 17:56:55.742644	204	Muy buena receta!	1
389	2025-09-15 17:56:55.742644	205	Muy buena receta!	1
390	2025-09-15 17:56:55.742644	206	Muy buena receta!	1
391	2025-09-15 17:56:55.742644	207	Muy buena receta!	1
392	2025-09-15 17:56:55.742644	208	Muy buena receta!	1
393	2025-09-15 17:56:55.742644	209	Muy buena receta!	1
394	2025-09-15 17:56:55.742644	210	Muy buena receta!	1
395	2025-09-15 17:56:55.742644	211	Muy buena receta!	1
396	2025-09-15 17:56:55.742644	212	Muy buena receta!	1
397	2025-09-15 17:56:55.742644	213	Muy buena receta!	1
398	2025-09-15 17:56:55.742644	214	Muy buena receta!	1
399	2025-09-15 17:56:55.742644	215	Muy buena receta!	1
400	2025-09-15 17:56:55.742644	216	Muy buena receta!	1
401	2025-09-15 17:56:55.742644	217	Muy buena receta!	1
402	2025-09-15 17:56:55.742644	218	Muy buena receta!	1
403	2025-09-15 17:56:55.742644	219	Muy buena receta!	1
404	2025-09-15 17:56:55.742644	220	Muy buena receta!	1
405	2025-09-15 17:56:55.742644	221	Muy buena receta!	1
406	2025-09-15 17:56:55.742644	222	Muy buena receta!	1
407	2025-09-15 17:56:55.742644	223	Muy buena receta!	1
408	2025-09-15 17:56:55.742644	224	Muy buena receta!	1
409	2025-09-15 17:56:55.742644	225	Muy buena receta!	1
410	2025-09-15 17:56:55.742644	226	Muy buena receta!	1
411	2025-09-15 17:56:55.742644	227	Muy buena receta!	1
412	2025-09-15 17:56:55.742644	228	Muy buena receta!	1
413	2025-09-15 17:56:55.742644	229	Muy buena receta!	1
414	2025-09-15 17:56:55.742644	230	Muy buena receta!	1
415	2025-09-15 17:56:55.742644	231	Muy buena receta!	1
416	2025-09-15 17:56:55.742644	232	Muy buena receta!	1
417	2025-09-15 17:56:55.742644	233	Muy buena receta!	1
418	2025-09-15 17:56:55.742644	234	Muy buena receta!	1
419	2025-09-15 17:56:55.742644	235	Muy buena receta!	1
420	2025-09-15 17:56:55.742644	236	Muy buena receta!	1
421	2025-09-15 17:56:55.742644	237	Muy buena receta!	1
422	2025-09-15 17:56:55.742644	238	Muy buena receta!	1
423	2025-09-15 17:56:55.742644	239	Muy buena receta!	1
424	2025-09-15 17:56:55.742644	240	Muy buena receta!	1
425	2025-09-15 17:56:55.742644	241	Muy buena receta!	1
426	2025-09-15 17:56:55.742644	242	Muy buena receta!	1
427	2025-09-15 17:56:55.742644	243	Muy buena receta!	1
428	2025-09-15 17:56:55.742644	244	Muy buena receta!	1
429	2025-09-15 17:56:55.742644	245	Muy buena receta!	1
430	2025-09-15 17:56:55.742644	246	Muy buena receta!	1
431	2025-09-15 17:56:55.742644	247	Muy buena receta!	1
432	2025-09-15 17:56:55.742644	248	Muy buena receta!	1
433	2025-09-15 17:56:55.742644	249	Muy buena receta!	1
434	2025-09-15 17:56:55.742644	250	Muy buena receta!	1
435	2025-09-15 17:56:55.742644	251	Muy buena receta!	1
436	2025-09-15 17:56:55.742644	252	Muy buena receta!	1
437	2025-09-15 17:56:55.742644	253	Muy buena receta!	1
438	2025-09-15 17:56:55.742644	254	Muy buena receta!	1
439	2025-09-15 17:56:55.742644	255	Muy buena receta!	1
440	2025-09-15 17:56:55.742644	256	Muy buena receta!	1
441	2025-09-15 17:56:55.742644	257	Muy buena receta!	1
442	2025-09-15 17:56:55.742644	258	Muy buena receta!	1
443	2025-09-15 17:56:55.742644	259	Muy buena receta!	1
444	2025-09-15 17:56:55.742644	260	Muy buena receta!	1
445	2025-09-15 17:56:55.742644	261	Muy buena receta!	1
446	2025-09-15 17:56:55.742644	262	Muy buena receta!	1
447	2025-09-15 17:56:55.742644	263	Muy buena receta!	1
448	2025-09-15 17:56:55.742644	264	Muy buena receta!	1
449	2025-09-15 17:56:55.742644	265	Muy buena receta!	1
450	2025-09-15 17:56:55.742644	266	Muy buena receta!	1
451	2025-09-15 17:56:55.742644	267	Muy buena receta!	1
452	2025-09-15 17:56:55.742644	268	Muy buena receta!	1
453	2025-09-15 17:56:55.742644	269	Muy buena receta!	1
454	2025-09-15 17:56:55.742644	270	Muy buena receta!	1
455	2025-09-15 17:56:55.742644	271	Muy buena receta!	1
456	2025-09-15 17:56:55.742644	272	Muy buena receta!	1
457	2025-09-15 17:56:55.742644	273	Muy buena receta!	1
458	2025-09-15 17:56:55.742644	274	Muy buena receta!	1
459	2025-09-15 17:56:55.742644	275	Muy buena receta!	1
460	2025-09-15 17:56:55.742644	276	Muy buena receta!	1
461	2025-09-15 17:56:55.742644	277	Muy buena receta!	1
462	2025-09-15 17:56:55.742644	278	Muy buena receta!	1
463	2025-09-15 17:56:55.742644	279	Muy buena receta!	1
464	2025-09-15 17:56:55.742644	280	Muy buena receta!	1
465	2025-09-15 17:56:55.742644	281	Muy buena receta!	1
466	2025-09-15 17:56:55.742644	282	Muy buena receta!	1
467	2025-09-15 17:56:55.742644	283	Muy buena receta!	1
468	2025-09-15 17:56:55.742644	284	Muy buena receta!	1
469	2025-09-15 17:56:55.742644	285	Muy buena receta!	1
470	2025-09-15 17:56:55.742644	286	Muy buena receta!	1
471	2025-09-15 17:56:55.742644	287	Muy buena receta!	1
472	2025-09-15 17:56:55.742644	288	Muy buena receta!	1
473	2025-09-15 17:56:55.742644	289	Muy buena receta!	1
474	2025-09-15 17:56:55.742644	290	Muy buena receta!	1
475	2025-09-15 17:56:55.742644	291	Muy buena receta!	1
476	2025-09-15 17:56:55.742644	292	Muy buena receta!	1
477	2025-09-15 17:56:55.742644	293	Muy buena receta!	1
478	2025-09-15 17:56:55.742644	294	Muy buena receta!	1
479	2025-09-15 17:56:55.742644	295	Muy buena receta!	1
480	2025-09-15 17:56:55.742644	296	Muy buena receta!	1
481	2025-09-15 17:56:55.742644	297	Muy buena receta!	1
482	2025-09-15 17:56:55.742644	298	Muy buena receta!	1
483	2025-09-15 17:56:55.742644	299	Muy buena receta!	1
484	2025-09-15 17:56:55.742644	300	Muy buena receta!	1
485	2025-09-15 17:56:55.742644	301	Muy buena receta!	1
486	2025-09-15 17:56:55.742644	302	Muy buena receta!	1
487	2025-09-15 17:56:55.742644	303	Muy buena receta!	1
488	2025-09-15 17:56:55.742644	304	Muy buena receta!	1
489	2025-09-15 17:56:55.742644	305	Muy buena receta!	1
490	2025-09-15 17:56:55.742644	306	Muy buena receta!	1
491	2025-09-15 17:56:55.742644	307	Muy buena receta!	1
492	2025-09-15 17:56:55.742644	308	Muy buena receta!	1
493	2025-09-15 17:56:55.742644	309	Muy buena receta!	1
494	2025-09-15 17:56:55.742644	310	Muy buena receta!	1
495	2025-09-15 17:56:55.742644	311	Muy buena receta!	1
496	2025-09-15 17:56:55.742644	312	Muy buena receta!	1
497	2025-09-15 17:56:55.742644	313	Muy buena receta!	1
498	2025-09-15 17:56:55.742644	314	Muy buena receta!	1
499	2025-09-15 17:56:55.742644	315	Muy buena receta!	1
500	2025-09-15 17:56:55.742644	316	Muy buena receta!	1
501	2025-09-15 17:56:55.742644	317	Muy buena receta!	1
502	2025-09-15 17:56:55.742644	318	Muy buena receta!	1
503	2025-09-15 17:56:55.742644	319	Muy buena receta!	1
504	2025-09-15 17:56:55.742644	320	Muy buena receta!	1
505	2025-09-15 17:56:55.742644	321	Muy buena receta!	1
506	2025-09-15 17:56:55.742644	322	Muy buena receta!	1
507	2025-09-15 17:56:55.742644	323	Muy buena receta!	1
508	2025-09-15 17:56:55.742644	324	Muy buena receta!	1
509	2025-09-15 17:56:55.742644	325	Muy buena receta!	1
510	2025-09-15 17:56:55.742644	326	Muy buena receta!	1
511	2025-09-15 17:56:55.742644	327	Muy buena receta!	1
512	2025-09-15 17:56:55.742644	328	Muy buena receta!	1
513	2025-09-15 17:56:55.742644	329	Muy buena receta!	1
514	2025-09-15 17:56:55.742644	330	Muy buena receta!	1
515	2025-09-15 17:56:55.742644	331	Muy buena receta!	1
516	2025-09-15 17:56:55.742644	332	Muy buena receta!	1
517	2025-09-15 17:56:55.742644	333	Muy buena receta!	1
518	2025-09-15 17:56:55.742644	334	Muy buena receta!	1
519	2025-09-15 17:56:55.742644	335	Muy buena receta!	1
520	2025-09-15 17:56:55.742644	336	Muy buena receta!	1
521	2025-09-15 17:56:55.742644	337	Muy buena receta!	1
522	2025-09-15 17:56:55.742644	338	Muy buena receta!	1
523	2025-09-15 17:56:55.742644	339	Muy buena receta!	1
524	2025-09-15 17:56:55.742644	340	Muy buena receta!	1
525	2025-09-15 17:56:55.742644	341	Muy buena receta!	1
526	2025-09-15 17:56:55.742644	342	Muy buena receta!	1
527	2025-09-15 17:56:55.742644	343	Muy buena receta!	1
528	2025-09-15 17:56:55.742644	344	Muy buena receta!	1
529	2025-09-15 17:56:55.742644	345	Muy buena receta!	1
530	2025-09-15 17:56:55.742644	346	Muy buena receta!	1
531	2025-09-15 17:56:55.742644	347	Muy buena receta!	1
532	2025-09-15 17:56:55.742644	348	Muy buena receta!	1
533	2025-09-15 17:56:55.742644	349	Muy buena receta!	1
534	2025-09-15 17:56:55.742644	350	Muy buena receta!	1
535	2025-09-15 17:56:55.742644	351	Muy buena receta!	1
536	2025-09-15 17:56:55.742644	352	Muy buena receta!	1
537	2025-09-15 17:56:55.742644	353	Muy buena receta!	1
538	2025-09-15 17:56:55.742644	354	Muy buena receta!	1
539	2025-09-15 17:56:55.742644	355	Muy buena receta!	1
540	2025-09-15 17:56:55.742644	356	Muy buena receta!	1
541	2025-09-15 17:56:55.742644	357	Muy buena receta!	1
542	2025-09-15 17:56:55.742644	358	Muy buena receta!	1
543	2025-09-15 17:56:55.742644	359	Muy buena receta!	1
544	2025-09-15 17:56:55.742644	360	Muy buena receta!	1
545	2025-09-15 17:56:55.742644	361	Muy buena receta!	1
546	2025-09-15 17:56:55.742644	362	Muy buena receta!	1
547	2025-09-15 17:56:55.742644	363	Muy buena receta!	1
548	2025-09-15 17:56:55.742644	364	Muy buena receta!	1
549	2025-09-15 17:56:55.742644	365	Muy buena receta!	1
550	2025-09-15 17:56:55.742644	366	Muy buena receta!	1
551	2025-09-15 17:56:55.742644	367	Muy buena receta!	1
552	2025-09-15 17:56:55.742644	368	Muy buena receta!	1
553	2025-09-15 17:56:55.742644	369	Muy buena receta!	1
554	2025-09-15 17:56:55.742644	370	Muy buena receta!	1
555	2025-09-15 17:56:55.742644	371	Muy buena receta!	1
556	2025-09-15 17:56:55.742644	372	Muy buena receta!	1
557	2025-09-15 17:56:55.742644	373	Muy buena receta!	1
558	2025-09-15 17:56:55.742644	374	Muy buena receta!	1
559	2025-09-15 17:56:55.742644	375	Muy buena receta!	1
560	2025-09-15 17:56:55.742644	376	Muy buena receta!	1
561	2025-09-15 17:56:55.742644	377	Muy buena receta!	1
562	2025-09-15 17:56:55.742644	378	Muy buena receta!	1
563	2025-09-15 17:56:55.742644	379	Muy buena receta!	1
564	2025-09-15 17:56:55.742644	380	Muy buena receta!	1
565	2025-09-15 17:56:55.742644	381	Muy buena receta!	1
566	2025-09-15 17:56:55.742644	382	Muy buena receta!	1
567	2025-09-15 17:56:55.742644	383	Muy buena receta!	1
568	2025-09-15 17:56:55.742644	384	Muy buena receta!	1
569	2025-09-15 17:56:55.742644	385	Muy buena receta!	1
570	2025-09-15 17:56:55.742644	386	Muy buena receta!	1
571	2025-09-15 17:56:55.742644	387	Muy buena receta!	1
572	2025-09-15 17:56:55.742644	388	Muy buena receta!	1
573	2025-09-15 17:56:55.742644	389	Muy buena receta!	1
574	2025-09-15 17:56:55.742644	390	Muy buena receta!	1
575	2025-09-15 17:56:55.742644	391	Muy buena receta!	1
576	2025-09-15 17:56:55.742644	392	Muy buena receta!	1
577	2025-09-15 17:56:55.742644	393	Muy buena receta!	1
578	2025-09-15 17:56:55.742644	394	Muy buena receta!	1
579	2025-09-15 17:56:55.742644	395	Muy buena receta!	1
580	2025-09-15 17:56:55.742644	396	Muy buena receta!	1
581	2025-09-15 17:56:55.742644	397	Muy buena receta!	1
582	2025-09-15 17:56:55.742644	398	Muy buena receta!	1
583	2025-09-15 17:56:55.742644	399	Muy buena receta!	1
584	2025-09-15 17:56:55.742644	400	Muy buena receta!	1
585	2025-09-15 17:56:55.742644	401	Muy buena receta!	1
586	2025-09-15 17:56:55.742644	402	Muy buena receta!	1
587	2025-09-15 17:56:55.742644	403	Muy buena receta!	1
588	2025-09-15 17:56:55.742644	404	Muy buena receta!	1
589	2025-09-15 17:56:55.742644	405	Muy buena receta!	1
590	2025-09-15 17:56:55.742644	406	Muy buena receta!	1
591	2025-09-15 17:56:55.742644	407	Muy buena receta!	1
592	2025-09-15 17:56:55.742644	408	Muy buena receta!	1
593	2025-09-15 17:56:55.742644	409	Muy buena receta!	1
594	2025-09-15 17:56:55.742644	410	Muy buena receta!	1
595	2025-09-15 17:56:55.742644	411	Muy buena receta!	1
596	2025-09-15 17:56:55.742644	412	Muy buena receta!	1
597	2025-09-15 17:56:55.742644	413	Muy buena receta!	1
598	2025-09-15 17:56:55.742644	414	Muy buena receta!	1
599	2025-09-15 17:56:55.742644	415	Muy buena receta!	1
600	2025-09-15 17:56:55.742644	416	Muy buena receta!	1
601	2025-09-15 17:56:55.742644	417	Muy buena receta!	1
602	2025-09-15 17:56:55.742644	418	Muy buena receta!	1
603	2025-09-15 17:56:55.742644	419	Muy buena receta!	1
604	2025-09-15 17:56:55.742644	420	Muy buena receta!	1
605	2025-09-15 17:56:55.742644	421	Muy buena receta!	1
606	2025-09-15 17:56:55.742644	422	Muy buena receta!	1
607	2025-09-15 17:56:55.742644	423	Muy buena receta!	1
608	2025-09-15 17:56:55.742644	424	Muy buena receta!	1
609	2025-09-15 17:56:55.742644	425	Muy buena receta!	1
610	2025-09-15 17:56:55.742644	426	Muy buena receta!	1
611	2025-09-15 17:56:55.742644	427	Muy buena receta!	1
612	2025-09-15 17:56:55.742644	428	Muy buena receta!	1
613	2025-09-15 17:56:55.742644	429	Muy buena receta!	1
614	2025-09-15 17:56:55.742644	430	Muy buena receta!	1
615	2025-09-15 17:56:55.742644	431	Muy buena receta!	1
616	2025-09-15 17:56:55.742644	432	Muy buena receta!	1
617	2025-09-15 17:56:55.742644	433	Muy buena receta!	1
618	2025-09-15 17:56:55.742644	434	Muy buena receta!	1
619	2025-09-15 17:56:55.742644	435	Muy buena receta!	1
620	2025-09-15 17:56:55.742644	436	Muy buena receta!	1
621	2025-09-15 17:56:55.742644	437	Muy buena receta!	1
622	2025-09-15 17:56:55.742644	438	Muy buena receta!	1
623	2025-09-15 17:56:55.742644	439	Muy buena receta!	1
624	2025-09-15 17:56:55.742644	440	Muy buena receta!	1
625	2025-09-15 17:56:55.742644	441	Muy buena receta!	1
626	2025-09-15 17:56:55.742644	442	Muy buena receta!	1
627	2025-09-15 17:56:55.742644	443	Muy buena receta!	1
628	2025-09-15 17:56:55.742644	444	Muy buena receta!	1
629	2025-09-15 17:56:55.742644	445	Muy buena receta!	1
630	2025-09-15 17:56:55.742644	446	Muy buena receta!	1
631	2025-09-15 17:56:55.742644	447	Muy buena receta!	1
632	2025-09-15 17:56:55.742644	448	Muy buena receta!	1
633	2025-09-15 17:56:55.742644	449	Muy buena receta!	1
634	2025-09-15 17:56:55.742644	450	Muy buena receta!	1
635	2025-09-15 17:56:55.742644	451	Muy buena receta!	1
636	2025-09-15 17:56:55.742644	452	Muy buena receta!	1
637	2025-09-15 17:56:55.742644	453	Muy buena receta!	1
638	2025-09-15 17:56:55.742644	454	Muy buena receta!	1
639	2025-09-15 17:56:55.742644	455	Muy buena receta!	1
640	2025-09-15 17:56:55.742644	456	Muy buena receta!	1
641	2025-09-15 17:56:55.742644	457	Muy buena receta!	1
642	2025-09-15 17:56:55.742644	458	Muy buena receta!	1
643	2025-09-15 17:56:55.742644	459	Muy buena receta!	1
644	2025-09-15 17:56:55.742644	460	Muy buena receta!	1
645	2025-09-15 17:56:55.742644	461	Muy buena receta!	1
646	2025-09-15 17:56:55.742644	462	Muy buena receta!	1
647	2025-09-15 17:56:55.742644	463	Muy buena receta!	1
648	2025-09-15 17:56:55.742644	464	Muy buena receta!	1
649	2025-09-15 17:56:55.742644	465	Muy buena receta!	1
650	2025-09-15 17:56:55.742644	466	Muy buena receta!	1
651	2025-09-15 17:56:55.742644	467	Muy buena receta!	1
652	2025-09-15 17:56:55.742644	468	Muy buena receta!	1
653	2025-09-15 17:56:55.742644	469	Muy buena receta!	1
654	2025-09-15 17:56:55.742644	470	Muy buena receta!	1
655	2025-09-15 17:56:55.742644	471	Muy buena receta!	1
656	2025-09-15 17:56:55.742644	472	Muy buena receta!	1
657	2025-09-15 17:56:55.742644	473	Muy buena receta!	1
658	2025-09-15 17:56:55.742644	474	Muy buena receta!	1
659	2025-09-15 17:56:55.742644	475	Muy buena receta!	1
660	2025-09-15 17:56:55.742644	476	Muy buena receta!	1
661	2025-09-15 17:56:55.742644	477	Muy buena receta!	1
662	2025-09-15 17:56:55.742644	478	Muy buena receta!	1
663	2025-09-15 17:56:55.742644	479	Muy buena receta!	1
664	2025-09-15 17:56:55.742644	480	Muy buena receta!	1
665	2025-09-15 17:56:55.742644	481	Muy buena receta!	1
666	2025-09-15 17:56:55.742644	482	Muy buena receta!	1
667	2025-09-15 17:56:55.742644	483	Muy buena receta!	1
668	2025-09-15 17:56:55.742644	484	Muy buena receta!	1
669	2025-09-15 17:56:55.742644	485	Muy buena receta!	1
670	2025-09-15 17:56:55.742644	486	Muy buena receta!	1
671	2025-09-15 17:56:55.742644	487	Muy buena receta!	1
672	2025-09-15 17:56:55.742644	488	Muy buena receta!	1
673	2025-09-15 17:56:55.742644	489	Muy buena receta!	1
674	2025-09-15 17:56:55.742644	490	Muy buena receta!	1
675	2025-09-15 17:56:55.742644	491	Muy buena receta!	1
676	2025-09-15 17:56:55.742644	492	Muy buena receta!	1
677	2025-09-15 17:56:55.742644	493	Muy buena receta!	1
678	2025-09-15 17:56:55.742644	494	Muy buena receta!	1
679	2025-09-15 17:56:55.742644	495	Muy buena receta!	1
680	2025-09-15 17:56:55.742644	496	Muy buena receta!	1
681	2025-09-15 17:56:55.742644	497	Muy buena receta!	1
682	2025-09-15 17:56:55.742644	498	Muy buena receta!	1
683	2025-09-15 17:56:55.742644	499	Muy buena receta!	1
684	2025-09-15 17:56:55.742644	500	Muy buena receta!	1
685	2025-09-15 17:56:55.742644	501	Muy buena receta!	1
686	2025-09-15 17:56:55.742644	502	Muy buena receta!	1
687	2025-09-15 17:56:55.742644	503	Muy buena receta!	1
688	2025-09-15 17:56:55.742644	504	Muy buena receta!	1
689	2025-09-15 17:56:55.742644	505	Muy buena receta!	1
690	2025-09-15 17:56:55.742644	506	Muy buena receta!	1
691	2025-09-15 17:56:55.742644	507	Muy buena receta!	1
692	2025-09-15 17:56:55.742644	508	Muy buena receta!	1
693	2025-09-15 17:56:55.742644	509	Muy buena receta!	1
694	2025-09-15 17:56:55.742644	510	Muy buena receta!	1
695	2025-09-15 17:56:55.742644	511	Muy buena receta!	1
696	2025-09-15 17:56:55.742644	512	Muy buena receta!	1
697	2025-09-15 17:56:55.742644	513	Muy buena receta!	1
698	2025-09-15 17:56:55.742644	514	Muy buena receta!	1
699	2025-09-15 17:56:55.742644	515	Muy buena receta!	1
700	2025-09-15 17:56:55.742644	516	Muy buena receta!	1
701	2025-09-15 17:56:55.742644	517	Muy buena receta!	1
702	2025-09-15 17:56:55.742644	518	Muy buena receta!	1
703	2025-09-15 17:56:55.742644	519	Muy buena receta!	1
704	2025-09-15 17:56:55.742644	520	Muy buena receta!	1
705	2025-09-15 17:56:55.742644	521	Muy buena receta!	1
706	2025-09-15 17:56:55.742644	522	Muy buena receta!	1
707	2025-09-15 17:56:55.742644	523	Muy buena receta!	1
708	2025-09-15 17:56:55.742644	524	Muy buena receta!	1
709	2025-09-15 17:56:55.742644	525	Muy buena receta!	1
710	2025-09-15 17:56:55.742644	526	Muy buena receta!	1
711	2025-09-15 17:56:55.742644	527	Muy buena receta!	1
712	2025-09-15 17:56:55.742644	528	Muy buena receta!	1
713	2025-09-15 17:56:55.742644	529	Muy buena receta!	1
714	2025-09-15 17:56:55.742644	530	Muy buena receta!	1
715	2025-09-15 17:56:55.742644	531	Muy buena receta!	1
716	2025-09-15 17:56:55.742644	532	Muy buena receta!	1
717	2025-09-15 17:56:55.742644	533	Muy buena receta!	1
718	2025-09-15 17:56:55.742644	534	Muy buena receta!	1
719	2025-09-15 17:56:55.742644	535	Muy buena receta!	1
720	2025-09-15 17:56:55.742644	536	Muy buena receta!	1
721	2025-09-15 17:56:55.742644	537	Muy buena receta!	1
722	2025-09-15 17:56:55.742644	538	Muy buena receta!	1
723	2025-09-15 17:56:55.742644	539	Muy buena receta!	1
724	2025-09-15 17:56:55.742644	540	Muy buena receta!	1
725	2025-09-15 17:56:55.742644	541	Muy buena receta!	1
726	2025-09-15 17:56:55.742644	542	Muy buena receta!	1
727	2025-09-15 17:56:55.742644	543	Muy buena receta!	1
728	2025-09-15 17:56:55.742644	544	Muy buena receta!	1
729	2025-09-15 17:56:55.742644	545	Muy buena receta!	1
730	2025-09-15 17:56:55.742644	546	Muy buena receta!	1
731	2025-09-15 17:56:55.742644	547	Muy buena receta!	1
732	2025-09-15 17:56:55.742644	548	Muy buena receta!	1
733	2025-09-15 17:56:55.742644	549	Muy buena receta!	1
734	2025-09-15 17:56:55.742644	550	Muy buena receta!	1
735	2025-09-15 17:56:55.742644	551	Muy buena receta!	1
736	2025-09-15 17:56:55.742644	552	Muy buena receta!	1
737	2025-09-15 17:56:55.742644	553	Muy buena receta!	1
738	2025-09-15 17:56:55.742644	554	Muy buena receta!	1
739	2025-09-15 17:56:55.742644	555	Muy buena receta!	1
740	2025-09-15 17:56:55.742644	556	Muy buena receta!	1
741	2025-09-15 17:56:55.742644	557	Muy buena receta!	1
742	2025-09-15 17:56:55.742644	558	Muy buena receta!	1
743	2025-09-15 17:56:55.742644	559	Muy buena receta!	1
744	2025-09-15 17:56:55.742644	560	Muy buena receta!	1
745	2025-09-15 17:56:55.742644	561	Muy buena receta!	1
746	2025-09-15 17:56:55.742644	562	Muy buena receta!	1
747	2025-09-15 17:56:55.742644	563	Muy buena receta!	1
748	2025-09-15 17:56:55.742644	564	Muy buena receta!	1
749	2025-09-15 17:56:55.742644	565	Muy buena receta!	1
750	2025-09-15 17:56:55.742644	566	Muy buena receta!	1
751	2025-09-15 17:56:55.742644	567	Muy buena receta!	1
752	2025-09-15 17:56:55.742644	568	Muy buena receta!	1
753	2025-09-15 17:56:55.742644	569	Muy buena receta!	1
754	2025-09-15 17:56:55.742644	570	Muy buena receta!	1
755	2025-09-15 17:56:55.742644	571	Muy buena receta!	1
756	2025-09-15 17:56:55.742644	572	Muy buena receta!	1
757	2025-09-15 17:56:55.742644	573	Muy buena receta!	1
758	2025-09-15 17:56:55.742644	574	Muy buena receta!	1
759	2025-09-15 17:56:55.742644	575	Muy buena receta!	1
760	2025-09-15 17:56:55.742644	576	Muy buena receta!	1
761	2025-09-15 17:56:55.742644	577	Muy buena receta!	1
762	2025-09-15 17:56:55.742644	578	Muy buena receta!	1
763	2025-09-15 17:56:55.742644	579	Muy buena receta!	1
764	2025-09-15 17:56:55.742644	580	Muy buena receta!	1
765	2025-09-15 17:56:55.742644	581	Muy buena receta!	1
766	2025-09-15 17:56:55.742644	582	Muy buena receta!	1
767	2025-09-15 17:56:55.742644	583	Muy buena receta!	1
768	2025-09-15 17:56:55.742644	584	Muy buena receta!	1
769	2025-09-15 17:56:55.742644	585	Muy buena receta!	1
770	2025-09-15 17:56:55.742644	586	Muy buena receta!	1
771	2025-09-15 17:56:55.742644	587	Muy buena receta!	1
772	2025-09-15 17:56:55.742644	588	Muy buena receta!	1
773	2025-09-15 17:56:55.742644	589	Muy buena receta!	1
774	2025-09-15 17:56:55.742644	590	Muy buena receta!	1
775	2025-09-15 17:56:55.742644	591	Muy buena receta!	1
776	2025-09-15 17:56:55.742644	592	Muy buena receta!	1
777	2025-09-15 17:56:55.742644	593	Muy buena receta!	1
778	2025-09-15 17:56:55.742644	594	Muy buena receta!	1
779	2025-09-15 17:56:55.742644	595	Muy buena receta!	1
780	2025-09-15 17:56:55.742644	596	Muy buena receta!	1
781	2025-09-15 17:56:55.742644	597	Muy buena receta!	1
782	2025-09-15 17:56:55.742644	598	Muy buena receta!	1
783	2025-09-15 17:56:55.742644	599	Muy buena receta!	1
784	2025-09-15 17:56:55.742644	600	Muy buena receta!	1
785	2025-09-15 17:56:55.742644	601	Muy buena receta!	1
786	2025-09-15 17:56:55.742644	602	Muy buena receta!	1
787	2025-09-15 17:56:55.742644	603	Muy buena receta!	1
788	2025-09-15 17:56:55.742644	604	Muy buena receta!	1
789	2025-09-15 17:56:55.742644	605	Muy buena receta!	1
790	2025-09-15 17:56:55.742644	606	Muy buena receta!	1
791	2025-09-15 17:56:55.742644	607	Muy buena receta!	1
792	2025-09-15 17:56:55.742644	608	Muy buena receta!	1
793	2025-09-15 17:56:55.742644	609	Muy buena receta!	1
794	2025-09-15 17:56:55.742644	610	Muy buena receta!	1
795	2025-09-15 17:56:55.742644	611	Muy buena receta!	1
796	2025-09-15 17:56:55.742644	612	Muy buena receta!	1
797	2025-09-15 17:56:55.742644	613	Muy buena receta!	1
798	2025-09-15 17:56:55.742644	614	Muy buena receta!	1
799	2025-09-15 17:56:55.742644	615	Muy buena receta!	1
800	2025-09-15 17:56:55.742644	616	Muy buena receta!	1
801	2025-09-15 17:56:55.742644	617	Muy buena receta!	1
802	2025-09-15 17:56:55.742644	618	Muy buena receta!	1
803	2025-09-15 17:56:55.742644	619	Muy buena receta!	1
804	2025-09-15 17:56:55.742644	620	Muy buena receta!	1
805	2025-09-15 17:56:55.742644	621	Muy buena receta!	1
806	2025-09-15 17:56:55.742644	622	Muy buena receta!	1
807	2025-09-15 17:56:55.742644	623	Muy buena receta!	1
808	2025-09-15 17:56:55.742644	624	Muy buena receta!	1
809	2025-09-15 17:56:55.742644	625	Muy buena receta!	1
810	2025-09-15 17:56:55.742644	626	Muy buena receta!	1
811	2025-09-15 17:56:55.742644	627	Muy buena receta!	1
812	2025-09-15 17:56:55.742644	628	Muy buena receta!	1
813	2025-09-15 17:56:55.742644	629	Muy buena receta!	1
814	2025-09-15 17:56:55.742644	630	Muy buena receta!	1
815	2025-09-15 17:56:55.742644	631	Muy buena receta!	1
816	2025-09-15 17:56:55.742644	632	Muy buena receta!	1
817	2025-09-15 17:56:55.742644	633	Muy buena receta!	1
818	2025-09-15 17:56:55.742644	634	Muy buena receta!	1
819	2025-09-15 17:56:55.742644	635	Muy buena receta!	1
820	2025-09-15 17:56:55.742644	636	Muy buena receta!	1
821	2025-09-15 17:56:55.742644	637	Muy buena receta!	1
822	2025-09-15 17:56:55.742644	638	Muy buena receta!	1
823	2025-09-15 17:56:55.742644	639	Muy buena receta!	1
824	2025-09-15 17:56:55.742644	640	Muy buena receta!	1
825	2025-09-15 17:56:55.742644	1	Me encantÔö£Ôöé, la recomiendo.	2
826	2025-09-15 17:56:55.742644	2	Me encantÔö£Ôöé, la recomiendo.	2
827	2025-09-15 17:56:55.742644	3	Me encantÔö£Ôöé, la recomiendo.	2
828	2025-09-15 17:56:55.742644	4	Me encantÔö£Ôöé, la recomiendo.	2
829	2025-09-15 17:56:55.742644	5	Me encantÔö£Ôöé, la recomiendo.	2
830	2025-09-15 17:56:55.742644	6	Me encantÔö£Ôöé, la recomiendo.	2
831	2025-09-15 17:56:55.742644	7	Me encantÔö£Ôöé, la recomiendo.	2
832	2025-09-15 17:56:55.742644	8	Me encantÔö£Ôöé, la recomiendo.	2
833	2025-09-15 17:56:55.742644	9	Me encantÔö£Ôöé, la recomiendo.	2
834	2025-09-15 17:56:55.742644	10	Me encantÔö£Ôöé, la recomiendo.	2
835	2025-09-15 17:56:55.742644	11	Me encantÔö£Ôöé, la recomiendo.	2
836	2025-09-15 17:56:55.742644	12	Me encantÔö£Ôöé, la recomiendo.	2
837	2025-09-15 17:56:55.742644	13	Me encantÔö£Ôöé, la recomiendo.	2
838	2025-09-15 17:56:55.742644	14	Me encantÔö£Ôöé, la recomiendo.	2
839	2025-09-15 17:56:55.742644	15	Me encantÔö£Ôöé, la recomiendo.	2
840	2025-09-15 17:56:55.742644	16	Me encantÔö£Ôöé, la recomiendo.	2
841	2025-09-15 17:56:55.742644	17	Me encantÔö£Ôöé, la recomiendo.	2
842	2025-09-15 17:56:55.742644	18	Me encantÔö£Ôöé, la recomiendo.	2
843	2025-09-15 17:56:55.742644	19	Me encantÔö£Ôöé, la recomiendo.	2
844	2025-09-15 17:56:55.742644	20	Me encantÔö£Ôöé, la recomiendo.	2
845	2025-09-15 17:56:55.742644	21	Me encantÔö£Ôöé, la recomiendo.	2
846	2025-09-15 17:56:55.742644	22	Me encantÔö£Ôöé, la recomiendo.	2
847	2025-09-15 17:56:55.742644	23	Me encantÔö£Ôöé, la recomiendo.	2
848	2025-09-15 17:56:55.742644	24	Me encantÔö£Ôöé, la recomiendo.	2
849	2025-09-15 17:56:55.742644	25	Me encantÔö£Ôöé, la recomiendo.	2
850	2025-09-15 17:56:55.742644	26	Me encantÔö£Ôöé, la recomiendo.	2
851	2025-09-15 17:56:55.742644	27	Me encantÔö£Ôöé, la recomiendo.	2
852	2025-09-15 17:56:55.742644	28	Me encantÔö£Ôöé, la recomiendo.	2
853	2025-09-15 17:56:55.742644	29	Me encantÔö£Ôöé, la recomiendo.	2
854	2025-09-15 17:56:55.742644	30	Me encantÔö£Ôöé, la recomiendo.	2
855	2025-09-15 17:56:55.742644	31	Me encantÔö£Ôöé, la recomiendo.	2
856	2025-09-15 17:56:55.742644	32	Me encantÔö£Ôöé, la recomiendo.	2
857	2025-09-15 17:56:55.742644	33	Me encantÔö£Ôöé, la recomiendo.	2
858	2025-09-15 17:56:55.742644	34	Me encantÔö£Ôöé, la recomiendo.	2
859	2025-09-15 17:56:55.742644	35	Me encantÔö£Ôöé, la recomiendo.	2
860	2025-09-15 17:56:55.742644	36	Me encantÔö£Ôöé, la recomiendo.	2
861	2025-09-15 17:56:55.742644	37	Me encantÔö£Ôöé, la recomiendo.	2
862	2025-09-15 17:56:55.742644	38	Me encantÔö£Ôöé, la recomiendo.	2
863	2025-09-15 17:56:55.742644	39	Me encantÔö£Ôöé, la recomiendo.	2
864	2025-09-15 17:56:55.742644	40	Me encantÔö£Ôöé, la recomiendo.	2
865	2025-09-15 17:56:55.742644	41	Me encantÔö£Ôöé, la recomiendo.	2
866	2025-09-15 17:56:55.742644	42	Me encantÔö£Ôöé, la recomiendo.	2
867	2025-09-15 17:56:55.742644	43	Me encantÔö£Ôöé, la recomiendo.	2
868	2025-09-15 17:56:55.742644	44	Me encantÔö£Ôöé, la recomiendo.	2
869	2025-09-15 17:56:55.742644	45	Me encantÔö£Ôöé, la recomiendo.	2
870	2025-09-15 17:56:55.742644	46	Me encantÔö£Ôöé, la recomiendo.	2
871	2025-09-15 17:56:55.742644	47	Me encantÔö£Ôöé, la recomiendo.	2
872	2025-09-15 17:56:55.742644	48	Me encantÔö£Ôöé, la recomiendo.	2
873	2025-09-15 17:56:55.742644	49	Me encantÔö£Ôöé, la recomiendo.	2
874	2025-09-15 17:56:55.742644	50	Me encantÔö£Ôöé, la recomiendo.	2
875	2025-09-15 17:56:55.742644	51	Me encantÔö£Ôöé, la recomiendo.	2
876	2025-09-15 17:56:55.742644	52	Me encantÔö£Ôöé, la recomiendo.	2
877	2025-09-15 17:56:55.742644	53	Me encantÔö£Ôöé, la recomiendo.	2
878	2025-09-15 17:56:55.742644	54	Me encantÔö£Ôöé, la recomiendo.	2
879	2025-09-15 17:56:55.742644	55	Me encantÔö£Ôöé, la recomiendo.	2
880	2025-09-15 17:56:55.742644	56	Me encantÔö£Ôöé, la recomiendo.	2
881	2025-09-15 17:56:55.742644	57	Me encantÔö£Ôöé, la recomiendo.	2
882	2025-09-15 17:56:55.742644	58	Me encantÔö£Ôöé, la recomiendo.	2
883	2025-09-15 17:56:55.742644	59	Me encantÔö£Ôöé, la recomiendo.	2
884	2025-09-15 17:56:55.742644	60	Me encantÔö£Ôöé, la recomiendo.	2
885	2025-09-15 17:56:55.742644	61	Me encantÔö£Ôöé, la recomiendo.	2
886	2025-09-15 17:56:55.742644	62	Me encantÔö£Ôöé, la recomiendo.	2
887	2025-09-15 17:56:55.742644	63	Me encantÔö£Ôöé, la recomiendo.	2
888	2025-09-15 17:56:55.742644	64	Me encantÔö£Ôöé, la recomiendo.	2
889	2025-09-15 17:56:55.742644	65	Me encantÔö£Ôöé, la recomiendo.	2
890	2025-09-15 17:56:55.742644	66	Me encantÔö£Ôöé, la recomiendo.	2
891	2025-09-15 17:56:55.742644	67	Me encantÔö£Ôöé, la recomiendo.	2
892	2025-09-15 17:56:55.742644	68	Me encantÔö£Ôöé, la recomiendo.	2
893	2025-09-15 17:56:55.742644	69	Me encantÔö£Ôöé, la recomiendo.	2
894	2025-09-15 17:56:55.742644	70	Me encantÔö£Ôöé, la recomiendo.	2
895	2025-09-15 17:56:55.742644	71	Me encantÔö£Ôöé, la recomiendo.	2
896	2025-09-15 17:56:55.742644	72	Me encantÔö£Ôöé, la recomiendo.	2
897	2025-09-15 17:56:55.742644	73	Me encantÔö£Ôöé, la recomiendo.	2
898	2025-09-15 17:56:55.742644	74	Me encantÔö£Ôöé, la recomiendo.	2
899	2025-09-15 17:56:55.742644	75	Me encantÔö£Ôöé, la recomiendo.	2
900	2025-09-15 17:56:55.742644	76	Me encantÔö£Ôöé, la recomiendo.	2
901	2025-09-15 17:56:55.742644	77	Me encantÔö£Ôöé, la recomiendo.	2
902	2025-09-15 17:56:55.742644	78	Me encantÔö£Ôöé, la recomiendo.	2
903	2025-09-15 17:56:55.742644	79	Me encantÔö£Ôöé, la recomiendo.	2
904	2025-09-15 17:56:55.742644	80	Me encantÔö£Ôöé, la recomiendo.	2
905	2025-09-15 17:56:55.742644	81	Me encantÔö£Ôöé, la recomiendo.	2
906	2025-09-15 17:56:55.742644	82	Me encantÔö£Ôöé, la recomiendo.	2
907	2025-09-15 17:56:55.742644	83	Me encantÔö£Ôöé, la recomiendo.	2
908	2025-09-15 17:56:55.742644	84	Me encantÔö£Ôöé, la recomiendo.	2
909	2025-09-15 17:56:55.742644	85	Me encantÔö£Ôöé, la recomiendo.	2
910	2025-09-15 17:56:55.742644	86	Me encantÔö£Ôöé, la recomiendo.	2
911	2025-09-15 17:56:55.742644	87	Me encantÔö£Ôöé, la recomiendo.	2
912	2025-09-15 17:56:55.742644	88	Me encantÔö£Ôöé, la recomiendo.	2
913	2025-09-15 17:56:55.742644	89	Me encantÔö£Ôöé, la recomiendo.	2
914	2025-09-15 17:56:55.742644	90	Me encantÔö£Ôöé, la recomiendo.	2
915	2025-09-15 17:56:55.742644	91	Me encantÔö£Ôöé, la recomiendo.	2
916	2025-09-15 17:56:55.742644	92	Me encantÔö£Ôöé, la recomiendo.	2
917	2025-09-15 17:56:55.742644	93	Me encantÔö£Ôöé, la recomiendo.	2
918	2025-09-15 17:56:55.742644	94	Me encantÔö£Ôöé, la recomiendo.	2
919	2025-09-15 17:56:55.742644	95	Me encantÔö£Ôöé, la recomiendo.	2
920	2025-09-15 17:56:55.742644	96	Me encantÔö£Ôöé, la recomiendo.	2
921	2025-09-15 17:56:55.742644	97	Me encantÔö£Ôöé, la recomiendo.	2
922	2025-09-15 17:56:55.742644	98	Me encantÔö£Ôöé, la recomiendo.	2
923	2025-09-15 17:56:55.742644	99	Me encantÔö£Ôöé, la recomiendo.	2
924	2025-09-15 17:56:55.742644	100	Me encantÔö£Ôöé, la recomiendo.	2
925	2025-09-15 17:56:55.742644	101	Me encantÔö£Ôöé, la recomiendo.	2
926	2025-09-15 17:56:55.742644	102	Me encantÔö£Ôöé, la recomiendo.	2
927	2025-09-15 17:56:55.742644	103	Me encantÔö£Ôöé, la recomiendo.	2
928	2025-09-15 17:56:55.742644	104	Me encantÔö£Ôöé, la recomiendo.	2
929	2025-09-15 17:56:55.742644	105	Me encantÔö£Ôöé, la recomiendo.	2
930	2025-09-15 17:56:55.742644	106	Me encantÔö£Ôöé, la recomiendo.	2
931	2025-09-15 17:56:55.742644	107	Me encantÔö£Ôöé, la recomiendo.	2
932	2025-09-15 17:56:55.742644	108	Me encantÔö£Ôöé, la recomiendo.	2
933	2025-09-15 17:56:55.742644	109	Me encantÔö£Ôöé, la recomiendo.	2
934	2025-09-15 17:56:55.742644	110	Me encantÔö£Ôöé, la recomiendo.	2
935	2025-09-15 17:56:55.742644	111	Me encantÔö£Ôöé, la recomiendo.	2
936	2025-09-15 17:56:55.742644	112	Me encantÔö£Ôöé, la recomiendo.	2
937	2025-09-15 17:56:55.742644	113	Me encantÔö£Ôöé, la recomiendo.	2
938	2025-09-15 17:56:55.742644	114	Me encantÔö£Ôöé, la recomiendo.	2
939	2025-09-15 17:56:55.742644	115	Me encantÔö£Ôöé, la recomiendo.	2
940	2025-09-15 17:56:55.742644	116	Me encantÔö£Ôöé, la recomiendo.	2
941	2025-09-15 17:56:55.742644	117	Me encantÔö£Ôöé, la recomiendo.	2
942	2025-09-15 17:56:55.742644	118	Me encantÔö£Ôöé, la recomiendo.	2
943	2025-09-15 17:56:55.742644	119	Me encantÔö£Ôöé, la recomiendo.	2
944	2025-09-15 17:56:55.742644	120	Me encantÔö£Ôöé, la recomiendo.	2
945	2025-09-15 17:56:55.742644	121	Me encantÔö£Ôöé, la recomiendo.	2
946	2025-09-15 17:56:55.742644	122	Me encantÔö£Ôöé, la recomiendo.	2
947	2025-09-15 17:56:55.742644	123	Me encantÔö£Ôöé, la recomiendo.	2
948	2025-09-15 17:56:55.742644	124	Me encantÔö£Ôöé, la recomiendo.	2
949	2025-09-15 17:56:55.742644	125	Me encantÔö£Ôöé, la recomiendo.	2
950	2025-09-15 17:56:55.742644	126	Me encantÔö£Ôöé, la recomiendo.	2
951	2025-09-15 17:56:55.742644	127	Me encantÔö£Ôöé, la recomiendo.	2
952	2025-09-15 17:56:55.742644	128	Me encantÔö£Ôöé, la recomiendo.	2
953	2025-09-15 17:56:55.742644	129	Me encantÔö£Ôöé, la recomiendo.	2
954	2025-09-15 17:56:55.742644	130	Me encantÔö£Ôöé, la recomiendo.	2
955	2025-09-15 17:56:55.742644	131	Me encantÔö£Ôöé, la recomiendo.	2
956	2025-09-15 17:56:55.742644	132	Me encantÔö£Ôöé, la recomiendo.	2
957	2025-09-15 17:56:55.742644	133	Me encantÔö£Ôöé, la recomiendo.	2
958	2025-09-15 17:56:55.742644	134	Me encantÔö£Ôöé, la recomiendo.	2
959	2025-09-15 17:56:55.742644	135	Me encantÔö£Ôöé, la recomiendo.	2
960	2025-09-15 17:56:55.742644	136	Me encantÔö£Ôöé, la recomiendo.	2
961	2025-09-15 17:56:55.742644	137	Me encantÔö£Ôöé, la recomiendo.	2
962	2025-09-15 17:56:55.742644	138	Me encantÔö£Ôöé, la recomiendo.	2
963	2025-09-15 17:56:55.742644	139	Me encantÔö£Ôöé, la recomiendo.	2
964	2025-09-15 17:56:55.742644	140	Me encantÔö£Ôöé, la recomiendo.	2
965	2025-09-15 17:56:55.742644	141	Me encantÔö£Ôöé, la recomiendo.	2
966	2025-09-15 17:56:55.742644	142	Me encantÔö£Ôöé, la recomiendo.	2
967	2025-09-15 17:56:55.742644	143	Me encantÔö£Ôöé, la recomiendo.	2
968	2025-09-15 17:56:55.742644	144	Me encantÔö£Ôöé, la recomiendo.	2
969	2025-09-15 17:56:55.742644	145	Me encantÔö£Ôöé, la recomiendo.	2
970	2025-09-15 17:56:55.742644	146	Me encantÔö£Ôöé, la recomiendo.	2
971	2025-09-15 17:56:55.742644	147	Me encantÔö£Ôöé, la recomiendo.	2
972	2025-09-15 17:56:55.742644	148	Me encantÔö£Ôöé, la recomiendo.	2
973	2025-09-15 17:56:55.742644	149	Me encantÔö£Ôöé, la recomiendo.	2
974	2025-09-15 17:56:55.742644	150	Me encantÔö£Ôöé, la recomiendo.	2
975	2025-09-15 17:56:55.742644	151	Me encantÔö£Ôöé, la recomiendo.	2
976	2025-09-15 17:56:55.742644	152	Me encantÔö£Ôöé, la recomiendo.	2
977	2025-09-15 17:56:55.742644	153	Me encantÔö£Ôöé, la recomiendo.	2
978	2025-09-15 17:56:55.742644	154	Me encantÔö£Ôöé, la recomiendo.	2
979	2025-09-15 17:56:55.742644	155	Me encantÔö£Ôöé, la recomiendo.	2
980	2025-09-15 17:56:55.742644	156	Me encantÔö£Ôöé, la recomiendo.	2
981	2025-09-15 17:56:55.742644	157	Me encantÔö£Ôöé, la recomiendo.	2
982	2025-09-15 17:56:55.742644	158	Me encantÔö£Ôöé, la recomiendo.	2
983	2025-09-15 17:56:55.742644	159	Me encantÔö£Ôöé, la recomiendo.	2
984	2025-09-15 17:56:55.742644	160	Me encantÔö£Ôöé, la recomiendo.	2
985	2025-09-15 17:56:55.742644	161	Me encantÔö£Ôöé, la recomiendo.	2
986	2025-09-15 17:56:55.742644	162	Me encantÔö£Ôöé, la recomiendo.	2
987	2025-09-15 17:56:55.742644	163	Me encantÔö£Ôöé, la recomiendo.	2
988	2025-09-15 17:56:55.742644	164	Me encantÔö£Ôöé, la recomiendo.	2
989	2025-09-15 17:56:55.742644	165	Me encantÔö£Ôöé, la recomiendo.	2
990	2025-09-15 17:56:55.742644	166	Me encantÔö£Ôöé, la recomiendo.	2
991	2025-09-15 17:56:55.742644	167	Me encantÔö£Ôöé, la recomiendo.	2
992	2025-09-15 17:56:55.742644	168	Me encantÔö£Ôöé, la recomiendo.	2
993	2025-09-15 17:56:55.742644	169	Me encantÔö£Ôöé, la recomiendo.	2
994	2025-09-15 17:56:55.742644	170	Me encantÔö£Ôöé, la recomiendo.	2
995	2025-09-15 17:56:55.742644	171	Me encantÔö£Ôöé, la recomiendo.	2
996	2025-09-15 17:56:55.742644	172	Me encantÔö£Ôöé, la recomiendo.	2
997	2025-09-15 17:56:55.742644	173	Me encantÔö£Ôöé, la recomiendo.	2
998	2025-09-15 17:56:55.742644	174	Me encantÔö£Ôöé, la recomiendo.	2
999	2025-09-15 17:56:55.742644	175	Me encantÔö£Ôöé, la recomiendo.	2
1000	2025-09-15 17:56:55.742644	176	Me encantÔö£Ôöé, la recomiendo.	2
1001	2025-09-15 17:56:55.742644	177	Me encantÔö£Ôöé, la recomiendo.	2
1002	2025-09-15 17:56:55.742644	178	Me encantÔö£Ôöé, la recomiendo.	2
1003	2025-09-15 17:56:55.742644	179	Me encantÔö£Ôöé, la recomiendo.	2
1004	2025-09-15 17:56:55.742644	180	Me encantÔö£Ôöé, la recomiendo.	2
1005	2025-09-15 17:56:55.742644	181	Me encantÔö£Ôöé, la recomiendo.	2
1006	2025-09-15 17:56:55.742644	182	Me encantÔö£Ôöé, la recomiendo.	2
1007	2025-09-15 17:56:55.742644	183	Me encantÔö£Ôöé, la recomiendo.	2
1008	2025-09-15 17:56:55.742644	184	Me encantÔö£Ôöé, la recomiendo.	2
1009	2025-09-15 17:56:55.742644	185	Me encantÔö£Ôöé, la recomiendo.	2
1010	2025-09-15 17:56:55.742644	186	Me encantÔö£Ôöé, la recomiendo.	2
1011	2025-09-15 17:56:55.742644	187	Me encantÔö£Ôöé, la recomiendo.	2
1012	2025-09-15 17:56:55.742644	188	Me encantÔö£Ôöé, la recomiendo.	2
1013	2025-09-15 17:56:55.742644	189	Me encantÔö£Ôöé, la recomiendo.	2
1014	2025-09-15 17:56:55.742644	190	Me encantÔö£Ôöé, la recomiendo.	2
1015	2025-09-15 17:56:55.742644	191	Me encantÔö£Ôöé, la recomiendo.	2
1016	2025-09-15 17:56:55.742644	192	Me encantÔö£Ôöé, la recomiendo.	2
1017	2025-09-15 17:56:55.742644	193	Me encantÔö£Ôöé, la recomiendo.	2
1018	2025-09-15 17:56:55.742644	194	Me encantÔö£Ôöé, la recomiendo.	2
1019	2025-09-15 17:56:55.742644	195	Me encantÔö£Ôöé, la recomiendo.	2
1020	2025-09-15 17:56:55.742644	196	Me encantÔö£Ôöé, la recomiendo.	2
1021	2025-09-15 17:56:55.742644	197	Me encantÔö£Ôöé, la recomiendo.	2
1022	2025-09-15 17:56:55.742644	198	Me encantÔö£Ôöé, la recomiendo.	2
1023	2025-09-15 17:56:55.742644	199	Me encantÔö£Ôöé, la recomiendo.	2
1024	2025-09-15 17:56:55.742644	200	Me encantÔö£Ôöé, la recomiendo.	2
1025	2025-09-15 17:56:55.742644	201	Me encantÔö£Ôöé, la recomiendo.	2
1026	2025-09-15 17:56:55.742644	202	Me encantÔö£Ôöé, la recomiendo.	2
1027	2025-09-15 17:56:55.742644	203	Me encantÔö£Ôöé, la recomiendo.	2
1028	2025-09-15 17:56:55.742644	204	Me encantÔö£Ôöé, la recomiendo.	2
1029	2025-09-15 17:56:55.742644	205	Me encantÔö£Ôöé, la recomiendo.	2
1030	2025-09-15 17:56:55.742644	206	Me encantÔö£Ôöé, la recomiendo.	2
1031	2025-09-15 17:56:55.742644	207	Me encantÔö£Ôöé, la recomiendo.	2
1032	2025-09-15 17:56:55.742644	208	Me encantÔö£Ôöé, la recomiendo.	2
1033	2025-09-15 17:56:55.742644	209	Me encantÔö£Ôöé, la recomiendo.	2
1034	2025-09-15 17:56:55.742644	210	Me encantÔö£Ôöé, la recomiendo.	2
1035	2025-09-15 17:56:55.742644	211	Me encantÔö£Ôöé, la recomiendo.	2
1036	2025-09-15 17:56:55.742644	212	Me encantÔö£Ôöé, la recomiendo.	2
1037	2025-09-15 17:56:55.742644	213	Me encantÔö£Ôöé, la recomiendo.	2
1038	2025-09-15 17:56:55.742644	214	Me encantÔö£Ôöé, la recomiendo.	2
1039	2025-09-15 17:56:55.742644	215	Me encantÔö£Ôöé, la recomiendo.	2
1040	2025-09-15 17:56:55.742644	216	Me encantÔö£Ôöé, la recomiendo.	2
1041	2025-09-15 17:56:55.742644	217	Me encantÔö£Ôöé, la recomiendo.	2
1042	2025-09-15 17:56:55.742644	218	Me encantÔö£Ôöé, la recomiendo.	2
1043	2025-09-15 17:56:55.742644	219	Me encantÔö£Ôöé, la recomiendo.	2
1044	2025-09-15 17:56:55.742644	220	Me encantÔö£Ôöé, la recomiendo.	2
1045	2025-09-15 17:56:55.742644	221	Me encantÔö£Ôöé, la recomiendo.	2
1046	2025-09-15 17:56:55.742644	222	Me encantÔö£Ôöé, la recomiendo.	2
1047	2025-09-15 17:56:55.742644	223	Me encantÔö£Ôöé, la recomiendo.	2
1048	2025-09-15 17:56:55.742644	224	Me encantÔö£Ôöé, la recomiendo.	2
1049	2025-09-15 17:56:55.742644	225	Me encantÔö£Ôöé, la recomiendo.	2
1050	2025-09-15 17:56:55.742644	226	Me encantÔö£Ôöé, la recomiendo.	2
1051	2025-09-15 17:56:55.742644	227	Me encantÔö£Ôöé, la recomiendo.	2
1052	2025-09-15 17:56:55.742644	228	Me encantÔö£Ôöé, la recomiendo.	2
1053	2025-09-15 17:56:55.742644	229	Me encantÔö£Ôöé, la recomiendo.	2
1054	2025-09-15 17:56:55.742644	230	Me encantÔö£Ôöé, la recomiendo.	2
1055	2025-09-15 17:56:55.742644	231	Me encantÔö£Ôöé, la recomiendo.	2
1056	2025-09-15 17:56:55.742644	232	Me encantÔö£Ôöé, la recomiendo.	2
1057	2025-09-15 17:56:55.742644	233	Me encantÔö£Ôöé, la recomiendo.	2
1058	2025-09-15 17:56:55.742644	234	Me encantÔö£Ôöé, la recomiendo.	2
1059	2025-09-15 17:56:55.742644	235	Me encantÔö£Ôöé, la recomiendo.	2
1060	2025-09-15 17:56:55.742644	236	Me encantÔö£Ôöé, la recomiendo.	2
1061	2025-09-15 17:56:55.742644	237	Me encantÔö£Ôöé, la recomiendo.	2
1062	2025-09-15 17:56:55.742644	238	Me encantÔö£Ôöé, la recomiendo.	2
1063	2025-09-15 17:56:55.742644	239	Me encantÔö£Ôöé, la recomiendo.	2
1064	2025-09-15 17:56:55.742644	240	Me encantÔö£Ôöé, la recomiendo.	2
1065	2025-09-15 17:56:55.742644	241	Me encantÔö£Ôöé, la recomiendo.	2
1066	2025-09-15 17:56:55.742644	242	Me encantÔö£Ôöé, la recomiendo.	2
1067	2025-09-15 17:56:55.742644	243	Me encantÔö£Ôöé, la recomiendo.	2
1068	2025-09-15 17:56:55.742644	244	Me encantÔö£Ôöé, la recomiendo.	2
1069	2025-09-15 17:56:55.742644	245	Me encantÔö£Ôöé, la recomiendo.	2
1070	2025-09-15 17:56:55.742644	246	Me encantÔö£Ôöé, la recomiendo.	2
1071	2025-09-15 17:56:55.742644	247	Me encantÔö£Ôöé, la recomiendo.	2
1072	2025-09-15 17:56:55.742644	248	Me encantÔö£Ôöé, la recomiendo.	2
1073	2025-09-15 17:56:55.742644	249	Me encantÔö£Ôöé, la recomiendo.	2
1074	2025-09-15 17:56:55.742644	250	Me encantÔö£Ôöé, la recomiendo.	2
1075	2025-09-15 17:56:55.742644	251	Me encantÔö£Ôöé, la recomiendo.	2
1076	2025-09-15 17:56:55.742644	252	Me encantÔö£Ôöé, la recomiendo.	2
1077	2025-09-15 17:56:55.742644	253	Me encantÔö£Ôöé, la recomiendo.	2
1078	2025-09-15 17:56:55.742644	254	Me encantÔö£Ôöé, la recomiendo.	2
1079	2025-09-15 17:56:55.742644	255	Me encantÔö£Ôöé, la recomiendo.	2
1080	2025-09-15 17:56:55.742644	256	Me encantÔö£Ôöé, la recomiendo.	2
1081	2025-09-15 17:56:55.742644	257	Me encantÔö£Ôöé, la recomiendo.	2
1082	2025-09-15 17:56:55.742644	258	Me encantÔö£Ôöé, la recomiendo.	2
1083	2025-09-15 17:56:55.742644	259	Me encantÔö£Ôöé, la recomiendo.	2
1084	2025-09-15 17:56:55.742644	260	Me encantÔö£Ôöé, la recomiendo.	2
1085	2025-09-15 17:56:55.742644	261	Me encantÔö£Ôöé, la recomiendo.	2
1086	2025-09-15 17:56:55.742644	262	Me encantÔö£Ôöé, la recomiendo.	2
1087	2025-09-15 17:56:55.742644	263	Me encantÔö£Ôöé, la recomiendo.	2
1088	2025-09-15 17:56:55.742644	264	Me encantÔö£Ôöé, la recomiendo.	2
1089	2025-09-15 17:56:55.742644	265	Me encantÔö£Ôöé, la recomiendo.	2
1090	2025-09-15 17:56:55.742644	266	Me encantÔö£Ôöé, la recomiendo.	2
1091	2025-09-15 17:56:55.742644	267	Me encantÔö£Ôöé, la recomiendo.	2
1092	2025-09-15 17:56:55.742644	268	Me encantÔö£Ôöé, la recomiendo.	2
1093	2025-09-15 17:56:55.742644	269	Me encantÔö£Ôöé, la recomiendo.	2
1094	2025-09-15 17:56:55.742644	270	Me encantÔö£Ôöé, la recomiendo.	2
1095	2025-09-15 17:56:55.742644	271	Me encantÔö£Ôöé, la recomiendo.	2
1096	2025-09-15 17:56:55.742644	272	Me encantÔö£Ôöé, la recomiendo.	2
1097	2025-09-15 17:56:55.742644	273	Me encantÔö£Ôöé, la recomiendo.	2
1098	2025-09-15 17:56:55.742644	274	Me encantÔö£Ôöé, la recomiendo.	2
1099	2025-09-15 17:56:55.742644	275	Me encantÔö£Ôöé, la recomiendo.	2
1100	2025-09-15 17:56:55.742644	276	Me encantÔö£Ôöé, la recomiendo.	2
1101	2025-09-15 17:56:55.742644	277	Me encantÔö£Ôöé, la recomiendo.	2
1102	2025-09-15 17:56:55.742644	278	Me encantÔö£Ôöé, la recomiendo.	2
1103	2025-09-15 17:56:55.742644	279	Me encantÔö£Ôöé, la recomiendo.	2
1104	2025-09-15 17:56:55.742644	280	Me encantÔö£Ôöé, la recomiendo.	2
1105	2025-09-15 17:56:55.742644	281	Me encantÔö£Ôöé, la recomiendo.	2
1106	2025-09-15 17:56:55.742644	282	Me encantÔö£Ôöé, la recomiendo.	2
1107	2025-09-15 17:56:55.742644	283	Me encantÔö£Ôöé, la recomiendo.	2
1108	2025-09-15 17:56:55.742644	284	Me encantÔö£Ôöé, la recomiendo.	2
1109	2025-09-15 17:56:55.742644	285	Me encantÔö£Ôöé, la recomiendo.	2
1110	2025-09-15 17:56:55.742644	286	Me encantÔö£Ôöé, la recomiendo.	2
1111	2025-09-15 17:56:55.742644	287	Me encantÔö£Ôöé, la recomiendo.	2
1112	2025-09-15 17:56:55.742644	288	Me encantÔö£Ôöé, la recomiendo.	2
1113	2025-09-15 17:56:55.742644	289	Me encantÔö£Ôöé, la recomiendo.	2
1114	2025-09-15 17:56:55.742644	290	Me encantÔö£Ôöé, la recomiendo.	2
1115	2025-09-15 17:56:55.742644	291	Me encantÔö£Ôöé, la recomiendo.	2
1116	2025-09-15 17:56:55.742644	292	Me encantÔö£Ôöé, la recomiendo.	2
1117	2025-09-15 17:56:55.742644	293	Me encantÔö£Ôöé, la recomiendo.	2
1118	2025-09-15 17:56:55.742644	294	Me encantÔö£Ôöé, la recomiendo.	2
1119	2025-09-15 17:56:55.742644	295	Me encantÔö£Ôöé, la recomiendo.	2
1120	2025-09-15 17:56:55.742644	296	Me encantÔö£Ôöé, la recomiendo.	2
1121	2025-09-15 17:56:55.742644	297	Me encantÔö£Ôöé, la recomiendo.	2
1122	2025-09-15 17:56:55.742644	298	Me encantÔö£Ôöé, la recomiendo.	2
1123	2025-09-15 17:56:55.742644	299	Me encantÔö£Ôöé, la recomiendo.	2
1124	2025-09-15 17:56:55.742644	300	Me encantÔö£Ôöé, la recomiendo.	2
1125	2025-09-15 17:56:55.742644	301	Me encantÔö£Ôöé, la recomiendo.	2
1126	2025-09-15 17:56:55.742644	302	Me encantÔö£Ôöé, la recomiendo.	2
1127	2025-09-15 17:56:55.742644	303	Me encantÔö£Ôöé, la recomiendo.	2
1128	2025-09-15 17:56:55.742644	304	Me encantÔö£Ôöé, la recomiendo.	2
1129	2025-09-15 17:56:55.742644	305	Me encantÔö£Ôöé, la recomiendo.	2
1130	2025-09-15 17:56:55.742644	306	Me encantÔö£Ôöé, la recomiendo.	2
1131	2025-09-15 17:56:55.742644	307	Me encantÔö£Ôöé, la recomiendo.	2
1132	2025-09-15 17:56:55.742644	308	Me encantÔö£Ôöé, la recomiendo.	2
1133	2025-09-15 17:56:55.742644	309	Me encantÔö£Ôöé, la recomiendo.	2
1134	2025-09-15 17:56:55.742644	310	Me encantÔö£Ôöé, la recomiendo.	2
1135	2025-09-15 17:56:55.742644	311	Me encantÔö£Ôöé, la recomiendo.	2
1136	2025-09-15 17:56:55.742644	312	Me encantÔö£Ôöé, la recomiendo.	2
1137	2025-09-15 17:56:55.742644	313	Me encantÔö£Ôöé, la recomiendo.	2
1138	2025-09-15 17:56:55.742644	314	Me encantÔö£Ôöé, la recomiendo.	2
1139	2025-09-15 17:56:55.742644	315	Me encantÔö£Ôöé, la recomiendo.	2
1140	2025-09-15 17:56:55.742644	316	Me encantÔö£Ôöé, la recomiendo.	2
1141	2025-09-15 17:56:55.742644	317	Me encantÔö£Ôöé, la recomiendo.	2
1142	2025-09-15 17:56:55.742644	318	Me encantÔö£Ôöé, la recomiendo.	2
1143	2025-09-15 17:56:55.742644	319	Me encantÔö£Ôöé, la recomiendo.	2
1144	2025-09-15 17:56:55.742644	320	Me encantÔö£Ôöé, la recomiendo.	2
1145	2025-09-15 17:56:55.742644	321	Me encantÔö£Ôöé, la recomiendo.	2
1146	2025-09-15 17:56:55.742644	322	Me encantÔö£Ôöé, la recomiendo.	2
1147	2025-09-15 17:56:55.742644	323	Me encantÔö£Ôöé, la recomiendo.	2
1148	2025-09-15 17:56:55.742644	324	Me encantÔö£Ôöé, la recomiendo.	2
1149	2025-09-15 17:56:55.742644	325	Me encantÔö£Ôöé, la recomiendo.	2
1150	2025-09-15 17:56:55.742644	326	Me encantÔö£Ôöé, la recomiendo.	2
1151	2025-09-15 17:56:55.742644	327	Me encantÔö£Ôöé, la recomiendo.	2
1152	2025-09-15 17:56:55.742644	328	Me encantÔö£Ôöé, la recomiendo.	2
1153	2025-09-15 17:56:55.742644	329	Me encantÔö£Ôöé, la recomiendo.	2
1154	2025-09-15 17:56:55.742644	330	Me encantÔö£Ôöé, la recomiendo.	2
1155	2025-09-15 17:56:55.742644	331	Me encantÔö£Ôöé, la recomiendo.	2
1156	2025-09-15 17:56:55.742644	332	Me encantÔö£Ôöé, la recomiendo.	2
1157	2025-09-15 17:56:55.742644	333	Me encantÔö£Ôöé, la recomiendo.	2
1158	2025-09-15 17:56:55.742644	334	Me encantÔö£Ôöé, la recomiendo.	2
1159	2025-09-15 17:56:55.742644	335	Me encantÔö£Ôöé, la recomiendo.	2
1160	2025-09-15 17:56:55.742644	336	Me encantÔö£Ôöé, la recomiendo.	2
1161	2025-09-15 17:56:55.742644	337	Me encantÔö£Ôöé, la recomiendo.	2
1162	2025-09-15 17:56:55.742644	338	Me encantÔö£Ôöé, la recomiendo.	2
1163	2025-09-15 17:56:55.742644	339	Me encantÔö£Ôöé, la recomiendo.	2
1164	2025-09-15 17:56:55.742644	340	Me encantÔö£Ôöé, la recomiendo.	2
1165	2025-09-15 17:56:55.742644	341	Me encantÔö£Ôöé, la recomiendo.	2
1166	2025-09-15 17:56:55.742644	342	Me encantÔö£Ôöé, la recomiendo.	2
1167	2025-09-15 17:56:55.742644	343	Me encantÔö£Ôöé, la recomiendo.	2
1168	2025-09-15 17:56:55.742644	344	Me encantÔö£Ôöé, la recomiendo.	2
1169	2025-09-15 17:56:55.742644	345	Me encantÔö£Ôöé, la recomiendo.	2
1170	2025-09-15 17:56:55.742644	346	Me encantÔö£Ôöé, la recomiendo.	2
1171	2025-09-15 17:56:55.742644	347	Me encantÔö£Ôöé, la recomiendo.	2
1172	2025-09-15 17:56:55.742644	348	Me encantÔö£Ôöé, la recomiendo.	2
1173	2025-09-15 17:56:55.742644	349	Me encantÔö£Ôöé, la recomiendo.	2
1174	2025-09-15 17:56:55.742644	350	Me encantÔö£Ôöé, la recomiendo.	2
1175	2025-09-15 17:56:55.742644	351	Me encantÔö£Ôöé, la recomiendo.	2
1176	2025-09-15 17:56:55.742644	352	Me encantÔö£Ôöé, la recomiendo.	2
1177	2025-09-15 17:56:55.742644	353	Me encantÔö£Ôöé, la recomiendo.	2
1178	2025-09-15 17:56:55.742644	354	Me encantÔö£Ôöé, la recomiendo.	2
1179	2025-09-15 17:56:55.742644	355	Me encantÔö£Ôöé, la recomiendo.	2
1180	2025-09-15 17:56:55.742644	356	Me encantÔö£Ôöé, la recomiendo.	2
1181	2025-09-15 17:56:55.742644	357	Me encantÔö£Ôöé, la recomiendo.	2
1182	2025-09-15 17:56:55.742644	358	Me encantÔö£Ôöé, la recomiendo.	2
1183	2025-09-15 17:56:55.742644	359	Me encantÔö£Ôöé, la recomiendo.	2
1184	2025-09-15 17:56:55.742644	360	Me encantÔö£Ôöé, la recomiendo.	2
1185	2025-09-15 17:56:55.742644	361	Me encantÔö£Ôöé, la recomiendo.	2
1186	2025-09-15 17:56:55.742644	362	Me encantÔö£Ôöé, la recomiendo.	2
1187	2025-09-15 17:56:55.742644	363	Me encantÔö£Ôöé, la recomiendo.	2
1188	2025-09-15 17:56:55.742644	364	Me encantÔö£Ôöé, la recomiendo.	2
1189	2025-09-15 17:56:55.742644	365	Me encantÔö£Ôöé, la recomiendo.	2
1190	2025-09-15 17:56:55.742644	366	Me encantÔö£Ôöé, la recomiendo.	2
1191	2025-09-15 17:56:55.742644	367	Me encantÔö£Ôöé, la recomiendo.	2
1192	2025-09-15 17:56:55.742644	368	Me encantÔö£Ôöé, la recomiendo.	2
1193	2025-09-15 17:56:55.742644	369	Me encantÔö£Ôöé, la recomiendo.	2
1194	2025-09-15 17:56:55.742644	370	Me encantÔö£Ôöé, la recomiendo.	2
1195	2025-09-15 17:56:55.742644	371	Me encantÔö£Ôöé, la recomiendo.	2
1196	2025-09-15 17:56:55.742644	372	Me encantÔö£Ôöé, la recomiendo.	2
1197	2025-09-15 17:56:55.742644	373	Me encantÔö£Ôöé, la recomiendo.	2
1198	2025-09-15 17:56:55.742644	374	Me encantÔö£Ôöé, la recomiendo.	2
1199	2025-09-15 17:56:55.742644	375	Me encantÔö£Ôöé, la recomiendo.	2
1200	2025-09-15 17:56:55.742644	376	Me encantÔö£Ôöé, la recomiendo.	2
1201	2025-09-15 17:56:55.742644	377	Me encantÔö£Ôöé, la recomiendo.	2
1202	2025-09-15 17:56:55.742644	378	Me encantÔö£Ôöé, la recomiendo.	2
1203	2025-09-15 17:56:55.742644	379	Me encantÔö£Ôöé, la recomiendo.	2
1204	2025-09-15 17:56:55.742644	380	Me encantÔö£Ôöé, la recomiendo.	2
1205	2025-09-15 17:56:55.742644	381	Me encantÔö£Ôöé, la recomiendo.	2
1206	2025-09-15 17:56:55.742644	382	Me encantÔö£Ôöé, la recomiendo.	2
1207	2025-09-15 17:56:55.742644	383	Me encantÔö£Ôöé, la recomiendo.	2
1208	2025-09-15 17:56:55.742644	384	Me encantÔö£Ôöé, la recomiendo.	2
1209	2025-09-15 17:56:55.742644	385	Me encantÔö£Ôöé, la recomiendo.	2
1210	2025-09-15 17:56:55.742644	386	Me encantÔö£Ôöé, la recomiendo.	2
1211	2025-09-15 17:56:55.742644	387	Me encantÔö£Ôöé, la recomiendo.	2
1212	2025-09-15 17:56:55.742644	388	Me encantÔö£Ôöé, la recomiendo.	2
1213	2025-09-15 17:56:55.742644	389	Me encantÔö£Ôöé, la recomiendo.	2
1214	2025-09-15 17:56:55.742644	390	Me encantÔö£Ôöé, la recomiendo.	2
1215	2025-09-15 17:56:55.742644	391	Me encantÔö£Ôöé, la recomiendo.	2
1216	2025-09-15 17:56:55.742644	392	Me encantÔö£Ôöé, la recomiendo.	2
1217	2025-09-15 17:56:55.742644	393	Me encantÔö£Ôöé, la recomiendo.	2
1218	2025-09-15 17:56:55.742644	394	Me encantÔö£Ôöé, la recomiendo.	2
1219	2025-09-15 17:56:55.742644	395	Me encantÔö£Ôöé, la recomiendo.	2
1220	2025-09-15 17:56:55.742644	396	Me encantÔö£Ôöé, la recomiendo.	2
1221	2025-09-15 17:56:55.742644	397	Me encantÔö£Ôöé, la recomiendo.	2
1222	2025-09-15 17:56:55.742644	398	Me encantÔö£Ôöé, la recomiendo.	2
1223	2025-09-15 17:56:55.742644	399	Me encantÔö£Ôöé, la recomiendo.	2
1224	2025-09-15 17:56:55.742644	400	Me encantÔö£Ôöé, la recomiendo.	2
1225	2025-09-15 17:56:55.742644	401	Me encantÔö£Ôöé, la recomiendo.	2
1226	2025-09-15 17:56:55.742644	402	Me encantÔö£Ôöé, la recomiendo.	2
1227	2025-09-15 17:56:55.742644	403	Me encantÔö£Ôöé, la recomiendo.	2
1228	2025-09-15 17:56:55.742644	404	Me encantÔö£Ôöé, la recomiendo.	2
1229	2025-09-15 17:56:55.742644	405	Me encantÔö£Ôöé, la recomiendo.	2
1230	2025-09-15 17:56:55.742644	406	Me encantÔö£Ôöé, la recomiendo.	2
1231	2025-09-15 17:56:55.742644	407	Me encantÔö£Ôöé, la recomiendo.	2
1232	2025-09-15 17:56:55.742644	408	Me encantÔö£Ôöé, la recomiendo.	2
1233	2025-09-15 17:56:55.742644	409	Me encantÔö£Ôöé, la recomiendo.	2
1234	2025-09-15 17:56:55.742644	410	Me encantÔö£Ôöé, la recomiendo.	2
1235	2025-09-15 17:56:55.742644	411	Me encantÔö£Ôöé, la recomiendo.	2
1236	2025-09-15 17:56:55.742644	412	Me encantÔö£Ôöé, la recomiendo.	2
1237	2025-09-15 17:56:55.742644	413	Me encantÔö£Ôöé, la recomiendo.	2
1238	2025-09-15 17:56:55.742644	414	Me encantÔö£Ôöé, la recomiendo.	2
1239	2025-09-15 17:56:55.742644	415	Me encantÔö£Ôöé, la recomiendo.	2
1240	2025-09-15 17:56:55.742644	416	Me encantÔö£Ôöé, la recomiendo.	2
1241	2025-09-15 17:56:55.742644	417	Me encantÔö£Ôöé, la recomiendo.	2
1242	2025-09-15 17:56:55.742644	418	Me encantÔö£Ôöé, la recomiendo.	2
1243	2025-09-15 17:56:55.742644	419	Me encantÔö£Ôöé, la recomiendo.	2
1244	2025-09-15 17:56:55.742644	420	Me encantÔö£Ôöé, la recomiendo.	2
1245	2025-09-15 17:56:55.742644	421	Me encantÔö£Ôöé, la recomiendo.	2
1246	2025-09-15 17:56:55.742644	422	Me encantÔö£Ôöé, la recomiendo.	2
1247	2025-09-15 17:56:55.742644	423	Me encantÔö£Ôöé, la recomiendo.	2
1248	2025-09-15 17:56:55.742644	424	Me encantÔö£Ôöé, la recomiendo.	2
1249	2025-09-15 17:56:55.742644	425	Me encantÔö£Ôöé, la recomiendo.	2
1250	2025-09-15 17:56:55.742644	426	Me encantÔö£Ôöé, la recomiendo.	2
1251	2025-09-15 17:56:55.742644	427	Me encantÔö£Ôöé, la recomiendo.	2
1252	2025-09-15 17:56:55.742644	428	Me encantÔö£Ôöé, la recomiendo.	2
1253	2025-09-15 17:56:55.742644	429	Me encantÔö£Ôöé, la recomiendo.	2
1254	2025-09-15 17:56:55.742644	430	Me encantÔö£Ôöé, la recomiendo.	2
1255	2025-09-15 17:56:55.742644	431	Me encantÔö£Ôöé, la recomiendo.	2
1256	2025-09-15 17:56:55.742644	432	Me encantÔö£Ôöé, la recomiendo.	2
1257	2025-09-15 17:56:55.742644	433	Me encantÔö£Ôöé, la recomiendo.	2
1258	2025-09-15 17:56:55.742644	434	Me encantÔö£Ôöé, la recomiendo.	2
1259	2025-09-15 17:56:55.742644	435	Me encantÔö£Ôöé, la recomiendo.	2
1260	2025-09-15 17:56:55.742644	436	Me encantÔö£Ôöé, la recomiendo.	2
1261	2025-09-15 17:56:55.742644	437	Me encantÔö£Ôöé, la recomiendo.	2
1262	2025-09-15 17:56:55.742644	438	Me encantÔö£Ôöé, la recomiendo.	2
1263	2025-09-15 17:56:55.742644	439	Me encantÔö£Ôöé, la recomiendo.	2
1264	2025-09-15 17:56:55.742644	440	Me encantÔö£Ôöé, la recomiendo.	2
1265	2025-09-15 17:56:55.742644	441	Me encantÔö£Ôöé, la recomiendo.	2
1266	2025-09-15 17:56:55.742644	442	Me encantÔö£Ôöé, la recomiendo.	2
1267	2025-09-15 17:56:55.742644	443	Me encantÔö£Ôöé, la recomiendo.	2
1268	2025-09-15 17:56:55.742644	444	Me encantÔö£Ôöé, la recomiendo.	2
1269	2025-09-15 17:56:55.742644	445	Me encantÔö£Ôöé, la recomiendo.	2
1270	2025-09-15 17:56:55.742644	446	Me encantÔö£Ôöé, la recomiendo.	2
1271	2025-09-15 17:56:55.742644	447	Me encantÔö£Ôöé, la recomiendo.	2
1272	2025-09-15 17:56:55.742644	448	Me encantÔö£Ôöé, la recomiendo.	2
1273	2025-09-15 17:56:55.742644	449	Me encantÔö£Ôöé, la recomiendo.	2
1274	2025-09-15 17:56:55.742644	450	Me encantÔö£Ôöé, la recomiendo.	2
1275	2025-09-15 17:56:55.742644	451	Me encantÔö£Ôöé, la recomiendo.	2
1276	2025-09-15 17:56:55.742644	452	Me encantÔö£Ôöé, la recomiendo.	2
1277	2025-09-15 17:56:55.742644	453	Me encantÔö£Ôöé, la recomiendo.	2
1278	2025-09-15 17:56:55.742644	454	Me encantÔö£Ôöé, la recomiendo.	2
1279	2025-09-15 17:56:55.742644	455	Me encantÔö£Ôöé, la recomiendo.	2
1280	2025-09-15 17:56:55.742644	456	Me encantÔö£Ôöé, la recomiendo.	2
1281	2025-09-15 17:56:55.742644	457	Me encantÔö£Ôöé, la recomiendo.	2
1282	2025-09-15 17:56:55.742644	458	Me encantÔö£Ôöé, la recomiendo.	2
1283	2025-09-15 17:56:55.742644	459	Me encantÔö£Ôöé, la recomiendo.	2
1284	2025-09-15 17:56:55.742644	460	Me encantÔö£Ôöé, la recomiendo.	2
1285	2025-09-15 17:56:55.742644	461	Me encantÔö£Ôöé, la recomiendo.	2
1286	2025-09-15 17:56:55.742644	462	Me encantÔö£Ôöé, la recomiendo.	2
1287	2025-09-15 17:56:55.742644	463	Me encantÔö£Ôöé, la recomiendo.	2
1288	2025-09-15 17:56:55.742644	464	Me encantÔö£Ôöé, la recomiendo.	2
1289	2025-09-15 17:56:55.742644	465	Me encantÔö£Ôöé, la recomiendo.	2
1290	2025-09-15 17:56:55.742644	466	Me encantÔö£Ôöé, la recomiendo.	2
1291	2025-09-15 17:56:55.742644	467	Me encantÔö£Ôöé, la recomiendo.	2
1292	2025-09-15 17:56:55.742644	468	Me encantÔö£Ôöé, la recomiendo.	2
1293	2025-09-15 17:56:55.742644	469	Me encantÔö£Ôöé, la recomiendo.	2
1294	2025-09-15 17:56:55.742644	470	Me encantÔö£Ôöé, la recomiendo.	2
1295	2025-09-15 17:56:55.742644	471	Me encantÔö£Ôöé, la recomiendo.	2
1296	2025-09-15 17:56:55.742644	472	Me encantÔö£Ôöé, la recomiendo.	2
1297	2025-09-15 17:56:55.742644	473	Me encantÔö£Ôöé, la recomiendo.	2
1298	2025-09-15 17:56:55.742644	474	Me encantÔö£Ôöé, la recomiendo.	2
1299	2025-09-15 17:56:55.742644	475	Me encantÔö£Ôöé, la recomiendo.	2
1300	2025-09-15 17:56:55.742644	476	Me encantÔö£Ôöé, la recomiendo.	2
1301	2025-09-15 17:56:55.742644	477	Me encantÔö£Ôöé, la recomiendo.	2
1302	2025-09-15 17:56:55.742644	478	Me encantÔö£Ôöé, la recomiendo.	2
1303	2025-09-15 17:56:55.742644	479	Me encantÔö£Ôöé, la recomiendo.	2
1304	2025-09-15 17:56:55.742644	480	Me encantÔö£Ôöé, la recomiendo.	2
1305	2025-09-15 17:56:55.742644	481	Me encantÔö£Ôöé, la recomiendo.	2
1306	2025-09-15 17:56:55.742644	482	Me encantÔö£Ôöé, la recomiendo.	2
1307	2025-09-15 17:56:55.742644	483	Me encantÔö£Ôöé, la recomiendo.	2
1308	2025-09-15 17:56:55.742644	484	Me encantÔö£Ôöé, la recomiendo.	2
1309	2025-09-15 17:56:55.742644	485	Me encantÔö£Ôöé, la recomiendo.	2
1310	2025-09-15 17:56:55.742644	486	Me encantÔö£Ôöé, la recomiendo.	2
1311	2025-09-15 17:56:55.742644	487	Me encantÔö£Ôöé, la recomiendo.	2
1312	2025-09-15 17:56:55.742644	488	Me encantÔö£Ôöé, la recomiendo.	2
1313	2025-09-15 17:56:55.742644	489	Me encantÔö£Ôöé, la recomiendo.	2
1314	2025-09-15 17:56:55.742644	490	Me encantÔö£Ôöé, la recomiendo.	2
1315	2025-09-15 17:56:55.742644	491	Me encantÔö£Ôöé, la recomiendo.	2
1316	2025-09-15 17:56:55.742644	492	Me encantÔö£Ôöé, la recomiendo.	2
1317	2025-09-15 17:56:55.742644	493	Me encantÔö£Ôöé, la recomiendo.	2
1318	2025-09-15 17:56:55.742644	494	Me encantÔö£Ôöé, la recomiendo.	2
1319	2025-09-15 17:56:55.742644	495	Me encantÔö£Ôöé, la recomiendo.	2
1320	2025-09-15 17:56:55.742644	496	Me encantÔö£Ôöé, la recomiendo.	2
1321	2025-09-15 17:56:55.742644	497	Me encantÔö£Ôöé, la recomiendo.	2
1322	2025-09-15 17:56:55.742644	498	Me encantÔö£Ôöé, la recomiendo.	2
1323	2025-09-15 17:56:55.742644	499	Me encantÔö£Ôöé, la recomiendo.	2
1324	2025-09-15 17:56:55.742644	500	Me encantÔö£Ôöé, la recomiendo.	2
1325	2025-09-15 17:56:55.742644	501	Me encantÔö£Ôöé, la recomiendo.	2
1326	2025-09-15 17:56:55.742644	502	Me encantÔö£Ôöé, la recomiendo.	2
1327	2025-09-15 17:56:55.742644	503	Me encantÔö£Ôöé, la recomiendo.	2
1328	2025-09-15 17:56:55.742644	504	Me encantÔö£Ôöé, la recomiendo.	2
1329	2025-09-15 17:56:55.742644	505	Me encantÔö£Ôöé, la recomiendo.	2
1330	2025-09-15 17:56:55.742644	506	Me encantÔö£Ôöé, la recomiendo.	2
1331	2025-09-15 17:56:55.742644	507	Me encantÔö£Ôöé, la recomiendo.	2
1332	2025-09-15 17:56:55.742644	508	Me encantÔö£Ôöé, la recomiendo.	2
1333	2025-09-15 17:56:55.742644	509	Me encantÔö£Ôöé, la recomiendo.	2
1334	2025-09-15 17:56:55.742644	510	Me encantÔö£Ôöé, la recomiendo.	2
1335	2025-09-15 17:56:55.742644	511	Me encantÔö£Ôöé, la recomiendo.	2
1336	2025-09-15 17:56:55.742644	512	Me encantÔö£Ôöé, la recomiendo.	2
1337	2025-09-15 17:56:55.742644	513	Me encantÔö£Ôöé, la recomiendo.	2
1338	2025-09-15 17:56:55.742644	514	Me encantÔö£Ôöé, la recomiendo.	2
1339	2025-09-15 17:56:55.742644	515	Me encantÔö£Ôöé, la recomiendo.	2
1340	2025-09-15 17:56:55.742644	516	Me encantÔö£Ôöé, la recomiendo.	2
1341	2025-09-15 17:56:55.742644	517	Me encantÔö£Ôöé, la recomiendo.	2
1342	2025-09-15 17:56:55.742644	518	Me encantÔö£Ôöé, la recomiendo.	2
1343	2025-09-15 17:56:55.742644	519	Me encantÔö£Ôöé, la recomiendo.	2
1344	2025-09-15 17:56:55.742644	520	Me encantÔö£Ôöé, la recomiendo.	2
1345	2025-09-15 17:56:55.742644	521	Me encantÔö£Ôöé, la recomiendo.	2
1346	2025-09-15 17:56:55.742644	522	Me encantÔö£Ôöé, la recomiendo.	2
1347	2025-09-15 17:56:55.742644	523	Me encantÔö£Ôöé, la recomiendo.	2
1348	2025-09-15 17:56:55.742644	524	Me encantÔö£Ôöé, la recomiendo.	2
1349	2025-09-15 17:56:55.742644	525	Me encantÔö£Ôöé, la recomiendo.	2
1350	2025-09-15 17:56:55.742644	526	Me encantÔö£Ôöé, la recomiendo.	2
1351	2025-09-15 17:56:55.742644	527	Me encantÔö£Ôöé, la recomiendo.	2
1352	2025-09-15 17:56:55.742644	528	Me encantÔö£Ôöé, la recomiendo.	2
1353	2025-09-15 17:56:55.742644	529	Me encantÔö£Ôöé, la recomiendo.	2
1354	2025-09-15 17:56:55.742644	530	Me encantÔö£Ôöé, la recomiendo.	2
1355	2025-09-15 17:56:55.742644	531	Me encantÔö£Ôöé, la recomiendo.	2
1356	2025-09-15 17:56:55.742644	532	Me encantÔö£Ôöé, la recomiendo.	2
1357	2025-09-15 17:56:55.742644	533	Me encantÔö£Ôöé, la recomiendo.	2
1358	2025-09-15 17:56:55.742644	534	Me encantÔö£Ôöé, la recomiendo.	2
1359	2025-09-15 17:56:55.742644	535	Me encantÔö£Ôöé, la recomiendo.	2
1360	2025-09-15 17:56:55.742644	536	Me encantÔö£Ôöé, la recomiendo.	2
1361	2025-09-15 17:56:55.742644	537	Me encantÔö£Ôöé, la recomiendo.	2
1362	2025-09-15 17:56:55.742644	538	Me encantÔö£Ôöé, la recomiendo.	2
1363	2025-09-15 17:56:55.742644	539	Me encantÔö£Ôöé, la recomiendo.	2
1364	2025-09-15 17:56:55.742644	540	Me encantÔö£Ôöé, la recomiendo.	2
1365	2025-09-15 17:56:55.742644	541	Me encantÔö£Ôöé, la recomiendo.	2
1366	2025-09-15 17:56:55.742644	542	Me encantÔö£Ôöé, la recomiendo.	2
1367	2025-09-15 17:56:55.742644	543	Me encantÔö£Ôöé, la recomiendo.	2
1368	2025-09-15 17:56:55.742644	544	Me encantÔö£Ôöé, la recomiendo.	2
1369	2025-09-15 17:56:55.742644	545	Me encantÔö£Ôöé, la recomiendo.	2
1370	2025-09-15 17:56:55.742644	546	Me encantÔö£Ôöé, la recomiendo.	2
1371	2025-09-15 17:56:55.742644	547	Me encantÔö£Ôöé, la recomiendo.	2
1372	2025-09-15 17:56:55.742644	548	Me encantÔö£Ôöé, la recomiendo.	2
1373	2025-09-15 17:56:55.742644	549	Me encantÔö£Ôöé, la recomiendo.	2
1374	2025-09-15 17:56:55.742644	550	Me encantÔö£Ôöé, la recomiendo.	2
1375	2025-09-15 17:56:55.742644	551	Me encantÔö£Ôöé, la recomiendo.	2
1376	2025-09-15 17:56:55.742644	552	Me encantÔö£Ôöé, la recomiendo.	2
1377	2025-09-15 17:56:55.742644	553	Me encantÔö£Ôöé, la recomiendo.	2
1378	2025-09-15 17:56:55.742644	554	Me encantÔö£Ôöé, la recomiendo.	2
1379	2025-09-15 17:56:55.742644	555	Me encantÔö£Ôöé, la recomiendo.	2
1380	2025-09-15 17:56:55.742644	556	Me encantÔö£Ôöé, la recomiendo.	2
1381	2025-09-15 17:56:55.742644	557	Me encantÔö£Ôöé, la recomiendo.	2
1382	2025-09-15 17:56:55.742644	558	Me encantÔö£Ôöé, la recomiendo.	2
1383	2025-09-15 17:56:55.742644	559	Me encantÔö£Ôöé, la recomiendo.	2
1384	2025-09-15 17:56:55.742644	560	Me encantÔö£Ôöé, la recomiendo.	2
1385	2025-09-15 17:56:55.742644	561	Me encantÔö£Ôöé, la recomiendo.	2
1386	2025-09-15 17:56:55.742644	562	Me encantÔö£Ôöé, la recomiendo.	2
1387	2025-09-15 17:56:55.742644	563	Me encantÔö£Ôöé, la recomiendo.	2
1388	2025-09-15 17:56:55.742644	564	Me encantÔö£Ôöé, la recomiendo.	2
1389	2025-09-15 17:56:55.742644	565	Me encantÔö£Ôöé, la recomiendo.	2
1390	2025-09-15 17:56:55.742644	566	Me encantÔö£Ôöé, la recomiendo.	2
1391	2025-09-15 17:56:55.742644	567	Me encantÔö£Ôöé, la recomiendo.	2
1392	2025-09-15 17:56:55.742644	568	Me encantÔö£Ôöé, la recomiendo.	2
1393	2025-09-15 17:56:55.742644	569	Me encantÔö£Ôöé, la recomiendo.	2
1394	2025-09-15 17:56:55.742644	570	Me encantÔö£Ôöé, la recomiendo.	2
1395	2025-09-15 17:56:55.742644	571	Me encantÔö£Ôöé, la recomiendo.	2
1396	2025-09-15 17:56:55.742644	572	Me encantÔö£Ôöé, la recomiendo.	2
1397	2025-09-15 17:56:55.742644	573	Me encantÔö£Ôöé, la recomiendo.	2
1398	2025-09-15 17:56:55.742644	574	Me encantÔö£Ôöé, la recomiendo.	2
1399	2025-09-15 17:56:55.742644	575	Me encantÔö£Ôöé, la recomiendo.	2
1400	2025-09-15 17:56:55.742644	576	Me encantÔö£Ôöé, la recomiendo.	2
1401	2025-09-15 17:56:55.742644	577	Me encantÔö£Ôöé, la recomiendo.	2
1402	2025-09-15 17:56:55.742644	578	Me encantÔö£Ôöé, la recomiendo.	2
1403	2025-09-15 17:56:55.742644	579	Me encantÔö£Ôöé, la recomiendo.	2
1404	2025-09-15 17:56:55.742644	580	Me encantÔö£Ôöé, la recomiendo.	2
1405	2025-09-15 17:56:55.742644	581	Me encantÔö£Ôöé, la recomiendo.	2
1406	2025-09-15 17:56:55.742644	582	Me encantÔö£Ôöé, la recomiendo.	2
1407	2025-09-15 17:56:55.742644	583	Me encantÔö£Ôöé, la recomiendo.	2
1408	2025-09-15 17:56:55.742644	584	Me encantÔö£Ôöé, la recomiendo.	2
1409	2025-09-15 17:56:55.742644	585	Me encantÔö£Ôöé, la recomiendo.	2
1410	2025-09-15 17:56:55.742644	586	Me encantÔö£Ôöé, la recomiendo.	2
1411	2025-09-15 17:56:55.742644	587	Me encantÔö£Ôöé, la recomiendo.	2
1412	2025-09-15 17:56:55.742644	588	Me encantÔö£Ôöé, la recomiendo.	2
1413	2025-09-15 17:56:55.742644	589	Me encantÔö£Ôöé, la recomiendo.	2
1414	2025-09-15 17:56:55.742644	590	Me encantÔö£Ôöé, la recomiendo.	2
1415	2025-09-15 17:56:55.742644	591	Me encantÔö£Ôöé, la recomiendo.	2
1416	2025-09-15 17:56:55.742644	592	Me encantÔö£Ôöé, la recomiendo.	2
1417	2025-09-15 17:56:55.742644	593	Me encantÔö£Ôöé, la recomiendo.	2
1418	2025-09-15 17:56:55.742644	594	Me encantÔö£Ôöé, la recomiendo.	2
1419	2025-09-15 17:56:55.742644	595	Me encantÔö£Ôöé, la recomiendo.	2
1420	2025-09-15 17:56:55.742644	596	Me encantÔö£Ôöé, la recomiendo.	2
1421	2025-09-15 17:56:55.742644	597	Me encantÔö£Ôöé, la recomiendo.	2
1422	2025-09-15 17:56:55.742644	598	Me encantÔö£Ôöé, la recomiendo.	2
1423	2025-09-15 17:56:55.742644	599	Me encantÔö£Ôöé, la recomiendo.	2
1424	2025-09-15 17:56:55.742644	600	Me encantÔö£Ôöé, la recomiendo.	2
1425	2025-09-15 17:56:55.742644	601	Me encantÔö£Ôöé, la recomiendo.	2
1426	2025-09-15 17:56:55.742644	602	Me encantÔö£Ôöé, la recomiendo.	2
1427	2025-09-15 17:56:55.742644	603	Me encantÔö£Ôöé, la recomiendo.	2
1428	2025-09-15 17:56:55.742644	604	Me encantÔö£Ôöé, la recomiendo.	2
1429	2025-09-15 17:56:55.742644	605	Me encantÔö£Ôöé, la recomiendo.	2
1430	2025-09-15 17:56:55.742644	606	Me encantÔö£Ôöé, la recomiendo.	2
1431	2025-09-15 17:56:55.742644	607	Me encantÔö£Ôöé, la recomiendo.	2
1432	2025-09-15 17:56:55.742644	608	Me encantÔö£Ôöé, la recomiendo.	2
1433	2025-09-15 17:56:55.742644	609	Me encantÔö£Ôöé, la recomiendo.	2
1434	2025-09-15 17:56:55.742644	610	Me encantÔö£Ôöé, la recomiendo.	2
1435	2025-09-15 17:56:55.742644	611	Me encantÔö£Ôöé, la recomiendo.	2
1436	2025-09-15 17:56:55.742644	612	Me encantÔö£Ôöé, la recomiendo.	2
1437	2025-09-15 17:56:55.742644	613	Me encantÔö£Ôöé, la recomiendo.	2
1438	2025-09-15 17:56:55.742644	614	Me encantÔö£Ôöé, la recomiendo.	2
1439	2025-09-15 17:56:55.742644	615	Me encantÔö£Ôöé, la recomiendo.	2
1440	2025-09-15 17:56:55.742644	616	Me encantÔö£Ôöé, la recomiendo.	2
1441	2025-09-15 17:56:55.742644	617	Me encantÔö£Ôöé, la recomiendo.	2
1442	2025-09-15 17:56:55.742644	618	Me encantÔö£Ôöé, la recomiendo.	2
1443	2025-09-15 17:56:55.742644	619	Me encantÔö£Ôöé, la recomiendo.	2
1444	2025-09-15 17:56:55.742644	620	Me encantÔö£Ôöé, la recomiendo.	2
1445	2025-09-15 17:56:55.742644	621	Me encantÔö£Ôöé, la recomiendo.	2
1446	2025-09-15 17:56:55.742644	622	Me encantÔö£Ôöé, la recomiendo.	2
1447	2025-09-15 17:56:55.742644	623	Me encantÔö£Ôöé, la recomiendo.	2
1448	2025-09-15 17:56:55.742644	624	Me encantÔö£Ôöé, la recomiendo.	2
1449	2025-09-15 17:56:55.742644	625	Me encantÔö£Ôöé, la recomiendo.	2
1450	2025-09-15 17:56:55.742644	626	Me encantÔö£Ôöé, la recomiendo.	2
1451	2025-09-15 17:56:55.742644	627	Me encantÔö£Ôöé, la recomiendo.	2
1452	2025-09-15 17:56:55.742644	628	Me encantÔö£Ôöé, la recomiendo.	2
1453	2025-09-15 17:56:55.742644	629	Me encantÔö£Ôöé, la recomiendo.	2
1454	2025-09-15 17:56:55.742644	630	Me encantÔö£Ôöé, la recomiendo.	2
1455	2025-09-15 17:56:55.742644	631	Me encantÔö£Ôöé, la recomiendo.	2
1456	2025-09-15 17:56:55.742644	632	Me encantÔö£Ôöé, la recomiendo.	2
1457	2025-09-15 17:56:55.742644	633	Me encantÔö£Ôöé, la recomiendo.	2
1458	2025-09-15 17:56:55.742644	634	Me encantÔö£Ôöé, la recomiendo.	2
1459	2025-09-15 17:56:55.742644	635	Me encantÔö£Ôöé, la recomiendo.	2
1460	2025-09-15 17:56:55.742644	636	Me encantÔö£Ôöé, la recomiendo.	2
1461	2025-09-15 17:56:55.742644	637	Me encantÔö£Ôöé, la recomiendo.	2
1462	2025-09-15 17:56:55.742644	638	Me encantÔö£Ôöé, la recomiendo.	2
1463	2025-09-15 17:56:55.742644	639	Me encantÔö£Ôöé, la recomiendo.	2
1464	2025-09-15 17:56:55.742644	640	Me encantÔö£Ôöé, la recomiendo.	2
1466	2025-10-08 03:44:07.872318	15	Comentario editado final: Excelente receta, muy facil de seguir y con ingredientes accesibles. La recomiendo mucho!	3
\.


--
-- Data for Name: donacion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.donacion (id_donacion, amount, currency, fecha_actualizacion, fecha_creacion, id_receta, id_usr, status, stripe_payment_intent, stripe_session_id) FROM stdin;
1	100	USD	2025-10-08 03:39:29.191631	2025-10-08 03:39:29.191623	15	3	PENDING	\N	04d2dd9b-8ed1-4e1c-9065-1fbb97d994f2
2	100	USD	2025-10-09 00:49:10.040734	2025-10-09 00:49:10.040683	12	\N	PENDING	\N	e8f7820f-c32a-4146-ac83-e94c4d2133d4
3	100	USD	2025-10-09 00:49:44.584834	2025-10-09 00:49:44.5848	12	\N	PENDING	\N	c24f2503-87be-4b72-9651-4b0d847b3a00
\.


--
-- Data for Name: estrella; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.estrella (id_estrella, fecha_creacion, valor, id_receta, id_usr) FROM stdin;
1	2025-09-15 17:56:55.742644	4	476	1
2	2025-09-15 17:56:55.742644	5	205	2
3	2025-09-15 17:56:55.742644	4	344	1
4	2025-09-15 17:56:55.742644	4	598	1
5	2025-09-15 17:56:55.742644	4	14	1
6	2025-09-15 17:56:55.742644	4	472	1
7	2025-09-15 17:56:55.742644	5	114	2
8	2025-09-15 17:56:55.742644	5	447	2
9	2025-09-15 17:56:55.742644	5	187	2
10	2025-09-15 17:56:55.742644	5	639	2
11	2025-09-15 17:56:55.742644	5	197	2
12	2025-09-15 17:56:55.742644	4	147	1
13	2025-09-15 17:56:55.742644	5	604	2
14	2025-09-15 17:56:55.742644	5	97	2
15	2025-09-15 17:56:55.742644	4	121	1
16	2025-09-15 17:56:55.742644	5	389	2
17	2025-09-15 17:56:55.742644	4	634	1
18	2025-09-15 17:56:55.742644	4	161	1
19	2025-09-15 17:56:55.742644	5	446	2
20	2025-09-15 17:56:55.742644	5	155	2
21	2025-09-15 17:56:55.742644	5	409	2
22	2025-09-15 17:56:55.742644	4	210	1
23	2025-09-15 17:56:55.742644	5	605	2
24	2025-09-15 17:56:55.742644	5	587	2
25	2025-09-15 17:56:55.742644	4	154	1
26	2025-09-15 17:56:55.742644	4	584	1
27	2025-09-15 17:56:55.742644	5	417	2
28	2025-09-15 17:56:55.742644	4	157	1
29	2025-09-15 17:56:55.742644	5	434	2
30	2025-09-15 17:56:55.742644	4	602	1
31	2025-09-15 17:56:55.742644	4	35	1
32	2025-09-15 17:56:55.742644	5	341	2
33	2025-09-15 17:56:55.742644	4	503	1
34	2025-09-15 17:56:55.742644	5	286	2
35	2025-09-15 17:56:55.742644	5	632	2
36	2025-09-15 17:56:55.742644	5	553	2
37	2025-09-15 17:56:55.742644	4	43	1
38	2025-09-15 17:56:55.742644	5	363	2
39	2025-09-15 17:56:55.742644	4	482	1
40	2025-09-15 17:56:55.742644	5	349	2
41	2025-09-15 17:56:55.742644	4	220	1
42	2025-09-15 17:56:55.742644	5	309	2
43	2025-09-15 17:56:55.742644	5	545	2
44	2025-09-15 17:56:55.742644	4	573	1
45	2025-09-15 17:56:55.742644	4	166	1
46	2025-09-15 17:56:55.742644	4	259	1
47	2025-09-15 17:56:55.742644	5	487	2
48	2025-09-15 17:56:55.742644	4	522	1
49	2025-09-15 17:56:55.742644	5	560	2
50	2025-09-15 17:56:55.742644	5	185	2
51	2025-09-15 17:56:55.742644	4	431	1
52	2025-09-15 17:56:55.742644	4	3	1
53	2025-09-15 17:56:55.742644	5	438	2
54	2025-09-15 17:56:55.742644	4	423	1
55	2025-09-15 17:56:55.742644	5	117	2
56	2025-09-15 17:56:55.742644	4	291	1
57	2025-09-15 17:56:55.742644	4	176	1
58	2025-09-15 17:56:55.742644	5	439	2
59	2025-09-15 17:56:55.742644	4	61	1
60	2025-09-15 17:56:55.742644	4	201	1
61	2025-09-15 17:56:55.742644	4	597	1
62	2025-09-15 17:56:55.742644	4	388	1
63	2025-09-15 17:56:55.742644	4	169	1
64	2025-09-15 17:56:55.742644	4	87	1
65	2025-09-15 17:56:55.742644	5	390	2
66	2025-09-15 17:56:55.742644	5	127	2
67	2025-09-15 17:56:55.742644	4	118	1
68	2025-09-15 17:56:55.742644	4	88	1
69	2025-09-15 17:56:55.742644	5	628	2
70	2025-09-15 17:56:55.742644	5	329	2
71	2025-09-15 17:56:55.742644	5	623	2
72	2025-09-15 17:56:55.742644	5	514	2
73	2025-09-15 17:56:55.742644	5	62	2
74	2025-09-15 17:56:55.742644	4	283	1
75	2025-09-15 17:56:55.742644	4	240	1
76	2025-09-15 17:56:55.742644	4	223	1
77	2025-09-15 17:56:55.742644	5	122	2
78	2025-09-15 17:56:55.742644	4	272	1
79	2025-09-15 17:56:55.742644	4	130	1
80	2025-09-15 17:56:55.742644	5	180	2
81	2025-09-15 17:56:55.742644	4	548	1
82	2025-09-15 17:56:55.742644	4	231	1
83	2025-09-15 17:56:55.742644	4	217	1
84	2025-09-15 17:56:55.742644	5	454	2
85	2025-09-15 17:56:55.742644	5	531	2
86	2025-09-15 17:56:55.742644	5	30	2
87	2025-09-15 17:56:55.742644	4	612	1
88	2025-09-15 17:56:55.742644	4	328	1
89	2025-09-15 17:56:55.742644	4	383	1
90	2025-09-15 17:56:55.742644	4	212	1
91	2025-09-15 17:56:55.742644	5	162	2
92	2025-09-15 17:56:55.742644	4	538	1
93	2025-09-15 17:56:55.742644	5	95	2
94	2025-09-15 17:56:55.742644	5	585	2
95	2025-09-15 17:56:55.742644	5	299	2
96	2025-09-15 17:56:55.742644	5	356	2
97	2025-09-15 17:56:55.742644	5	48	2
98	2025-09-15 17:56:55.742644	4	616	1
99	2025-09-15 17:56:55.742644	4	263	1
100	2025-09-15 17:56:55.742644	5	99	2
101	2025-09-15 17:56:55.742644	4	453	1
102	2025-09-15 17:56:55.742644	4	7	1
103	2025-09-15 17:56:55.742644	4	144	1
104	2025-09-15 17:56:55.742644	5	204	2
105	2025-09-15 17:56:55.742644	5	362	2
106	2025-09-15 17:56:55.742644	4	615	1
107	2025-09-15 17:56:55.742644	5	313	2
108	2025-09-15 17:56:55.742644	5	262	2
109	2025-09-15 17:56:55.742644	5	94	2
110	2025-09-15 17:56:55.742644	5	28	2
111	2025-09-15 17:56:55.742644	5	110	2
112	2025-09-15 17:56:55.742644	4	173	1
113	2025-09-15 17:56:55.742644	4	448	1
114	2025-09-15 17:56:55.742644	5	622	2
115	2025-09-15 17:56:55.742644	4	592	1
116	2025-09-15 17:56:55.742644	5	370	2
117	2025-09-15 17:56:55.742644	4	375	1
118	2025-09-15 17:56:55.742644	4	188	1
119	2025-09-15 17:56:55.742644	5	175	2
120	2025-09-15 17:56:55.742644	5	571	2
121	2025-09-15 17:56:55.742644	5	470	2
122	2025-09-15 17:56:55.742644	5	542	2
123	2025-09-15 17:56:55.742644	4	491	1
124	2025-09-15 17:56:55.742644	4	527	1
125	2025-09-15 17:56:55.742644	4	306	1
126	2025-09-15 17:56:55.742644	5	80	2
127	2025-09-15 17:56:55.742644	4	436	1
128	2025-09-15 17:56:55.742644	5	305	2
129	2025-09-15 17:56:55.742644	4	345	1
130	2025-09-15 17:56:55.742644	4	490	1
131	2025-09-15 17:56:55.742644	5	179	2
132	2025-09-15 17:56:55.742644	5	312	2
133	2025-09-15 17:56:55.742644	4	420	1
134	2025-09-15 17:56:55.742644	5	318	2
135	2025-09-15 17:56:55.742644	4	308	1
136	2025-09-15 17:56:55.742644	4	150	1
137	2025-09-15 17:56:55.742644	5	551	2
138	2025-09-15 17:56:55.742644	5	195	2
139	2025-09-15 17:56:55.742644	4	331	1
140	2025-09-15 17:56:55.742644	5	129	2
141	2025-09-15 17:56:55.742644	4	445	1
142	2025-09-15 17:56:55.742644	4	260	1
143	2025-09-15 17:56:55.742644	4	411	1
144	2025-09-15 17:56:55.742644	4	9	1
145	2025-09-15 17:56:55.742644	4	183	1
146	2025-09-15 17:56:55.742644	4	63	1
147	2025-09-15 17:56:55.742644	5	483	2
148	2025-09-15 17:56:55.742644	5	8	2
149	2025-09-15 17:56:55.742644	4	294	1
150	2025-09-15 17:56:55.742644	4	368	1
151	2025-09-15 17:56:55.742644	5	516	2
152	2025-09-15 17:56:55.742644	5	41	2
153	2025-09-15 17:56:55.742644	4	174	1
154	2025-09-15 17:56:55.742644	5	564	2
155	2025-09-15 17:56:55.742644	4	36	1
156	2025-09-15 17:56:55.742644	5	580	2
157	2025-09-15 17:56:55.742644	5	141	2
158	2025-09-15 17:56:55.742644	4	407	1
159	2025-09-15 17:56:55.742644	4	4	1
160	2025-09-15 17:56:55.742644	5	246	2
161	2025-09-15 17:56:55.742644	5	463	2
162	2025-09-15 17:56:55.742644	4	451	1
163	2025-09-15 17:56:55.742644	5	509	2
164	2025-09-15 17:56:55.742644	5	6	2
165	2025-09-15 17:56:55.742644	5	267	2
166	2025-09-15 17:56:55.742644	5	354	2
167	2025-09-15 17:56:55.742644	4	257	1
168	2025-09-15 17:56:55.742644	5	159	2
169	2025-09-15 17:56:55.742644	4	200	1
170	2025-09-15 17:56:55.742644	5	488	2
171	2025-09-15 17:56:55.742644	5	29	2
172	2025-09-15 17:56:55.742644	5	207	2
173	2025-09-15 17:56:55.742644	4	53	1
174	2025-09-15 17:56:55.742644	5	418	2
175	2025-09-15 17:56:55.742644	4	92	1
176	2025-09-15 17:56:55.742644	4	613	1
177	2025-09-15 17:56:55.742644	5	74	2
178	2025-09-15 17:56:55.742644	4	275	1
179	2025-09-15 17:56:55.742644	4	222	1
180	2025-09-15 17:56:55.742644	5	235	2
181	2025-09-15 17:56:55.742644	5	607	2
182	2025-09-15 17:56:55.742644	4	23	1
183	2025-09-15 17:56:55.742644	4	528	1
184	2025-09-15 17:56:55.742644	5	501	2
185	2025-09-15 17:56:55.742644	4	568	1
186	2025-09-15 17:56:55.742644	5	84	2
187	2025-09-15 17:56:55.742644	4	371	1
188	2025-09-15 17:56:55.742644	5	387	2
189	2025-09-15 17:56:55.742644	5	248	2
190	2025-09-15 17:56:55.742644	4	44	1
191	2025-09-15 17:56:55.742644	5	394	2
192	2025-09-15 17:56:55.742644	4	583	1
193	2025-09-15 17:56:55.742644	4	227	1
194	2025-09-15 17:56:55.742644	4	171	1
195	2025-09-15 17:56:55.742644	4	467	1
196	2025-09-15 17:56:55.742644	4	402	1
197	2025-09-15 17:56:55.742644	4	539	1
198	2025-09-15 17:56:55.742644	4	347	1
199	2025-09-15 17:56:55.742644	4	311	1
200	2025-09-15 17:56:55.742644	4	380	1
201	2025-09-15 17:56:55.742644	4	247	1
202	2025-09-15 17:56:55.742644	5	116	2
203	2025-09-15 17:56:55.742644	5	350	2
204	2025-09-15 17:56:55.742644	5	271	2
205	2025-09-15 17:56:55.742644	5	621	2
206	2025-09-15 17:56:55.742644	4	242	1
207	2025-09-15 17:56:55.742644	4	138	1
208	2025-09-15 17:56:55.742644	4	517	1
209	2025-09-15 17:56:55.742644	4	410	1
210	2025-09-15 17:56:55.742644	5	338	2
211	2025-09-15 17:56:55.742644	4	16	1
212	2025-09-15 17:56:55.742644	4	190	1
213	2025-09-15 17:56:55.742644	4	574	1
214	2025-09-15 17:56:55.742644	5	134	2
215	2025-09-15 17:56:55.742644	4	342	1
216	2025-09-15 17:56:55.742644	5	481	2
217	2025-09-15 17:56:55.742644	5	90	2
218	2025-09-15 17:56:55.742644	4	54	1
219	2025-09-15 17:56:55.742644	5	502	2
220	2025-09-15 17:56:55.742644	5	42	2
221	2025-09-15 17:56:55.742644	5	450	2
222	2025-09-15 17:56:55.742644	5	192	2
223	2025-09-15 17:56:55.742644	4	103	1
224	2025-09-15 17:56:55.742644	5	59	2
225	2025-09-15 17:56:55.742644	4	208	1
226	2025-09-15 17:56:55.742644	5	557	2
227	2025-09-15 17:56:55.742644	5	219	2
228	2025-09-15 17:56:55.742644	5	81	2
229	2025-09-15 17:56:55.742644	4	236	1
230	2025-09-15 17:56:55.742644	4	148	1
231	2025-09-15 17:56:55.742644	5	393	2
232	2025-09-15 17:56:55.742644	5	591	2
233	2025-09-15 17:56:55.742644	5	552	2
234	2025-09-15 17:56:55.742644	4	525	1
235	2025-09-15 17:56:55.742644	4	115	1
236	2025-09-15 17:56:55.742644	5	441	2
237	2025-09-15 17:56:55.742644	5	385	2
238	2025-09-15 17:56:55.742644	5	79	2
239	2025-09-15 17:56:55.742644	4	322	1
240	2025-09-15 17:56:55.742644	5	521	2
241	2025-09-15 17:56:55.742644	5	273	2
242	2025-09-15 17:56:55.742644	4	323	1
243	2025-09-15 17:56:55.742644	4	225	1
244	2025-09-15 17:56:55.742644	5	69	2
245	2025-09-15 17:56:55.742644	5	460	2
246	2025-09-15 17:56:55.742644	5	406	2
247	2025-09-15 17:56:55.742644	5	76	2
248	2025-09-15 17:56:55.742644	4	45	1
249	2025-09-15 17:56:55.742644	4	70	1
250	2025-09-15 17:56:55.742644	5	529	2
251	2025-09-15 17:56:55.742644	5	203	2
252	2025-09-15 17:56:55.742644	4	199	1
253	2025-09-15 17:56:55.742644	5	334	2
254	2025-09-15 17:56:55.742644	4	611	1
255	2025-09-15 17:56:55.742644	4	495	1
256	2025-09-15 17:56:55.742644	5	513	2
257	2025-09-15 17:56:55.742644	5	586	2
258	2025-09-15 17:56:55.742644	5	51	2
259	2025-09-15 17:56:55.742644	4	60	1
260	2025-09-15 17:56:55.742644	5	477	2
261	2025-09-15 17:56:55.742644	5	224	2
262	2025-09-15 17:56:55.742644	5	567	2
263	2025-09-15 17:56:55.742644	4	618	1
264	2025-09-15 17:56:55.742644	5	50	2
265	2025-09-15 17:56:55.742644	4	327	1
266	2025-09-15 17:56:55.742644	4	105	1
267	2025-09-15 17:56:55.742644	4	422	1
268	2025-09-15 17:56:55.742644	4	124	1
269	2025-09-15 17:56:55.742644	5	352	2
270	2025-09-15 17:56:55.742644	5	464	2
271	2025-09-15 17:56:55.742644	4	75	1
272	2025-09-15 17:56:55.742644	4	469	1
273	2025-09-15 17:56:55.742644	4	425	1
274	2025-09-15 17:56:55.742644	4	415	1
275	2025-09-15 17:56:55.742644	4	245	1
276	2025-09-15 17:56:55.742644	4	510	1
277	2025-09-15 17:56:55.742644	4	229	1
278	2025-09-15 17:56:55.742644	5	395	2
279	2025-09-15 17:56:55.742644	4	561	1
280	2025-09-15 17:56:55.742644	4	544	1
281	2025-09-15 17:56:55.742644	5	369	2
282	2025-09-15 17:56:55.742644	5	457	2
283	2025-09-15 17:56:55.742644	5	67	2
284	2025-09-15 17:56:55.742644	4	1	1
285	2025-09-15 17:56:55.742644	4	58	1
286	2025-09-15 17:56:55.742644	5	316	2
287	2025-09-15 17:56:55.742644	4	290	1
288	2025-09-15 17:56:55.742644	5	506	2
289	2025-09-15 17:56:55.742644	4	619	1
290	2025-09-15 17:56:55.742644	5	378	2
291	2025-09-15 17:56:55.742644	5	336	2
292	2025-09-15 17:56:55.742644	5	520	2
293	2025-09-15 17:56:55.742644	5	132	2
294	2025-09-15 17:56:55.742644	4	206	1
295	2025-09-15 17:56:55.742644	5	249	2
296	2025-09-15 17:56:55.742644	4	562	1
297	2025-09-15 17:56:55.742644	4	111	1
298	2025-09-15 17:56:55.742644	5	269	2
299	2025-09-15 17:56:55.742644	5	386	2
300	2025-09-15 17:56:55.742644	5	302	2
301	2025-09-15 17:56:55.742644	4	372	1
302	2025-09-15 17:56:55.742644	4	364	1
303	2025-09-15 17:56:55.742644	4	237	1
304	2025-09-15 17:56:55.742644	5	430	2
305	2025-09-15 17:56:55.742644	5	511	2
306	2025-09-15 17:56:55.742644	5	194	2
307	2025-09-15 17:56:55.742644	5	126	2
308	2025-09-15 17:56:55.742644	4	608	1
309	2025-09-15 17:56:55.742644	5	534	2
310	2025-09-15 17:56:55.742644	5	351	2
311	2025-09-15 17:56:55.742644	4	86	1
312	2025-09-15 17:56:55.742644	5	558	2
313	2025-09-15 17:56:55.742644	4	360	1
314	2025-09-15 17:56:55.742644	4	22	1
315	2025-09-15 17:56:55.742644	5	156	2
316	2025-09-15 17:56:55.742644	4	49	1
317	2025-09-15 17:56:55.742644	4	572	1
318	2025-09-15 17:56:55.742644	5	124	2
319	2025-09-15 17:56:55.742644	4	352	1
320	2025-09-15 17:56:55.742644	4	464	1
321	2025-09-15 17:56:55.742644	5	75	2
322	2025-09-15 17:56:55.742644	5	469	2
323	2025-09-15 17:56:55.742644	5	425	2
324	2025-09-15 17:56:55.742644	5	415	2
325	2025-09-15 17:56:55.742644	5	245	2
326	2025-09-15 17:56:55.742644	5	510	2
327	2025-09-15 17:56:55.742644	5	229	2
328	2025-09-15 17:56:55.742644	4	395	1
329	2025-09-15 17:56:55.742644	5	561	2
330	2025-09-15 17:56:55.742644	4	477	1
331	2025-09-15 17:56:55.742644	4	224	1
332	2025-09-15 17:56:55.742644	4	567	1
333	2025-09-15 17:56:55.742644	5	618	2
334	2025-09-15 17:56:55.742644	4	50	1
335	2025-09-15 17:56:55.742644	5	327	2
336	2025-09-15 17:56:55.742644	5	105	2
337	2025-09-15 17:56:55.742644	5	422	2
338	2025-09-15 17:56:55.742644	5	611	2
339	2025-09-15 17:56:55.742644	5	495	2
340	2025-09-15 17:56:55.742644	4	513	1
341	2025-09-15 17:56:55.742644	4	586	1
342	2025-09-15 17:56:55.742644	4	51	1
343	2025-09-15 17:56:55.742644	5	60	2
344	2025-09-15 17:56:55.742644	4	69	1
345	2025-09-15 17:56:55.742644	5	225	2
346	2025-09-15 17:56:55.742644	4	460	1
347	2025-09-15 17:56:55.742644	4	406	1
348	2025-09-15 17:56:55.742644	4	76	1
349	2025-09-15 17:56:55.742644	5	45	2
350	2025-09-15 17:56:55.742644	5	70	2
351	2025-09-15 17:56:55.742644	4	529	1
352	2025-09-15 17:56:55.742644	4	203	1
353	2025-09-15 17:56:55.742644	5	199	2
354	2025-09-15 17:56:55.742644	4	334	1
355	2025-09-15 17:56:55.742644	4	351	1
356	2025-09-15 17:56:55.742644	5	86	2
357	2025-09-15 17:56:55.742644	4	558	1
358	2025-09-15 17:56:55.742644	5	360	2
359	2025-09-15 17:56:55.742644	5	22	2
360	2025-09-15 17:56:55.742644	4	156	1
361	2025-09-15 17:56:55.742644	5	49	2
362	2025-09-15 17:56:55.742644	5	572	2
363	2025-09-15 17:56:55.742644	4	249	1
364	2025-09-15 17:56:55.742644	5	206	2
365	2025-09-15 17:56:55.742644	4	269	1
366	2025-09-15 17:56:55.742644	5	111	2
367	2025-09-15 17:56:55.742644	5	562	2
368	2025-09-15 17:56:55.742644	4	386	1
369	2025-09-15 17:56:55.742644	4	302	1
370	2025-09-15 17:56:55.742644	5	372	2
371	2025-09-15 17:56:55.742644	5	364	2
372	2025-09-15 17:56:55.742644	5	237	2
373	2025-09-15 17:56:55.742644	4	430	1
374	2025-09-15 17:56:55.742644	4	534	1
375	2025-09-15 17:56:55.742644	4	511	1
376	2025-09-15 17:56:55.742644	4	194	1
377	2025-09-15 17:56:55.742644	4	126	1
378	2025-09-15 17:56:55.742644	5	608	2
379	2025-09-15 17:56:55.742644	4	316	1
380	2025-09-15 17:56:55.742644	5	290	2
381	2025-09-15 17:56:55.742644	4	506	1
382	2025-09-15 17:56:55.742644	5	619	2
383	2025-09-15 17:56:55.742644	4	378	1
384	2025-09-15 17:56:55.742644	4	336	1
385	2025-09-15 17:56:55.742644	4	520	1
386	2025-09-15 17:56:55.742644	4	132	1
387	2025-09-15 17:56:55.742644	5	544	2
388	2025-09-15 17:56:55.742644	4	369	1
389	2025-09-15 17:56:55.742644	4	457	1
390	2025-09-15 17:56:55.742644	4	67	1
391	2025-09-15 17:56:55.742644	5	1	2
392	2025-09-15 17:56:55.742644	5	58	2
393	2025-09-15 17:56:55.742644	4	235	1
394	2025-09-15 17:56:55.742644	4	607	1
395	2025-09-15 17:56:55.742644	5	23	2
396	2025-09-15 17:56:55.742644	5	528	2
397	2025-09-15 17:56:55.742644	4	501	1
398	2025-09-15 17:56:55.742644	5	568	2
399	2025-09-15 17:56:55.742644	4	84	1
400	2025-09-15 17:56:55.742644	4	387	1
401	2025-09-15 17:56:55.742644	5	371	2
402	2025-09-15 17:56:55.742644	4	248	1
403	2025-09-15 17:56:55.742644	4	394	1
404	2025-09-15 17:56:55.742644	5	44	2
405	2025-09-15 17:56:55.742644	5	583	2
406	2025-09-15 17:56:55.742644	4	207	1
407	2025-09-15 17:56:55.742644	5	53	2
408	2025-09-15 17:56:55.742644	4	418	1
409	2025-09-15 17:56:55.742644	5	92	2
410	2025-09-15 17:56:55.742644	5	613	2
411	2025-09-15 17:56:55.742644	4	74	1
412	2025-09-15 17:56:55.742644	5	275	2
413	2025-09-15 17:56:55.742644	5	222	2
414	2025-09-15 17:56:55.742644	4	246	1
415	2025-09-15 17:56:55.742644	5	407	2
416	2025-09-15 17:56:55.742644	5	4	2
417	2025-09-15 17:56:55.742644	4	463	1
418	2025-09-15 17:56:55.742644	5	451	2
419	2025-09-15 17:56:55.742644	4	509	1
420	2025-09-15 17:56:55.742644	4	6	1
421	2025-09-15 17:56:55.742644	4	267	1
422	2025-09-15 17:56:55.742644	4	354	1
423	2025-09-15 17:56:55.742644	4	159	1
424	2025-09-15 17:56:55.742644	5	257	2
425	2025-09-15 17:56:55.742644	5	200	2
426	2025-09-15 17:56:55.742644	4	488	1
427	2025-09-15 17:56:55.742644	4	29	1
428	2025-09-15 17:56:55.742644	5	294	2
429	2025-09-15 17:56:55.742644	5	368	2
430	2025-09-15 17:56:55.742644	4	516	1
431	2025-09-15 17:56:55.742644	4	41	1
432	2025-09-15 17:56:55.742644	4	564	1
433	2025-09-15 17:56:55.742644	5	174	2
434	2025-09-15 17:56:55.742644	5	36	2
435	2025-09-15 17:56:55.742644	4	580	1
436	2025-09-15 17:56:55.742644	4	141	1
437	2025-09-15 17:56:55.742644	4	557	1
438	2025-09-15 17:56:55.742644	5	208	2
439	2025-09-15 17:56:55.742644	4	219	1
440	2025-09-15 17:56:55.742644	4	81	1
441	2025-09-15 17:56:55.742644	5	236	2
442	2025-09-15 17:56:55.742644	5	148	2
443	2025-09-15 17:56:55.742644	4	552	1
444	2025-09-15 17:56:55.742644	4	393	1
445	2025-09-15 17:56:55.742644	4	591	1
446	2025-09-15 17:56:55.742644	5	525	2
447	2025-09-15 17:56:55.742644	4	441	1
448	2025-09-15 17:56:55.742644	4	385	1
449	2025-09-15 17:56:55.742644	5	115	2
450	2025-09-15 17:56:55.742644	4	79	1
451	2025-09-15 17:56:55.742644	4	521	1
452	2025-09-15 17:56:55.742644	5	322	2
453	2025-09-15 17:56:55.742644	4	273	1
454	2025-09-15 17:56:55.742644	5	323	2
455	2025-09-15 17:56:55.742644	4	134	1
456	2025-09-15 17:56:55.742644	5	574	2
457	2025-09-15 17:56:55.742644	4	481	1
458	2025-09-15 17:56:55.742644	4	90	1
459	2025-09-15 17:56:55.742644	5	342	2
460	2025-09-15 17:56:55.742644	5	54	2
461	2025-09-15 17:56:55.742644	4	502	1
462	2025-09-15 17:56:55.742644	4	42	1
463	2025-09-15 17:56:55.742644	4	450	1
464	2025-09-15 17:56:55.742644	4	192	1
465	2025-09-15 17:56:55.742644	5	103	2
466	2025-09-15 17:56:55.742644	4	59	1
467	2025-09-15 17:56:55.742644	4	271	1
468	2025-09-15 17:56:55.742644	4	621	1
469	2025-09-15 17:56:55.742644	5	242	2
470	2025-09-15 17:56:55.742644	5	138	2
471	2025-09-15 17:56:55.742644	5	517	2
472	2025-09-15 17:56:55.742644	4	338	1
473	2025-09-15 17:56:55.742644	5	410	2
474	2025-09-15 17:56:55.742644	5	16	2
475	2025-09-15 17:56:55.742644	5	190	2
476	2025-09-15 17:56:55.742644	5	227	2
477	2025-09-15 17:56:55.742644	5	171	2
478	2025-09-15 17:56:55.742644	5	467	2
479	2025-09-15 17:56:55.742644	5	402	2
480	2025-09-15 17:56:55.742644	5	539	2
481	2025-09-15 17:56:55.742644	5	347	2
482	2025-09-15 17:56:55.742644	5	311	2
483	2025-09-15 17:56:55.742644	5	380	2
484	2025-09-15 17:56:55.742644	5	247	2
485	2025-09-15 17:56:55.742644	4	116	1
486	2025-09-15 17:56:55.742644	4	350	1
487	2025-09-15 17:56:55.742644	4	48	1
488	2025-09-15 17:56:55.742644	5	616	2
489	2025-09-15 17:56:55.742644	4	99	1
490	2025-09-15 17:56:55.742644	5	263	2
491	2025-09-15 17:56:55.742644	5	453	2
492	2025-09-15 17:56:55.742644	5	7	2
493	2025-09-15 17:56:55.742644	4	204	1
494	2025-09-15 17:56:55.742644	5	144	2
495	2025-09-15 17:56:55.742644	4	362	1
496	2025-09-15 17:56:55.742644	5	615	2
497	2025-09-15 17:56:55.742644	4	313	1
498	2025-09-15 17:56:55.742644	4	262	1
499	2025-09-15 17:56:55.742644	4	94	1
500	2025-09-15 17:56:55.742644	4	28	1
501	2025-09-15 17:56:55.742644	4	30	1
502	2025-09-15 17:56:55.742644	5	612	2
503	2025-09-15 17:56:55.742644	5	328	2
504	2025-09-15 17:56:55.742644	5	383	2
505	2025-09-15 17:56:55.742644	4	162	1
506	2025-09-15 17:56:55.742644	5	212	2
507	2025-09-15 17:56:55.742644	5	538	2
508	2025-09-15 17:56:55.742644	4	585	1
509	2025-09-15 17:56:55.742644	4	95	1
510	2025-09-15 17:56:55.742644	4	299	1
511	2025-09-15 17:56:55.742644	4	356	1
512	2025-09-15 17:56:55.742644	4	329	1
513	2025-09-15 17:56:55.742644	4	623	1
514	2025-09-15 17:56:55.742644	4	514	1
515	2025-09-15 17:56:55.742644	4	62	1
516	2025-09-15 17:56:55.742644	5	283	2
517	2025-09-15 17:56:55.742644	5	240	2
518	2025-09-15 17:56:55.742644	5	223	2
519	2025-09-15 17:56:55.742644	4	122	1
520	2025-09-15 17:56:55.742644	5	272	2
521	2025-09-15 17:56:55.742644	5	130	2
522	2025-09-15 17:56:55.742644	4	180	1
523	2025-09-15 17:56:55.742644	5	231	2
524	2025-09-15 17:56:55.742644	5	217	2
525	2025-09-15 17:56:55.742644	5	548	2
526	2025-09-15 17:56:55.742644	4	454	1
527	2025-09-15 17:56:55.742644	4	531	1
528	2025-09-15 17:56:55.742644	4	390	1
529	2025-09-15 17:56:55.742644	4	127	1
530	2025-09-15 17:56:55.742644	5	118	2
531	2025-09-15 17:56:55.742644	5	88	2
532	2025-09-15 17:56:55.742644	4	628	1
533	2025-09-15 17:56:55.742644	4	195	1
534	2025-09-15 17:56:55.742644	4	129	1
535	2025-09-15 17:56:55.742644	5	331	2
536	2025-09-15 17:56:55.742644	5	445	2
537	2025-09-15 17:56:55.742644	5	260	2
538	2025-09-15 17:56:55.742644	5	411	2
539	2025-09-15 17:56:55.742644	5	9	2
540	2025-09-15 17:56:55.742644	5	183	2
541	2025-09-15 17:56:55.742644	4	483	1
542	2025-09-15 17:56:55.742644	5	63	2
543	2025-09-15 17:56:55.742644	4	8	1
544	2025-09-15 17:56:55.742644	4	80	1
545	2025-09-15 17:56:55.742644	5	436	2
546	2025-09-15 17:56:55.742644	4	305	1
547	2025-09-15 17:56:55.742644	5	345	2
548	2025-09-15 17:56:55.742644	4	179	1
549	2025-09-15 17:56:55.742644	5	490	2
550	2025-09-15 17:56:55.742644	4	312	1
551	2025-09-15 17:56:55.742644	4	318	1
552	2025-09-15 17:56:55.742644	5	420	2
553	2025-09-15 17:56:55.742644	5	308	2
554	2025-09-15 17:56:55.742644	5	150	2
555	2025-09-15 17:56:55.742644	4	551	1
556	2025-09-15 17:56:55.742644	4	571	1
557	2025-09-15 17:56:55.742644	4	542	1
558	2025-09-15 17:56:55.742644	4	470	1
559	2025-09-15 17:56:55.742644	5	491	2
560	2025-09-15 17:56:55.742644	5	527	2
561	2025-09-15 17:56:55.742644	5	306	2
562	2025-09-15 17:56:55.742644	4	110	1
563	2025-09-15 17:56:55.742644	5	173	2
564	2025-09-15 17:56:55.742644	5	448	2
565	2025-09-15 17:56:55.742644	4	622	1
566	2025-09-15 17:56:55.742644	5	592	2
567	2025-09-15 17:56:55.742644	4	370	1
568	2025-09-15 17:56:55.742644	4	175	1
569	2025-09-15 17:56:55.742644	5	375	2
570	2025-09-15 17:56:55.742644	5	188	2
571	2025-09-15 17:56:55.742644	5	602	2
572	2025-09-15 17:56:55.742644	5	35	2
573	2025-09-15 17:56:55.742644	4	341	1
574	2025-09-15 17:56:55.742644	5	503	2
575	2025-09-15 17:56:55.742644	4	286	1
576	2025-09-15 17:56:55.742644	4	632	1
577	2025-09-15 17:56:55.742644	4	446	1
578	2025-09-15 17:56:55.742644	5	161	2
579	2025-09-15 17:56:55.742644	4	155	1
580	2025-09-15 17:56:55.742644	4	409	1
581	2025-09-15 17:56:55.742644	5	210	2
582	2025-09-15 17:56:55.742644	4	605	1
583	2025-09-15 17:56:55.742644	4	587	1
584	2025-09-15 17:56:55.742644	5	154	2
585	2025-09-15 17:56:55.742644	5	584	2
586	2025-09-15 17:56:55.742644	4	417	1
587	2025-09-15 17:56:55.742644	4	434	1
588	2025-09-15 17:56:55.742644	5	157	2
589	2025-09-15 17:56:55.742644	5	147	2
590	2025-09-15 17:56:55.742644	4	604	1
591	2025-09-15 17:56:55.742644	4	97	1
592	2025-09-15 17:56:55.742644	4	389	1
593	2025-09-15 17:56:55.742644	5	121	2
594	2025-09-15 17:56:55.742644	5	634	2
595	2025-09-15 17:56:55.742644	5	476	2
596	2025-09-15 17:56:55.742644	4	205	1
597	2025-09-15 17:56:55.742644	5	344	2
598	2025-09-15 17:56:55.742644	5	598	2
599	2025-09-15 17:56:55.742644	5	14	2
600	2025-09-15 17:56:55.742644	4	114	1
601	2025-09-15 17:56:55.742644	5	472	2
602	2025-09-15 17:56:55.742644	4	447	1
603	2025-09-15 17:56:55.742644	4	187	1
604	2025-09-15 17:56:55.742644	4	639	1
605	2025-09-15 17:56:55.742644	4	197	1
606	2025-09-15 17:56:55.742644	4	439	1
607	2025-09-15 17:56:55.742644	5	176	2
608	2025-09-15 17:56:55.742644	5	61	2
609	2025-09-15 17:56:55.742644	5	201	2
610	2025-09-15 17:56:55.742644	5	597	2
611	2025-09-15 17:56:55.742644	5	388	2
612	2025-09-15 17:56:55.742644	5	169	2
613	2025-09-15 17:56:55.742644	5	87	2
614	2025-09-15 17:56:55.742644	5	522	2
615	2025-09-15 17:56:55.742644	4	560	1
616	2025-09-15 17:56:55.742644	4	185	1
617	2025-09-15 17:56:55.742644	5	431	2
618	2025-09-15 17:56:55.742644	5	3	2
619	2025-09-15 17:56:55.742644	4	438	1
620	2025-09-15 17:56:55.742644	5	423	2
621	2025-09-15 17:56:55.742644	4	117	1
622	2025-09-15 17:56:55.742644	5	291	2
623	2025-09-15 17:56:55.742644	4	545	1
624	2025-09-15 17:56:55.742644	5	166	2
625	2025-09-15 17:56:55.742644	5	573	2
626	2025-09-15 17:56:55.742644	5	259	2
627	2025-09-15 17:56:55.742644	4	487	1
628	2025-09-15 17:56:55.742644	4	553	1
629	2025-09-15 17:56:55.742644	5	43	2
630	2025-09-15 17:56:55.742644	4	363	1
631	2025-09-15 17:56:55.742644	4	349	1
632	2025-09-15 17:56:55.742644	5	482	2
633	2025-09-15 17:56:55.742644	5	220	2
634	2025-09-15 17:56:55.742644	4	309	1
635	2025-09-15 17:56:55.742644	4	107	1
636	2025-09-15 17:56:55.742644	5	335	2
637	2025-09-15 17:56:55.742644	4	396	1
638	2025-09-15 17:56:55.742644	4	319	1
639	2025-09-15 17:56:55.742644	5	555	2
640	2025-09-15 17:56:55.742644	5	541	2
641	2025-09-15 17:56:55.742644	4	600	1
642	2025-09-15 17:56:55.742644	4	493	1
643	2025-09-15 17:56:55.742644	4	435	1
644	2025-09-15 17:56:55.742644	4	221	1
645	2025-09-15 17:56:55.742644	4	530	1
646	2025-09-15 17:56:55.742644	4	576	1
647	2025-09-15 17:56:55.742644	5	382	2
648	2025-09-15 17:56:55.742644	5	307	2
649	2025-09-15 17:56:55.742644	5	93	2
650	2025-09-15 17:56:55.742644	5	149	2
651	2025-09-15 17:56:55.742644	5	449	2
652	2025-09-15 17:56:55.742644	4	258	1
653	2025-09-15 17:56:55.742644	5	414	2
654	2025-09-15 17:56:55.742644	4	215	1
655	2025-09-15 17:56:55.742644	4	108	1
656	2025-09-15 17:56:55.742644	4	398	1
657	2025-09-15 17:56:55.742644	4	19	1
658	2025-09-15 17:56:55.742644	4	589	1
659	2025-09-15 17:56:55.742644	4	366	1
660	2025-09-15 17:56:55.742644	5	27	2
661	2025-09-15 17:56:55.742644	4	635	1
662	2025-09-15 17:56:55.742644	4	317	1
663	2025-09-15 17:56:55.742644	4	52	1
664	2025-09-15 17:56:55.742644	5	238	2
665	2025-09-15 17:56:55.742644	4	65	1
666	2025-09-15 17:56:55.742644	4	37	1
667	2025-09-15 17:56:55.742644	5	230	2
668	2025-09-15 17:56:55.742644	4	440	1
669	2025-09-15 17:56:55.742644	5	218	2
670	2025-09-15 17:56:55.742644	5	196	2
671	2025-09-15 17:56:55.742644	4	593	1
672	2025-09-15 17:56:55.742644	4	340	1
673	2025-09-15 17:56:55.742644	4	367	1
674	2025-09-15 17:56:55.742644	5	373	2
675	2025-09-15 17:56:55.742644	4	498	1
676	2025-09-15 17:56:55.742644	4	392	1
677	2025-09-15 17:56:55.742644	5	405	2
678	2025-09-15 17:56:55.742644	5	379	2
679	2025-09-15 17:56:55.742644	5	136	2
680	2025-09-15 17:56:55.742644	5	168	2
681	2025-09-15 17:56:55.742644	4	298	1
682	2025-09-15 17:56:55.742644	4	609	1
683	2025-09-15 17:56:55.742644	5	292	2
684	2025-09-15 17:56:55.742644	4	432	1
685	2025-09-15 17:56:55.742644	4	519	1
686	2025-09-15 17:56:55.742644	5	137	2
687	2025-09-15 17:56:55.742644	4	429	1
688	2025-09-15 17:56:55.742644	5	213	2
689	2025-09-15 17:56:55.742644	5	26	2
690	2025-09-15 17:56:55.742644	5	265	2
691	2025-09-15 17:56:55.742644	4	254	1
692	2025-09-15 17:56:55.742644	4	112	1
693	2025-09-15 17:56:55.742644	4	625	1
694	2025-09-15 17:56:55.742644	4	96	1
695	2025-09-15 17:56:55.742644	5	25	2
696	2025-09-15 17:56:55.742644	5	82	2
697	2025-09-15 17:56:55.742644	4	581	1
698	2025-09-15 17:56:55.742644	5	359	2
699	2025-09-15 17:56:55.742644	4	55	1
700	2025-09-15 17:56:55.742644	5	339	2
701	2025-09-15 17:56:55.742644	5	20	2
702	2025-09-15 17:56:55.742644	5	101	2
703	2025-09-15 17:56:55.742644	4	494	1
704	2025-09-15 17:56:55.742644	5	397	2
705	2025-09-15 17:56:55.742644	4	403	1
706	2025-09-15 17:56:55.742644	4	170	1
707	2025-09-15 17:56:55.742644	4	244	1
708	2025-09-15 17:56:55.742644	4	535	1
709	2025-09-15 17:56:55.742644	5	330	2
710	2025-09-15 17:56:55.742644	5	486	2
711	2025-09-15 17:56:55.742644	4	68	1
712	2025-09-15 17:56:55.742644	4	374	1
713	2025-09-15 17:56:55.742644	5	518	2
714	2025-09-15 17:56:55.742644	5	620	2
715	2025-09-15 17:56:55.742644	4	300	1
716	2025-09-15 17:56:55.742644	4	456	1
717	2025-09-15 17:56:55.742644	4	128	1
718	2025-09-15 17:56:55.742644	4	38	1
719	2025-09-15 17:56:55.742644	5	437	2
720	2025-09-15 17:56:55.742644	4	565	1
721	2025-09-15 17:56:55.742644	5	310	2
722	2025-09-15 17:56:55.742644	5	214	2
723	2025-09-15 17:56:55.742644	5	268	2
724	2025-09-15 17:56:55.742644	5	549	2
725	2025-09-15 17:56:55.742644	5	253	2
726	2025-09-15 17:56:55.742644	4	353	1
727	2025-09-15 17:56:55.742644	5	384	2
728	2025-09-15 17:56:55.742644	5	151	2
729	2025-09-15 17:56:55.742644	4	256	1
730	2025-09-15 17:56:55.742644	5	270	2
731	2025-09-15 17:56:55.742644	5	399	2
732	2025-09-15 17:56:55.742644	5	119	2
733	2025-09-15 17:56:55.742644	4	202	1
734	2025-09-15 17:56:55.742644	4	216	1
735	2025-09-15 17:56:55.742644	4	266	1
736	2025-09-15 17:56:55.742644	4	421	1
737	2025-09-15 17:56:55.742644	4	32	1
738	2025-09-15 17:56:55.742644	5	606	2
739	2025-09-15 17:56:55.742644	5	577	2
740	2025-09-15 17:56:55.742644	4	85	1
741	2025-09-15 17:56:55.742644	5	276	2
742	2025-09-15 17:56:55.742644	4	358	1
743	2025-09-15 17:56:55.742644	5	599	2
744	2025-09-15 17:56:55.742644	4	546	1
745	2025-09-15 17:56:55.742644	5	550	2
746	2025-09-15 17:56:55.742644	4	326	1
747	2025-09-15 17:56:55.742644	5	455	2
748	2025-09-15 17:56:55.742644	5	496	2
749	2025-09-15 17:56:55.742644	4	164	1
750	2025-09-15 17:56:55.742644	5	209	2
751	2025-09-15 17:56:55.742644	4	278	1
752	2025-09-15 17:56:55.742644	4	78	1
753	2025-09-15 17:56:55.742644	5	630	2
754	2025-09-15 17:56:55.742644	4	279	1
755	2025-09-15 17:56:55.742644	4	289	1
756	2025-09-15 17:56:55.742644	4	637	1
757	2025-09-15 17:56:55.742644	4	133	1
758	2025-09-15 17:56:55.742644	5	497	2
759	2025-09-15 17:56:55.742644	4	603	1
760	2025-09-15 17:56:55.742644	5	452	2
761	2025-09-15 17:56:55.742644	4	638	1
762	2025-09-15 17:56:55.742644	4	492	1
763	2025-09-15 17:56:55.742644	4	416	1
764	2025-09-15 17:56:55.742644	4	443	1
765	2025-09-15 17:56:55.742644	4	100	1
766	2025-09-15 17:56:55.742644	4	158	1
767	2025-09-15 17:56:55.742644	5	285	2
768	2025-09-15 17:56:55.742644	5	120	2
769	2025-09-15 17:56:55.742644	4	427	1
770	2025-09-15 17:56:55.742644	5	106	2
771	2025-09-15 17:56:55.742644	4	232	1
772	2025-09-15 17:56:55.742644	5	251	2
773	2025-09-15 17:56:55.742644	4	184	1
774	2025-09-15 17:56:55.742644	4	24	1
775	2025-09-15 17:56:55.742644	5	601	2
776	2025-09-15 17:56:55.742644	5	264	2
777	2025-09-15 17:56:55.742644	4	377	1
778	2025-09-15 17:56:55.742644	4	113	1
779	2025-09-15 17:56:55.742644	4	172	1
780	2025-09-15 17:56:55.742644	5	626	2
781	2025-09-15 17:56:55.742644	4	46	1
782	2025-09-15 17:56:55.742644	5	177	2
783	2025-09-15 17:56:55.742644	5	186	2
784	2025-09-15 17:56:55.742644	4	211	1
785	2025-09-15 17:56:55.742644	5	234	2
786	2025-09-15 17:56:55.742644	5	624	2
787	2025-09-15 17:56:55.742644	4	361	1
788	2025-09-15 17:56:55.742644	4	304	1
789	2025-09-15 17:56:55.742644	4	15	1
790	2025-09-15 17:56:55.742644	4	83	1
791	2025-09-15 17:56:55.742644	5	71	2
792	2025-09-15 17:56:55.742644	5	533	2
793	2025-09-15 17:56:55.742644	4	474	1
794	2025-09-15 17:56:55.742644	4	140	1
795	2025-09-15 17:56:55.742644	5	315	2
796	2025-09-15 17:56:55.742644	4	125	1
797	2025-09-15 17:56:55.742644	5	102	2
798	2025-09-15 17:56:55.742644	4	77	1
799	2025-09-15 17:56:55.742644	4	73	1
800	2025-09-15 17:56:55.742644	5	343	2
801	2025-09-15 17:56:55.742644	5	72	2
802	2025-09-15 17:56:55.742644	4	631	1
803	2025-09-15 17:56:55.742644	5	2	2
804	2025-09-15 17:56:55.742644	4	153	1
805	2025-09-15 17:56:55.742644	5	588	2
806	2025-09-15 17:56:55.742644	4	579	1
807	2025-09-15 17:56:55.742644	5	458	2
808	2025-09-15 17:56:55.742644	4	590	1
809	2025-09-15 17:56:55.742644	5	582	2
810	2025-09-15 17:56:55.742644	4	355	1
811	2025-09-15 17:56:55.742644	4	56	1
812	2025-09-15 17:56:55.742644	4	182	1
813	2025-09-15 17:56:55.742644	4	40	1
814	2025-09-15 17:56:55.742644	5	413	2
815	2025-09-15 17:56:55.742644	5	163	2
816	2025-09-15 17:56:55.742644	5	104	2
817	2025-09-15 17:56:55.742644	5	629	2
818	2025-09-15 17:56:55.742644	4	261	1
819	2025-09-15 17:56:55.742644	4	123	1
820	2025-09-15 17:56:55.742644	5	198	2
821	2025-09-15 17:56:55.742644	4	277	1
822	2025-09-15 17:56:55.742644	4	348	1
823	2025-09-15 17:56:55.742644	5	478	2
824	2025-09-15 17:56:55.742644	5	64	2
825	2025-09-15 17:56:55.742644	5	145	2
826	2025-09-15 17:56:55.742644	4	332	1
827	2025-09-15 17:56:55.742644	4	337	1
828	2025-09-15 17:56:55.742644	5	250	2
829	2025-09-15 17:56:55.742644	4	480	1
830	2025-09-15 17:56:55.742644	5	167	2
831	2025-09-15 17:56:55.742644	4	346	1
832	2025-09-15 17:56:55.742644	5	617	2
833	2025-09-15 17:56:55.742644	4	280	1
834	2025-09-15 17:56:55.742644	4	297	1
835	2025-09-15 17:56:55.742644	5	381	2
836	2025-09-15 17:56:55.742644	5	193	2
837	2025-09-15 17:56:55.742644	5	424	2
838	2025-09-15 17:56:55.742644	5	98	2
839	2025-09-15 17:56:55.742644	5	594	2
840	2025-09-15 17:56:55.742644	5	243	2
841	2025-09-15 17:56:55.742644	4	627	1
842	2025-09-15 17:56:55.742644	4	314	1
843	2025-09-15 17:56:55.742644	5	466	2
844	2025-09-15 17:56:55.742644	4	459	1
845	2025-09-15 17:56:55.742644	4	419	1
846	2025-09-15 17:56:55.742644	5	408	2
847	2025-09-15 17:56:55.742644	4	473	1
848	2025-09-15 17:56:55.742644	5	18	2
849	2025-09-15 17:56:55.742644	4	636	1
850	2025-09-15 17:56:55.742644	4	400	1
851	2025-09-15 17:56:55.742644	4	274	1
852	2025-09-15 17:56:55.742644	4	391	1
853	2025-09-15 17:56:55.742644	4	444	1
854	2025-09-15 17:56:55.742644	5	324	2
855	2025-09-15 17:56:55.742644	4	47	1
856	2025-09-15 17:56:55.742644	4	412	1
857	2025-09-15 17:56:55.742644	5	143	2
858	2025-09-15 17:56:55.742644	4	426	1
859	2025-09-15 17:56:55.742644	4	595	1
860	2025-09-15 17:56:55.742644	4	320	1
861	2025-09-15 17:56:55.742644	5	146	2
862	2025-09-15 17:56:55.742644	5	139	2
863	2025-09-15 17:56:55.742644	5	614	2
864	2025-09-15 17:56:55.742644	5	34	2
865	2025-09-15 17:56:55.742644	5	505	2
866	2025-09-15 17:56:55.742644	5	428	2
867	2025-09-15 17:56:55.742644	5	321	2
868	2025-09-15 17:56:55.742644	5	10	2
869	2025-09-15 17:56:55.742644	5	282	2
870	2025-09-15 17:56:55.742644	5	296	2
871	2025-09-15 17:56:55.742644	5	12	2
872	2025-09-15 17:56:55.742644	5	524	2
873	2025-09-15 17:56:55.742644	5	288	2
874	2025-09-15 17:56:55.742644	5	31	2
875	2025-09-15 17:56:55.742644	5	239	2
876	2025-09-15 17:56:55.742644	4	433	1
877	2025-09-15 17:56:55.742644	4	543	1
878	2025-09-15 17:56:55.742644	4	293	1
879	2025-09-15 17:56:55.742644	4	540	1
880	2025-09-15 17:56:55.742644	4	303	1
881	2025-09-15 17:56:55.742644	5	633	2
882	2025-09-15 17:56:55.742644	4	532	1
883	2025-09-15 17:56:55.742644	4	365	1
884	2025-09-15 17:56:55.742644	5	57	2
885	2025-09-15 17:56:55.742644	4	610	1
886	2025-09-15 17:56:55.742644	5	109	2
887	2025-09-15 17:56:55.742644	5	442	2
888	2025-09-15 17:56:55.742644	5	160	2
889	2025-09-15 17:56:55.742644	5	89	2
890	2025-09-15 17:56:55.742644	5	640	2
891	2025-09-15 17:56:55.742644	5	479	2
892	2025-09-15 17:56:55.742644	4	165	1
893	2025-09-15 17:56:55.742644	5	66	2
894	2025-09-15 17:56:55.742644	4	287	1
895	2025-09-15 17:56:55.742644	5	142	2
896	2025-09-15 17:56:55.742644	5	563	2
897	2025-09-15 17:56:55.742644	5	512	2
898	2025-09-15 17:56:55.742644	5	33	2
899	2025-09-15 17:56:55.742644	4	21	1
900	2025-09-15 17:56:55.742644	5	504	2
901	2025-09-15 17:56:55.742644	5	284	2
902	2025-09-15 17:56:55.742644	4	570	1
903	2025-09-15 17:56:55.742644	4	401	1
904	2025-09-15 17:56:55.742644	5	465	2
905	2025-09-15 17:56:55.742644	4	536	1
906	2025-09-15 17:56:55.742644	4	475	1
907	2025-09-15 17:56:55.742644	5	357	2
908	2025-09-15 17:56:55.742644	5	241	2
909	2025-09-15 17:56:55.742644	5	255	2
910	2025-09-15 17:56:55.742644	4	152	1
911	2025-09-15 17:56:55.742644	5	471	2
912	2025-09-15 17:56:55.742644	4	499	1
913	2025-09-15 17:56:55.742644	4	181	1
914	2025-09-15 17:56:55.742644	4	461	1
915	2025-09-15 17:56:55.742644	4	301	1
916	2025-09-15 17:56:55.742644	4	462	1
917	2025-09-15 17:56:55.742644	4	281	1
918	2025-09-15 17:56:55.742644	5	325	2
919	2025-09-15 17:56:55.742644	4	5	1
920	2025-09-15 17:56:55.742644	5	17	2
921	2025-09-15 17:56:55.742644	4	575	1
922	2025-09-15 17:56:55.742644	4	333	1
923	2025-09-15 17:56:55.742644	4	468	1
924	2025-09-15 17:56:55.742644	4	484	1
925	2025-09-15 17:56:55.742644	5	178	2
926	2025-09-15 17:56:55.742644	4	569	1
927	2025-09-15 17:56:55.742644	4	189	1
928	2025-09-15 17:56:55.742644	5	537	2
929	2025-09-15 17:56:55.742644	5	131	2
930	2025-09-15 17:56:55.742644	4	596	1
931	2025-09-15 17:56:55.742644	5	559	2
932	2025-09-15 17:56:55.742644	4	507	1
933	2025-09-15 17:56:55.742644	5	489	2
934	2025-09-15 17:56:55.742644	4	404	1
935	2025-09-15 17:56:55.742644	5	508	2
936	2025-09-15 17:56:55.742644	5	526	2
937	2025-09-15 17:56:55.742644	4	485	1
938	2025-09-15 17:56:55.742644	5	11	2
939	2025-09-15 17:56:55.742644	4	233	1
940	2025-09-15 17:56:55.742644	4	547	1
941	2025-09-15 17:56:55.742644	5	295	2
942	2025-09-15 17:56:55.742644	4	556	1
943	2025-09-15 17:56:55.742644	5	39	2
944	2025-09-15 17:56:55.742644	5	523	2
945	2025-09-15 17:56:55.742644	5	252	2
946	2025-09-15 17:56:55.742644	5	135	2
947	2025-09-15 17:56:55.742644	4	578	1
948	2025-09-15 17:56:55.742644	5	228	2
949	2025-09-15 17:56:55.742644	4	500	1
950	2025-09-15 17:56:55.742644	4	226	1
951	2025-09-15 17:56:55.742644	5	554	2
952	2025-09-15 17:56:55.742644	4	376	1
953	2025-09-15 17:56:55.742644	4	91	1
954	2025-09-15 17:56:55.742644	4	566	1
955	2025-09-15 17:56:55.742644	4	515	1
956	2025-09-15 17:56:55.742644	4	13	1
957	2025-09-15 17:56:55.742644	5	191	2
958	2025-09-15 17:56:55.742644	4	465	1
959	2025-09-15 17:56:55.742644	5	401	2
960	2025-09-15 17:56:55.742644	5	570	2
961	2025-09-15 17:56:55.742644	4	357	1
962	2025-09-15 17:56:55.742644	4	241	1
963	2025-09-15 17:56:55.742644	5	475	2
964	2025-09-15 17:56:55.742644	5	536	2
965	2025-09-15 17:56:55.742644	4	255	1
966	2025-09-15 17:56:55.742644	5	152	2
967	2025-09-15 17:56:55.742644	4	471	1
968	2025-09-15 17:56:55.742644	5	499	2
969	2025-09-15 17:56:55.742644	5	181	2
970	2025-09-15 17:56:55.742644	5	461	2
971	2025-09-15 17:56:55.742644	5	301	2
972	2025-09-15 17:56:55.742644	4	325	1
973	2025-09-15 17:56:55.742644	5	462	2
974	2025-09-15 17:56:55.742644	5	281	2
975	2025-09-15 17:56:55.742644	4	17	1
976	2025-09-15 17:56:55.742644	5	5	2
977	2025-09-15 17:56:55.742644	4	160	1
978	2025-09-15 17:56:55.742644	4	89	1
979	2025-09-15 17:56:55.742644	4	640	1
980	2025-09-15 17:56:55.742644	4	479	1
981	2025-09-15 17:56:55.742644	4	66	1
982	2025-09-15 17:56:55.742644	5	165	2
983	2025-09-15 17:56:55.742644	4	563	1
984	2025-09-15 17:56:55.742644	4	142	1
985	2025-09-15 17:56:55.742644	5	287	2
986	2025-09-15 17:56:55.742644	4	512	1
987	2025-09-15 17:56:55.742644	4	33	1
988	2025-09-15 17:56:55.742644	5	21	2
989	2025-09-15 17:56:55.742644	4	504	1
990	2025-09-15 17:56:55.742644	4	284	1
991	2025-09-15 17:56:55.742644	5	543	2
992	2025-09-15 17:56:55.742644	5	293	2
993	2025-09-15 17:56:55.742644	5	540	2
994	2025-09-15 17:56:55.742644	5	303	2
995	2025-09-15 17:56:55.742644	4	633	1
996	2025-09-15 17:56:55.742644	5	532	2
997	2025-09-15 17:56:55.742644	4	57	1
998	2025-09-15 17:56:55.742644	5	365	2
999	2025-09-15 17:56:55.742644	5	610	2
1000	2025-09-15 17:56:55.742644	4	109	1
1001	2025-09-15 17:56:55.742644	4	442	1
1002	2025-09-15 17:56:55.742644	4	524	1
1003	2025-09-15 17:56:55.742644	4	288	1
1004	2025-09-15 17:56:55.742644	4	31	1
1005	2025-09-15 17:56:55.742644	4	239	1
1006	2025-09-15 17:56:55.742644	5	433	2
1007	2025-09-15 17:56:55.742644	5	500	2
1008	2025-09-15 17:56:55.742644	4	554	1
1009	2025-09-15 17:56:55.742644	5	226	2
1010	2025-09-15 17:56:55.742644	5	376	2
1011	2025-09-15 17:56:55.742644	5	91	2
1012	2025-09-15 17:56:55.742644	5	515	2
1013	2025-09-15 17:56:55.742644	5	566	2
1014	2025-09-15 17:56:55.742644	5	13	2
1015	2025-09-15 17:56:55.742644	4	191	1
1016	2025-09-15 17:56:55.742644	5	485	2
1017	2025-09-15 17:56:55.742644	4	11	1
1018	2025-09-15 17:56:55.742644	5	233	2
1019	2025-09-15 17:56:55.742644	4	295	1
1020	2025-09-15 17:56:55.742644	5	547	2
1021	2025-09-15 17:56:55.742644	4	39	1
1022	2025-09-15 17:56:55.742644	5	556	2
1023	2025-09-15 17:56:55.742644	4	523	1
1024	2025-09-15 17:56:55.742644	4	252	1
1025	2025-09-15 17:56:55.742644	4	135	1
1026	2025-09-15 17:56:55.742644	4	228	1
1027	2025-09-15 17:56:55.742644	5	578	2
1028	2025-09-15 17:56:55.742644	5	569	2
1029	2025-09-15 17:56:55.742644	5	189	2
1030	2025-09-15 17:56:55.742644	4	537	1
1031	2025-09-15 17:56:55.742644	4	131	1
1032	2025-09-15 17:56:55.742644	5	596	2
1033	2025-09-15 17:56:55.742644	4	559	1
1034	2025-09-15 17:56:55.742644	5	507	2
1035	2025-09-15 17:56:55.742644	4	489	1
1036	2025-09-15 17:56:55.742644	4	508	1
1037	2025-09-15 17:56:55.742644	5	404	2
1038	2025-09-15 17:56:55.742644	4	526	1
1039	2025-09-15 17:56:55.742644	5	333	2
1040	2025-09-15 17:56:55.742644	5	575	2
1041	2025-09-15 17:56:55.742644	5	468	2
1042	2025-09-15 17:56:55.742644	5	484	2
1043	2025-09-15 17:56:55.742644	4	178	1
1044	2025-09-15 17:56:55.742644	5	348	2
1045	2025-09-15 17:56:55.742644	4	478	1
1046	2025-09-15 17:56:55.742644	4	64	1
1047	2025-09-15 17:56:55.742644	4	145	1
1048	2025-09-15 17:56:55.742644	5	332	2
1049	2025-09-15 17:56:55.742644	4	458	1
1050	2025-09-15 17:56:55.742644	5	579	2
1051	2025-09-15 17:56:55.742644	5	590	2
1052	2025-09-15 17:56:55.742644	4	582	1
1053	2025-09-15 17:56:55.742644	5	355	2
1054	2025-09-15 17:56:55.742644	5	56	2
1055	2025-09-15 17:56:55.742644	5	182	2
1056	2025-09-15 17:56:55.742644	5	40	2
1057	2025-09-15 17:56:55.742644	4	413	1
1058	2025-09-15 17:56:55.742644	4	163	1
1059	2025-09-15 17:56:55.742644	4	104	1
1060	2025-09-15 17:56:55.742644	4	629	1
1061	2025-09-15 17:56:55.742644	4	198	1
1062	2025-09-15 17:56:55.742644	5	261	2
1063	2025-09-15 17:56:55.742644	5	123	2
1064	2025-09-15 17:56:55.742644	5	277	2
1065	2025-09-15 17:56:55.742644	4	71	1
1066	2025-09-15 17:56:55.742644	4	533	1
1067	2025-09-15 17:56:55.742644	5	474	2
1068	2025-09-15 17:56:55.742644	4	315	1
1069	2025-09-15 17:56:55.742644	5	140	2
1070	2025-09-15 17:56:55.742644	4	102	1
1071	2025-09-15 17:56:55.742644	5	125	2
1072	2025-09-15 17:56:55.742644	5	77	2
1073	2025-09-15 17:56:55.742644	4	343	1
1074	2025-09-15 17:56:55.742644	4	72	1
1075	2025-09-15 17:56:55.742644	5	73	2
1076	2025-09-15 17:56:55.742644	5	631	2
1077	2025-09-15 17:56:55.742644	4	2	1
1078	2025-09-15 17:56:55.742644	5	153	2
1079	2025-09-15 17:56:55.742644	4	588	1
1080	2025-09-15 17:56:55.742644	4	626	1
1081	2025-09-15 17:56:55.742644	4	177	1
1082	2025-09-15 17:56:55.742644	5	46	2
1083	2025-09-15 17:56:55.742644	4	186	1
1084	2025-09-15 17:56:55.742644	4	234	1
1085	2025-09-15 17:56:55.742644	5	211	2
1086	2025-09-15 17:56:55.742644	4	624	1
1087	2025-09-15 17:56:55.742644	5	361	2
1088	2025-09-15 17:56:55.742644	5	304	2
1089	2025-09-15 17:56:55.742644	5	15	2
1090	2025-09-15 17:56:55.742644	5	83	2
1091	2025-09-15 17:56:55.742644	4	34	1
1092	2025-09-15 17:56:55.742644	4	505	1
1093	2025-09-15 17:56:55.742644	4	428	1
1094	2025-09-15 17:56:55.742644	4	321	1
1095	2025-09-15 17:56:55.742644	4	10	1
1096	2025-09-15 17:56:55.742644	4	282	1
1097	2025-09-15 17:56:55.742644	4	296	1
1098	2025-09-15 17:56:55.742644	4	12	1
1099	2025-09-15 17:56:55.742644	4	18	1
1100	2025-09-15 17:56:55.742644	5	473	2
1101	2025-09-15 17:56:55.742644	5	636	2
1102	2025-09-15 17:56:55.742644	5	400	2
1103	2025-09-15 17:56:55.742644	5	274	2
1104	2025-09-15 17:56:55.742644	5	391	2
1105	2025-09-15 17:56:55.742644	4	324	1
1106	2025-09-15 17:56:55.742644	5	444	2
1107	2025-09-15 17:56:55.742644	5	47	2
1108	2025-09-15 17:56:55.742644	4	143	1
1109	2025-09-15 17:56:55.742644	5	412	2
1110	2025-09-15 17:56:55.742644	5	426	2
1111	2025-09-15 17:56:55.742644	5	595	2
1112	2025-09-15 17:56:55.742644	5	320	2
1113	2025-09-15 17:56:55.742644	4	146	1
1114	2025-09-15 17:56:55.742644	4	139	1
1115	2025-09-15 17:56:55.742644	4	614	1
1116	2025-09-15 17:56:55.742644	4	381	1
1117	2025-09-15 17:56:55.742644	4	193	1
1118	2025-09-15 17:56:55.742644	5	297	2
1119	2025-09-15 17:56:55.742644	4	424	1
1120	2025-09-15 17:56:55.742644	4	98	1
1121	2025-09-15 17:56:55.742644	4	594	1
1122	2025-09-15 17:56:55.742644	4	243	1
1123	2025-09-15 17:56:55.742644	5	627	2
1124	2025-09-15 17:56:55.742644	5	314	2
1125	2025-09-15 17:56:55.742644	4	466	1
1126	2025-09-15 17:56:55.742644	5	459	2
1127	2025-09-15 17:56:55.742644	5	419	2
1128	2025-09-15 17:56:55.742644	4	408	1
1129	2025-09-15 17:56:55.742644	4	250	1
1130	2025-09-15 17:56:55.742644	5	337	2
1131	2025-09-15 17:56:55.742644	4	167	1
1132	2025-09-15 17:56:55.742644	5	480	2
1133	2025-09-15 17:56:55.742644	5	346	2
1134	2025-09-15 17:56:55.742644	4	617	1
1135	2025-09-15 17:56:55.742644	5	280	2
1136	2025-09-15 17:56:55.742644	5	202	2
1137	2025-09-15 17:56:55.742644	5	216	2
1138	2025-09-15 17:56:55.742644	5	266	2
1139	2025-09-15 17:56:55.742644	4	253	1
1140	2025-09-15 17:56:55.742644	5	353	2
1141	2025-09-15 17:56:55.742644	4	384	1
1142	2025-09-15 17:56:55.742644	4	151	1
1143	2025-09-15 17:56:55.742644	4	270	1
1144	2025-09-15 17:56:55.742644	5	256	2
1145	2025-09-15 17:56:55.742644	4	399	1
1146	2025-09-15 17:56:55.742644	4	119	1
1147	2025-09-15 17:56:55.742644	4	518	1
1148	2025-09-15 17:56:55.742644	4	620	1
1149	2025-09-15 17:56:55.742644	5	300	2
1150	2025-09-15 17:56:55.742644	4	437	1
1151	2025-09-15 17:56:55.742644	5	456	2
1152	2025-09-15 17:56:55.742644	5	128	2
1153	2025-09-15 17:56:55.742644	5	38	2
1154	2025-09-15 17:56:55.742644	5	565	2
1155	2025-09-15 17:56:55.742644	4	310	1
1156	2025-09-15 17:56:55.742644	4	214	1
1157	2025-09-15 17:56:55.742644	4	549	1
1158	2025-09-15 17:56:55.742644	4	268	1
1159	2025-09-15 17:56:55.742644	4	339	1
1160	2025-09-15 17:56:55.742644	4	20	1
1161	2025-09-15 17:56:55.742644	5	55	2
1162	2025-09-15 17:56:55.742644	4	101	1
1163	2025-09-15 17:56:55.742644	5	494	2
1164	2025-09-15 17:56:55.742644	4	397	1
1165	2025-09-15 17:56:55.742644	5	403	2
1166	2025-09-15 17:56:55.742644	5	170	2
1167	2025-09-15 17:56:55.742644	5	244	2
1168	2025-09-15 17:56:55.742644	4	330	1
1169	2025-09-15 17:56:55.742644	5	535	2
1170	2025-09-15 17:56:55.742644	4	486	1
1171	2025-09-15 17:56:55.742644	5	68	2
1172	2025-09-15 17:56:55.742644	5	374	2
1173	2025-09-15 17:56:55.742644	5	158	2
1174	2025-09-15 17:56:55.742644	4	285	1
1175	2025-09-15 17:56:55.742644	4	120	1
1176	2025-09-15 17:56:55.742644	5	427	2
1177	2025-09-15 17:56:55.742644	4	106	1
1178	2025-09-15 17:56:55.742644	4	251	1
1179	2025-09-15 17:56:55.742644	5	232	2
1180	2025-09-15 17:56:55.742644	5	184	2
1181	2025-09-15 17:56:55.742644	5	24	2
1182	2025-09-15 17:56:55.742644	4	601	1
1183	2025-09-15 17:56:55.742644	4	264	1
1184	2025-09-15 17:56:55.742644	5	377	2
1185	2025-09-15 17:56:55.742644	5	113	2
1186	2025-09-15 17:56:55.742644	5	172	2
1187	2025-09-15 17:56:55.742644	5	279	2
1188	2025-09-15 17:56:55.742644	5	289	2
1189	2025-09-15 17:56:55.742644	5	637	2
1190	2025-09-15 17:56:55.742644	5	133	2
1191	2025-09-15 17:56:55.742644	4	497	1
1192	2025-09-15 17:56:55.742644	5	603	2
1193	2025-09-15 17:56:55.742644	4	452	1
1194	2025-09-15 17:56:55.742644	5	638	2
1195	2025-09-15 17:56:55.742644	5	492	2
1196	2025-09-15 17:56:55.742644	5	416	2
1197	2025-09-15 17:56:55.742644	5	443	2
1198	2025-09-15 17:56:55.742644	5	100	2
1199	2025-09-15 17:56:55.742644	5	326	2
1200	2025-09-15 17:56:55.742644	4	455	1
1201	2025-09-15 17:56:55.742644	4	496	1
1202	2025-09-15 17:56:55.742644	5	164	2
1203	2025-09-15 17:56:55.742644	4	209	1
1204	2025-09-15 17:56:55.742644	5	278	2
1205	2025-09-15 17:56:55.742644	5	78	2
1206	2025-09-15 17:56:55.742644	4	630	1
1207	2025-09-15 17:56:55.742644	5	421	2
1208	2025-09-15 17:56:55.742644	5	32	2
1209	2025-09-15 17:56:55.742644	4	577	1
1210	2025-09-15 17:56:55.742644	4	606	1
1211	2025-09-15 17:56:55.742644	4	276	1
1212	2025-09-15 17:56:55.742644	5	85	2
1213	2025-09-15 17:56:55.742644	5	358	2
1214	2025-09-15 17:56:55.742644	4	599	1
1215	2025-09-15 17:56:55.742644	4	550	1
1216	2025-09-15 17:56:55.742644	5	546	2
1217	2025-09-15 17:56:55.742644	4	27	1
1218	2025-09-15 17:56:55.742644	5	366	2
1219	2025-09-15 17:56:55.742644	5	635	2
1220	2025-09-15 17:56:55.742644	5	317	2
1221	2025-09-15 17:56:55.742644	5	52	2
1222	2025-09-15 17:56:55.742644	4	238	1
1223	2025-09-15 17:56:55.742644	5	65	2
1224	2025-09-15 17:56:55.742644	4	230	1
1225	2025-09-15 17:56:55.742644	5	37	2
1226	2025-09-15 17:56:55.742644	5	440	2
1227	2025-09-15 17:56:55.742644	4	449	1
1228	2025-09-15 17:56:55.742644	5	258	2
1229	2025-09-15 17:56:55.742644	4	414	1
1230	2025-09-15 17:56:55.742644	5	215	2
1231	2025-09-15 17:56:55.742644	5	108	2
1232	2025-09-15 17:56:55.742644	5	398	2
1233	2025-09-15 17:56:55.742644	5	19	2
1234	2025-09-15 17:56:55.742644	5	589	2
1235	2025-09-15 17:56:55.742644	5	435	2
1236	2025-09-15 17:56:55.742644	5	221	2
1237	2025-09-15 17:56:55.742644	5	530	2
1238	2025-09-15 17:56:55.742644	4	382	1
1239	2025-09-15 17:56:55.742644	5	576	2
1240	2025-09-15 17:56:55.742644	4	307	1
1241	2025-09-15 17:56:55.742644	4	93	1
1242	2025-09-15 17:56:55.742644	4	149	1
1243	2025-09-15 17:56:55.742644	5	107	2
1244	2025-09-15 17:56:55.742644	4	335	1
1245	2025-09-15 17:56:55.742644	5	396	2
1246	2025-09-15 17:56:55.742644	4	555	1
1247	2025-09-15 17:56:55.742644	5	319	2
1248	2025-09-15 17:56:55.742644	4	541	1
1249	2025-09-15 17:56:55.742644	5	600	2
1250	2025-09-15 17:56:55.742644	5	493	2
1251	2025-09-15 17:56:55.742644	4	25	1
1252	2025-09-15 17:56:55.742644	5	96	2
1253	2025-09-15 17:56:55.742644	4	82	1
1254	2025-09-15 17:56:55.742644	5	581	2
1255	2025-09-15 17:56:55.742644	4	359	1
1256	2025-09-15 17:56:55.742644	5	432	2
1257	2025-09-15 17:56:55.742644	5	519	2
1258	2025-09-15 17:56:55.742644	4	137	1
1259	2025-09-15 17:56:55.742644	5	429	2
1260	2025-09-15 17:56:55.742644	4	213	1
1261	2025-09-15 17:56:55.742644	4	26	1
1262	2025-09-15 17:56:55.742644	4	265	1
1263	2025-09-15 17:56:55.742644	5	254	2
1264	2025-09-15 17:56:55.742644	5	112	2
1265	2025-09-15 17:56:55.742644	5	625	2
1266	2025-09-15 17:56:55.742644	5	392	2
1267	2025-09-15 17:56:55.742644	4	405	1
1268	2025-09-15 17:56:55.742644	4	379	1
1269	2025-09-15 17:56:55.742644	4	136	1
1270	2025-09-15 17:56:55.742644	4	168	1
1271	2025-09-15 17:56:55.742644	5	298	2
1272	2025-09-15 17:56:55.742644	5	609	2
1273	2025-09-15 17:56:55.742644	4	292	1
1274	2025-09-15 17:56:55.742644	4	218	1
1275	2025-09-15 17:56:55.742644	4	196	1
1276	2025-09-15 17:56:55.742644	5	593	2
1277	2025-09-15 17:56:55.742644	5	340	2
1278	2025-09-15 17:56:55.742644	5	367	2
1279	2025-09-15 17:56:55.742644	4	373	1
1280	2025-09-15 17:56:55.742644	5	498	2
1282	\N	5	648	15
\.


--
-- Data for Name: favorito; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.favorito (id_fav, fecha_creacion, id_receta, id_usr) FROM stdin;
1	2025-09-15 17:56:55.742644	1	1
2	2025-09-15 17:56:55.742644	2	1
3	2025-09-15 17:56:55.742644	3	1
4	2025-09-15 17:56:55.742644	4	1
5	2025-09-15 17:56:55.742644	5	1
6	2025-09-15 17:56:55.742644	6	1
7	2025-09-15 17:56:55.742644	7	1
8	2025-09-15 17:56:55.742644	8	1
9	2025-09-15 17:56:55.742644	9	1
10	2025-09-15 17:56:55.742644	10	1
11	2025-09-15 17:56:55.742644	11	1
12	2025-09-15 17:56:55.742644	12	1
13	2025-09-15 17:56:55.742644	13	1
14	2025-09-15 17:56:55.742644	14	1
15	2025-09-15 17:56:55.742644	15	1
16	2025-09-15 17:56:55.742644	16	1
17	2025-09-15 17:56:55.742644	17	1
18	2025-09-15 17:56:55.742644	18	1
19	2025-09-15 17:56:55.742644	19	1
20	2025-09-15 17:56:55.742644	20	1
21	2025-09-15 17:56:55.742644	21	1
22	2025-09-15 17:56:55.742644	22	1
23	2025-09-15 17:56:55.742644	23	1
24	2025-09-15 17:56:55.742644	24	1
25	2025-09-15 17:56:55.742644	25	1
26	2025-09-15 17:56:55.742644	26	1
27	2025-09-15 17:56:55.742644	27	1
28	2025-09-15 17:56:55.742644	28	1
29	2025-09-15 17:56:55.742644	29	1
30	2025-09-15 17:56:55.742644	30	1
31	2025-09-15 17:56:55.742644	31	1
32	2025-09-15 17:56:55.742644	32	1
33	2025-09-15 17:56:55.742644	33	1
34	2025-09-15 17:56:55.742644	34	1
35	2025-09-15 17:56:55.742644	35	1
36	2025-09-15 17:56:55.742644	36	1
37	2025-09-15 17:56:55.742644	37	1
38	2025-09-15 17:56:55.742644	38	1
39	2025-09-15 17:56:55.742644	39	1
40	2025-09-15 17:56:55.742644	40	1
41	2025-09-15 17:56:55.742644	41	1
42	2025-09-15 17:56:55.742644	42	1
43	2025-09-15 17:56:55.742644	43	1
44	2025-09-15 17:56:55.742644	44	1
45	2025-09-15 17:56:55.742644	45	1
46	2025-09-15 17:56:55.742644	46	1
47	2025-09-15 17:56:55.742644	47	1
48	2025-09-15 17:56:55.742644	48	1
49	2025-09-15 17:56:55.742644	49	1
50	2025-09-15 17:56:55.742644	50	1
51	2025-09-15 17:56:55.742644	51	1
52	2025-09-15 17:56:55.742644	52	1
53	2025-09-15 17:56:55.742644	53	1
54	2025-09-15 17:56:55.742644	54	1
55	2025-09-15 17:56:55.742644	55	1
56	2025-09-15 17:56:55.742644	56	1
57	2025-09-15 17:56:55.742644	57	1
58	2025-09-15 17:56:55.742644	58	1
59	2025-09-15 17:56:55.742644	59	1
60	2025-09-15 17:56:55.742644	60	1
61	2025-09-15 17:56:55.742644	61	1
62	2025-09-15 17:56:55.742644	62	1
63	2025-09-15 17:56:55.742644	63	1
64	2025-09-15 17:56:55.742644	64	1
65	2025-09-15 17:56:55.742644	65	1
66	2025-09-15 17:56:55.742644	66	1
67	2025-09-15 17:56:55.742644	67	1
68	2025-09-15 17:56:55.742644	68	1
69	2025-09-15 17:56:55.742644	69	1
70	2025-09-15 17:56:55.742644	70	1
71	2025-09-15 17:56:55.742644	71	1
72	2025-09-15 17:56:55.742644	72	1
73	2025-09-15 17:56:55.742644	73	1
74	2025-09-15 17:56:55.742644	74	1
75	2025-09-15 17:56:55.742644	75	1
76	2025-09-15 17:56:55.742644	76	1
77	2025-09-15 17:56:55.742644	77	1
78	2025-09-15 17:56:55.742644	78	1
79	2025-09-15 17:56:55.742644	79	1
80	2025-09-15 17:56:55.742644	80	1
81	2025-09-15 17:56:55.742644	81	1
82	2025-09-15 17:56:55.742644	82	1
83	2025-09-15 17:56:55.742644	83	1
84	2025-09-15 17:56:55.742644	84	1
85	2025-09-15 17:56:55.742644	85	1
86	2025-09-15 17:56:55.742644	86	1
87	2025-09-15 17:56:55.742644	87	1
88	2025-09-15 17:56:55.742644	88	1
89	2025-09-15 17:56:55.742644	89	1
90	2025-09-15 17:56:55.742644	90	1
91	2025-09-15 17:56:55.742644	91	1
92	2025-09-15 17:56:55.742644	92	1
93	2025-09-15 17:56:55.742644	93	1
94	2025-09-15 17:56:55.742644	94	1
95	2025-09-15 17:56:55.742644	95	1
96	2025-09-15 17:56:55.742644	96	1
97	2025-09-15 17:56:55.742644	97	1
98	2025-09-15 17:56:55.742644	98	1
99	2025-09-15 17:56:55.742644	99	1
100	2025-09-15 17:56:55.742644	100	1
101	2025-09-15 17:56:55.742644	101	1
102	2025-09-15 17:56:55.742644	102	1
103	2025-09-15 17:56:55.742644	103	1
104	2025-09-15 17:56:55.742644	104	1
105	2025-09-15 17:56:55.742644	105	1
106	2025-09-15 17:56:55.742644	106	1
107	2025-09-15 17:56:55.742644	107	1
108	2025-09-15 17:56:55.742644	108	1
109	2025-09-15 17:56:55.742644	109	1
110	2025-09-15 17:56:55.742644	110	1
111	2025-09-15 17:56:55.742644	111	1
112	2025-09-15 17:56:55.742644	112	1
113	2025-09-15 17:56:55.742644	113	1
114	2025-09-15 17:56:55.742644	114	1
115	2025-09-15 17:56:55.742644	115	1
116	2025-09-15 17:56:55.742644	116	1
117	2025-09-15 17:56:55.742644	117	1
118	2025-09-15 17:56:55.742644	118	1
119	2025-09-15 17:56:55.742644	119	1
120	2025-09-15 17:56:55.742644	120	1
121	2025-09-15 17:56:55.742644	121	1
122	2025-09-15 17:56:55.742644	122	1
123	2025-09-15 17:56:55.742644	123	1
124	2025-09-15 17:56:55.742644	124	1
125	2025-09-15 17:56:55.742644	125	1
126	2025-09-15 17:56:55.742644	126	1
127	2025-09-15 17:56:55.742644	127	1
128	2025-09-15 17:56:55.742644	128	1
129	2025-09-15 17:56:55.742644	129	1
130	2025-09-15 17:56:55.742644	130	1
131	2025-09-15 17:56:55.742644	131	1
132	2025-09-15 17:56:55.742644	132	1
133	2025-09-15 17:56:55.742644	133	1
134	2025-09-15 17:56:55.742644	134	1
135	2025-09-15 17:56:55.742644	135	1
136	2025-09-15 17:56:55.742644	136	1
137	2025-09-15 17:56:55.742644	137	1
138	2025-09-15 17:56:55.742644	138	1
139	2025-09-15 17:56:55.742644	139	1
140	2025-09-15 17:56:55.742644	140	1
141	2025-09-15 17:56:55.742644	141	1
142	2025-09-15 17:56:55.742644	142	1
143	2025-09-15 17:56:55.742644	143	1
144	2025-09-15 17:56:55.742644	144	1
145	2025-09-15 17:56:55.742644	145	1
146	2025-09-15 17:56:55.742644	146	1
147	2025-09-15 17:56:55.742644	147	1
148	2025-09-15 17:56:55.742644	148	1
149	2025-09-15 17:56:55.742644	149	1
150	2025-09-15 17:56:55.742644	150	1
151	2025-09-15 17:56:55.742644	151	1
152	2025-09-15 17:56:55.742644	152	1
153	2025-09-15 17:56:55.742644	153	1
154	2025-09-15 17:56:55.742644	154	1
155	2025-09-15 17:56:55.742644	155	1
156	2025-09-15 17:56:55.742644	156	1
157	2025-09-15 17:56:55.742644	157	1
158	2025-09-15 17:56:55.742644	158	1
159	2025-09-15 17:56:55.742644	159	1
160	2025-09-15 17:56:55.742644	160	1
161	2025-09-15 17:56:55.742644	161	1
162	2025-09-15 17:56:55.742644	162	1
163	2025-09-15 17:56:55.742644	163	1
164	2025-09-15 17:56:55.742644	164	1
165	2025-09-15 17:56:55.742644	165	1
166	2025-09-15 17:56:55.742644	166	1
167	2025-09-15 17:56:55.742644	167	1
168	2025-09-15 17:56:55.742644	168	1
169	2025-09-15 17:56:55.742644	169	1
170	2025-09-15 17:56:55.742644	170	1
171	2025-09-15 17:56:55.742644	171	1
172	2025-09-15 17:56:55.742644	172	1
173	2025-09-15 17:56:55.742644	173	1
174	2025-09-15 17:56:55.742644	174	1
175	2025-09-15 17:56:55.742644	175	1
176	2025-09-15 17:56:55.742644	176	1
177	2025-09-15 17:56:55.742644	177	1
178	2025-09-15 17:56:55.742644	178	1
179	2025-09-15 17:56:55.742644	179	1
180	2025-09-15 17:56:55.742644	180	1
181	2025-09-15 17:56:55.742644	181	1
182	2025-09-15 17:56:55.742644	182	1
183	2025-09-15 17:56:55.742644	183	1
184	2025-09-15 17:56:55.742644	184	1
185	2025-09-15 17:56:55.742644	185	1
186	2025-09-15 17:56:55.742644	186	1
187	2025-09-15 17:56:55.742644	187	1
188	2025-09-15 17:56:55.742644	188	1
189	2025-09-15 17:56:55.742644	189	1
190	2025-09-15 17:56:55.742644	190	1
191	2025-09-15 17:56:55.742644	191	1
192	2025-09-15 17:56:55.742644	192	1
193	2025-09-15 17:56:55.742644	193	1
194	2025-09-15 17:56:55.742644	194	1
195	2025-09-15 17:56:55.742644	195	1
196	2025-09-15 17:56:55.742644	196	1
197	2025-09-15 17:56:55.742644	197	1
198	2025-09-15 17:56:55.742644	198	1
199	2025-09-15 17:56:55.742644	199	1
200	2025-09-15 17:56:55.742644	200	1
201	2025-09-15 17:56:55.742644	201	1
202	2025-09-15 17:56:55.742644	202	1
203	2025-09-15 17:56:55.742644	203	1
204	2025-09-15 17:56:55.742644	204	1
205	2025-09-15 17:56:55.742644	205	1
206	2025-09-15 17:56:55.742644	206	1
207	2025-09-15 17:56:55.742644	207	1
208	2025-09-15 17:56:55.742644	208	1
209	2025-09-15 17:56:55.742644	209	1
210	2025-09-15 17:56:55.742644	210	1
211	2025-09-15 17:56:55.742644	211	1
212	2025-09-15 17:56:55.742644	212	1
213	2025-09-15 17:56:55.742644	213	1
214	2025-09-15 17:56:55.742644	214	1
215	2025-09-15 17:56:55.742644	215	1
216	2025-09-15 17:56:55.742644	216	1
217	2025-09-15 17:56:55.742644	217	1
218	2025-09-15 17:56:55.742644	218	1
219	2025-09-15 17:56:55.742644	219	1
220	2025-09-15 17:56:55.742644	220	1
221	2025-09-15 17:56:55.742644	221	1
222	2025-09-15 17:56:55.742644	222	1
223	2025-09-15 17:56:55.742644	223	1
224	2025-09-15 17:56:55.742644	224	1
225	2025-09-15 17:56:55.742644	225	1
226	2025-09-15 17:56:55.742644	226	1
227	2025-09-15 17:56:55.742644	227	1
228	2025-09-15 17:56:55.742644	228	1
229	2025-09-15 17:56:55.742644	229	1
230	2025-09-15 17:56:55.742644	230	1
231	2025-09-15 17:56:55.742644	231	1
232	2025-09-15 17:56:55.742644	232	1
233	2025-09-15 17:56:55.742644	233	1
234	2025-09-15 17:56:55.742644	234	1
235	2025-09-15 17:56:55.742644	235	1
236	2025-09-15 17:56:55.742644	236	1
237	2025-09-15 17:56:55.742644	237	1
238	2025-09-15 17:56:55.742644	238	1
239	2025-09-15 17:56:55.742644	239	1
240	2025-09-15 17:56:55.742644	240	1
241	2025-09-15 17:56:55.742644	241	1
242	2025-09-15 17:56:55.742644	242	1
243	2025-09-15 17:56:55.742644	243	1
244	2025-09-15 17:56:55.742644	244	1
245	2025-09-15 17:56:55.742644	245	1
246	2025-09-15 17:56:55.742644	246	1
247	2025-09-15 17:56:55.742644	247	1
248	2025-09-15 17:56:55.742644	248	1
249	2025-09-15 17:56:55.742644	249	1
250	2025-09-15 17:56:55.742644	250	1
251	2025-09-15 17:56:55.742644	251	1
252	2025-09-15 17:56:55.742644	252	1
253	2025-09-15 17:56:55.742644	253	1
254	2025-09-15 17:56:55.742644	254	1
255	2025-09-15 17:56:55.742644	255	1
256	2025-09-15 17:56:55.742644	256	1
257	2025-09-15 17:56:55.742644	257	1
258	2025-09-15 17:56:55.742644	258	1
259	2025-09-15 17:56:55.742644	259	1
260	2025-09-15 17:56:55.742644	260	1
261	2025-09-15 17:56:55.742644	261	1
262	2025-09-15 17:56:55.742644	262	1
263	2025-09-15 17:56:55.742644	263	1
264	2025-09-15 17:56:55.742644	264	1
265	2025-09-15 17:56:55.742644	265	1
266	2025-09-15 17:56:55.742644	266	1
267	2025-09-15 17:56:55.742644	267	1
268	2025-09-15 17:56:55.742644	268	1
269	2025-09-15 17:56:55.742644	269	1
270	2025-09-15 17:56:55.742644	270	1
271	2025-09-15 17:56:55.742644	271	1
272	2025-09-15 17:56:55.742644	272	1
273	2025-09-15 17:56:55.742644	273	1
274	2025-09-15 17:56:55.742644	274	1
275	2025-09-15 17:56:55.742644	275	1
276	2025-09-15 17:56:55.742644	276	1
277	2025-09-15 17:56:55.742644	277	1
278	2025-09-15 17:56:55.742644	278	1
279	2025-09-15 17:56:55.742644	279	1
280	2025-09-15 17:56:55.742644	280	1
281	2025-09-15 17:56:55.742644	281	1
282	2025-09-15 17:56:55.742644	282	1
283	2025-09-15 17:56:55.742644	283	1
284	2025-09-15 17:56:55.742644	284	1
285	2025-09-15 17:56:55.742644	285	1
286	2025-09-15 17:56:55.742644	286	1
287	2025-09-15 17:56:55.742644	287	1
288	2025-09-15 17:56:55.742644	288	1
289	2025-09-15 17:56:55.742644	289	1
290	2025-09-15 17:56:55.742644	290	1
291	2025-09-15 17:56:55.742644	291	1
292	2025-09-15 17:56:55.742644	292	1
293	2025-09-15 17:56:55.742644	293	1
294	2025-09-15 17:56:55.742644	294	1
295	2025-09-15 17:56:55.742644	295	1
296	2025-09-15 17:56:55.742644	296	1
297	2025-09-15 17:56:55.742644	297	1
298	2025-09-15 17:56:55.742644	298	1
299	2025-09-15 17:56:55.742644	299	1
300	2025-09-15 17:56:55.742644	300	1
301	2025-09-15 17:56:55.742644	301	1
302	2025-09-15 17:56:55.742644	302	1
303	2025-09-15 17:56:55.742644	303	1
304	2025-09-15 17:56:55.742644	304	1
305	2025-09-15 17:56:55.742644	305	1
306	2025-09-15 17:56:55.742644	306	1
307	2025-09-15 17:56:55.742644	307	1
308	2025-09-15 17:56:55.742644	308	1
309	2025-09-15 17:56:55.742644	309	1
310	2025-09-15 17:56:55.742644	310	1
311	2025-09-15 17:56:55.742644	311	1
312	2025-09-15 17:56:55.742644	312	1
313	2025-09-15 17:56:55.742644	313	1
314	2025-09-15 17:56:55.742644	314	1
315	2025-09-15 17:56:55.742644	315	1
316	2025-09-15 17:56:55.742644	316	1
317	2025-09-15 17:56:55.742644	317	1
318	2025-09-15 17:56:55.742644	318	1
319	2025-09-15 17:56:55.742644	319	1
320	2025-09-15 17:56:55.742644	320	1
321	2025-09-15 17:56:55.742644	321	1
322	2025-09-15 17:56:55.742644	322	1
323	2025-09-15 17:56:55.742644	323	1
324	2025-09-15 17:56:55.742644	324	1
325	2025-09-15 17:56:55.742644	325	1
326	2025-09-15 17:56:55.742644	326	1
327	2025-09-15 17:56:55.742644	327	1
328	2025-09-15 17:56:55.742644	328	1
329	2025-09-15 17:56:55.742644	329	1
330	2025-09-15 17:56:55.742644	330	1
331	2025-09-15 17:56:55.742644	331	1
332	2025-09-15 17:56:55.742644	332	1
333	2025-09-15 17:56:55.742644	333	1
334	2025-09-15 17:56:55.742644	334	1
335	2025-09-15 17:56:55.742644	335	1
336	2025-09-15 17:56:55.742644	336	1
337	2025-09-15 17:56:55.742644	337	1
338	2025-09-15 17:56:55.742644	338	1
339	2025-09-15 17:56:55.742644	339	1
340	2025-09-15 17:56:55.742644	340	1
341	2025-09-15 17:56:55.742644	341	1
342	2025-09-15 17:56:55.742644	342	1
343	2025-09-15 17:56:55.742644	343	1
344	2025-09-15 17:56:55.742644	344	1
345	2025-09-15 17:56:55.742644	345	1
346	2025-09-15 17:56:55.742644	346	1
347	2025-09-15 17:56:55.742644	347	1
348	2025-09-15 17:56:55.742644	348	1
349	2025-09-15 17:56:55.742644	349	1
350	2025-09-15 17:56:55.742644	350	1
351	2025-09-15 17:56:55.742644	351	1
352	2025-09-15 17:56:55.742644	352	1
353	2025-09-15 17:56:55.742644	353	1
354	2025-09-15 17:56:55.742644	354	1
355	2025-09-15 17:56:55.742644	355	1
356	2025-09-15 17:56:55.742644	356	1
357	2025-09-15 17:56:55.742644	357	1
358	2025-09-15 17:56:55.742644	358	1
359	2025-09-15 17:56:55.742644	359	1
360	2025-09-15 17:56:55.742644	360	1
361	2025-09-15 17:56:55.742644	361	1
362	2025-09-15 17:56:55.742644	362	1
363	2025-09-15 17:56:55.742644	363	1
364	2025-09-15 17:56:55.742644	364	1
365	2025-09-15 17:56:55.742644	365	1
366	2025-09-15 17:56:55.742644	366	1
367	2025-09-15 17:56:55.742644	367	1
368	2025-09-15 17:56:55.742644	368	1
369	2025-09-15 17:56:55.742644	369	1
370	2025-09-15 17:56:55.742644	370	1
371	2025-09-15 17:56:55.742644	371	1
372	2025-09-15 17:56:55.742644	372	1
373	2025-09-15 17:56:55.742644	373	1
374	2025-09-15 17:56:55.742644	374	1
375	2025-09-15 17:56:55.742644	375	1
376	2025-09-15 17:56:55.742644	376	1
377	2025-09-15 17:56:55.742644	377	1
378	2025-09-15 17:56:55.742644	378	1
379	2025-09-15 17:56:55.742644	379	1
380	2025-09-15 17:56:55.742644	380	1
381	2025-09-15 17:56:55.742644	381	1
382	2025-09-15 17:56:55.742644	382	1
383	2025-09-15 17:56:55.742644	383	1
384	2025-09-15 17:56:55.742644	384	1
385	2025-09-15 17:56:55.742644	385	1
386	2025-09-15 17:56:55.742644	386	1
387	2025-09-15 17:56:55.742644	387	1
388	2025-09-15 17:56:55.742644	388	1
389	2025-09-15 17:56:55.742644	389	1
390	2025-09-15 17:56:55.742644	390	1
391	2025-09-15 17:56:55.742644	391	1
392	2025-09-15 17:56:55.742644	392	1
393	2025-09-15 17:56:55.742644	393	1
394	2025-09-15 17:56:55.742644	394	1
395	2025-09-15 17:56:55.742644	395	1
396	2025-09-15 17:56:55.742644	396	1
397	2025-09-15 17:56:55.742644	397	1
398	2025-09-15 17:56:55.742644	398	1
399	2025-09-15 17:56:55.742644	399	1
400	2025-09-15 17:56:55.742644	400	1
401	2025-09-15 17:56:55.742644	401	1
402	2025-09-15 17:56:55.742644	402	1
403	2025-09-15 17:56:55.742644	403	1
404	2025-09-15 17:56:55.742644	404	1
405	2025-09-15 17:56:55.742644	405	1
406	2025-09-15 17:56:55.742644	406	1
407	2025-09-15 17:56:55.742644	407	1
408	2025-09-15 17:56:55.742644	408	1
409	2025-09-15 17:56:55.742644	409	1
410	2025-09-15 17:56:55.742644	410	1
411	2025-09-15 17:56:55.742644	411	1
412	2025-09-15 17:56:55.742644	412	1
413	2025-09-15 17:56:55.742644	413	1
414	2025-09-15 17:56:55.742644	414	1
415	2025-09-15 17:56:55.742644	415	1
416	2025-09-15 17:56:55.742644	416	1
417	2025-09-15 17:56:55.742644	417	1
418	2025-09-15 17:56:55.742644	418	1
419	2025-09-15 17:56:55.742644	419	1
420	2025-09-15 17:56:55.742644	420	1
421	2025-09-15 17:56:55.742644	421	1
422	2025-09-15 17:56:55.742644	422	1
423	2025-09-15 17:56:55.742644	423	1
424	2025-09-15 17:56:55.742644	424	1
425	2025-09-15 17:56:55.742644	425	1
426	2025-09-15 17:56:55.742644	426	1
427	2025-09-15 17:56:55.742644	427	1
428	2025-09-15 17:56:55.742644	428	1
429	2025-09-15 17:56:55.742644	429	1
430	2025-09-15 17:56:55.742644	430	1
431	2025-09-15 17:56:55.742644	431	1
432	2025-09-15 17:56:55.742644	432	1
433	2025-09-15 17:56:55.742644	433	1
434	2025-09-15 17:56:55.742644	434	1
435	2025-09-15 17:56:55.742644	435	1
436	2025-09-15 17:56:55.742644	436	1
437	2025-09-15 17:56:55.742644	437	1
438	2025-09-15 17:56:55.742644	438	1
439	2025-09-15 17:56:55.742644	439	1
440	2025-09-15 17:56:55.742644	440	1
441	2025-09-15 17:56:55.742644	441	1
442	2025-09-15 17:56:55.742644	442	1
443	2025-09-15 17:56:55.742644	443	1
444	2025-09-15 17:56:55.742644	444	1
445	2025-09-15 17:56:55.742644	445	1
446	2025-09-15 17:56:55.742644	446	1
447	2025-09-15 17:56:55.742644	447	1
448	2025-09-15 17:56:55.742644	448	1
449	2025-09-15 17:56:55.742644	449	1
450	2025-09-15 17:56:55.742644	450	1
451	2025-09-15 17:56:55.742644	451	1
452	2025-09-15 17:56:55.742644	452	1
453	2025-09-15 17:56:55.742644	453	1
454	2025-09-15 17:56:55.742644	454	1
455	2025-09-15 17:56:55.742644	455	1
456	2025-09-15 17:56:55.742644	456	1
457	2025-09-15 17:56:55.742644	457	1
458	2025-09-15 17:56:55.742644	458	1
459	2025-09-15 17:56:55.742644	459	1
460	2025-09-15 17:56:55.742644	460	1
461	2025-09-15 17:56:55.742644	461	1
462	2025-09-15 17:56:55.742644	462	1
463	2025-09-15 17:56:55.742644	463	1
464	2025-09-15 17:56:55.742644	464	1
465	2025-09-15 17:56:55.742644	465	1
466	2025-09-15 17:56:55.742644	466	1
467	2025-09-15 17:56:55.742644	467	1
468	2025-09-15 17:56:55.742644	468	1
469	2025-09-15 17:56:55.742644	469	1
470	2025-09-15 17:56:55.742644	470	1
471	2025-09-15 17:56:55.742644	471	1
472	2025-09-15 17:56:55.742644	472	1
473	2025-09-15 17:56:55.742644	473	1
474	2025-09-15 17:56:55.742644	474	1
475	2025-09-15 17:56:55.742644	475	1
476	2025-09-15 17:56:55.742644	476	1
477	2025-09-15 17:56:55.742644	477	1
478	2025-09-15 17:56:55.742644	478	1
479	2025-09-15 17:56:55.742644	479	1
480	2025-09-15 17:56:55.742644	480	1
481	2025-09-15 17:56:55.742644	481	1
482	2025-09-15 17:56:55.742644	482	1
483	2025-09-15 17:56:55.742644	483	1
484	2025-09-15 17:56:55.742644	484	1
485	2025-09-15 17:56:55.742644	485	1
486	2025-09-15 17:56:55.742644	486	1
487	2025-09-15 17:56:55.742644	487	1
488	2025-09-15 17:56:55.742644	488	1
489	2025-09-15 17:56:55.742644	489	1
490	2025-09-15 17:56:55.742644	490	1
491	2025-09-15 17:56:55.742644	491	1
492	2025-09-15 17:56:55.742644	492	1
493	2025-09-15 17:56:55.742644	493	1
494	2025-09-15 17:56:55.742644	494	1
495	2025-09-15 17:56:55.742644	495	1
496	2025-09-15 17:56:55.742644	496	1
497	2025-09-15 17:56:55.742644	497	1
498	2025-09-15 17:56:55.742644	498	1
499	2025-09-15 17:56:55.742644	499	1
500	2025-09-15 17:56:55.742644	500	1
501	2025-09-15 17:56:55.742644	501	1
502	2025-09-15 17:56:55.742644	502	1
503	2025-09-15 17:56:55.742644	503	1
504	2025-09-15 17:56:55.742644	504	1
505	2025-09-15 17:56:55.742644	505	1
506	2025-09-15 17:56:55.742644	506	1
507	2025-09-15 17:56:55.742644	507	1
508	2025-09-15 17:56:55.742644	508	1
509	2025-09-15 17:56:55.742644	509	1
510	2025-09-15 17:56:55.742644	510	1
511	2025-09-15 17:56:55.742644	511	1
512	2025-09-15 17:56:55.742644	512	1
513	2025-09-15 17:56:55.742644	513	1
514	2025-09-15 17:56:55.742644	514	1
515	2025-09-15 17:56:55.742644	515	1
516	2025-09-15 17:56:55.742644	516	1
517	2025-09-15 17:56:55.742644	517	1
518	2025-09-15 17:56:55.742644	518	1
519	2025-09-15 17:56:55.742644	519	1
520	2025-09-15 17:56:55.742644	520	1
521	2025-09-15 17:56:55.742644	521	1
522	2025-09-15 17:56:55.742644	522	1
523	2025-09-15 17:56:55.742644	523	1
524	2025-09-15 17:56:55.742644	524	1
525	2025-09-15 17:56:55.742644	525	1
526	2025-09-15 17:56:55.742644	526	1
527	2025-09-15 17:56:55.742644	527	1
528	2025-09-15 17:56:55.742644	528	1
529	2025-09-15 17:56:55.742644	529	1
530	2025-09-15 17:56:55.742644	530	1
531	2025-09-15 17:56:55.742644	531	1
532	2025-09-15 17:56:55.742644	532	1
533	2025-09-15 17:56:55.742644	533	1
534	2025-09-15 17:56:55.742644	534	1
535	2025-09-15 17:56:55.742644	535	1
536	2025-09-15 17:56:55.742644	536	1
537	2025-09-15 17:56:55.742644	537	1
538	2025-09-15 17:56:55.742644	538	1
539	2025-09-15 17:56:55.742644	539	1
540	2025-09-15 17:56:55.742644	540	1
541	2025-09-15 17:56:55.742644	541	1
542	2025-09-15 17:56:55.742644	542	1
543	2025-09-15 17:56:55.742644	543	1
544	2025-09-15 17:56:55.742644	544	1
545	2025-09-15 17:56:55.742644	545	1
546	2025-09-15 17:56:55.742644	546	1
547	2025-09-15 17:56:55.742644	547	1
548	2025-09-15 17:56:55.742644	548	1
549	2025-09-15 17:56:55.742644	549	1
550	2025-09-15 17:56:55.742644	550	1
551	2025-09-15 17:56:55.742644	551	1
552	2025-09-15 17:56:55.742644	552	1
553	2025-09-15 17:56:55.742644	553	1
554	2025-09-15 17:56:55.742644	554	1
555	2025-09-15 17:56:55.742644	555	1
556	2025-09-15 17:56:55.742644	556	1
557	2025-09-15 17:56:55.742644	557	1
558	2025-09-15 17:56:55.742644	558	1
559	2025-09-15 17:56:55.742644	559	1
560	2025-09-15 17:56:55.742644	560	1
561	2025-09-15 17:56:55.742644	561	1
562	2025-09-15 17:56:55.742644	562	1
563	2025-09-15 17:56:55.742644	563	1
564	2025-09-15 17:56:55.742644	564	1
565	2025-09-15 17:56:55.742644	565	1
566	2025-09-15 17:56:55.742644	566	1
567	2025-09-15 17:56:55.742644	567	1
568	2025-09-15 17:56:55.742644	568	1
569	2025-09-15 17:56:55.742644	569	1
570	2025-09-15 17:56:55.742644	570	1
571	2025-09-15 17:56:55.742644	571	1
572	2025-09-15 17:56:55.742644	572	1
573	2025-09-15 17:56:55.742644	573	1
574	2025-09-15 17:56:55.742644	574	1
575	2025-09-15 17:56:55.742644	575	1
576	2025-09-15 17:56:55.742644	576	1
577	2025-09-15 17:56:55.742644	577	1
578	2025-09-15 17:56:55.742644	578	1
579	2025-09-15 17:56:55.742644	579	1
580	2025-09-15 17:56:55.742644	580	1
581	2025-09-15 17:56:55.742644	581	1
582	2025-09-15 17:56:55.742644	582	1
583	2025-09-15 17:56:55.742644	583	1
584	2025-09-15 17:56:55.742644	584	1
585	2025-09-15 17:56:55.742644	585	1
586	2025-09-15 17:56:55.742644	586	1
587	2025-09-15 17:56:55.742644	587	1
588	2025-09-15 17:56:55.742644	588	1
589	2025-09-15 17:56:55.742644	589	1
590	2025-09-15 17:56:55.742644	590	1
591	2025-09-15 17:56:55.742644	591	1
592	2025-09-15 17:56:55.742644	592	1
593	2025-09-15 17:56:55.742644	593	1
594	2025-09-15 17:56:55.742644	594	1
595	2025-09-15 17:56:55.742644	595	1
596	2025-09-15 17:56:55.742644	596	1
597	2025-09-15 17:56:55.742644	597	1
598	2025-09-15 17:56:55.742644	598	1
599	2025-09-15 17:56:55.742644	599	1
600	2025-09-15 17:56:55.742644	600	1
601	2025-09-15 17:56:55.742644	601	1
602	2025-09-15 17:56:55.742644	602	1
603	2025-09-15 17:56:55.742644	603	1
604	2025-09-15 17:56:55.742644	604	1
605	2025-09-15 17:56:55.742644	605	1
606	2025-09-15 17:56:55.742644	606	1
607	2025-09-15 17:56:55.742644	607	1
608	2025-09-15 17:56:55.742644	608	1
609	2025-09-15 17:56:55.742644	609	1
610	2025-09-15 17:56:55.742644	610	1
611	2025-09-15 17:56:55.742644	611	1
612	2025-09-15 17:56:55.742644	612	1
613	2025-09-15 17:56:55.742644	613	1
614	2025-09-15 17:56:55.742644	614	1
615	2025-09-15 17:56:55.742644	615	1
616	2025-09-15 17:56:55.742644	616	1
617	2025-09-15 17:56:55.742644	617	1
618	2025-09-15 17:56:55.742644	618	1
619	2025-09-15 17:56:55.742644	619	1
620	2025-09-15 17:56:55.742644	620	1
621	2025-09-15 17:56:55.742644	621	1
622	2025-09-15 17:56:55.742644	622	1
623	2025-09-15 17:56:55.742644	623	1
624	2025-09-15 17:56:55.742644	624	1
625	2025-09-15 17:56:55.742644	625	1
626	2025-09-15 17:56:55.742644	626	1
627	2025-09-15 17:56:55.742644	627	1
628	2025-09-15 17:56:55.742644	628	1
629	2025-09-15 17:56:55.742644	629	1
630	2025-09-15 17:56:55.742644	630	1
631	2025-09-15 17:56:55.742644	631	1
632	2025-09-15 17:56:55.742644	632	1
633	2025-09-15 17:56:55.742644	633	1
634	2025-09-15 17:56:55.742644	634	1
635	2025-09-15 17:56:55.742644	635	1
636	2025-09-15 17:56:55.742644	636	1
637	2025-09-15 17:56:55.742644	637	1
638	2025-09-15 17:56:55.742644	638	1
639	2025-09-15 17:56:55.742644	639	1
640	2025-09-15 17:56:55.742644	640	1
644	2025-10-09 01:36:39.871164	1	3
645	2025-10-09 01:40:42.090313	2	3
646	2025-10-09 17:58:43.96245	11	3
647	2025-10-10 02:14:09.460128	648	15
\.


--
-- Data for Name: ingrediente; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ingrediente (id_ingrediente, nombre, id_receta) FROM stdin;
2	mantequilla	1
3	pan	1
4	pimienta	1
5	queso	1
6	huevos	2
7	mantequilla	2
8	pan	2
9	pimienta	2
10	queso	2
11	huevos	3
12	mantequilla	3
13	pan	3
14	pimienta	3
15	queso	3
16	huevos	4
17	mantequilla	4
18	pan	4
19	pimienta	4
20	queso	4
21	huevos	5
22	mantequilla	5
23	pan	5
24	pimienta	5
25	queso	5
26	huevos	6
27	mantequilla	6
28	pan	6
29	pimienta	6
30	queso	6
31	huevos	7
32	mantequilla	7
33	pan	7
34	pimienta	7
35	queso	7
36	huevos	8
37	mantequilla	8
38	pan	8
39	pimienta	8
40	queso	8
41	ajo	9
42	arroz	9
43	carne	9
44	cebolla	9
45	ensalada	9
46	ajo	10
47	arroz	10
48	carne	10
49	cebolla	10
50	ensalada	10
51	ajo	11
52	arroz	11
53	carne	11
54	cebolla	11
55	ensalada	11
56	ajo	12
57	arroz	12
58	carne	12
59	cebolla	12
60	ensalada	12
61	ajo	13
62	arroz	13
63	carne	13
64	cebolla	13
65	ensalada	13
66	ajo	14
67	arroz	14
68	carne	14
69	cebolla	14
70	ensalada	14
71	ajo	15
72	arroz	15
73	carne	15
74	cebolla	15
75	ensalada	15
76	ajo	16
77	arroz	16
78	carne	16
79	cebolla	16
80	ensalada	16
81	aceite de oliva	17
82	albahaca	17
83	pasta	17
84	queso	17
85	sal	17
86	aceite de oliva	18
87	albahaca	18
88	pasta	18
89	queso	18
90	sal	18
91	aceite de oliva	19
92	albahaca	19
93	pasta	19
94	queso	19
95	sal	19
96	aceite de oliva	20
97	albahaca	20
98	pasta	20
99	queso	20
100	sal	20
101	aceite de oliva	21
102	albahaca	21
103	pasta	21
104	queso	21
105	sal	21
106	aceite de oliva	22
107	albahaca	22
108	pasta	22
109	queso	22
110	sal	22
111	aceite de oliva	23
112	albahaca	23
113	pasta	23
114	queso	23
115	sal	23
116	aceite de oliva	24
117	albahaca	24
118	pasta	24
119	queso	24
120	sal	24
121	azÔö£Ôòæcar	25
122	harina	25
123	huevo	25
124	leche	25
125	mantequilla	25
126	azÔö£Ôòæcar	26
127	harina	26
128	huevo	26
129	leche	26
130	mantequilla	26
131	azÔö£Ôòæcar	27
132	harina	27
133	huevo	27
134	leche	27
135	mantequilla	27
136	azÔö£Ôòæcar	28
137	harina	28
138	huevo	28
139	leche	28
140	mantequilla	28
141	azÔö£Ôòæcar	29
142	harina	29
143	huevo	29
144	leche	29
145	mantequilla	29
146	azÔö£Ôòæcar	30
147	harina	30
148	huevo	30
149	leche	30
150	mantequilla	30
151	azÔö£Ôòæcar	31
152	harina	31
153	huevo	31
154	leche	31
155	mantequilla	31
156	azÔö£Ôòæcar	32
157	harina	32
158	huevo	32
159	leche	32
160	mantequilla	32
161	agua	33
162	azÔö£Ôòæcar	33
163	hielo	33
164	limÔö£Ôöén	33
165	menta	33
166	agua	34
167	azÔö£Ôòæcar	34
168	hielo	34
169	limÔö£Ôöén	34
170	menta	34
171	agua	35
172	azÔö£Ôòæcar	35
173	hielo	35
174	limÔö£Ôöén	35
175	menta	35
176	agua	36
177	azÔö£Ôòæcar	36
178	hielo	36
179	limÔö£Ôöén	36
180	menta	36
181	agua	37
182	azÔö£Ôòæcar	37
183	hielo	37
184	limÔö£Ôöén	37
185	menta	37
186	agua	38
187	azÔö£Ôòæcar	38
188	hielo	38
189	limÔö£Ôöén	38
190	menta	38
191	agua	39
192	azÔö£Ôòæcar	39
193	hielo	39
194	limÔö£Ôöén	39
195	menta	39
196	agua	40
197	azÔö£Ôòæcar	40
198	hielo	40
199	limÔö£Ôöén	40
200	menta	40
201	aceite	41
202	cebolla	41
203	lechuga	41
204	pepino	41
205	tomate	41
206	aceite	42
207	cebolla	42
208	lechuga	42
209	pepino	42
210	tomate	42
211	aceite	43
212	cebolla	43
213	lechuga	43
214	pepino	43
215	tomate	43
216	aceite	44
217	cebolla	44
218	lechuga	44
219	pepino	44
220	tomate	44
221	aceite	45
222	cebolla	45
223	lechuga	45
224	pepino	45
225	tomate	45
226	aceite	46
227	cebolla	46
228	lechuga	46
229	pepino	46
230	tomate	46
231	aceite	47
232	cebolla	47
233	lechuga	47
234	pepino	47
235	tomate	47
236	aceite	48
237	cebolla	48
238	lechuga	48
239	pepino	48
240	tomate	48
241	caldo	49
242	fideos	49
243	pimienta	49
244	pollo	49
245	sal	49
246	caldo	50
247	fideos	50
248	pimienta	50
249	pollo	50
250	sal	50
251	caldo	51
252	fideos	51
253	pimienta	51
254	pollo	51
255	sal	51
256	caldo	52
257	fideos	52
258	pimienta	52
259	pollo	52
260	sal	52
261	caldo	53
262	fideos	53
263	pimienta	53
264	pollo	53
265	sal	53
266	caldo	54
267	fideos	54
268	pimienta	54
269	pollo	54
270	sal	54
271	caldo	55
272	fideos	55
273	pimienta	55
274	pollo	55
275	sal	55
276	caldo	56
277	fideos	56
278	pimienta	56
279	pollo	56
280	sal	56
281	ajonjolÔö£┬í	57
282	pimiento	57
283	salsa de soja	57
284	tofu	57
285	verduras	57
286	ajonjolÔö£┬í	58
287	pimiento	58
288	salsa de soja	58
289	tofu	58
290	verduras	58
291	ajonjolÔö£┬í	59
292	pimiento	59
293	salsa de soja	59
294	tofu	59
295	verduras	59
296	ajonjolÔö£┬í	60
297	pimiento	60
298	salsa de soja	60
299	tofu	60
300	verduras	60
301	ajonjolÔö£┬í	61
302	pimiento	61
303	salsa de soja	61
304	tofu	61
305	verduras	61
306	ajonjolÔö£┬í	62
307	pimiento	62
308	salsa de soja	62
309	tofu	62
310	verduras	62
311	ajonjolÔö£┬í	63
312	pimiento	63
313	salsa de soja	63
314	tofu	63
315	verduras	63
316	ajonjolÔö£┬í	64
317	pimiento	64
318	salsa de soja	64
319	tofu	64
320	verduras	64
321	huevos	65
322	mantequilla	65
323	pan	65
324	pimienta	65
325	queso	65
326	huevos	66
327	mantequilla	66
328	pan	66
329	pimienta	66
330	queso	66
331	huevos	67
332	mantequilla	67
333	pan	67
334	pimienta	67
335	queso	67
336	huevos	68
337	mantequilla	68
338	pan	68
339	pimienta	68
340	queso	68
341	huevos	69
342	mantequilla	69
343	pan	69
344	pimienta	69
345	queso	69
346	huevos	70
347	mantequilla	70
348	pan	70
349	pimienta	70
350	queso	70
351	huevos	71
352	mantequilla	71
353	pan	71
354	pimienta	71
355	queso	71
356	huevos	72
357	mantequilla	72
358	pan	72
359	pimienta	72
360	queso	72
361	ajo	73
362	arroz	73
363	carne	73
364	cebolla	73
365	ensalada	73
366	ajo	74
367	arroz	74
368	carne	74
369	cebolla	74
370	ensalada	74
371	ajo	75
372	arroz	75
373	carne	75
374	cebolla	75
375	ensalada	75
376	ajo	76
377	arroz	76
378	carne	76
379	cebolla	76
380	ensalada	76
381	ajo	77
382	arroz	77
383	carne	77
384	cebolla	77
385	ensalada	77
386	ajo	78
387	arroz	78
388	carne	78
389	cebolla	78
390	ensalada	78
391	ajo	79
392	arroz	79
393	carne	79
394	cebolla	79
395	ensalada	79
396	ajo	80
397	arroz	80
398	carne	80
399	cebolla	80
400	ensalada	80
401	aceite de oliva	81
402	albahaca	81
403	pasta	81
404	queso	81
405	sal	81
406	aceite de oliva	82
407	albahaca	82
408	pasta	82
409	queso	82
410	sal	82
411	aceite de oliva	83
412	albahaca	83
413	pasta	83
414	queso	83
415	sal	83
416	aceite de oliva	84
417	albahaca	84
418	pasta	84
419	queso	84
420	sal	84
421	aceite de oliva	85
422	albahaca	85
423	pasta	85
424	queso	85
425	sal	85
426	aceite de oliva	86
427	albahaca	86
428	pasta	86
429	queso	86
430	sal	86
431	aceite de oliva	87
432	albahaca	87
433	pasta	87
434	queso	87
435	sal	87
436	aceite de oliva	88
437	albahaca	88
438	pasta	88
439	queso	88
440	sal	88
441	azÔö£Ôòæcar	89
442	harina	89
443	huevo	89
444	leche	89
445	mantequilla	89
446	azÔö£Ôòæcar	90
447	harina	90
448	huevo	90
449	leche	90
450	mantequilla	90
451	azÔö£Ôòæcar	91
452	harina	91
453	huevo	91
454	leche	91
455	mantequilla	91
456	azÔö£Ôòæcar	92
457	harina	92
458	huevo	92
459	leche	92
460	mantequilla	92
461	azÔö£Ôòæcar	93
462	harina	93
463	huevo	93
464	leche	93
465	mantequilla	93
466	azÔö£Ôòæcar	94
467	harina	94
468	huevo	94
469	leche	94
470	mantequilla	94
471	azÔö£Ôòæcar	95
472	harina	95
473	huevo	95
474	leche	95
475	mantequilla	95
476	azÔö£Ôòæcar	96
477	harina	96
478	huevo	96
479	leche	96
480	mantequilla	96
481	agua	97
482	azÔö£Ôòæcar	97
483	hielo	97
484	limÔö£Ôöén	97
485	menta	97
486	agua	98
487	azÔö£Ôòæcar	98
488	hielo	98
489	limÔö£Ôöén	98
490	menta	98
491	agua	99
492	azÔö£Ôòæcar	99
493	hielo	99
494	limÔö£Ôöén	99
495	menta	99
496	agua	100
497	azÔö£Ôòæcar	100
498	hielo	100
499	limÔö£Ôöén	100
500	menta	100
501	agua	101
502	azÔö£Ôòæcar	101
503	hielo	101
504	limÔö£Ôöén	101
505	menta	101
506	agua	102
507	azÔö£Ôòæcar	102
508	hielo	102
509	limÔö£Ôöén	102
510	menta	102
511	agua	103
512	azÔö£Ôòæcar	103
513	hielo	103
514	limÔö£Ôöén	103
515	menta	103
516	agua	104
517	azÔö£Ôòæcar	104
518	hielo	104
519	limÔö£Ôöén	104
520	menta	104
521	aceite	105
522	cebolla	105
523	lechuga	105
524	pepino	105
525	tomate	105
526	aceite	106
527	cebolla	106
528	lechuga	106
529	pepino	106
530	tomate	106
531	aceite	107
532	cebolla	107
533	lechuga	107
534	pepino	107
535	tomate	107
536	aceite	108
537	cebolla	108
538	lechuga	108
539	pepino	108
540	tomate	108
541	aceite	109
542	cebolla	109
543	lechuga	109
544	pepino	109
545	tomate	109
546	aceite	110
547	cebolla	110
548	lechuga	110
549	pepino	110
550	tomate	110
551	aceite	111
552	cebolla	111
553	lechuga	111
554	pepino	111
555	tomate	111
556	aceite	112
557	cebolla	112
558	lechuga	112
559	pepino	112
560	tomate	112
561	caldo	113
562	fideos	113
563	pimienta	113
564	pollo	113
565	sal	113
566	caldo	114
567	fideos	114
568	pimienta	114
569	pollo	114
570	sal	114
571	caldo	115
572	fideos	115
573	pimienta	115
574	pollo	115
575	sal	115
576	caldo	116
577	fideos	116
578	pimienta	116
579	pollo	116
580	sal	116
581	caldo	117
582	fideos	117
583	pimienta	117
584	pollo	117
585	sal	117
586	caldo	118
587	fideos	118
588	pimienta	118
589	pollo	118
590	sal	118
591	caldo	119
592	fideos	119
593	pimienta	119
594	pollo	119
595	sal	119
596	caldo	120
597	fideos	120
598	pimienta	120
599	pollo	120
600	sal	120
601	ajonjolÔö£┬í	121
602	pimiento	121
603	salsa de soja	121
604	tofu	121
605	verduras	121
606	ajonjolÔö£┬í	122
607	pimiento	122
608	salsa de soja	122
609	tofu	122
610	verduras	122
611	ajonjolÔö£┬í	123
612	pimiento	123
613	salsa de soja	123
614	tofu	123
615	verduras	123
616	ajonjolÔö£┬í	124
617	pimiento	124
618	salsa de soja	124
619	tofu	124
620	verduras	124
621	ajonjolÔö£┬í	125
622	pimiento	125
623	salsa de soja	125
624	tofu	125
625	verduras	125
626	ajonjolÔö£┬í	126
627	pimiento	126
628	salsa de soja	126
629	tofu	126
630	verduras	126
631	ajonjolÔö£┬í	127
632	pimiento	127
633	salsa de soja	127
634	tofu	127
635	verduras	127
636	ajonjolÔö£┬í	128
637	pimiento	128
638	salsa de soja	128
639	tofu	128
640	verduras	128
641	huevos	129
642	mantequilla	129
643	pan	129
644	pimienta	129
645	queso	129
646	huevos	130
647	mantequilla	130
648	pan	130
649	pimienta	130
650	queso	130
651	huevos	131
652	mantequilla	131
653	pan	131
654	pimienta	131
655	queso	131
656	huevos	132
657	mantequilla	132
658	pan	132
659	pimienta	132
660	queso	132
661	huevos	133
662	mantequilla	133
663	pan	133
664	pimienta	133
665	queso	133
666	huevos	134
667	mantequilla	134
668	pan	134
669	pimienta	134
670	queso	134
671	huevos	135
672	mantequilla	135
673	pan	135
674	pimienta	135
675	queso	135
676	huevos	136
677	mantequilla	136
678	pan	136
679	pimienta	136
680	queso	136
681	ajo	137
682	arroz	137
683	carne	137
684	cebolla	137
685	ensalada	137
686	ajo	138
687	arroz	138
688	carne	138
689	cebolla	138
690	ensalada	138
691	ajo	139
692	arroz	139
693	carne	139
694	cebolla	139
695	ensalada	139
696	ajo	140
697	arroz	140
698	carne	140
699	cebolla	140
700	ensalada	140
701	ajo	141
702	arroz	141
703	carne	141
704	cebolla	141
705	ensalada	141
706	ajo	142
707	arroz	142
708	carne	142
709	cebolla	142
710	ensalada	142
711	ajo	143
712	arroz	143
713	carne	143
714	cebolla	143
715	ensalada	143
716	ajo	144
717	arroz	144
718	carne	144
719	cebolla	144
720	ensalada	144
721	aceite de oliva	145
722	albahaca	145
723	pasta	145
724	queso	145
725	sal	145
726	aceite de oliva	146
727	albahaca	146
728	pasta	146
729	queso	146
730	sal	146
731	aceite de oliva	147
732	albahaca	147
733	pasta	147
734	queso	147
735	sal	147
736	aceite de oliva	148
737	albahaca	148
738	pasta	148
739	queso	148
740	sal	148
741	aceite de oliva	149
742	albahaca	149
743	pasta	149
744	queso	149
745	sal	149
746	aceite de oliva	150
747	albahaca	150
748	pasta	150
749	queso	150
750	sal	150
751	aceite de oliva	151
752	albahaca	151
753	pasta	151
754	queso	151
755	sal	151
756	aceite de oliva	152
757	albahaca	152
758	pasta	152
759	queso	152
760	sal	152
761	azÔö£Ôòæcar	153
762	harina	153
763	huevo	153
764	leche	153
765	mantequilla	153
766	azÔö£Ôòæcar	154
767	harina	154
768	huevo	154
769	leche	154
770	mantequilla	154
771	azÔö£Ôòæcar	155
772	harina	155
773	huevo	155
774	leche	155
775	mantequilla	155
776	azÔö£Ôòæcar	156
777	harina	156
778	huevo	156
779	leche	156
780	mantequilla	156
781	azÔö£Ôòæcar	157
782	harina	157
783	huevo	157
784	leche	157
785	mantequilla	157
786	azÔö£Ôòæcar	158
787	harina	158
788	huevo	158
789	leche	158
790	mantequilla	158
791	azÔö£Ôòæcar	159
792	harina	159
793	huevo	159
794	leche	159
795	mantequilla	159
796	azÔö£Ôòæcar	160
797	harina	160
798	huevo	160
799	leche	160
800	mantequilla	160
801	agua	161
802	azÔö£Ôòæcar	161
803	hielo	161
804	limÔö£Ôöén	161
805	menta	161
806	agua	162
807	azÔö£Ôòæcar	162
808	hielo	162
809	limÔö£Ôöén	162
810	menta	162
811	agua	163
812	azÔö£Ôòæcar	163
813	hielo	163
814	limÔö£Ôöén	163
815	menta	163
816	agua	164
817	azÔö£Ôòæcar	164
818	hielo	164
819	limÔö£Ôöén	164
820	menta	164
821	agua	165
822	azÔö£Ôòæcar	165
823	hielo	165
824	limÔö£Ôöén	165
825	menta	165
826	agua	166
827	azÔö£Ôòæcar	166
828	hielo	166
829	limÔö£Ôöén	166
830	menta	166
831	agua	167
832	azÔö£Ôòæcar	167
833	hielo	167
834	limÔö£Ôöén	167
835	menta	167
836	agua	168
837	azÔö£Ôòæcar	168
838	hielo	168
839	limÔö£Ôöén	168
840	menta	168
841	aceite	169
842	cebolla	169
843	lechuga	169
844	pepino	169
845	tomate	169
846	aceite	170
847	cebolla	170
848	lechuga	170
849	pepino	170
850	tomate	170
851	aceite	171
852	cebolla	171
853	lechuga	171
854	pepino	171
855	tomate	171
856	aceite	172
857	cebolla	172
858	lechuga	172
859	pepino	172
860	tomate	172
861	aceite	173
862	cebolla	173
863	lechuga	173
864	pepino	173
865	tomate	173
866	aceite	174
867	cebolla	174
868	lechuga	174
869	pepino	174
870	tomate	174
871	aceite	175
872	cebolla	175
873	lechuga	175
874	pepino	175
875	tomate	175
876	aceite	176
877	cebolla	176
878	lechuga	176
879	pepino	176
880	tomate	176
881	caldo	177
882	fideos	177
883	pimienta	177
884	pollo	177
885	sal	177
886	caldo	178
887	fideos	178
888	pimienta	178
889	pollo	178
890	sal	178
891	caldo	179
892	fideos	179
893	pimienta	179
894	pollo	179
895	sal	179
896	caldo	180
897	fideos	180
898	pimienta	180
899	pollo	180
900	sal	180
901	caldo	181
902	fideos	181
903	pimienta	181
904	pollo	181
905	sal	181
906	caldo	182
907	fideos	182
908	pimienta	182
909	pollo	182
910	sal	182
911	caldo	183
912	fideos	183
913	pimienta	183
914	pollo	183
915	sal	183
916	caldo	184
917	fideos	184
918	pimienta	184
919	pollo	184
920	sal	184
921	ajonjolÔö£┬í	185
922	pimiento	185
923	salsa de soja	185
924	tofu	185
925	verduras	185
926	ajonjolÔö£┬í	186
927	pimiento	186
928	salsa de soja	186
929	tofu	186
930	verduras	186
931	ajonjolÔö£┬í	187
932	pimiento	187
933	salsa de soja	187
934	tofu	187
935	verduras	187
936	ajonjolÔö£┬í	188
937	pimiento	188
938	salsa de soja	188
939	tofu	188
940	verduras	188
941	ajonjolÔö£┬í	189
942	pimiento	189
943	salsa de soja	189
944	tofu	189
945	verduras	189
946	ajonjolÔö£┬í	190
947	pimiento	190
948	salsa de soja	190
949	tofu	190
950	verduras	190
951	ajonjolÔö£┬í	191
952	pimiento	191
953	salsa de soja	191
954	tofu	191
955	verduras	191
956	ajonjolÔö£┬í	192
957	pimiento	192
958	salsa de soja	192
959	tofu	192
960	verduras	192
961	huevos	193
962	mantequilla	193
963	pan	193
964	pimienta	193
965	queso	193
966	huevos	194
967	mantequilla	194
968	pan	194
969	pimienta	194
970	queso	194
971	huevos	195
972	mantequilla	195
973	pan	195
974	pimienta	195
975	queso	195
976	huevos	196
977	mantequilla	196
978	pan	196
979	pimienta	196
980	queso	196
981	huevos	197
982	mantequilla	197
983	pan	197
984	pimienta	197
985	queso	197
986	huevos	198
987	mantequilla	198
988	pan	198
989	pimienta	198
990	queso	198
991	huevos	199
992	mantequilla	199
993	pan	199
994	pimienta	199
995	queso	199
996	huevos	200
997	mantequilla	200
998	pan	200
999	pimienta	200
1000	queso	200
1001	ajo	201
1002	arroz	201
1003	carne	201
1004	cebolla	201
1005	ensalada	201
1006	ajo	202
1007	arroz	202
1008	carne	202
1009	cebolla	202
1010	ensalada	202
1011	ajo	203
1012	arroz	203
1013	carne	203
1014	cebolla	203
1015	ensalada	203
1016	ajo	204
1017	arroz	204
1018	carne	204
1019	cebolla	204
1020	ensalada	204
1021	ajo	205
1022	arroz	205
1023	carne	205
1024	cebolla	205
1025	ensalada	205
1026	ajo	206
1027	arroz	206
1028	carne	206
1029	cebolla	206
1030	ensalada	206
1031	ajo	207
1032	arroz	207
1033	carne	207
1034	cebolla	207
1035	ensalada	207
1036	ajo	208
1037	arroz	208
1038	carne	208
1039	cebolla	208
1040	ensalada	208
1041	aceite de oliva	209
1042	albahaca	209
1043	pasta	209
1044	queso	209
1045	sal	209
1046	aceite de oliva	210
1047	albahaca	210
1048	pasta	210
1049	queso	210
1050	sal	210
1051	aceite de oliva	211
1052	albahaca	211
1053	pasta	211
1054	queso	211
1055	sal	211
1056	aceite de oliva	212
1057	albahaca	212
1058	pasta	212
1059	queso	212
1060	sal	212
1061	aceite de oliva	213
1062	albahaca	213
1063	pasta	213
1064	queso	213
1065	sal	213
1066	aceite de oliva	214
1067	albahaca	214
1068	pasta	214
1069	queso	214
1070	sal	214
1071	aceite de oliva	215
1072	albahaca	215
1073	pasta	215
1074	queso	215
1075	sal	215
1076	aceite de oliva	216
1077	albahaca	216
1078	pasta	216
1079	queso	216
1080	sal	216
1081	azÔö£Ôòæcar	217
1082	harina	217
1083	huevo	217
1084	leche	217
1085	mantequilla	217
1086	azÔö£Ôòæcar	218
1087	harina	218
1088	huevo	218
1089	leche	218
1090	mantequilla	218
1091	azÔö£Ôòæcar	219
1092	harina	219
1093	huevo	219
1094	leche	219
1095	mantequilla	219
1096	azÔö£Ôòæcar	220
1097	harina	220
1098	huevo	220
1099	leche	220
1100	mantequilla	220
1101	azÔö£Ôòæcar	221
1102	harina	221
1103	huevo	221
1104	leche	221
1105	mantequilla	221
1106	azÔö£Ôòæcar	222
1107	harina	222
1108	huevo	222
1109	leche	222
1110	mantequilla	222
1111	azÔö£Ôòæcar	223
1112	harina	223
1113	huevo	223
1114	leche	223
1115	mantequilla	223
1116	azÔö£Ôòæcar	224
1117	harina	224
1118	huevo	224
1119	leche	224
1120	mantequilla	224
1121	agua	225
1122	azÔö£Ôòæcar	225
1123	hielo	225
1124	limÔö£Ôöén	225
1125	menta	225
1126	agua	226
1127	azÔö£Ôòæcar	226
1128	hielo	226
1129	limÔö£Ôöén	226
1130	menta	226
1131	agua	227
1132	azÔö£Ôòæcar	227
1133	hielo	227
1134	limÔö£Ôöén	227
1135	menta	227
1136	agua	228
1137	azÔö£Ôòæcar	228
1138	hielo	228
1139	limÔö£Ôöén	228
1140	menta	228
1141	agua	229
1142	azÔö£Ôòæcar	229
1143	hielo	229
1144	limÔö£Ôöén	229
1145	menta	229
1146	agua	230
1147	azÔö£Ôòæcar	230
1148	hielo	230
1149	limÔö£Ôöén	230
1150	menta	230
1151	agua	231
1152	azÔö£Ôòæcar	231
1153	hielo	231
1154	limÔö£Ôöén	231
1155	menta	231
1156	agua	232
1157	azÔö£Ôòæcar	232
1158	hielo	232
1159	limÔö£Ôöén	232
1160	menta	232
1161	aceite	233
1162	cebolla	233
1163	lechuga	233
1164	pepino	233
1165	tomate	233
1166	aceite	234
1167	cebolla	234
1168	lechuga	234
1169	pepino	234
1170	tomate	234
1171	aceite	235
1172	cebolla	235
1173	lechuga	235
1174	pepino	235
1175	tomate	235
1176	aceite	236
1177	cebolla	236
1178	lechuga	236
1179	pepino	236
1180	tomate	236
1181	aceite	237
1182	cebolla	237
1183	lechuga	237
1184	pepino	237
1185	tomate	237
1186	aceite	238
1187	cebolla	238
1188	lechuga	238
1189	pepino	238
1190	tomate	238
1191	aceite	239
1192	cebolla	239
1193	lechuga	239
1194	pepino	239
1195	tomate	239
1196	aceite	240
1197	cebolla	240
1198	lechuga	240
1199	pepino	240
1200	tomate	240
1201	caldo	241
1202	fideos	241
1203	pimienta	241
1204	pollo	241
1205	sal	241
1206	caldo	242
1207	fideos	242
1208	pimienta	242
1209	pollo	242
1210	sal	242
1211	caldo	243
1212	fideos	243
1213	pimienta	243
1214	pollo	243
1215	sal	243
1216	caldo	244
1217	fideos	244
1218	pimienta	244
1219	pollo	244
1220	sal	244
1221	caldo	245
1222	fideos	245
1223	pimienta	245
1224	pollo	245
1225	sal	245
1226	caldo	246
1227	fideos	246
1228	pimienta	246
1229	pollo	246
1230	sal	246
1231	caldo	247
1232	fideos	247
1233	pimienta	247
1234	pollo	247
1235	sal	247
1236	caldo	248
1237	fideos	248
1238	pimienta	248
1239	pollo	248
1240	sal	248
1241	ajonjolÔö£┬í	249
1242	pimiento	249
1243	salsa de soja	249
1244	tofu	249
1245	verduras	249
1246	ajonjolÔö£┬í	250
1247	pimiento	250
1248	salsa de soja	250
1249	tofu	250
1250	verduras	250
1251	ajonjolÔö£┬í	251
1252	pimiento	251
1253	salsa de soja	251
1254	tofu	251
1255	verduras	251
1256	ajonjolÔö£┬í	252
1257	pimiento	252
1258	salsa de soja	252
1259	tofu	252
1260	verduras	252
1261	ajonjolÔö£┬í	253
1262	pimiento	253
1263	salsa de soja	253
1264	tofu	253
1265	verduras	253
1266	ajonjolÔö£┬í	254
1267	pimiento	254
1268	salsa de soja	254
1269	tofu	254
1270	verduras	254
1271	ajonjolÔö£┬í	255
1272	pimiento	255
1273	salsa de soja	255
1274	tofu	255
1275	verduras	255
1276	ajonjolÔö£┬í	256
1277	pimiento	256
1278	salsa de soja	256
1279	tofu	256
1280	verduras	256
1281	huevos	257
1282	mantequilla	257
1283	pan	257
1284	pimienta	257
1285	queso	257
1286	huevos	258
1287	mantequilla	258
1288	pan	258
1289	pimienta	258
1290	queso	258
1291	huevos	259
1292	mantequilla	259
1293	pan	259
1294	pimienta	259
1295	queso	259
1296	huevos	260
1297	mantequilla	260
1298	pan	260
1299	pimienta	260
1300	queso	260
1301	huevos	261
1302	mantequilla	261
1303	pan	261
1304	pimienta	261
1305	queso	261
1306	huevos	262
1307	mantequilla	262
1308	pan	262
1309	pimienta	262
1310	queso	262
1311	huevos	263
1312	mantequilla	263
1313	pan	263
1314	pimienta	263
1315	queso	263
1316	huevos	264
1317	mantequilla	264
1318	pan	264
1319	pimienta	264
1320	queso	264
1321	ajo	265
1322	arroz	265
1323	carne	265
1324	cebolla	265
1325	ensalada	265
1326	ajo	266
1327	arroz	266
1328	carne	266
1329	cebolla	266
1330	ensalada	266
1331	ajo	267
1332	arroz	267
1333	carne	267
1334	cebolla	267
1335	ensalada	267
1336	ajo	268
1337	arroz	268
1338	carne	268
1339	cebolla	268
1340	ensalada	268
1341	ajo	269
1342	arroz	269
1343	carne	269
1344	cebolla	269
1345	ensalada	269
1346	ajo	270
1347	arroz	270
1348	carne	270
1349	cebolla	270
1350	ensalada	270
1351	ajo	271
1352	arroz	271
1353	carne	271
1354	cebolla	271
1355	ensalada	271
1356	ajo	272
1357	arroz	272
1358	carne	272
1359	cebolla	272
1360	ensalada	272
1361	aceite de oliva	273
1362	albahaca	273
1363	pasta	273
1364	queso	273
1365	sal	273
1366	aceite de oliva	274
1367	albahaca	274
1368	pasta	274
1369	queso	274
1370	sal	274
1371	aceite de oliva	275
1372	albahaca	275
1373	pasta	275
1374	queso	275
1375	sal	275
1376	aceite de oliva	276
1377	albahaca	276
1378	pasta	276
1379	queso	276
1380	sal	276
1381	aceite de oliva	277
1382	albahaca	277
1383	pasta	277
1384	queso	277
1385	sal	277
1386	aceite de oliva	278
1387	albahaca	278
1388	pasta	278
1389	queso	278
1390	sal	278
1391	aceite de oliva	279
1392	albahaca	279
1393	pasta	279
1394	queso	279
1395	sal	279
1396	aceite de oliva	280
1397	albahaca	280
1398	pasta	280
1399	queso	280
1400	sal	280
1401	azÔö£Ôòæcar	281
1402	harina	281
1403	huevo	281
1404	leche	281
1405	mantequilla	281
1406	azÔö£Ôòæcar	282
1407	harina	282
1408	huevo	282
1409	leche	282
1410	mantequilla	282
1411	azÔö£Ôòæcar	283
1412	harina	283
1413	huevo	283
1414	leche	283
1415	mantequilla	283
1416	azÔö£Ôòæcar	284
1417	harina	284
1418	huevo	284
1419	leche	284
1420	mantequilla	284
1421	azÔö£Ôòæcar	285
1422	harina	285
1423	huevo	285
1424	leche	285
1425	mantequilla	285
1426	azÔö£Ôòæcar	286
1427	harina	286
1428	huevo	286
1429	leche	286
1430	mantequilla	286
1431	azÔö£Ôòæcar	287
1432	harina	287
1433	huevo	287
1434	leche	287
1435	mantequilla	287
1436	azÔö£Ôòæcar	288
1437	harina	288
1438	huevo	288
1439	leche	288
1440	mantequilla	288
1441	agua	289
1442	azÔö£Ôòæcar	289
1443	hielo	289
1444	limÔö£Ôöén	289
1445	menta	289
1446	agua	290
1447	azÔö£Ôòæcar	290
1448	hielo	290
1449	limÔö£Ôöén	290
1450	menta	290
1451	agua	291
1452	azÔö£Ôòæcar	291
1453	hielo	291
1454	limÔö£Ôöén	291
1455	menta	291
1456	agua	292
1457	azÔö£Ôòæcar	292
1458	hielo	292
1459	limÔö£Ôöén	292
1460	menta	292
1461	agua	293
1462	azÔö£Ôòæcar	293
1463	hielo	293
1464	limÔö£Ôöén	293
1465	menta	293
1466	agua	294
1467	azÔö£Ôòæcar	294
1468	hielo	294
1469	limÔö£Ôöén	294
1470	menta	294
1471	agua	295
1472	azÔö£Ôòæcar	295
1473	hielo	295
1474	limÔö£Ôöén	295
1475	menta	295
1476	agua	296
1477	azÔö£Ôòæcar	296
1478	hielo	296
1479	limÔö£Ôöén	296
1480	menta	296
1481	aceite	297
1482	cebolla	297
1483	lechuga	297
1484	pepino	297
1485	tomate	297
1486	aceite	298
1487	cebolla	298
1488	lechuga	298
1489	pepino	298
1490	tomate	298
1491	aceite	299
1492	cebolla	299
1493	lechuga	299
1494	pepino	299
1495	tomate	299
1496	aceite	300
1497	cebolla	300
1498	lechuga	300
1499	pepino	300
1500	tomate	300
1501	aceite	301
1502	cebolla	301
1503	lechuga	301
1504	pepino	301
1505	tomate	301
1506	aceite	302
1507	cebolla	302
1508	lechuga	302
1509	pepino	302
1510	tomate	302
1511	aceite	303
1512	cebolla	303
1513	lechuga	303
1514	pepino	303
1515	tomate	303
1516	aceite	304
1517	cebolla	304
1518	lechuga	304
1519	pepino	304
1520	tomate	304
1521	caldo	305
1522	fideos	305
1523	pimienta	305
1524	pollo	305
1525	sal	305
1526	caldo	306
1527	fideos	306
1528	pimienta	306
1529	pollo	306
1530	sal	306
1531	caldo	307
1532	fideos	307
1533	pimienta	307
1534	pollo	307
1535	sal	307
1536	caldo	308
1537	fideos	308
1538	pimienta	308
1539	pollo	308
1540	sal	308
1541	caldo	309
1542	fideos	309
1543	pimienta	309
1544	pollo	309
1545	sal	309
1546	caldo	310
1547	fideos	310
1548	pimienta	310
1549	pollo	310
1550	sal	310
1551	caldo	311
1552	fideos	311
1553	pimienta	311
1554	pollo	311
1555	sal	311
1556	caldo	312
1557	fideos	312
1558	pimienta	312
1559	pollo	312
1560	sal	312
1561	ajonjolÔö£┬í	313
1562	pimiento	313
1563	salsa de soja	313
1564	tofu	313
1565	verduras	313
1566	ajonjolÔö£┬í	314
1567	pimiento	314
1568	salsa de soja	314
1569	tofu	314
1570	verduras	314
1571	ajonjolÔö£┬í	315
1572	pimiento	315
1573	salsa de soja	315
1574	tofu	315
1575	verduras	315
1576	ajonjolÔö£┬í	316
1577	pimiento	316
1578	salsa de soja	316
1579	tofu	316
1580	verduras	316
1581	ajonjolÔö£┬í	317
1582	pimiento	317
1583	salsa de soja	317
1584	tofu	317
1585	verduras	317
1586	ajonjolÔö£┬í	318
1587	pimiento	318
1588	salsa de soja	318
1589	tofu	318
1590	verduras	318
1591	ajonjolÔö£┬í	319
1592	pimiento	319
1593	salsa de soja	319
1594	tofu	319
1595	verduras	319
1596	ajonjolÔö£┬í	320
1597	pimiento	320
1598	salsa de soja	320
1599	tofu	320
1600	verduras	320
1601	huevos	321
1602	mantequilla	321
1603	pan	321
1604	pimienta	321
1605	queso	321
1606	huevos	322
1607	mantequilla	322
1608	pan	322
1609	pimienta	322
1610	queso	322
1611	huevos	323
1612	mantequilla	323
1613	pan	323
1614	pimienta	323
1615	queso	323
1616	huevos	324
1617	mantequilla	324
1618	pan	324
1619	pimienta	324
1620	queso	324
1621	huevos	325
1622	mantequilla	325
1623	pan	325
1624	pimienta	325
1625	queso	325
1626	huevos	326
1627	mantequilla	326
1628	pan	326
1629	pimienta	326
1630	queso	326
1631	huevos	327
1632	mantequilla	327
1633	pan	327
1634	pimienta	327
1635	queso	327
1636	huevos	328
1637	mantequilla	328
1638	pan	328
1639	pimienta	328
1640	queso	328
1641	ajo	329
1642	arroz	329
1643	carne	329
1644	cebolla	329
1645	ensalada	329
1646	ajo	330
1647	arroz	330
1648	carne	330
1649	cebolla	330
1650	ensalada	330
1651	ajo	331
1652	arroz	331
1653	carne	331
1654	cebolla	331
1655	ensalada	331
1656	ajo	332
1657	arroz	332
1658	carne	332
1659	cebolla	332
1660	ensalada	332
1661	ajo	333
1662	arroz	333
1663	carne	333
1664	cebolla	333
1665	ensalada	333
1666	ajo	334
1667	arroz	334
1668	carne	334
1669	cebolla	334
1670	ensalada	334
1671	ajo	335
1672	arroz	335
1673	carne	335
1674	cebolla	335
1675	ensalada	335
1676	ajo	336
1677	arroz	336
1678	carne	336
1679	cebolla	336
1680	ensalada	336
1681	aceite de oliva	337
1682	albahaca	337
1683	pasta	337
1684	queso	337
1685	sal	337
1686	aceite de oliva	338
1687	albahaca	338
1688	pasta	338
1689	queso	338
1690	sal	338
1691	aceite de oliva	339
1692	albahaca	339
1693	pasta	339
1694	queso	339
1695	sal	339
1696	aceite de oliva	340
1697	albahaca	340
1698	pasta	340
1699	queso	340
1700	sal	340
1701	aceite de oliva	341
1702	albahaca	341
1703	pasta	341
1704	queso	341
1705	sal	341
1706	aceite de oliva	342
1707	albahaca	342
1708	pasta	342
1709	queso	342
1710	sal	342
1711	aceite de oliva	343
1712	albahaca	343
1713	pasta	343
1714	queso	343
1715	sal	343
1716	aceite de oliva	344
1717	albahaca	344
1718	pasta	344
1719	queso	344
1720	sal	344
1721	azÔö£Ôòæcar	345
1722	harina	345
1723	huevo	345
1724	leche	345
1725	mantequilla	345
1726	azÔö£Ôòæcar	346
1727	harina	346
1728	huevo	346
1729	leche	346
1730	mantequilla	346
1731	azÔö£Ôòæcar	347
1732	harina	347
1733	huevo	347
1734	leche	347
1735	mantequilla	347
1736	azÔö£Ôòæcar	348
1737	harina	348
1738	huevo	348
1739	leche	348
1740	mantequilla	348
1741	azÔö£Ôòæcar	349
1742	harina	349
1743	huevo	349
1744	leche	349
1745	mantequilla	349
1746	azÔö£Ôòæcar	350
1747	harina	350
1748	huevo	350
1749	leche	350
1750	mantequilla	350
1751	azÔö£Ôòæcar	351
1752	harina	351
1753	huevo	351
1754	leche	351
1755	mantequilla	351
1756	azÔö£Ôòæcar	352
1757	harina	352
1758	huevo	352
1759	leche	352
1760	mantequilla	352
1761	agua	353
1762	azÔö£Ôòæcar	353
1763	hielo	353
1764	limÔö£Ôöén	353
1765	menta	353
1766	agua	354
1767	azÔö£Ôòæcar	354
1768	hielo	354
1769	limÔö£Ôöén	354
1770	menta	354
1771	agua	355
1772	azÔö£Ôòæcar	355
1773	hielo	355
1774	limÔö£Ôöén	355
1775	menta	355
1776	agua	356
1777	azÔö£Ôòæcar	356
1778	hielo	356
1779	limÔö£Ôöén	356
1780	menta	356
1781	agua	357
1782	azÔö£Ôòæcar	357
1783	hielo	357
1784	limÔö£Ôöén	357
1785	menta	357
1786	agua	358
1787	azÔö£Ôòæcar	358
1788	hielo	358
1789	limÔö£Ôöén	358
1790	menta	358
1791	agua	359
1792	azÔö£Ôòæcar	359
1793	hielo	359
1794	limÔö£Ôöén	359
1795	menta	359
1796	agua	360
1797	azÔö£Ôòæcar	360
1798	hielo	360
1799	limÔö£Ôöén	360
1800	menta	360
1801	aceite	361
1802	cebolla	361
1803	lechuga	361
1804	pepino	361
1805	tomate	361
1806	aceite	362
1807	cebolla	362
1808	lechuga	362
1809	pepino	362
1810	tomate	362
1811	aceite	363
1812	cebolla	363
1813	lechuga	363
1814	pepino	363
1815	tomate	363
1816	aceite	364
1817	cebolla	364
1818	lechuga	364
1819	pepino	364
1820	tomate	364
1821	aceite	365
1822	cebolla	365
1823	lechuga	365
1824	pepino	365
1825	tomate	365
1826	aceite	366
1827	cebolla	366
1828	lechuga	366
1829	pepino	366
1830	tomate	366
1831	aceite	367
1832	cebolla	367
1833	lechuga	367
1834	pepino	367
1835	tomate	367
1836	aceite	368
1837	cebolla	368
1838	lechuga	368
1839	pepino	368
1840	tomate	368
1841	caldo	369
1842	fideos	369
1843	pimienta	369
1844	pollo	369
1845	sal	369
1846	caldo	370
1847	fideos	370
1848	pimienta	370
1849	pollo	370
1850	sal	370
1851	caldo	371
1852	fideos	371
1853	pimienta	371
1854	pollo	371
1855	sal	371
1856	caldo	372
1857	fideos	372
1858	pimienta	372
1859	pollo	372
1860	sal	372
1861	caldo	373
1862	fideos	373
1863	pimienta	373
1864	pollo	373
1865	sal	373
1866	caldo	374
1867	fideos	374
1868	pimienta	374
1869	pollo	374
1870	sal	374
1871	caldo	375
1872	fideos	375
1873	pimienta	375
1874	pollo	375
1875	sal	375
1876	caldo	376
1877	fideos	376
1878	pimienta	376
1879	pollo	376
1880	sal	376
1881	ajonjolÔö£┬í	377
1882	pimiento	377
1883	salsa de soja	377
1884	tofu	377
1885	verduras	377
1886	ajonjolÔö£┬í	378
1887	pimiento	378
1888	salsa de soja	378
1889	tofu	378
1890	verduras	378
1891	ajonjolÔö£┬í	379
1892	pimiento	379
1893	salsa de soja	379
1894	tofu	379
1895	verduras	379
1896	ajonjolÔö£┬í	380
1897	pimiento	380
1898	salsa de soja	380
1899	tofu	380
1900	verduras	380
1901	ajonjolÔö£┬í	381
1902	pimiento	381
1903	salsa de soja	381
1904	tofu	381
1905	verduras	381
1906	ajonjolÔö£┬í	382
1907	pimiento	382
1908	salsa de soja	382
1909	tofu	382
1910	verduras	382
1911	ajonjolÔö£┬í	383
1912	pimiento	383
1913	salsa de soja	383
1914	tofu	383
1915	verduras	383
1916	ajonjolÔö£┬í	384
1917	pimiento	384
1918	salsa de soja	384
1919	tofu	384
1920	verduras	384
1921	huevos	385
1922	mantequilla	385
1923	pan	385
1924	pimienta	385
1925	queso	385
1926	huevos	386
1927	mantequilla	386
1928	pan	386
1929	pimienta	386
1930	queso	386
1931	huevos	387
1932	mantequilla	387
1933	pan	387
1934	pimienta	387
1935	queso	387
1936	huevos	388
1937	mantequilla	388
1938	pan	388
1939	pimienta	388
1940	queso	388
1941	huevos	389
1942	mantequilla	389
1943	pan	389
1944	pimienta	389
1945	queso	389
1946	huevos	390
1947	mantequilla	390
1948	pan	390
1949	pimienta	390
1950	queso	390
1951	huevos	391
1952	mantequilla	391
1953	pan	391
1954	pimienta	391
1955	queso	391
1956	huevos	392
1957	mantequilla	392
1958	pan	392
1959	pimienta	392
1960	queso	392
1961	ajo	393
1962	arroz	393
1963	carne	393
1964	cebolla	393
1965	ensalada	393
1966	ajo	394
1967	arroz	394
1968	carne	394
1969	cebolla	394
1970	ensalada	394
1971	ajo	395
1972	arroz	395
1973	carne	395
1974	cebolla	395
1975	ensalada	395
1976	ajo	396
1977	arroz	396
1978	carne	396
1979	cebolla	396
1980	ensalada	396
1981	ajo	397
1982	arroz	397
1983	carne	397
1984	cebolla	397
1985	ensalada	397
1986	ajo	398
1987	arroz	398
1988	carne	398
1989	cebolla	398
1990	ensalada	398
1991	ajo	399
1992	arroz	399
1993	carne	399
1994	cebolla	399
1995	ensalada	399
1996	ajo	400
1997	arroz	400
1998	carne	400
1999	cebolla	400
2000	ensalada	400
2001	aceite de oliva	401
2002	albahaca	401
2003	pasta	401
2004	queso	401
2005	sal	401
2006	aceite de oliva	402
2007	albahaca	402
2008	pasta	402
2009	queso	402
2010	sal	402
2011	aceite de oliva	403
2012	albahaca	403
2013	pasta	403
2014	queso	403
2015	sal	403
2016	aceite de oliva	404
2017	albahaca	404
2018	pasta	404
2019	queso	404
2020	sal	404
2021	aceite de oliva	405
2022	albahaca	405
2023	pasta	405
2024	queso	405
2025	sal	405
2026	aceite de oliva	406
2027	albahaca	406
2028	pasta	406
2029	queso	406
2030	sal	406
2031	aceite de oliva	407
2032	albahaca	407
2033	pasta	407
2034	queso	407
2035	sal	407
2036	aceite de oliva	408
2037	albahaca	408
2038	pasta	408
2039	queso	408
2040	sal	408
2041	azÔö£Ôòæcar	409
2042	harina	409
2043	huevo	409
2044	leche	409
2045	mantequilla	409
2046	azÔö£Ôòæcar	410
2047	harina	410
2048	huevo	410
2049	leche	410
2050	mantequilla	410
2051	azÔö£Ôòæcar	411
2052	harina	411
2053	huevo	411
2054	leche	411
2055	mantequilla	411
2056	azÔö£Ôòæcar	412
2057	harina	412
2058	huevo	412
2059	leche	412
2060	mantequilla	412
2061	azÔö£Ôòæcar	413
2062	harina	413
2063	huevo	413
2064	leche	413
2065	mantequilla	413
2066	azÔö£Ôòæcar	414
2067	harina	414
2068	huevo	414
2069	leche	414
2070	mantequilla	414
2071	azÔö£Ôòæcar	415
2072	harina	415
2073	huevo	415
2074	leche	415
2075	mantequilla	415
2076	azÔö£Ôòæcar	416
2077	harina	416
2078	huevo	416
2079	leche	416
2080	mantequilla	416
2081	agua	417
2082	azÔö£Ôòæcar	417
2083	hielo	417
2084	limÔö£Ôöén	417
2085	menta	417
2086	agua	418
2087	azÔö£Ôòæcar	418
2088	hielo	418
2089	limÔö£Ôöén	418
2090	menta	418
2091	agua	419
2092	azÔö£Ôòæcar	419
2093	hielo	419
2094	limÔö£Ôöén	419
2095	menta	419
2096	agua	420
2097	azÔö£Ôòæcar	420
2098	hielo	420
2099	limÔö£Ôöén	420
2100	menta	420
2101	agua	421
2102	azÔö£Ôòæcar	421
2103	hielo	421
2104	limÔö£Ôöén	421
2105	menta	421
2106	agua	422
2107	azÔö£Ôòæcar	422
2108	hielo	422
2109	limÔö£Ôöén	422
2110	menta	422
2111	agua	423
2112	azÔö£Ôòæcar	423
2113	hielo	423
2114	limÔö£Ôöén	423
2115	menta	423
2116	agua	424
2117	azÔö£Ôòæcar	424
2118	hielo	424
2119	limÔö£Ôöén	424
2120	menta	424
2121	aceite	425
2122	cebolla	425
2123	lechuga	425
2124	pepino	425
2125	tomate	425
2126	aceite	426
2127	cebolla	426
2128	lechuga	426
2129	pepino	426
2130	tomate	426
2131	aceite	427
2132	cebolla	427
2133	lechuga	427
2134	pepino	427
2135	tomate	427
2136	aceite	428
2137	cebolla	428
2138	lechuga	428
2139	pepino	428
2140	tomate	428
2141	aceite	429
2142	cebolla	429
2143	lechuga	429
2144	pepino	429
2145	tomate	429
2146	aceite	430
2147	cebolla	430
2148	lechuga	430
2149	pepino	430
2150	tomate	430
2151	aceite	431
2152	cebolla	431
2153	lechuga	431
2154	pepino	431
2155	tomate	431
2156	aceite	432
2157	cebolla	432
2158	lechuga	432
2159	pepino	432
2160	tomate	432
2161	caldo	433
2162	fideos	433
2163	pimienta	433
2164	pollo	433
2165	sal	433
2166	caldo	434
2167	fideos	434
2168	pimienta	434
2169	pollo	434
2170	sal	434
2171	caldo	435
2172	fideos	435
2173	pimienta	435
2174	pollo	435
2175	sal	435
2176	caldo	436
2177	fideos	436
2178	pimienta	436
2179	pollo	436
2180	sal	436
2181	caldo	437
2182	fideos	437
2183	pimienta	437
2184	pollo	437
2185	sal	437
2186	caldo	438
2187	fideos	438
2188	pimienta	438
2189	pollo	438
2190	sal	438
2191	caldo	439
2192	fideos	439
2193	pimienta	439
2194	pollo	439
2195	sal	439
2196	caldo	440
2197	fideos	440
2198	pimienta	440
2199	pollo	440
2200	sal	440
2201	ajonjolÔö£┬í	441
2202	pimiento	441
2203	salsa de soja	441
2204	tofu	441
2205	verduras	441
2206	ajonjolÔö£┬í	442
2207	pimiento	442
2208	salsa de soja	442
2209	tofu	442
2210	verduras	442
2211	ajonjolÔö£┬í	443
2212	pimiento	443
2213	salsa de soja	443
2214	tofu	443
2215	verduras	443
2216	ajonjolÔö£┬í	444
2217	pimiento	444
2218	salsa de soja	444
2219	tofu	444
2220	verduras	444
2221	ajonjolÔö£┬í	445
2222	pimiento	445
2223	salsa de soja	445
2224	tofu	445
2225	verduras	445
2226	ajonjolÔö£┬í	446
2227	pimiento	446
2228	salsa de soja	446
2229	tofu	446
2230	verduras	446
2231	ajonjolÔö£┬í	447
2232	pimiento	447
2233	salsa de soja	447
2234	tofu	447
2235	verduras	447
2236	ajonjolÔö£┬í	448
2237	pimiento	448
2238	salsa de soja	448
2239	tofu	448
2240	verduras	448
2241	huevos	449
2242	mantequilla	449
2243	pan	449
2244	pimienta	449
2245	queso	449
2246	huevos	450
2247	mantequilla	450
2248	pan	450
2249	pimienta	450
2250	queso	450
2251	huevos	451
2252	mantequilla	451
2253	pan	451
2254	pimienta	451
2255	queso	451
2256	huevos	452
2257	mantequilla	452
2258	pan	452
2259	pimienta	452
2260	queso	452
2261	huevos	453
2262	mantequilla	453
2263	pan	453
2264	pimienta	453
2265	queso	453
2266	huevos	454
2267	mantequilla	454
2268	pan	454
2269	pimienta	454
2270	queso	454
2271	huevos	455
2272	mantequilla	455
2273	pan	455
2274	pimienta	455
2275	queso	455
2276	huevos	456
2277	mantequilla	456
2278	pan	456
2279	pimienta	456
2280	queso	456
2281	ajo	457
2282	arroz	457
2283	carne	457
2284	cebolla	457
2285	ensalada	457
2286	ajo	458
2287	arroz	458
2288	carne	458
2289	cebolla	458
2290	ensalada	458
2291	ajo	459
2292	arroz	459
2293	carne	459
2294	cebolla	459
2295	ensalada	459
2296	ajo	460
2297	arroz	460
2298	carne	460
2299	cebolla	460
2300	ensalada	460
2301	ajo	461
2302	arroz	461
2303	carne	461
2304	cebolla	461
2305	ensalada	461
2306	ajo	462
2307	arroz	462
2308	carne	462
2309	cebolla	462
2310	ensalada	462
2311	ajo	463
2312	arroz	463
2313	carne	463
2314	cebolla	463
2315	ensalada	463
2316	ajo	464
2317	arroz	464
2318	carne	464
2319	cebolla	464
2320	ensalada	464
2321	aceite de oliva	465
2322	albahaca	465
2323	pasta	465
2324	queso	465
2325	sal	465
2326	aceite de oliva	466
2327	albahaca	466
2328	pasta	466
2329	queso	466
2330	sal	466
2331	aceite de oliva	467
2332	albahaca	467
2333	pasta	467
2334	queso	467
2335	sal	467
2336	aceite de oliva	468
2337	albahaca	468
2338	pasta	468
2339	queso	468
2340	sal	468
2341	aceite de oliva	469
2342	albahaca	469
2343	pasta	469
2344	queso	469
2345	sal	469
2346	aceite de oliva	470
2347	albahaca	470
2348	pasta	470
2349	queso	470
2350	sal	470
2351	aceite de oliva	471
2352	albahaca	471
2353	pasta	471
2354	queso	471
2355	sal	471
2356	aceite de oliva	472
2357	albahaca	472
2358	pasta	472
2359	queso	472
2360	sal	472
2361	azÔö£Ôòæcar	473
2362	harina	473
2363	huevo	473
2364	leche	473
2365	mantequilla	473
2366	azÔö£Ôòæcar	474
2367	harina	474
2368	huevo	474
2369	leche	474
2370	mantequilla	474
2371	azÔö£Ôòæcar	475
2372	harina	475
2373	huevo	475
2374	leche	475
2375	mantequilla	475
2376	azÔö£Ôòæcar	476
2377	harina	476
2378	huevo	476
2379	leche	476
2380	mantequilla	476
2381	azÔö£Ôòæcar	477
2382	harina	477
2383	huevo	477
2384	leche	477
2385	mantequilla	477
2386	azÔö£Ôòæcar	478
2387	harina	478
2388	huevo	478
2389	leche	478
2390	mantequilla	478
2391	azÔö£Ôòæcar	479
2392	harina	479
2393	huevo	479
2394	leche	479
2395	mantequilla	479
2396	azÔö£Ôòæcar	480
2397	harina	480
2398	huevo	480
2399	leche	480
2400	mantequilla	480
2401	agua	481
2402	azÔö£Ôòæcar	481
2403	hielo	481
2404	limÔö£Ôöén	481
2405	menta	481
2406	agua	482
2407	azÔö£Ôòæcar	482
2408	hielo	482
2409	limÔö£Ôöén	482
2410	menta	482
2411	agua	483
2412	azÔö£Ôòæcar	483
2413	hielo	483
2414	limÔö£Ôöén	483
2415	menta	483
2416	agua	484
2417	azÔö£Ôòæcar	484
2418	hielo	484
2419	limÔö£Ôöén	484
2420	menta	484
2421	agua	485
2422	azÔö£Ôòæcar	485
2423	hielo	485
2424	limÔö£Ôöén	485
2425	menta	485
2426	agua	486
2427	azÔö£Ôòæcar	486
2428	hielo	486
2429	limÔö£Ôöén	486
2430	menta	486
2431	agua	487
2432	azÔö£Ôòæcar	487
2433	hielo	487
2434	limÔö£Ôöén	487
2435	menta	487
2436	agua	488
2437	azÔö£Ôòæcar	488
2438	hielo	488
2439	limÔö£Ôöén	488
2440	menta	488
2441	aceite	489
2442	cebolla	489
2443	lechuga	489
2444	pepino	489
2445	tomate	489
2446	aceite	490
2447	cebolla	490
2448	lechuga	490
2449	pepino	490
2450	tomate	490
2451	aceite	491
2452	cebolla	491
2453	lechuga	491
2454	pepino	491
2455	tomate	491
2456	aceite	492
2457	cebolla	492
2458	lechuga	492
2459	pepino	492
2460	tomate	492
2461	aceite	493
2462	cebolla	493
2463	lechuga	493
2464	pepino	493
2465	tomate	493
2466	aceite	494
2467	cebolla	494
2468	lechuga	494
2469	pepino	494
2470	tomate	494
2471	aceite	495
2472	cebolla	495
2473	lechuga	495
2474	pepino	495
2475	tomate	495
2476	aceite	496
2477	cebolla	496
2478	lechuga	496
2479	pepino	496
2480	tomate	496
2481	caldo	497
2482	fideos	497
2483	pimienta	497
2484	pollo	497
2485	sal	497
2486	caldo	498
2487	fideos	498
2488	pimienta	498
2489	pollo	498
2490	sal	498
2491	caldo	499
2492	fideos	499
2493	pimienta	499
2494	pollo	499
2495	sal	499
2496	caldo	500
2497	fideos	500
2498	pimienta	500
2499	pollo	500
2500	sal	500
2501	caldo	501
2502	fideos	501
2503	pimienta	501
2504	pollo	501
2505	sal	501
2506	caldo	502
2507	fideos	502
2508	pimienta	502
2509	pollo	502
2510	sal	502
2511	caldo	503
2512	fideos	503
2513	pimienta	503
2514	pollo	503
2515	sal	503
2516	caldo	504
2517	fideos	504
2518	pimienta	504
2519	pollo	504
2520	sal	504
2521	ajonjolÔö£┬í	505
2522	pimiento	505
2523	salsa de soja	505
2524	tofu	505
2525	verduras	505
2526	ajonjolÔö£┬í	506
2527	pimiento	506
2528	salsa de soja	506
2529	tofu	506
2530	verduras	506
2531	ajonjolÔö£┬í	507
2532	pimiento	507
2533	salsa de soja	507
2534	tofu	507
2535	verduras	507
2536	ajonjolÔö£┬í	508
2537	pimiento	508
2538	salsa de soja	508
2539	tofu	508
2540	verduras	508
2541	ajonjolÔö£┬í	509
2542	pimiento	509
2543	salsa de soja	509
2544	tofu	509
2545	verduras	509
2546	ajonjolÔö£┬í	510
2547	pimiento	510
2548	salsa de soja	510
2549	tofu	510
2550	verduras	510
2551	ajonjolÔö£┬í	511
2552	pimiento	511
2553	salsa de soja	511
2554	tofu	511
2555	verduras	511
2556	ajonjolÔö£┬í	512
2557	pimiento	512
2558	salsa de soja	512
2559	tofu	512
2560	verduras	512
2561	huevos	513
2562	mantequilla	513
2563	pan	513
2564	pimienta	513
2565	queso	513
2566	huevos	514
2567	mantequilla	514
2568	pan	514
2569	pimienta	514
2570	queso	514
2571	huevos	515
2572	mantequilla	515
2573	pan	515
2574	pimienta	515
2575	queso	515
2576	huevos	516
2577	mantequilla	516
2578	pan	516
2579	pimienta	516
2580	queso	516
2581	huevos	517
2582	mantequilla	517
2583	pan	517
2584	pimienta	517
2585	queso	517
2586	huevos	518
2587	mantequilla	518
2588	pan	518
2589	pimienta	518
2590	queso	518
2591	huevos	519
2592	mantequilla	519
2593	pan	519
2594	pimienta	519
2595	queso	519
2596	huevos	520
2597	mantequilla	520
2598	pan	520
2599	pimienta	520
2600	queso	520
2601	ajo	521
2602	arroz	521
2603	carne	521
2604	cebolla	521
2605	ensalada	521
2606	ajo	522
2607	arroz	522
2608	carne	522
2609	cebolla	522
2610	ensalada	522
2611	ajo	523
2612	arroz	523
2613	carne	523
2614	cebolla	523
2615	ensalada	523
2616	ajo	524
2617	arroz	524
2618	carne	524
2619	cebolla	524
2620	ensalada	524
2621	ajo	525
2622	arroz	525
2623	carne	525
2624	cebolla	525
2625	ensalada	525
2626	ajo	526
2627	arroz	526
2628	carne	526
2629	cebolla	526
2630	ensalada	526
2631	ajo	527
2632	arroz	527
2633	carne	527
2634	cebolla	527
2635	ensalada	527
2636	ajo	528
2637	arroz	528
2638	carne	528
2639	cebolla	528
2640	ensalada	528
2641	aceite de oliva	529
2642	albahaca	529
2643	pasta	529
2644	queso	529
2645	sal	529
2646	aceite de oliva	530
2647	albahaca	530
2648	pasta	530
2649	queso	530
2650	sal	530
2651	aceite de oliva	531
2652	albahaca	531
2653	pasta	531
2654	queso	531
2655	sal	531
2656	aceite de oliva	532
2657	albahaca	532
2658	pasta	532
2659	queso	532
2660	sal	532
2661	aceite de oliva	533
2662	albahaca	533
2663	pasta	533
2664	queso	533
2665	sal	533
2666	aceite de oliva	534
2667	albahaca	534
2668	pasta	534
2669	queso	534
2670	sal	534
2671	aceite de oliva	535
2672	albahaca	535
2673	pasta	535
2674	queso	535
2675	sal	535
2676	aceite de oliva	536
2677	albahaca	536
2678	pasta	536
2679	queso	536
2680	sal	536
2681	azÔö£Ôòæcar	537
2682	harina	537
2683	huevo	537
2684	leche	537
2685	mantequilla	537
2686	azÔö£Ôòæcar	538
2687	harina	538
2688	huevo	538
2689	leche	538
2690	mantequilla	538
2691	azÔö£Ôòæcar	539
2692	harina	539
2693	huevo	539
2694	leche	539
2695	mantequilla	539
2696	azÔö£Ôòæcar	540
2697	harina	540
2698	huevo	540
2699	leche	540
2700	mantequilla	540
2701	azÔö£Ôòæcar	541
2702	harina	541
2703	huevo	541
2704	leche	541
2705	mantequilla	541
2706	azÔö£Ôòæcar	542
2707	harina	542
2708	huevo	542
2709	leche	542
2710	mantequilla	542
2711	azÔö£Ôòæcar	543
2712	harina	543
2713	huevo	543
2714	leche	543
2715	mantequilla	543
2716	azÔö£Ôòæcar	544
2717	harina	544
2718	huevo	544
2719	leche	544
2720	mantequilla	544
2721	agua	545
2722	azÔö£Ôòæcar	545
2723	hielo	545
2724	limÔö£Ôöén	545
2725	menta	545
2726	agua	546
2727	azÔö£Ôòæcar	546
2728	hielo	546
2729	limÔö£Ôöén	546
2730	menta	546
2731	agua	547
2732	azÔö£Ôòæcar	547
2733	hielo	547
2734	limÔö£Ôöén	547
2735	menta	547
2736	agua	548
2737	azÔö£Ôòæcar	548
2738	hielo	548
2739	limÔö£Ôöén	548
2740	menta	548
2741	agua	549
2742	azÔö£Ôòæcar	549
2743	hielo	549
2744	limÔö£Ôöén	549
2745	menta	549
2746	agua	550
2747	azÔö£Ôòæcar	550
2748	hielo	550
2749	limÔö£Ôöén	550
2750	menta	550
2751	agua	551
2752	azÔö£Ôòæcar	551
2753	hielo	551
2754	limÔö£Ôöén	551
2755	menta	551
2756	agua	552
2757	azÔö£Ôòæcar	552
2758	hielo	552
2759	limÔö£Ôöén	552
2760	menta	552
2761	aceite	553
2762	cebolla	553
2763	lechuga	553
2764	pepino	553
2765	tomate	553
2766	aceite	554
2767	cebolla	554
2768	lechuga	554
2769	pepino	554
2770	tomate	554
2771	aceite	555
2772	cebolla	555
2773	lechuga	555
2774	pepino	555
2775	tomate	555
2776	aceite	556
2777	cebolla	556
2778	lechuga	556
2779	pepino	556
2780	tomate	556
2781	aceite	557
2782	cebolla	557
2783	lechuga	557
2784	pepino	557
2785	tomate	557
2786	aceite	558
2787	cebolla	558
2788	lechuga	558
2789	pepino	558
2790	tomate	558
2791	aceite	559
2792	cebolla	559
2793	lechuga	559
2794	pepino	559
2795	tomate	559
2796	aceite	560
2797	cebolla	560
2798	lechuga	560
2799	pepino	560
2800	tomate	560
2801	caldo	561
2802	fideos	561
2803	pimienta	561
2804	pollo	561
2805	sal	561
2806	caldo	562
2807	fideos	562
2808	pimienta	562
2809	pollo	562
2810	sal	562
2811	caldo	563
2812	fideos	563
2813	pimienta	563
2814	pollo	563
2815	sal	563
2816	caldo	564
2817	fideos	564
2818	pimienta	564
2819	pollo	564
2820	sal	564
2821	caldo	565
2822	fideos	565
2823	pimienta	565
2824	pollo	565
2825	sal	565
2826	caldo	566
2827	fideos	566
2828	pimienta	566
2829	pollo	566
2830	sal	566
2831	caldo	567
2832	fideos	567
2833	pimienta	567
2834	pollo	567
2835	sal	567
2836	caldo	568
2837	fideos	568
2838	pimienta	568
2839	pollo	568
2840	sal	568
2841	ajonjolÔö£┬í	569
2842	pimiento	569
2843	salsa de soja	569
2844	tofu	569
2845	verduras	569
2846	ajonjolÔö£┬í	570
2847	pimiento	570
2848	salsa de soja	570
2849	tofu	570
2850	verduras	570
2851	ajonjolÔö£┬í	571
2852	pimiento	571
2853	salsa de soja	571
2854	tofu	571
2855	verduras	571
2856	ajonjolÔö£┬í	572
2857	pimiento	572
2858	salsa de soja	572
2859	tofu	572
2860	verduras	572
2861	ajonjolÔö£┬í	573
2862	pimiento	573
2863	salsa de soja	573
2864	tofu	573
2865	verduras	573
2866	ajonjolÔö£┬í	574
2867	pimiento	574
2868	salsa de soja	574
2869	tofu	574
2870	verduras	574
2871	ajonjolÔö£┬í	575
2872	pimiento	575
2873	salsa de soja	575
2874	tofu	575
2875	verduras	575
2876	ajonjolÔö£┬í	576
2877	pimiento	576
2878	salsa de soja	576
2879	tofu	576
2880	verduras	576
2881	huevos	577
2882	mantequilla	577
2883	pan	577
2884	pimienta	577
2885	queso	577
2886	huevos	578
2887	mantequilla	578
2888	pan	578
2889	pimienta	578
2890	queso	578
2891	huevos	579
2892	mantequilla	579
2893	pan	579
2894	pimienta	579
2895	queso	579
2896	huevos	580
2897	mantequilla	580
2898	pan	580
2899	pimienta	580
2900	queso	580
2901	huevos	581
2902	mantequilla	581
2903	pan	581
2904	pimienta	581
2905	queso	581
2906	huevos	582
2907	mantequilla	582
2908	pan	582
2909	pimienta	582
2910	queso	582
2911	huevos	583
2912	mantequilla	583
2913	pan	583
2914	pimienta	583
2915	queso	583
2916	huevos	584
2917	mantequilla	584
2918	pan	584
2919	pimienta	584
2920	queso	584
2921	ajo	585
2922	arroz	585
2923	carne	585
2924	cebolla	585
2925	ensalada	585
2926	ajo	586
2927	arroz	586
2928	carne	586
2929	cebolla	586
2930	ensalada	586
2931	ajo	587
2932	arroz	587
2933	carne	587
2934	cebolla	587
2935	ensalada	587
2936	ajo	588
2937	arroz	588
2938	carne	588
2939	cebolla	588
2940	ensalada	588
2941	ajo	589
2942	arroz	589
2943	carne	589
2944	cebolla	589
2945	ensalada	589
2946	ajo	590
2947	arroz	590
2948	carne	590
2949	cebolla	590
2950	ensalada	590
2951	ajo	591
2952	arroz	591
2953	carne	591
2954	cebolla	591
2955	ensalada	591
2956	ajo	592
2957	arroz	592
2958	carne	592
2959	cebolla	592
2960	ensalada	592
2961	aceite de oliva	593
2962	albahaca	593
2963	pasta	593
2964	queso	593
2965	sal	593
2966	aceite de oliva	594
2967	albahaca	594
2968	pasta	594
2969	queso	594
2970	sal	594
2971	aceite de oliva	595
2972	albahaca	595
2973	pasta	595
2974	queso	595
2975	sal	595
2976	aceite de oliva	596
2977	albahaca	596
2978	pasta	596
2979	queso	596
2980	sal	596
2981	aceite de oliva	597
2982	albahaca	597
2983	pasta	597
2984	queso	597
2985	sal	597
2986	aceite de oliva	598
2987	albahaca	598
2988	pasta	598
2989	queso	598
2990	sal	598
2991	aceite de oliva	599
2992	albahaca	599
2993	pasta	599
2994	queso	599
2995	sal	599
2996	aceite de oliva	600
2997	albahaca	600
2998	pasta	600
2999	queso	600
3000	sal	600
3001	azÔö£Ôòæcar	601
3002	harina	601
3003	huevo	601
3004	leche	601
3005	mantequilla	601
3006	azÔö£Ôòæcar	602
3007	harina	602
3008	huevo	602
3009	leche	602
3010	mantequilla	602
3011	azÔö£Ôòæcar	603
3012	harina	603
3013	huevo	603
3014	leche	603
3015	mantequilla	603
3016	azÔö£Ôòæcar	604
3017	harina	604
3018	huevo	604
3019	leche	604
3020	mantequilla	604
3021	azÔö£Ôòæcar	605
3022	harina	605
3023	huevo	605
3024	leche	605
3025	mantequilla	605
3026	azÔö£Ôòæcar	606
3027	harina	606
3028	huevo	606
3029	leche	606
3030	mantequilla	606
3031	azÔö£Ôòæcar	607
3032	harina	607
3033	huevo	607
3034	leche	607
3035	mantequilla	607
3036	azÔö£Ôòæcar	608
3037	harina	608
3038	huevo	608
3039	leche	608
3040	mantequilla	608
3041	agua	609
3042	azÔö£Ôòæcar	609
3043	hielo	609
3044	limÔö£Ôöén	609
3045	menta	609
3046	agua	610
3047	azÔö£Ôòæcar	610
3048	hielo	610
3049	limÔö£Ôöén	610
3050	menta	610
3051	agua	611
3052	azÔö£Ôòæcar	611
3053	hielo	611
3054	limÔö£Ôöén	611
3055	menta	611
3056	agua	612
3057	azÔö£Ôòæcar	612
3058	hielo	612
3059	limÔö£Ôöén	612
3060	menta	612
3061	agua	613
3062	azÔö£Ôòæcar	613
3063	hielo	613
3064	limÔö£Ôöén	613
3065	menta	613
3066	agua	614
3067	azÔö£Ôòæcar	614
3068	hielo	614
3069	limÔö£Ôöén	614
3070	menta	614
3071	agua	615
3072	azÔö£Ôòæcar	615
3073	hielo	615
3074	limÔö£Ôöén	615
3075	menta	615
3076	agua	616
3077	azÔö£Ôòæcar	616
3078	hielo	616
3079	limÔö£Ôöén	616
3080	menta	616
3081	aceite	617
3082	cebolla	617
3083	lechuga	617
3084	pepino	617
3085	tomate	617
3086	aceite	618
3087	cebolla	618
3088	lechuga	618
3089	pepino	618
3090	tomate	618
3091	aceite	619
3092	cebolla	619
3093	lechuga	619
3094	pepino	619
3095	tomate	619
3096	aceite	620
3097	cebolla	620
3098	lechuga	620
3099	pepino	620
3100	tomate	620
3101	aceite	621
3102	cebolla	621
3103	lechuga	621
3104	pepino	621
3105	tomate	621
3106	aceite	622
3107	cebolla	622
3108	lechuga	622
3109	pepino	622
3110	tomate	622
3111	aceite	623
3112	cebolla	623
3113	lechuga	623
3114	pepino	623
3115	tomate	623
3116	aceite	624
3117	cebolla	624
3118	lechuga	624
3119	pepino	624
3120	tomate	624
3121	caldo	625
3122	fideos	625
3123	pimienta	625
3124	pollo	625
3125	sal	625
3126	caldo	626
3127	fideos	626
3128	pimienta	626
3129	pollo	626
3130	sal	626
3131	caldo	627
3132	fideos	627
3133	pimienta	627
3134	pollo	627
3135	sal	627
3136	caldo	628
3137	fideos	628
3138	pimienta	628
3139	pollo	628
3140	sal	628
3141	caldo	629
3142	fideos	629
3143	pimienta	629
3144	pollo	629
3145	sal	629
3146	caldo	630
3147	fideos	630
3148	pimienta	630
3149	pollo	630
3150	sal	630
3151	caldo	631
3152	fideos	631
3153	pimienta	631
3154	pollo	631
3155	sal	631
3156	caldo	632
3157	fideos	632
3158	pimienta	632
3159	pollo	632
3160	sal	632
3161	ajonjolÔö£┬í	633
3162	pimiento	633
3163	salsa de soja	633
3164	tofu	633
3165	verduras	633
3166	ajonjolÔö£┬í	634
3167	pimiento	634
3168	salsa de soja	634
3169	tofu	634
3170	verduras	634
3171	ajonjolÔö£┬í	635
3172	pimiento	635
3173	salsa de soja	635
3174	tofu	635
3175	verduras	635
3176	ajonjolÔö£┬í	636
3177	pimiento	636
3178	salsa de soja	636
3179	tofu	636
3180	verduras	636
3181	ajonjolÔö£┬í	637
3182	pimiento	637
3183	salsa de soja	637
3184	tofu	637
3185	verduras	637
3186	ajonjolÔö£┬í	638
3187	pimiento	638
3188	salsa de soja	638
3189	tofu	638
3190	verduras	638
3191	ajonjolÔö£┬í	639
3192	pimiento	639
3193	salsa de soja	639
3194	tofu	639
3195	verduras	639
3196	ajonjolÔö£┬í	640
3197	pimiento	640
3198	salsa de soja	640
3199	tofu	640
3200	verduras	640
3209	Ingrediente adicional 1	648
3210	Ingrediente adicional 2	648
\.


--
-- Data for Name: me_gusta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.me_gusta (id_megusta, fecha_creacion, id_receta, id_usr) FROM stdin;
1	2025-09-15 17:56:55.742644	476	1
2	2025-09-15 17:56:55.742644	205	2
3	2025-09-15 17:56:55.742644	598	1
4	2025-09-15 17:56:55.742644	344	1
5	2025-09-15 17:56:55.742644	14	1
6	2025-09-15 17:56:55.742644	491	3
7	2025-09-15 17:56:55.742644	114	2
8	2025-09-15 17:56:55.742644	472	1
9	2025-09-15 17:56:55.742644	527	3
10	2025-09-15 17:56:55.742644	447	2
11	2025-09-15 17:56:55.742644	187	2
12	2025-09-15 17:56:55.742644	306	3
13	2025-09-15 17:56:55.742644	639	2
14	2025-09-15 17:56:55.742644	197	2
15	2025-09-15 17:56:55.742644	147	1
16	2025-09-15 17:56:55.742644	604	2
17	2025-09-15 17:56:55.742644	173	3
18	2025-09-15 17:56:55.742644	97	2
19	2025-09-15 17:56:55.742644	448	3
20	2025-09-15 17:56:55.742644	592	3
21	2025-09-15 17:56:55.742644	634	1
22	2025-09-15 17:56:55.742644	121	1
23	2025-09-15 17:56:55.742644	389	2
24	2025-09-15 17:56:55.742644	188	3
25	2025-09-15 17:56:55.742644	375	3
26	2025-09-15 17:56:55.742644	161	1
27	2025-09-15 17:56:55.742644	446	2
28	2025-09-15 17:56:55.742644	155	2
29	2025-09-15 17:56:55.742644	331	3
30	2025-09-15 17:56:55.742644	409	2
31	2025-09-15 17:56:55.742644	210	1
32	2025-09-15 17:56:55.742644	411	3
33	2025-09-15 17:56:55.742644	260	3
34	2025-09-15 17:56:55.742644	605	2
35	2025-09-15 17:56:55.742644	587	2
36	2025-09-15 17:56:55.742644	445	3
37	2025-09-15 17:56:55.742644	183	3
38	2025-09-15 17:56:55.742644	9	3
39	2025-09-15 17:56:55.742644	154	1
40	2025-09-15 17:56:55.742644	63	3
41	2025-09-15 17:56:55.742644	584	1
42	2025-09-15 17:56:55.742644	417	2
43	2025-09-15 17:56:55.742644	157	1
44	2025-09-15 17:56:55.742644	434	2
45	2025-09-15 17:56:55.742644	436	3
46	2025-09-15 17:56:55.742644	602	1
47	2025-09-15 17:56:55.742644	345	3
48	2025-09-15 17:56:55.742644	35	1
49	2025-09-15 17:56:55.742644	341	2
50	2025-09-15 17:56:55.742644	490	3
51	2025-09-15 17:56:55.742644	503	1
52	2025-09-15 17:56:55.742644	286	2
53	2025-09-15 17:56:55.742644	420	3
54	2025-09-15 17:56:55.742644	308	3
55	2025-09-15 17:56:55.742644	150	3
56	2025-09-15 17:56:55.742644	632	2
57	2025-09-15 17:56:55.742644	553	2
58	2025-09-15 17:56:55.742644	283	3
59	2025-09-15 17:56:55.742644	43	1
60	2025-09-15 17:56:55.742644	223	3
61	2025-09-15 17:56:55.742644	240	3
62	2025-09-15 17:56:55.742644	272	3
63	2025-09-15 17:56:55.742644	130	3
64	2025-09-15 17:56:55.742644	231	3
65	2025-09-15 17:56:55.742644	217	3
66	2025-09-15 17:56:55.742644	548	3
67	2025-09-15 17:56:55.742644	363	2
68	2025-09-15 17:56:55.742644	482	1
69	2025-09-15 17:56:55.742644	349	2
70	2025-09-15 17:56:55.742644	220	1
71	2025-09-15 17:56:55.742644	309	2
72	2025-09-15 17:56:55.742644	545	2
73	2025-09-15 17:56:55.742644	573	1
74	2025-09-15 17:56:55.742644	166	1
75	2025-09-15 17:56:55.742644	259	1
76	2025-09-15 17:56:55.742644	118	3
77	2025-09-15 17:56:55.742644	88	3
78	2025-09-15 17:56:55.742644	487	2
79	2025-09-15 17:56:55.742644	522	1
80	2025-09-15 17:56:55.742644	616	3
81	2025-09-15 17:56:55.742644	560	2
82	2025-09-15 17:56:55.742644	263	3
83	2025-09-15 17:56:55.742644	7	3
84	2025-09-15 17:56:55.742644	185	2
85	2025-09-15 17:56:55.742644	453	3
86	2025-09-15 17:56:55.742644	431	1
87	2025-09-15 17:56:55.742644	3	1
88	2025-09-15 17:56:55.742644	144	3
89	2025-09-15 17:56:55.742644	438	2
90	2025-09-15 17:56:55.742644	423	1
91	2025-09-15 17:56:55.742644	117	2
92	2025-09-15 17:56:55.742644	615	3
93	2025-09-15 17:56:55.742644	291	1
94	2025-09-15 17:56:55.742644	328	3
95	2025-09-15 17:56:55.742644	612	3
96	2025-09-15 17:56:55.742644	212	3
97	2025-09-15 17:56:55.742644	176	1
98	2025-09-15 17:56:55.742644	439	2
99	2025-09-15 17:56:55.742644	383	3
100	2025-09-15 17:56:55.742644	61	1
101	2025-09-15 17:56:55.742644	538	3
102	2025-09-15 17:56:55.742644	597	1
103	2025-09-15 17:56:55.742644	201	1
104	2025-09-15 17:56:55.742644	388	1
105	2025-09-15 17:56:55.742644	169	1
106	2025-09-15 17:56:55.742644	87	1
107	2025-09-15 17:56:55.742644	166	3
108	2025-09-15 17:56:55.742644	573	3
109	2025-09-15 17:56:55.742644	127	2
110	2025-09-15 17:56:55.742644	390	2
111	2025-09-15 17:56:55.742644	259	3
112	2025-09-15 17:56:55.742644	118	1
113	2025-09-15 17:56:55.742644	88	1
114	2025-09-15 17:56:55.742644	628	2
115	2025-09-15 17:56:55.742644	623	2
116	2025-09-15 17:56:55.742644	329	2
117	2025-09-15 17:56:55.742644	62	2
118	2025-09-15 17:56:55.742644	514	2
119	2025-09-15 17:56:55.742644	283	1
120	2025-09-15 17:56:55.742644	240	1
121	2025-09-15 17:56:55.742644	223	1
122	2025-09-15 17:56:55.742644	43	3
123	2025-09-15 17:56:55.742644	122	2
124	2025-09-15 17:56:55.742644	272	1
125	2025-09-15 17:56:55.742644	130	1
126	2025-09-15 17:56:55.742644	180	2
127	2025-09-15 17:56:55.742644	548	1
128	2025-09-15 17:56:55.742644	231	1
129	2025-09-15 17:56:55.742644	217	1
130	2025-09-15 17:56:55.742644	454	2
131	2025-09-15 17:56:55.742644	482	3
132	2025-09-15 17:56:55.742644	220	3
133	2025-09-15 17:56:55.742644	531	2
134	2025-09-15 17:56:55.742644	30	2
135	2025-09-15 17:56:55.742644	612	1
136	2025-09-15 17:56:55.742644	328	1
137	2025-09-15 17:56:55.742644	383	1
138	2025-09-15 17:56:55.742644	176	3
139	2025-09-15 17:56:55.742644	162	2
140	2025-09-15 17:56:55.742644	212	1
141	2025-09-15 17:56:55.742644	538	1
142	2025-09-15 17:56:55.742644	61	3
143	2025-09-15 17:56:55.742644	201	3
144	2025-09-15 17:56:55.742644	597	3
145	2025-09-15 17:56:55.742644	95	2
146	2025-09-15 17:56:55.742644	585	2
147	2025-09-15 17:56:55.742644	169	3
148	2025-09-15 17:56:55.742644	388	3
149	2025-09-15 17:56:55.742644	87	3
150	2025-09-15 17:56:55.742644	299	2
151	2025-09-15 17:56:55.742644	356	2
152	2025-09-15 17:56:55.742644	48	2
153	2025-09-15 17:56:55.742644	616	1
154	2025-09-15 17:56:55.742644	522	3
155	2025-09-15 17:56:55.742644	99	2
156	2025-09-15 17:56:55.742644	263	1
157	2025-09-15 17:56:55.742644	3	3
158	2025-09-15 17:56:55.742644	431	3
159	2025-09-15 17:56:55.742644	453	1
160	2025-09-15 17:56:55.742644	7	1
161	2025-09-15 17:56:55.742644	144	1
162	2025-09-15 17:56:55.742644	204	2
163	2025-09-15 17:56:55.742644	362	2
164	2025-09-15 17:56:55.742644	615	1
165	2025-09-15 17:56:55.742644	94	2
166	2025-09-15 17:56:55.742644	313	2
167	2025-09-15 17:56:55.742644	262	2
168	2025-09-15 17:56:55.742644	423	3
169	2025-09-15 17:56:55.742644	28	2
170	2025-09-15 17:56:55.742644	291	3
171	2025-09-15 17:56:55.742644	110	2
172	2025-09-15 17:56:55.742644	147	3
173	2025-09-15 17:56:55.742644	173	1
174	2025-09-15 17:56:55.742644	448	1
175	2025-09-15 17:56:55.742644	622	2
176	2025-09-15 17:56:55.742644	121	3
177	2025-09-15 17:56:55.742644	634	3
178	2025-09-15 17:56:55.742644	592	1
179	2025-09-15 17:56:55.742644	370	2
180	2025-09-15 17:56:55.742644	175	2
181	2025-09-15 17:56:55.742644	375	1
182	2025-09-15 17:56:55.742644	188	1
183	2025-09-15 17:56:55.742644	571	2
184	2025-09-15 17:56:55.742644	476	3
185	2025-09-15 17:56:55.742644	344	3
186	2025-09-15 17:56:55.742644	598	3
187	2025-09-15 17:56:55.742644	542	2
188	2025-09-15 17:56:55.742644	470	2
189	2025-09-15 17:56:55.742644	491	1
191	2025-09-15 17:56:55.742644	527	1
192	2025-09-15 17:56:55.742644	472	3
193	2025-09-15 17:56:55.742644	306	1
194	2025-09-15 17:56:55.742644	80	2
195	2025-09-15 17:56:55.742644	602	3
196	2025-09-15 17:56:55.742644	436	1
197	2025-09-15 17:56:55.742644	35	3
198	2025-09-15 17:56:55.742644	305	2
199	2025-09-15 17:56:55.742644	345	1
200	2025-09-15 17:56:55.742644	179	2
201	2025-09-15 17:56:55.742644	490	1
202	2025-09-15 17:56:55.742644	312	2
203	2025-09-15 17:56:55.742644	503	3
204	2025-09-15 17:56:55.742644	420	1
205	2025-09-15 17:56:55.742644	318	2
206	2025-09-15 17:56:55.742644	308	1
207	2025-09-15 17:56:55.742644	150	1
208	2025-09-15 17:56:55.742644	551	2
209	2025-09-15 17:56:55.742644	161	3
210	2025-09-15 17:56:55.742644	210	3
211	2025-09-15 17:56:55.742644	195	2
212	2025-09-15 17:56:55.742644	129	2
213	2025-09-15 17:56:55.742644	331	1
214	2025-09-15 17:56:55.742644	445	1
215	2025-09-15 17:56:55.742644	260	1
216	2025-09-15 17:56:55.742644	411	1
217	2025-09-15 17:56:55.742644	9	1
218	2025-09-15 17:56:55.742644	183	1
219	2025-09-15 17:56:55.742644	584	3
220	2025-09-15 17:56:55.742644	63	1
221	2025-09-15 17:56:55.742644	154	3
222	2025-09-15 17:56:55.742644	483	2
223	2025-09-15 17:56:55.742644	157	3
224	2025-09-15 17:56:55.742644	8	2
225	2025-09-15 17:56:55.742644	294	1
226	2025-09-15 17:56:55.742644	368	1
227	2025-09-15 17:56:55.742644	290	3
228	2025-09-15 17:56:55.742644	516	2
229	2025-09-15 17:56:55.742644	41	2
230	2025-09-15 17:56:55.742644	619	3
231	2025-09-15 17:56:55.742644	174	1
232	2025-09-15 17:56:55.742644	564	2
233	2025-09-15 17:56:55.742644	36	1
234	2025-09-15 17:56:55.742644	580	2
235	2025-09-15 17:56:55.742644	141	2
236	2025-09-15 17:56:55.742644	407	1
237	2025-09-15 17:56:55.742644	4	1
238	2025-09-15 17:56:55.742644	246	2
239	2025-09-15 17:56:55.742644	463	2
240	2025-09-15 17:56:55.742644	544	3
241	2025-09-15 17:56:55.742644	451	1
242	2025-09-15 17:56:55.742644	6	2
243	2025-09-15 17:56:55.742644	509	2
244	2025-09-15 17:56:55.742644	267	2
245	2025-09-15 17:56:55.742644	354	2
246	2025-09-15 17:56:55.742644	159	2
247	2025-09-15 17:56:55.742644	257	1
248	2025-09-15 17:56:55.742644	1	3
249	2025-09-15 17:56:55.742644	200	1
250	2025-09-15 17:56:55.742644	29	2
251	2025-09-15 17:56:55.742644	488	2
252	2025-09-15 17:56:55.742644	58	3
253	2025-09-15 17:56:55.742644	207	2
254	2025-09-15 17:56:55.742644	53	1
255	2025-09-15 17:56:55.742644	86	3
256	2025-09-15 17:56:55.742644	418	2
257	2025-09-15 17:56:55.742644	92	1
258	2025-09-15 17:56:55.742644	613	1
259	2025-09-15 17:56:55.742644	74	2
260	2025-09-15 17:56:55.742644	360	3
261	2025-09-15 17:56:55.742644	275	1
262	2025-09-15 17:56:55.742644	22	3
263	2025-09-15 17:56:55.742644	222	1
264	2025-09-15 17:56:55.742644	572	3
265	2025-09-15 17:56:55.742644	49	3
266	2025-09-15 17:56:55.742644	111	3
267	2025-09-15 17:56:55.742644	235	2
268	2025-09-15 17:56:55.742644	562	3
269	2025-09-15 17:56:55.742644	206	3
270	2025-09-15 17:56:55.742644	607	2
271	2025-09-15 17:56:55.742644	23	1
272	2025-09-15 17:56:55.742644	528	1
273	2025-09-15 17:56:55.742644	501	2
274	2025-09-15 17:56:55.742644	568	1
275	2025-09-15 17:56:55.742644	84	2
276	2025-09-15 17:56:55.742644	372	3
277	2025-09-15 17:56:55.742644	371	1
278	2025-09-15 17:56:55.742644	387	2
279	2025-09-15 17:56:55.742644	237	3
280	2025-09-15 17:56:55.742644	248	2
281	2025-09-15 17:56:55.742644	364	3
282	2025-09-15 17:56:55.742644	44	1
283	2025-09-15 17:56:55.742644	394	2
284	2025-09-15 17:56:55.742644	583	1
285	2025-09-15 17:56:55.742644	608	3
286	2025-09-15 17:56:55.742644	227	1
287	2025-09-15 17:56:55.742644	611	3
288	2025-09-15 17:56:55.742644	171	1
289	2025-09-15 17:56:55.742644	467	1
290	2025-09-15 17:56:55.742644	402	1
291	2025-09-15 17:56:55.742644	495	3
292	2025-09-15 17:56:55.742644	539	1
293	2025-09-15 17:56:55.742644	347	1
294	2025-09-15 17:56:55.742644	311	1
295	2025-09-15 17:56:55.742644	60	3
296	2025-09-15 17:56:55.742644	380	1
297	2025-09-15 17:56:55.742644	247	1
298	2025-09-15 17:56:55.742644	116	2
299	2025-09-15 17:56:55.742644	350	2
300	2025-09-15 17:56:55.742644	225	3
301	2025-09-15 17:56:55.742644	271	2
302	2025-09-15 17:56:55.742644	621	2
303	2025-09-15 17:56:55.742644	242	1
304	2025-09-15 17:56:55.742644	45	3
305	2025-09-15 17:56:55.742644	138	1
306	2025-09-15 17:56:55.742644	517	1
307	2025-09-15 17:56:55.742644	410	1
308	2025-09-15 17:56:55.742644	70	3
309	2025-09-15 17:56:55.742644	338	2
310	2025-09-15 17:56:55.742644	16	1
311	2025-09-15 17:56:55.742644	190	1
312	2025-09-15 17:56:55.742644	199	3
313	2025-09-15 17:56:55.742644	134	2
314	2025-09-15 17:56:55.742644	574	1
315	2025-09-15 17:56:55.742644	124	3
316	2025-09-15 17:56:55.742644	90	2
317	2025-09-15 17:56:55.742644	342	1
318	2025-09-15 17:56:55.742644	481	2
319	2025-09-15 17:56:55.742644	469	3
320	2025-09-15 17:56:55.742644	54	1
321	2025-09-15 17:56:55.742644	75	3
322	2025-09-15 17:56:55.742644	42	2
323	2025-09-15 17:56:55.742644	502	2
324	2025-09-15 17:56:55.742644	450	2
325	2025-09-15 17:56:55.742644	192	2
326	2025-09-15 17:56:55.742644	103	1
327	2025-09-15 17:56:55.742644	425	3
328	2025-09-15 17:56:55.742644	415	3
329	2025-09-15 17:56:55.742644	245	3
330	2025-09-15 17:56:55.742644	59	2
331	2025-09-15 17:56:55.742644	229	3
332	2025-09-15 17:56:55.742644	510	3
333	2025-09-15 17:56:55.742644	561	3
334	2025-09-15 17:56:55.742644	208	1
335	2025-09-15 17:56:55.742644	557	2
336	2025-09-15 17:56:55.742644	81	2
337	2025-09-15 17:56:55.742644	219	2
338	2025-09-15 17:56:55.742644	236	1
339	2025-09-15 17:56:55.742644	148	1
340	2025-09-15 17:56:55.742644	591	2
341	2025-09-15 17:56:55.742644	552	2
342	2025-09-15 17:56:55.742644	393	2
343	2025-09-15 17:56:55.742644	525	1
344	2025-09-15 17:56:55.742644	618	3
345	2025-09-15 17:56:55.742644	115	1
346	2025-09-15 17:56:55.742644	441	2
347	2025-09-15 17:56:55.742644	385	2
348	2025-09-15 17:56:55.742644	79	2
349	2025-09-15 17:56:55.742644	322	1
350	2025-09-15 17:56:55.742644	105	3
351	2025-09-15 17:56:55.742644	521	2
352	2025-09-15 17:56:55.742644	327	3
353	2025-09-15 17:56:55.742644	273	2
354	2025-09-15 17:56:55.742644	323	1
355	2025-09-15 17:56:55.742644	422	3
356	2025-09-15 17:56:55.742644	69	2
357	2025-09-15 17:56:55.742644	225	1
358	2025-09-15 17:56:55.742644	460	2
359	2025-09-15 17:56:55.742644	76	2
360	2025-09-15 17:56:55.742644	406	2
361	2025-09-15 17:56:55.742644	138	3
362	2025-09-15 17:56:55.742644	45	1
363	2025-09-15 17:56:55.742644	242	3
364	2025-09-15 17:56:55.742644	70	1
365	2025-09-15 17:56:55.742644	410	3
366	2025-09-15 17:56:55.742644	517	3
367	2025-09-15 17:56:55.742644	16	3
368	2025-09-15 17:56:55.742644	529	2
369	2025-09-15 17:56:55.742644	203	2
370	2025-09-15 17:56:55.742644	190	3
371	2025-09-15 17:56:55.742644	199	1
372	2025-09-15 17:56:55.742644	334	2
373	2025-09-15 17:56:55.742644	611	1
374	2025-09-15 17:56:55.742644	227	3
375	2025-09-15 17:56:55.742644	171	3
376	2025-09-15 17:56:55.742644	495	1
377	2025-09-15 17:56:55.742644	467	3
378	2025-09-15 17:56:55.742644	402	3
379	2025-09-15 17:56:55.742644	586	2
380	2025-09-15 17:56:55.742644	513	2
381	2025-09-15 17:56:55.742644	539	3
382	2025-09-15 17:56:55.742644	347	3
383	2025-09-15 17:56:55.742644	311	3
384	2025-09-15 17:56:55.742644	51	2
385	2025-09-15 17:56:55.742644	247	3
386	2025-09-15 17:56:55.742644	380	3
387	2025-09-15 17:56:55.742644	60	1
388	2025-09-15 17:56:55.742644	208	3
389	2025-09-15 17:56:55.742644	236	3
390	2025-09-15 17:56:55.742644	148	3
391	2025-09-15 17:56:55.742644	477	2
392	2025-09-15 17:56:55.742644	224	2
393	2025-09-15 17:56:55.742644	115	3
394	2025-09-15 17:56:55.742644	567	2
395	2025-09-15 17:56:55.742644	618	1
396	2025-09-15 17:56:55.742644	525	3
397	2025-09-15 17:56:55.742644	50	2
398	2025-09-15 17:56:55.742644	327	1
399	2025-09-15 17:56:55.742644	105	1
400	2025-09-15 17:56:55.742644	322	3
401	2025-09-15 17:56:55.742644	422	1
402	2025-09-15 17:56:55.742644	323	3
403	2025-09-15 17:56:55.742644	124	1
404	2025-09-15 17:56:55.742644	352	2
405	2025-09-15 17:56:55.742644	574	3
406	2025-09-15 17:56:55.742644	342	3
407	2025-09-15 17:56:55.742644	464	2
408	2025-09-15 17:56:55.742644	75	1
409	2025-09-15 17:56:55.742644	54	3
410	2025-09-15 17:56:55.742644	469	1
411	2025-09-15 17:56:55.742644	425	1
412	2025-09-15 17:56:55.742644	415	1
413	2025-09-15 17:56:55.742644	103	3
414	2025-09-15 17:56:55.742644	245	1
415	2025-09-15 17:56:55.742644	510	1
416	2025-09-15 17:56:55.742644	229	1
417	2025-09-15 17:56:55.742644	395	2
418	2025-09-15 17:56:55.742644	561	1
420	2025-09-15 17:56:55.742644	407	3
421	2025-09-15 17:56:55.742644	544	1
422	2025-09-15 17:56:55.742644	451	3
423	2025-09-15 17:56:55.742644	369	2
424	2025-09-15 17:56:55.742644	67	2
425	2025-09-15 17:56:55.742644	200	3
426	2025-09-15 17:56:55.742644	457	2
427	2025-09-15 17:56:55.742644	1	1
428	2025-09-15 17:56:55.742644	257	3
429	2025-09-15 17:56:55.742644	58	1
430	2025-09-15 17:56:55.742644	368	3
431	2025-09-15 17:56:55.742644	294	3
432	2025-09-15 17:56:55.742644	316	2
433	2025-09-15 17:56:55.742644	290	1
434	2025-09-15 17:56:55.742644	506	2
435	2025-09-15 17:56:55.742644	619	1
436	2025-09-15 17:56:55.742644	174	3
437	2025-09-15 17:56:55.742644	378	2
438	2025-09-15 17:56:55.742644	36	3
439	2025-09-15 17:56:55.742644	336	2
440	2025-09-15 17:56:55.742644	132	2
441	2025-09-15 17:56:55.742644	520	2
442	2025-09-15 17:56:55.742644	206	1
443	2025-09-15 17:56:55.742644	249	2
444	2025-09-15 17:56:55.742644	562	1
445	2025-09-15 17:56:55.742644	111	1
446	2025-09-15 17:56:55.742644	269	2
447	2025-09-15 17:56:55.742644	386	2
448	2025-09-15 17:56:55.742644	302	2
449	2025-09-15 17:56:55.742644	528	3
450	2025-09-15 17:56:55.742644	23	3
451	2025-09-15 17:56:55.742644	568	3
452	2025-09-15 17:56:55.742644	372	1
453	2025-09-15 17:56:55.742644	364	1
454	2025-09-15 17:56:55.742644	237	1
455	2025-09-15 17:56:55.742644	430	2
456	2025-09-15 17:56:55.742644	371	3
457	2025-09-15 17:56:55.742644	126	2
458	2025-09-15 17:56:55.742644	608	1
459	2025-09-15 17:56:55.742644	534	2
460	2025-09-15 17:56:55.742644	511	2
461	2025-09-15 17:56:55.742644	194	2
462	2025-09-15 17:56:55.742644	583	3
463	2025-09-15 17:56:55.742644	44	3
464	2025-09-15 17:56:55.742644	351	2
465	2025-09-15 17:56:55.742644	86	1
466	2025-09-15 17:56:55.742644	53	3
467	2025-09-15 17:56:55.742644	558	2
468	2025-09-15 17:56:55.742644	92	3
469	2025-09-15 17:56:55.742644	360	1
470	2025-09-15 17:56:55.742644	613	3
471	2025-09-15 17:56:55.742644	22	1
472	2025-09-15 17:56:55.742644	156	2
473	2025-09-15 17:56:55.742644	275	3
474	2025-09-15 17:56:55.742644	49	1
475	2025-09-15 17:56:55.742644	572	1
476	2025-09-15 17:56:55.742644	222	3
477	2025-09-15 17:56:55.742644	124	2
478	2025-09-15 17:56:55.742644	352	1
479	2025-09-15 17:56:55.742644	134	3
480	2025-09-15 17:56:55.742644	464	1
481	2025-09-15 17:56:55.742644	90	3
482	2025-09-15 17:56:55.742644	481	3
483	2025-09-15 17:56:55.742644	75	2
484	2025-09-15 17:56:55.742644	469	2
485	2025-09-15 17:56:55.742644	450	3
486	2025-09-15 17:56:55.742644	42	3
487	2025-09-15 17:56:55.742644	502	3
488	2025-09-15 17:56:55.742644	425	2
489	2025-09-15 17:56:55.742644	415	2
490	2025-09-15 17:56:55.742644	192	3
491	2025-09-15 17:56:55.742644	245	2
492	2025-09-15 17:56:55.742644	510	2
493	2025-09-15 17:56:55.742644	59	3
494	2025-09-15 17:56:55.742644	229	2
495	2025-09-15 17:56:55.742644	395	1
496	2025-09-15 17:56:55.742644	561	2
497	2025-09-15 17:56:55.742644	557	3
498	2025-09-15 17:56:55.742644	477	1
499	2025-09-15 17:56:55.742644	219	3
500	2025-09-15 17:56:55.742644	81	3
501	2025-09-15 17:56:55.742644	224	1
502	2025-09-15 17:56:55.742644	591	3
503	2025-09-15 17:56:55.742644	552	3
504	2025-09-15 17:56:55.742644	393	3
505	2025-09-15 17:56:55.742644	567	1
506	2025-09-15 17:56:55.742644	441	3
507	2025-09-15 17:56:55.742644	385	3
508	2025-09-15 17:56:55.742644	618	2
509	2025-09-15 17:56:55.742644	79	3
510	2025-09-15 17:56:55.742644	50	1
511	2025-09-15 17:56:55.742644	327	2
512	2025-09-15 17:56:55.742644	105	2
513	2025-09-15 17:56:55.742644	521	3
514	2025-09-15 17:56:55.742644	422	2
515	2025-09-15 17:56:55.742644	273	3
516	2025-09-15 17:56:55.742644	611	2
517	2025-09-15 17:56:55.742644	495	2
518	2025-09-15 17:56:55.742644	586	1
519	2025-09-15 17:56:55.742644	513	1
520	2025-09-15 17:56:55.742644	51	1
521	2025-09-15 17:56:55.742644	60	2
522	2025-09-15 17:56:55.742644	350	3
523	2025-09-15 17:56:55.742644	116	3
524	2025-09-15 17:56:55.742644	69	1
525	2025-09-15 17:56:55.742644	271	3
526	2025-09-15 17:56:55.742644	225	2
527	2025-09-15 17:56:55.742644	460	1
528	2025-09-15 17:56:55.742644	406	1
529	2025-09-15 17:56:55.742644	76	1
530	2025-09-15 17:56:55.742644	621	3
531	2025-09-15 17:56:55.742644	45	2
532	2025-09-15 17:56:55.742644	70	2
533	2025-09-15 17:56:55.742644	338	3
534	2025-09-15 17:56:55.742644	529	1
535	2025-09-15 17:56:55.742644	203	1
536	2025-09-15 17:56:55.742644	199	2
537	2025-09-15 17:56:55.742644	334	1
538	2025-09-15 17:56:55.742644	351	1
539	2025-09-15 17:56:55.742644	207	3
540	2025-09-15 17:56:55.742644	86	2
541	2025-09-15 17:56:55.742644	558	1
542	2025-09-15 17:56:55.742644	418	3
543	2025-09-15 17:56:55.742644	74	3
544	2025-09-15 17:56:55.742644	360	2
545	2025-09-15 17:56:55.742644	22	2
546	2025-09-15 17:56:55.742644	156	1
547	2025-09-15 17:56:55.742644	49	2
548	2025-09-15 17:56:55.742644	572	2
549	2025-09-15 17:56:55.742644	249	1
550	2025-09-15 17:56:55.742644	206	2
551	2025-09-15 17:56:55.742644	111	2
552	2025-09-15 17:56:55.742644	269	1
553	2025-09-15 17:56:55.742644	235	3
554	2025-09-15 17:56:55.742644	562	2
555	2025-09-15 17:56:55.742644	607	3
556	2025-09-15 17:56:55.742644	386	1
557	2025-09-15 17:56:55.742644	302	1
558	2025-09-15 17:56:55.742644	501	3
559	2025-09-15 17:56:55.742644	84	3
560	2025-09-15 17:56:55.742644	372	2
561	2025-09-15 17:56:55.742644	248	3
562	2025-09-15 17:56:55.742644	364	2
563	2025-09-15 17:56:55.742644	237	2
564	2025-09-15 17:56:55.742644	430	1
565	2025-09-15 17:56:55.742644	387	3
566	2025-09-15 17:56:55.742644	534	1
567	2025-09-15 17:56:55.742644	511	1
568	2025-09-15 17:56:55.742644	194	1
569	2025-09-15 17:56:55.742644	126	1
570	2025-09-15 17:56:55.742644	608	2
571	2025-09-15 17:56:55.742644	394	3
572	2025-09-15 17:56:55.742644	316	1
573	2025-09-15 17:56:55.742644	290	2
574	2025-09-15 17:56:55.742644	516	3
575	2025-09-15 17:56:55.742644	506	1
576	2025-09-15 17:56:55.742644	41	3
577	2025-09-15 17:56:55.742644	619	2
578	2025-09-15 17:56:55.742644	564	3
579	2025-09-15 17:56:55.742644	378	1
580	2025-09-15 17:56:55.742644	336	1
581	2025-09-15 17:56:55.742644	141	3
582	2025-09-15 17:56:55.742644	520	1
583	2025-09-15 17:56:55.742644	132	1
584	2025-09-15 17:56:55.742644	580	3
585	2025-09-15 17:56:55.742644	246	3
586	2025-09-15 17:56:55.742644	544	2
587	2025-09-15 17:56:55.742644	463	3
588	2025-09-15 17:56:55.742644	369	1
589	2025-09-15 17:56:55.742644	6	3
590	2025-09-15 17:56:55.742644	509	3
591	2025-09-15 17:56:55.742644	354	3
592	2025-09-15 17:56:55.742644	267	3
593	2025-09-15 17:56:55.742644	457	1
594	2025-09-15 17:56:55.742644	67	1
595	2025-09-15 17:56:55.742644	1	2
596	2025-09-15 17:56:55.742644	159	3
597	2025-09-15 17:56:55.742644	58	2
598	2025-09-15 17:56:55.742644	29	3
599	2025-09-15 17:56:55.742644	488	3
600	2025-09-15 17:56:55.742644	235	1
601	2025-09-15 17:56:55.742644	269	3
602	2025-09-15 17:56:55.742644	249	3
603	2025-09-15 17:56:55.742644	302	3
604	2025-09-15 17:56:55.742644	386	3
605	2025-09-15 17:56:55.742644	607	1
606	2025-09-15 17:56:55.742644	23	2
607	2025-09-15 17:56:55.742644	528	2
608	2025-09-15 17:56:55.742644	501	1
609	2025-09-15 17:56:55.742644	568	2
610	2025-09-15 17:56:55.742644	84	1
611	2025-09-15 17:56:55.742644	387	1
612	2025-09-15 17:56:55.742644	371	2
613	2025-09-15 17:56:55.742644	430	3
614	2025-09-15 17:56:55.742644	248	1
615	2025-09-15 17:56:55.742644	44	2
616	2025-09-15 17:56:55.742644	394	1
617	2025-09-15 17:56:55.742644	194	3
618	2025-09-15 17:56:55.742644	126	3
619	2025-09-15 17:56:55.742644	583	2
620	2025-09-15 17:56:55.742644	534	3
621	2025-09-15 17:56:55.742644	511	3
622	2025-09-15 17:56:55.742644	207	1
623	2025-09-15 17:56:55.742644	351	3
624	2025-09-15 17:56:55.742644	558	3
625	2025-09-15 17:56:55.742644	53	2
626	2025-09-15 17:56:55.742644	418	1
627	2025-09-15 17:56:55.742644	92	2
628	2025-09-15 17:56:55.742644	613	2
629	2025-09-15 17:56:55.742644	74	1
630	2025-09-15 17:56:55.742644	156	3
631	2025-09-15 17:56:55.742644	275	2
632	2025-09-15 17:56:55.742644	222	2
633	2025-09-15 17:56:55.742644	4	2
634	2025-09-15 17:56:55.742644	246	1
635	2025-09-15 17:56:55.742644	407	2
636	2025-09-15 17:56:55.742644	463	1
637	2025-09-15 17:56:55.742644	451	2
638	2025-09-15 17:56:55.742644	509	1
639	2025-09-15 17:56:55.742644	6	1
640	2025-09-15 17:56:55.742644	369	3
641	2025-09-15 17:56:55.742644	267	1
642	2025-09-15 17:56:55.742644	354	1
643	2025-09-15 17:56:55.742644	159	1
644	2025-09-15 17:56:55.742644	257	2
645	2025-09-15 17:56:55.742644	67	3
646	2025-09-15 17:56:55.742644	200	2
647	2025-09-15 17:56:55.742644	457	3
648	2025-09-15 17:56:55.742644	488	1
649	2025-09-15 17:56:55.742644	29	1
650	2025-09-15 17:56:55.742644	316	3
651	2025-09-15 17:56:55.742644	294	2
652	2025-09-15 17:56:55.742644	368	2
653	2025-09-15 17:56:55.742644	516	1
654	2025-09-15 17:56:55.742644	41	1
655	2025-09-15 17:56:55.742644	506	3
656	2025-09-15 17:56:55.742644	378	3
657	2025-09-15 17:56:55.742644	174	2
658	2025-09-15 17:56:55.742644	564	1
659	2025-09-15 17:56:55.742644	36	2
660	2025-09-15 17:56:55.742644	580	1
661	2025-09-15 17:56:55.742644	132	3
662	2025-09-15 17:56:55.742644	520	3
663	2025-09-15 17:56:55.742644	141	1
664	2025-09-15 17:56:55.742644	336	3
665	2025-09-15 17:56:55.742644	557	1
666	2025-09-15 17:56:55.742644	208	2
667	2025-09-15 17:56:55.742644	219	1
668	2025-09-15 17:56:55.742644	81	1
669	2025-09-15 17:56:55.742644	148	2
670	2025-09-15 17:56:55.742644	236	2
671	2025-09-15 17:56:55.742644	477	3
672	2025-09-15 17:56:55.742644	591	1
673	2025-09-15 17:56:55.742644	552	1
674	2025-09-15 17:56:55.742644	393	1
675	2025-09-15 17:56:55.742644	224	3
676	2025-09-15 17:56:55.742644	525	2
677	2025-09-15 17:56:55.742644	115	2
678	2025-09-15 17:56:55.742644	441	1
679	2025-09-15 17:56:55.742644	385	1
680	2025-09-15 17:56:55.742644	567	3
681	2025-09-15 17:56:55.742644	79	1
682	2025-09-15 17:56:55.742644	50	3
683	2025-09-15 17:56:55.742644	521	1
684	2025-09-15 17:56:55.742644	322	2
685	2025-09-15 17:56:55.742644	273	1
686	2025-09-15 17:56:55.742644	323	2
687	2025-09-15 17:56:55.742644	134	1
688	2025-09-15 17:56:55.742644	352	3
689	2025-09-15 17:56:55.742644	574	2
690	2025-09-15 17:56:55.742644	481	1
691	2025-09-15 17:56:55.742644	90	1
692	2025-09-15 17:56:55.742644	342	2
693	2025-09-15 17:56:55.742644	464	3
694	2025-09-15 17:56:55.742644	54	2
695	2025-09-15 17:56:55.742644	502	1
696	2025-09-15 17:56:55.742644	42	1
697	2025-09-15 17:56:55.742644	450	1
698	2025-09-15 17:56:55.742644	192	1
699	2025-09-15 17:56:55.742644	103	2
700	2025-09-15 17:56:55.742644	59	1
701	2025-09-15 17:56:55.742644	395	3
702	2025-09-15 17:56:55.742644	460	3
703	2025-09-15 17:56:55.742644	271	1
704	2025-09-15 17:56:55.742644	69	3
705	2025-09-15 17:56:55.742644	621	1
706	2025-09-15 17:56:55.742644	76	3
707	2025-09-15 17:56:55.742644	406	3
708	2025-09-15 17:56:55.742644	242	2
709	2025-09-15 17:56:55.742644	138	2
710	2025-09-15 17:56:55.742644	517	2
711	2025-09-15 17:56:55.742644	338	1
712	2025-09-15 17:56:55.742644	410	2
713	2025-09-15 17:56:55.742644	16	2
714	2025-09-15 17:56:55.742644	203	3
715	2025-09-15 17:56:55.742644	529	3
716	2025-09-15 17:56:55.742644	190	2
717	2025-09-15 17:56:55.742644	334	3
718	2025-09-15 17:56:55.742644	227	2
719	2025-09-15 17:56:55.742644	171	2
720	2025-09-15 17:56:55.742644	467	2
721	2025-09-15 17:56:55.742644	402	2
722	2025-09-15 17:56:55.742644	539	2
723	2025-09-15 17:56:55.742644	586	3
724	2025-09-15 17:56:55.742644	513	3
725	2025-09-15 17:56:55.742644	51	3
726	2025-09-15 17:56:55.742644	347	2
727	2025-09-15 17:56:55.742644	311	2
728	2025-09-15 17:56:55.742644	380	2
729	2025-09-15 17:56:55.742644	247	2
730	2025-09-15 17:56:55.742644	116	1
731	2025-09-15 17:56:55.742644	350	1
732	2025-09-15 17:56:55.742644	560	3
733	2025-09-15 17:56:55.742644	48	1
734	2025-09-15 17:56:55.742644	616	2
735	2025-09-15 17:56:55.742644	99	1
736	2025-09-15 17:56:55.742644	263	2
737	2025-09-15 17:56:55.742644	7	2
738	2025-09-15 17:56:55.742644	185	3
739	2025-09-15 17:56:55.742644	453	2
740	2025-09-15 17:56:55.742644	144	2
741	2025-09-15 17:56:55.742644	204	1
742	2025-09-15 17:56:55.742644	438	3
743	2025-09-15 17:56:55.742644	362	1
744	2025-09-15 17:56:55.742644	117	3
745	2025-09-15 17:56:55.742644	615	2
746	2025-09-15 17:56:55.742644	313	1
747	2025-09-15 17:56:55.742644	262	1
748	2025-09-15 17:56:55.742644	94	1
749	2025-09-15 17:56:55.742644	28	1
750	2025-09-15 17:56:55.742644	30	1
751	2025-09-15 17:56:55.742644	612	2
752	2025-09-15 17:56:55.742644	328	2
753	2025-09-15 17:56:55.742644	383	2
754	2025-09-15 17:56:55.742644	439	3
755	2025-09-15 17:56:55.742644	162	1
756	2025-09-15 17:56:55.742644	212	2
757	2025-09-15 17:56:55.742644	538	2
758	2025-09-15 17:56:55.742644	585	1
759	2025-09-15 17:56:55.742644	95	1
760	2025-09-15 17:56:55.742644	299	1
761	2025-09-15 17:56:55.742644	356	1
762	2025-09-15 17:56:55.742644	623	1
763	2025-09-15 17:56:55.742644	329	1
764	2025-09-15 17:56:55.742644	553	3
765	2025-09-15 17:56:55.742644	514	1
766	2025-09-15 17:56:55.742644	62	1
767	2025-09-15 17:56:55.742644	283	2
768	2025-09-15 17:56:55.742644	240	2
769	2025-09-15 17:56:55.742644	223	2
770	2025-09-15 17:56:55.742644	122	1
771	2025-09-15 17:56:55.742644	130	2
772	2025-09-15 17:56:55.742644	272	2
773	2025-09-15 17:56:55.742644	180	1
774	2025-09-15 17:56:55.742644	363	3
775	2025-09-15 17:56:55.742644	548	2
776	2025-09-15 17:56:55.742644	231	2
777	2025-09-15 17:56:55.742644	217	2
778	2025-09-15 17:56:55.742644	454	1
779	2025-09-15 17:56:55.742644	349	3
780	2025-09-15 17:56:55.742644	531	1
781	2025-09-15 17:56:55.742644	309	3
782	2025-09-15 17:56:55.742644	545	3
783	2025-09-15 17:56:55.742644	390	1
784	2025-09-15 17:56:55.742644	127	1
785	2025-09-15 17:56:55.742644	118	2
786	2025-09-15 17:56:55.742644	88	2
787	2025-09-15 17:56:55.742644	628	1
788	2025-09-15 17:56:55.742644	487	3
789	2025-09-15 17:56:55.742644	155	3
790	2025-09-15 17:56:55.742644	446	3
791	2025-09-15 17:56:55.742644	195	1
792	2025-09-15 17:56:55.742644	129	1
793	2025-09-15 17:56:55.742644	331	2
794	2025-09-15 17:56:55.742644	409	3
795	2025-09-15 17:56:55.742644	445	2
796	2025-09-15 17:56:55.742644	260	2
797	2025-09-15 17:56:55.742644	605	3
798	2025-09-15 17:56:55.742644	587	3
799	2025-09-15 17:56:55.742644	411	2
800	2025-09-15 17:56:55.742644	9	2
801	2025-09-15 17:56:55.742644	183	2
802	2025-09-15 17:56:55.742644	63	2
803	2025-09-15 17:56:55.742644	483	1
804	2025-09-15 17:56:55.742644	434	3
805	2025-09-15 17:56:55.742644	8	1
806	2025-09-15 17:56:55.742644	417	3
807	2025-09-15 17:56:55.742644	80	1
808	2025-09-15 17:56:55.742644	436	2
809	2025-09-15 17:56:55.742644	305	1
810	2025-09-15 17:56:55.742644	345	2
811	2025-09-15 17:56:55.742644	341	3
812	2025-09-15 17:56:55.742644	179	1
813	2025-09-15 17:56:55.742644	490	2
814	2025-09-15 17:56:55.742644	312	1
815	2025-09-15 17:56:55.742644	286	3
816	2025-09-15 17:56:55.742644	318	1
817	2025-09-15 17:56:55.742644	420	2
818	2025-09-15 17:56:55.742644	150	2
819	2025-09-15 17:56:55.742644	308	2
820	2025-09-15 17:56:55.742644	632	3
821	2025-09-15 17:56:55.742644	551	1
822	2025-09-15 17:56:55.742644	205	3
823	2025-09-15 17:56:55.742644	571	1
824	2025-09-15 17:56:55.742644	542	1
825	2025-09-15 17:56:55.742644	470	1
826	2025-09-15 17:56:55.742644	491	2
827	2025-09-15 17:56:55.742644	527	2
828	2025-09-15 17:56:55.742644	114	3
829	2025-09-15 17:56:55.742644	187	3
830	2025-09-15 17:56:55.742644	447	3
831	2025-09-15 17:56:55.742644	306	2
832	2025-09-15 17:56:55.742644	639	3
833	2025-09-15 17:56:55.742644	197	3
834	2025-09-15 17:56:55.742644	110	1
835	2025-09-15 17:56:55.742644	604	3
836	2025-09-15 17:56:55.742644	173	2
837	2025-09-15 17:56:55.742644	448	2
838	2025-09-15 17:56:55.742644	97	3
839	2025-09-15 17:56:55.742644	622	1
840	2025-09-15 17:56:55.742644	389	3
841	2025-09-15 17:56:55.742644	592	2
842	2025-09-15 17:56:55.742644	370	1
843	2025-09-15 17:56:55.742644	175	1
844	2025-09-15 17:56:55.742644	375	2
845	2025-09-15 17:56:55.742644	188	2
846	2025-09-15 17:56:55.742644	80	3
847	2025-09-15 17:56:55.742644	602	2
848	2025-09-15 17:56:55.742644	35	2
849	2025-09-15 17:56:55.742644	305	3
850	2025-09-15 17:56:55.742644	341	1
851	2025-09-15 17:56:55.742644	179	3
852	2025-09-15 17:56:55.742644	503	2
853	2025-09-15 17:56:55.742644	286	1
854	2025-09-15 17:56:55.742644	312	3
855	2025-09-15 17:56:55.742644	318	3
856	2025-09-15 17:56:55.742644	551	3
857	2025-09-15 17:56:55.742644	632	1
858	2025-09-15 17:56:55.742644	161	2
859	2025-09-15 17:56:55.742644	446	1
860	2025-09-15 17:56:55.742644	155	1
861	2025-09-15 17:56:55.742644	409	1
862	2025-09-15 17:56:55.742644	129	3
863	2025-09-15 17:56:55.742644	195	3
864	2025-09-15 17:56:55.742644	210	2
865	2025-09-15 17:56:55.742644	605	1
866	2025-09-15 17:56:55.742644	587	1
867	2025-09-15 17:56:55.742644	154	2
868	2025-09-15 17:56:55.742644	483	3
869	2025-09-15 17:56:55.742644	584	2
870	2025-09-15 17:56:55.742644	417	1
871	2025-09-15 17:56:55.742644	8	3
872	2025-09-15 17:56:55.742644	157	2
873	2025-09-15 17:56:55.742644	434	1
874	2025-09-15 17:56:55.742644	110	3
875	2025-09-15 17:56:55.742644	147	2
876	2025-09-15 17:56:55.742644	604	1
877	2025-09-15 17:56:55.742644	97	1
878	2025-09-15 17:56:55.742644	622	3
879	2025-09-15 17:56:55.742644	121	2
880	2025-09-15 17:56:55.742644	389	1
881	2025-09-15 17:56:55.742644	634	2
882	2025-09-15 17:56:55.742644	175	3
883	2025-09-15 17:56:55.742644	370	3
884	2025-09-15 17:56:55.742644	476	2
885	2025-09-15 17:56:55.742644	571	3
886	2025-09-15 17:56:55.742644	205	1
887	2025-09-15 17:56:55.742644	542	3
888	2025-09-15 17:56:55.742644	470	3
889	2025-09-15 17:56:55.742644	598	2
890	2025-09-15 17:56:55.742644	344	2
891	2025-09-15 17:56:55.742644	14	2
892	2025-09-15 17:56:55.742644	114	1
893	2025-09-15 17:56:55.742644	472	2
894	2025-09-15 17:56:55.742644	447	1
895	2025-09-15 17:56:55.742644	187	1
896	2025-09-15 17:56:55.742644	639	1
897	2025-09-15 17:56:55.742644	197	1
898	2025-09-15 17:56:55.742644	30	3
899	2025-09-15 17:56:55.742644	162	3
900	2025-09-15 17:56:55.742644	176	2
901	2025-09-15 17:56:55.742644	439	1
902	2025-09-15 17:56:55.742644	61	2
903	2025-09-15 17:56:55.742644	597	2
904	2025-09-15 17:56:55.742644	201	2
905	2025-09-15 17:56:55.742644	169	2
906	2025-09-15 17:56:55.742644	388	2
907	2025-09-15 17:56:55.742644	95	3
908	2025-09-15 17:56:55.742644	585	3
909	2025-09-15 17:56:55.742644	87	2
910	2025-09-15 17:56:55.742644	299	3
911	2025-09-15 17:56:55.742644	356	3
912	2025-09-15 17:56:55.742644	48	3
913	2025-09-15 17:56:55.742644	522	2
914	2025-09-15 17:56:55.742644	560	1
915	2025-09-15 17:56:55.742644	99	3
916	2025-09-15 17:56:55.742644	185	1
917	2025-09-15 17:56:55.742644	3	2
918	2025-09-15 17:56:55.742644	431	2
919	2025-09-15 17:56:55.742644	362	3
920	2025-09-15 17:56:55.742644	438	1
921	2025-09-15 17:56:55.742644	204	3
922	2025-09-15 17:56:55.742644	313	3
923	2025-09-15 17:56:55.742644	262	3
924	2025-09-15 17:56:55.742644	94	3
925	2025-09-15 17:56:55.742644	423	2
926	2025-09-15 17:56:55.742644	117	1
927	2025-09-15 17:56:55.742644	28	3
928	2025-09-15 17:56:55.742644	291	2
929	2025-09-15 17:56:55.742644	545	1
930	2025-09-15 17:56:55.742644	166	2
931	2025-09-15 17:56:55.742644	573	2
932	2025-09-15 17:56:55.742644	127	3
933	2025-09-15 17:56:55.742644	390	3
934	2025-09-15 17:56:55.742644	259	2
935	2025-09-15 17:56:55.742644	628	3
936	2025-09-15 17:56:55.742644	487	1
937	2025-09-15 17:56:55.742644	553	1
938	2025-09-15 17:56:55.742644	329	3
939	2025-09-15 17:56:55.742644	623	3
940	2025-09-15 17:56:55.742644	62	3
941	2025-09-15 17:56:55.742644	514	3
942	2025-09-15 17:56:55.742644	43	2
943	2025-09-15 17:56:55.742644	122	3
944	2025-09-15 17:56:55.742644	363	1
945	2025-09-15 17:56:55.742644	180	3
946	2025-09-15 17:56:55.742644	349	1
947	2025-09-15 17:56:55.742644	482	2
948	2025-09-15 17:56:55.742644	454	3
949	2025-09-15 17:56:55.742644	531	3
950	2025-09-15 17:56:55.742644	220	2
951	2025-09-15 17:56:55.742644	309	1
952	2025-09-15 17:56:55.742644	107	1
953	2025-09-15 17:56:55.742644	326	3
954	2025-09-15 17:56:55.742644	335	2
955	2025-09-15 17:56:55.742644	396	1
956	2025-09-15 17:56:55.742644	164	3
957	2025-09-15 17:56:55.742644	319	1
958	2025-09-15 17:56:55.742644	555	2
959	2025-09-15 17:56:55.742644	541	2
960	2025-09-15 17:56:55.742644	600	1
961	2025-09-15 17:56:55.742644	278	3
962	2025-09-15 17:56:55.742644	78	3
963	2025-09-15 17:56:55.742644	493	1
964	2025-09-15 17:56:55.742644	435	1
965	2025-09-15 17:56:55.742644	32	3
966	2025-09-15 17:56:55.742644	421	3
967	2025-09-15 17:56:55.742644	221	1
968	2025-09-15 17:56:55.742644	530	1
969	2025-09-15 17:56:55.742644	85	3
970	2025-09-15 17:56:55.742644	576	1
971	2025-09-15 17:56:55.742644	382	2
972	2025-09-15 17:56:55.742644	307	2
973	2025-09-15 17:56:55.742644	358	3
974	2025-09-15 17:56:55.742644	546	3
975	2025-09-15 17:56:55.742644	93	2
976	2025-09-15 17:56:55.742644	149	2
977	2025-09-15 17:56:55.742644	158	3
978	2025-09-15 17:56:55.742644	449	2
979	2025-09-15 17:56:55.742644	258	1
980	2025-09-15 17:56:55.742644	414	2
981	2025-09-15 17:56:55.742644	427	3
982	2025-09-15 17:56:55.742644	232	3
983	2025-09-15 17:56:55.742644	24	3
984	2025-09-15 17:56:55.742644	215	1
985	2025-09-15 17:56:55.742644	184	3
986	2025-09-15 17:56:55.742644	377	3
987	2025-09-15 17:56:55.742644	108	1
988	2025-09-15 17:56:55.742644	172	3
989	2025-09-15 17:56:55.742644	589	1
990	2025-09-15 17:56:55.742644	398	1
991	2025-09-15 17:56:55.742644	19	1
992	2025-09-15 17:56:55.742644	113	3
993	2025-09-15 17:56:55.742644	27	2
994	2025-09-15 17:56:55.742644	635	1
995	2025-09-15 17:56:55.742644	366	1
996	2025-09-15 17:56:55.742644	317	1
997	2025-09-15 17:56:55.742644	279	3
998	2025-09-15 17:56:55.742644	52	1
999	2025-09-15 17:56:55.742644	133	3
1000	2025-09-15 17:56:55.742644	289	3
1001	2025-09-15 17:56:55.742644	637	3
1002	2025-09-15 17:56:55.742644	238	2
1003	2025-09-15 17:56:55.742644	603	3
1004	2025-09-15 17:56:55.742644	65	1
1005	2025-09-15 17:56:55.742644	492	3
1006	2025-09-15 17:56:55.742644	416	3
1007	2025-09-15 17:56:55.742644	37	1
1008	2025-09-15 17:56:55.742644	230	2
1009	2025-09-15 17:56:55.742644	638	3
1010	2025-09-15 17:56:55.742644	443	3
1011	2025-09-15 17:56:55.742644	440	1
1012	2025-09-15 17:56:55.742644	100	3
1013	2025-09-15 17:56:55.742644	300	3
1014	2025-09-15 17:56:55.742644	218	2
1015	2025-09-15 17:56:55.742644	196	2
1016	2025-09-15 17:56:55.742644	593	1
1017	2025-09-15 17:56:55.742644	128	3
1018	2025-09-15 17:56:55.742644	38	3
1019	2025-09-15 17:56:55.742644	456	3
1020	2025-09-15 17:56:55.742644	565	3
1021	2025-09-15 17:56:55.742644	340	1
1022	2025-09-15 17:56:55.742644	367	1
1023	2025-09-15 17:56:55.742644	373	2
1024	2025-09-15 17:56:55.742644	498	1
1025	2025-09-15 17:56:55.742644	55	3
1026	2025-09-15 17:56:55.742644	392	1
1027	2025-09-15 17:56:55.742644	494	3
1028	2025-09-15 17:56:55.742644	170	3
1029	2025-09-15 17:56:55.742644	403	3
1030	2025-09-15 17:56:55.742644	405	2
1031	2025-09-15 17:56:55.742644	379	2
1032	2025-09-15 17:56:55.742644	136	2
1033	2025-09-15 17:56:55.742644	244	3
1034	2025-09-15 17:56:55.742644	168	2
1035	2025-09-15 17:56:55.742644	535	3
1036	2025-09-15 17:56:55.742644	609	1
1037	2025-09-15 17:56:55.742644	298	1
1038	2025-09-15 17:56:55.742644	374	3
1039	2025-09-15 17:56:55.742644	68	3
1040	2025-09-15 17:56:55.742644	292	2
1041	2025-09-15 17:56:55.742644	432	1
1042	2025-09-15 17:56:55.742644	202	3
1043	2025-09-15 17:56:55.742644	519	1
1044	2025-09-15 17:56:55.742644	137	2
1045	2025-09-15 17:56:55.742644	216	3
1046	2025-09-15 17:56:55.742644	429	1
1047	2025-09-15 17:56:55.742644	26	2
1048	2025-09-15 17:56:55.742644	213	2
1049	2025-09-15 17:56:55.742644	265	2
1050	2025-09-15 17:56:55.742644	254	1
1051	2025-09-15 17:56:55.742644	625	1
1052	2025-09-15 17:56:55.742644	112	1
1053	2025-09-15 17:56:55.742644	266	3
1054	2025-09-15 17:56:55.742644	25	2
1055	2025-09-15 17:56:55.742644	96	1
1056	2025-09-15 17:56:55.742644	353	3
1057	2025-09-15 17:56:55.742644	82	2
1058	2025-09-15 17:56:55.742644	256	3
1059	2025-09-15 17:56:55.742644	581	1
1060	2025-09-15 17:56:55.742644	359	2
1061	2025-09-15 17:56:55.742644	20	2
1062	2025-09-15 17:56:55.742644	55	1
1063	2025-09-15 17:56:55.742644	339	2
1064	2025-09-15 17:56:55.742644	392	3
1065	2025-09-15 17:56:55.742644	101	2
1066	2025-09-15 17:56:55.742644	494	1
1067	2025-09-15 17:56:55.742644	397	2
1068	2025-09-15 17:56:55.742644	403	1
1069	2025-09-15 17:56:55.742644	170	1
1070	2025-09-15 17:56:55.742644	244	1
1071	2025-09-15 17:56:55.742644	298	3
1072	2025-09-15 17:56:55.742644	609	3
1073	2025-09-15 17:56:55.742644	535	1
1074	2025-09-15 17:56:55.742644	330	2
1075	2025-09-15 17:56:55.742644	486	2
1076	2025-09-15 17:56:55.742644	68	1
1077	2025-09-15 17:56:55.742644	374	1
1078	2025-09-15 17:56:55.742644	518	2
1079	2025-09-15 17:56:55.742644	620	2
1080	2025-09-15 17:56:55.742644	300	1
1081	2025-09-15 17:56:55.742644	456	1
1082	2025-09-15 17:56:55.742644	128	1
1083	2025-09-15 17:56:55.742644	38	1
1084	2025-09-15 17:56:55.742644	437	2
1085	2025-09-15 17:56:55.742644	593	3
1086	2025-09-15 17:56:55.742644	340	3
1087	2025-09-15 17:56:55.742644	565	1
1088	2025-09-15 17:56:55.742644	310	2
1089	2025-09-15 17:56:55.742644	214	2
1090	2025-09-15 17:56:55.742644	367	3
1091	2025-09-15 17:56:55.742644	498	3
1092	2025-09-15 17:56:55.742644	549	2
1093	2025-09-15 17:56:55.742644	268	2
1094	2025-09-15 17:56:55.742644	96	3
1095	2025-09-15 17:56:55.742644	253	2
1096	2025-09-15 17:56:55.742644	353	1
1097	2025-09-15 17:56:55.742644	384	2
1098	2025-09-15 17:56:55.742644	151	2
1099	2025-09-15 17:56:55.742644	256	1
1100	2025-09-15 17:56:55.742644	270	2
1101	2025-09-15 17:56:55.742644	581	3
1102	2025-09-15 17:56:55.742644	399	2
1103	2025-09-15 17:56:55.742644	119	2
1104	2025-09-15 17:56:55.742644	202	1
1105	2025-09-15 17:56:55.742644	432	3
1106	2025-09-15 17:56:55.742644	519	3
1107	2025-09-15 17:56:55.742644	216	1
1108	2025-09-15 17:56:55.742644	429	3
1109	2025-09-15 17:56:55.742644	112	3
1110	2025-09-15 17:56:55.742644	625	3
1111	2025-09-15 17:56:55.742644	254	3
1112	2025-09-15 17:56:55.742644	266	1
1113	2025-09-15 17:56:55.742644	421	1
1114	2025-09-15 17:56:55.742644	32	1
1115	2025-09-15 17:56:55.742644	435	3
1116	2025-09-15 17:56:55.742644	221	3
1117	2025-09-15 17:56:55.742644	606	2
1118	2025-09-15 17:56:55.742644	577	2
1119	2025-09-15 17:56:55.742644	85	1
1120	2025-09-15 17:56:55.742644	276	2
1121	2025-09-15 17:56:55.742644	530	3
1122	2025-09-15 17:56:55.742644	576	3
1123	2025-09-15 17:56:55.742644	358	1
1124	2025-09-15 17:56:55.742644	599	2
1125	2025-09-15 17:56:55.742644	546	1
1126	2025-09-15 17:56:55.742644	550	2
1127	2025-09-15 17:56:55.742644	107	3
1128	2025-09-15 17:56:55.742644	326	1
1129	2025-09-15 17:56:55.742644	396	3
1130	2025-09-15 17:56:55.742644	455	2
1131	2025-09-15 17:56:55.742644	496	2
1132	2025-09-15 17:56:55.742644	164	1
1133	2025-09-15 17:56:55.742644	319	3
1134	2025-09-15 17:56:55.742644	209	2
1135	2025-09-15 17:56:55.742644	278	1
1136	2025-09-15 17:56:55.742644	600	3
1137	2025-09-15 17:56:55.742644	78	1
1138	2025-09-15 17:56:55.742644	630	2
1139	2025-09-15 17:56:55.742644	493	3
1140	2025-09-15 17:56:55.742644	279	1
1141	2025-09-15 17:56:55.742644	317	3
1142	2025-09-15 17:56:55.742644	635	3
1143	2025-09-15 17:56:55.742644	366	3
1144	2025-09-15 17:56:55.742644	637	1
1145	2025-09-15 17:56:55.742644	289	1
1146	2025-09-15 17:56:55.742644	133	1
1147	2025-09-15 17:56:55.742644	52	3
1148	2025-09-15 17:56:55.742644	65	3
1149	2025-09-15 17:56:55.742644	497	2
1150	2025-09-15 17:56:55.742644	603	1
1151	2025-09-15 17:56:55.742644	638	1
1152	2025-09-15 17:56:55.742644	37	3
1153	2025-09-15 17:56:55.742644	452	2
1154	2025-09-15 17:56:55.742644	492	1
1155	2025-09-15 17:56:55.742644	416	1
1156	2025-09-15 17:56:55.742644	443	1
1157	2025-09-15 17:56:55.742644	100	1
1158	2025-09-15 17:56:55.742644	440	3
1159	2025-09-15 17:56:55.742644	158	1
1160	2025-09-15 17:56:55.742644	258	3
1161	2025-09-15 17:56:55.742644	120	2
1162	2025-09-15 17:56:55.742644	285	2
1163	2025-09-15 17:56:55.742644	427	1
1164	2025-09-15 17:56:55.742644	106	2
1165	2025-09-15 17:56:55.742644	232	1
1166	2025-09-15 17:56:55.742644	251	2
1167	2025-09-15 17:56:55.742644	184	1
1168	2025-09-15 17:56:55.742644	215	3
1169	2025-09-15 17:56:55.742644	24	1
1170	2025-09-15 17:56:55.742644	601	2
1171	2025-09-15 17:56:55.742644	264	2
1172	2025-09-15 17:56:55.742644	377	1
1173	2025-09-15 17:56:55.742644	113	1
1174	2025-09-15 17:56:55.742644	19	3
1175	2025-09-15 17:56:55.742644	589	3
1176	2025-09-15 17:56:55.742644	398	3
1177	2025-09-15 17:56:55.742644	172	1
1178	2025-09-15 17:56:55.742644	108	3
1179	2025-09-15 17:56:55.742644	626	2
1180	2025-09-15 17:56:55.742644	569	3
1181	2025-09-15 17:56:55.742644	177	2
1182	2025-09-15 17:56:55.742644	46	1
1183	2025-09-15 17:56:55.742644	189	3
1184	2025-09-15 17:56:55.742644	186	2
1185	2025-09-15 17:56:55.742644	211	1
1186	2025-09-15 17:56:55.742644	234	2
1187	2025-09-15 17:56:55.742644	624	2
1188	2025-09-15 17:56:55.742644	596	3
1189	2025-09-15 17:56:55.742644	361	1
1190	2025-09-15 17:56:55.742644	304	1
1191	2025-09-15 17:56:55.742644	15	1
1192	2025-09-15 17:56:55.742644	507	3
1193	2025-09-15 17:56:55.742644	83	1
1194	2025-09-15 17:56:55.742644	404	3
1195	2025-09-15 17:56:55.742644	71	2
1196	2025-09-15 17:56:55.742644	533	2
1197	2025-09-15 17:56:55.742644	474	1
1198	2025-09-15 17:56:55.742644	333	3
1199	2025-09-15 17:56:55.742644	575	3
1200	2025-09-15 17:56:55.742644	140	1
1201	2025-09-15 17:56:55.742644	315	2
1202	2025-09-15 17:56:55.742644	468	3
1203	2025-09-15 17:56:55.742644	102	2
1204	2025-09-15 17:56:55.742644	125	1
1205	2025-09-15 17:56:55.742644	77	1
1206	2025-09-15 17:56:55.742644	72	2
1207	2025-09-15 17:56:55.742644	631	1
1208	2025-09-15 17:56:55.742644	73	1
1209	2025-09-15 17:56:55.742644	343	2
1210	2025-09-15 17:56:55.742644	2	2
1211	2025-09-15 17:56:55.742644	484	3
1212	2025-09-15 17:56:55.742644	153	1
1213	2025-09-15 17:56:55.742644	588	2
1214	2025-09-15 17:56:55.742644	579	1
1215	2025-09-15 17:56:55.742644	458	2
1216	2025-09-15 17:56:55.742644	590	1
1217	2025-09-15 17:56:55.742644	500	3
1218	2025-09-15 17:56:55.742644	226	3
1219	2025-09-15 17:56:55.742644	582	2
1220	2025-09-15 17:56:55.742644	355	1
1221	2025-09-15 17:56:55.742644	56	1
1222	2025-09-15 17:56:55.742644	376	3
1223	2025-09-15 17:56:55.742644	182	1
1224	2025-09-15 17:56:55.742644	40	1
1225	2025-09-15 17:56:55.742644	91	3
1226	2025-09-15 17:56:55.742644	413	2
1227	2025-09-15 17:56:55.742644	163	2
1228	2025-09-15 17:56:55.742644	104	2
1229	2025-09-15 17:56:55.742644	629	2
1230	2025-09-15 17:56:55.742644	566	3
1231	2025-09-15 17:56:55.742644	515	3
1232	2025-09-15 17:56:55.742644	261	1
1233	2025-09-15 17:56:55.742644	123	1
1234	2025-09-15 17:56:55.742644	198	2
1235	2025-09-15 17:56:55.742644	277	1
1237	2025-09-15 17:56:55.742644	485	3
1238	2025-09-15 17:56:55.742644	348	1
1239	2025-09-15 17:56:55.742644	478	2
1240	2025-09-15 17:56:55.742644	547	3
1241	2025-09-15 17:56:55.742644	64	2
1242	2025-09-15 17:56:55.742644	233	3
1243	2025-09-15 17:56:55.742644	145	2
1244	2025-09-15 17:56:55.742644	556	3
1245	2025-09-15 17:56:55.742644	332	1
1246	2025-09-15 17:56:55.742644	578	3
1247	2025-09-15 17:56:55.742644	337	1
1248	2025-09-15 17:56:55.742644	250	2
1249	2025-09-15 17:56:55.742644	167	2
1250	2025-09-15 17:56:55.742644	480	1
1251	2025-09-15 17:56:55.742644	543	3
1252	2025-09-15 17:56:55.742644	346	1
1253	2025-09-15 17:56:55.742644	293	3
1254	2025-09-15 17:56:55.742644	303	3
1255	2025-09-15 17:56:55.742644	617	2
1256	2025-09-15 17:56:55.742644	540	3
1257	2025-09-15 17:56:55.742644	532	3
1258	2025-09-15 17:56:55.742644	280	1
1259	2025-09-15 17:56:55.742644	610	3
1260	2025-09-15 17:56:55.742644	365	3
1261	2025-09-15 17:56:55.742644	297	1
1262	2025-09-15 17:56:55.742644	381	2
1263	2025-09-15 17:56:55.742644	193	2
1264	2025-09-15 17:56:55.742644	424	2
1265	2025-09-15 17:56:55.742644	98	2
1266	2025-09-15 17:56:55.742644	594	2
1267	2025-09-15 17:56:55.742644	243	2
1268	2025-09-15 17:56:55.742644	627	1
1269	2025-09-15 17:56:55.742644	314	1
1270	2025-09-15 17:56:55.742644	433	3
1271	2025-09-15 17:56:55.742644	466	2
1272	2025-09-15 17:56:55.742644	459	1
1273	2025-09-15 17:56:55.742644	419	1
1274	2025-09-15 17:56:55.742644	408	2
1275	2025-09-15 17:56:55.742644	18	2
1276	2025-09-15 17:56:55.742644	473	1
1277	2025-09-15 17:56:55.742644	570	3
1278	2025-09-15 17:56:55.742644	401	3
1279	2025-09-15 17:56:55.742644	636	1
1280	2025-09-15 17:56:55.742644	536	3
1281	2025-09-15 17:56:55.742644	475	3
1282	2025-09-15 17:56:55.742644	400	1
1283	2025-09-15 17:56:55.742644	274	1
1284	2025-09-15 17:56:55.742644	391	1
1285	2025-09-15 17:56:55.742644	444	1
1286	2025-09-15 17:56:55.742644	152	3
1287	2025-09-15 17:56:55.742644	324	2
1288	2025-09-15 17:56:55.742644	47	1
1289	2025-09-15 17:56:55.742644	181	3
1290	2025-09-15 17:56:55.742644	143	2
1291	2025-09-15 17:56:55.742644	412	1
1292	2025-09-15 17:56:55.742644	499	3
1293	2025-09-15 17:56:55.742644	426	1
1294	2025-09-15 17:56:55.742644	461	3
1295	2025-09-15 17:56:55.742644	595	1
1296	2025-09-15 17:56:55.742644	320	1
1297	2025-09-15 17:56:55.742644	301	3
1298	2025-09-15 17:56:55.742644	146	2
1299	2025-09-15 17:56:55.742644	139	2
1300	2025-09-15 17:56:55.742644	614	2
1301	2025-09-15 17:56:55.742644	5	3
1302	2025-09-15 17:56:55.742644	281	3
1303	2025-09-15 17:56:55.742644	462	3
1304	2025-09-15 17:56:55.742644	34	2
1305	2025-09-15 17:56:55.742644	505	2
1306	2025-09-15 17:56:55.742644	287	3
1307	2025-09-15 17:56:55.742644	165	3
1308	2025-09-15 17:56:55.742644	428	2
1309	2025-09-15 17:56:55.742644	10	2
1310	2025-09-15 17:56:55.742644	321	2
1311	2025-09-15 17:56:55.742644	282	2
1312	2025-09-15 17:56:55.742644	21	3
1313	2025-09-15 17:56:55.742644	12	2
1314	2025-09-15 17:56:55.742644	296	2
1315	2025-09-15 17:56:55.742644	524	2
1316	2025-09-15 17:56:55.742644	297	3
1317	2025-09-15 17:56:55.742644	288	2
1318	2025-09-15 17:56:55.742644	31	2
1319	2025-09-15 17:56:55.742644	239	2
1320	2025-09-15 17:56:55.742644	627	3
1321	2025-09-15 17:56:55.742644	433	1
1322	2025-09-15 17:56:55.742644	314	3
1323	2025-09-15 17:56:55.742644	459	3
1324	2025-09-15 17:56:55.742644	419	3
1325	2025-09-15 17:56:55.742644	337	3
1326	2025-09-15 17:56:55.742644	543	1
1327	2025-09-15 17:56:55.742644	480	3
1328	2025-09-15 17:56:55.742644	293	1
1329	2025-09-15 17:56:55.742644	346	3
1330	2025-09-15 17:56:55.742644	540	1
1331	2025-09-15 17:56:55.742644	303	1
1332	2025-09-15 17:56:55.742644	633	2
1333	2025-09-15 17:56:55.742644	532	1
1334	2025-09-15 17:56:55.742644	57	2
1335	2025-09-15 17:56:55.742644	610	1
1336	2025-09-15 17:56:55.742644	365	1
1337	2025-09-15 17:56:55.742644	280	3
1338	2025-09-15 17:56:55.742644	109	2
1339	2025-09-15 17:56:55.742644	442	2
1340	2025-09-15 17:56:55.742644	160	2
1341	2025-09-15 17:56:55.742644	89	2
1342	2025-09-15 17:56:55.742644	640	2
1343	2025-09-15 17:56:55.742644	479	2
1344	2025-09-15 17:56:55.742644	66	2
1345	2025-09-15 17:56:55.742644	165	1
1346	2025-09-15 17:56:55.742644	142	2
1347	2025-09-15 17:56:55.742644	287	1
1348	2025-09-15 17:56:55.742644	563	2
1349	2025-09-15 17:56:55.742644	512	2
1350	2025-09-15 17:56:55.742644	33	2
1351	2025-09-15 17:56:55.742644	21	1
1352	2025-09-15 17:56:55.742644	504	2
1353	2025-09-15 17:56:55.742644	284	2
1354	2025-09-15 17:56:55.742644	636	3
1355	2025-09-15 17:56:55.742644	570	1
1356	2025-09-15 17:56:55.742644	401	1
1357	2025-09-15 17:56:55.742644	465	2
1358	2025-09-15 17:56:55.742644	473	3
1359	2025-09-15 17:56:55.742644	536	1
1360	2025-09-15 17:56:55.742644	475	1
1361	2025-09-15 17:56:55.742644	357	2
1362	2025-09-15 17:56:55.742644	241	2
1363	2025-09-15 17:56:55.742644	274	3
1364	2025-09-15 17:56:55.742644	400	3
1365	2025-09-15 17:56:55.742644	255	2
1366	2025-09-15 17:56:55.742644	152	1
1367	2025-09-15 17:56:55.742644	444	3
1368	2025-09-15 17:56:55.742644	471	2
1369	2025-09-15 17:56:55.742644	391	3
1370	2025-09-15 17:56:55.742644	499	1
1371	2025-09-15 17:56:55.742644	412	3
1372	2025-09-15 17:56:55.742644	181	1
1373	2025-09-15 17:56:55.742644	47	3
1374	2025-09-15 17:56:55.742644	595	3
1375	2025-09-15 17:56:55.742644	461	1
1376	2025-09-15 17:56:55.742644	426	3
1377	2025-09-15 17:56:55.742644	301	1
1378	2025-09-15 17:56:55.742644	320	3
1379	2025-09-15 17:56:55.742644	462	1
1380	2025-09-15 17:56:55.742644	281	1
1381	2025-09-15 17:56:55.742644	325	2
1382	2025-09-15 17:56:55.742644	17	2
1383	2025-09-15 17:56:55.742644	5	1
1384	2025-09-15 17:56:55.742644	575	1
1385	2025-09-15 17:56:55.742644	333	1
1386	2025-09-15 17:56:55.742644	474	3
1387	2025-09-15 17:56:55.742644	468	1
1388	2025-09-15 17:56:55.742644	140	3
1389	2025-09-15 17:56:55.742644	77	3
1390	2025-09-15 17:56:55.742644	125	3
1391	2025-09-15 17:56:55.742644	73	3
1392	2025-09-15 17:56:55.742644	631	3
1393	2025-09-15 17:56:55.742644	484	1
1394	2025-09-15 17:56:55.742644	178	2
1395	2025-09-15 17:56:55.742644	153	3
1396	2025-09-15 17:56:55.742644	569	1
1397	2025-09-15 17:56:55.742644	46	3
1398	2025-09-15 17:56:55.742644	211	3
1399	2025-09-15 17:56:55.742644	189	1
1400	2025-09-15 17:56:55.742644	537	2
1401	2025-09-15 17:56:55.742644	131	2
1402	2025-09-15 17:56:55.742644	361	3
1403	2025-09-15 17:56:55.742644	596	1
1405	2025-09-15 17:56:55.742644	304	3
1406	2025-09-15 17:56:55.742644	559	2
1407	2025-09-15 17:56:55.742644	507	1
1408	2025-09-15 17:56:55.742644	489	2
1409	2025-09-15 17:56:55.742644	404	1
1410	2025-09-15 17:56:55.742644	508	2
1411	2025-09-15 17:56:55.742644	83	3
1412	2025-09-15 17:56:55.742644	526	2
1413	2025-09-15 17:56:55.742644	485	1
1414	2025-09-15 17:56:55.742644	348	3
1415	2025-09-15 17:56:55.742644	11	2
1416	2025-09-15 17:56:55.742644	233	1
1417	2025-09-15 17:56:55.742644	547	1
1418	2025-09-15 17:56:55.742644	295	2
1419	2025-09-15 17:56:55.742644	39	2
1420	2025-09-15 17:56:55.742644	556	1
1421	2025-09-15 17:56:55.742644	332	3
1422	2025-09-15 17:56:55.742644	523	2
1423	2025-09-15 17:56:55.742644	252	2
1424	2025-09-15 17:56:55.742644	135	2
1425	2025-09-15 17:56:55.742644	578	1
1426	2025-09-15 17:56:55.742644	228	2
1427	2025-09-15 17:56:55.742644	579	3
1428	2025-09-15 17:56:55.742644	500	1
1429	2025-09-15 17:56:55.742644	590	3
1430	2025-09-15 17:56:55.742644	355	3
1431	2025-09-15 17:56:55.742644	226	1
1432	2025-09-15 17:56:55.742644	554	2
1433	2025-09-15 17:56:55.742644	182	3
1434	2025-09-15 17:56:55.742644	40	3
1435	2025-09-15 17:56:55.742644	376	1
1436	2025-09-15 17:56:55.742644	56	3
1437	2025-09-15 17:56:55.742644	91	1
1438	2025-09-15 17:56:55.742644	566	1
1439	2025-09-15 17:56:55.742644	515	1
1440	2025-09-15 17:56:55.742644	261	3
1441	2025-09-15 17:56:55.742644	123	3
1442	2025-09-15 17:56:55.742644	13	1
1443	2025-09-15 17:56:55.742644	277	3
1444	2025-09-15 17:56:55.742644	191	2
1445	2025-09-15 17:56:55.742644	465	1
1446	2025-09-15 17:56:55.742644	18	3
1447	2025-09-15 17:56:55.742644	570	2
1448	2025-09-15 17:56:55.742644	401	2
1449	2025-09-15 17:56:55.742644	357	1
1450	2025-09-15 17:56:55.742644	241	1
1451	2025-09-15 17:56:55.742644	536	2
1452	2025-09-15 17:56:55.742644	475	2
1453	2025-09-15 17:56:55.742644	255	1
1454	2025-09-15 17:56:55.742644	152	2
1455	2025-09-15 17:56:55.742644	324	3
1456	2025-09-15 17:56:55.742644	471	1
1457	2025-09-15 17:56:55.742644	143	3
1458	2025-09-15 17:56:55.742644	499	2
1459	2025-09-15 17:56:55.742644	181	2
1460	2025-09-15 17:56:55.742644	461	2
1461	2025-09-15 17:56:55.742644	146	3
1462	2025-09-15 17:56:55.742644	139	3
1463	2025-09-15 17:56:55.742644	614	3
1464	2025-09-15 17:56:55.742644	301	2
1465	2025-09-15 17:56:55.742644	325	1
1466	2025-09-15 17:56:55.742644	462	2
1467	2025-09-15 17:56:55.742644	281	2
1468	2025-09-15 17:56:55.742644	5	2
1469	2025-09-15 17:56:55.742644	17	1
1470	2025-09-15 17:56:55.742644	160	1
1471	2025-09-15 17:56:55.742644	640	1
1472	2025-09-15 17:56:55.742644	89	1
1473	2025-09-15 17:56:55.742644	479	1
1474	2025-09-15 17:56:55.742644	505	3
1475	2025-09-15 17:56:55.742644	34	3
1476	2025-09-15 17:56:55.742644	165	2
1477	2025-09-15 17:56:55.742644	66	1
1478	2025-09-15 17:56:55.742644	563	1
1479	2025-09-15 17:56:55.742644	142	1
1480	2025-09-15 17:56:55.742644	287	2
1481	2025-09-15 17:56:55.742644	512	1
1482	2025-09-15 17:56:55.742644	321	3
1484	2025-09-15 17:56:55.742644	33	1
1485	2025-09-15 17:56:55.742644	428	3
1486	2025-09-15 17:56:55.742644	21	2
1487	2025-09-15 17:56:55.742644	282	3
1488	2025-09-15 17:56:55.742644	504	1
1489	2025-09-15 17:56:55.742644	284	1
1490	2025-09-15 17:56:55.742644	296	3
1492	2025-09-15 17:56:55.742644	250	3
1493	2025-09-15 17:56:55.742644	543	2
1494	2025-09-15 17:56:55.742644	167	3
1495	2025-09-15 17:56:55.742644	293	2
1496	2025-09-15 17:56:55.742644	540	2
1497	2025-09-15 17:56:55.742644	617	3
1498	2025-09-15 17:56:55.742644	633	1
1499	2025-09-15 17:56:55.742644	303	2
1500	2025-09-15 17:56:55.742644	532	2
1501	2025-09-15 17:56:55.742644	57	1
1502	2025-09-15 17:56:55.742644	610	2
1503	2025-09-15 17:56:55.742644	365	2
1504	2025-09-15 17:56:55.742644	109	1
1505	2025-09-15 17:56:55.742644	442	1
1506	2025-09-15 17:56:55.742644	524	1
1507	2025-09-15 17:56:55.742644	193	3
1508	2025-09-15 17:56:55.742644	381	3
1509	2025-09-15 17:56:55.742644	288	1
1510	2025-09-15 17:56:55.742644	98	3
1511	2025-09-15 17:56:55.742644	594	3
1512	2025-09-15 17:56:55.742644	31	1
1513	2025-09-15 17:56:55.742644	424	3
1514	2025-09-15 17:56:55.742644	239	1
1515	2025-09-15 17:56:55.742644	243	3
1516	2025-09-15 17:56:55.742644	466	3
1517	2025-09-15 17:56:55.742644	433	2
1518	2025-09-15 17:56:55.742644	408	3
1519	2025-09-15 17:56:55.742644	458	3
1520	2025-09-15 17:56:55.742644	500	2
1521	2025-09-15 17:56:55.742644	554	1
1522	2025-09-15 17:56:55.742644	226	2
1523	2025-09-15 17:56:55.742644	582	3
1524	2025-09-15 17:56:55.742644	376	2
1525	2025-09-15 17:56:55.742644	163	3
1526	2025-09-15 17:56:55.742644	91	2
1527	2025-09-15 17:56:55.742644	413	3
1528	2025-09-15 17:56:55.742644	104	3
1529	2025-09-15 17:56:55.742644	566	2
1530	2025-09-15 17:56:55.742644	515	2
1531	2025-09-15 17:56:55.742644	629	3
1532	2025-09-15 17:56:55.742644	198	3
1533	2025-09-15 17:56:55.742644	13	2
1534	2025-09-15 17:56:55.742644	191	1
1535	2025-09-15 17:56:55.742644	485	2
1536	2025-09-15 17:56:55.742644	11	1
1537	2025-09-15 17:56:55.742644	478	3
1538	2025-09-15 17:56:55.742644	64	3
1539	2025-09-15 17:56:55.742644	233	2
1540	2025-09-15 17:56:55.742644	295	1
1541	2025-09-15 17:56:55.742644	547	2
1542	2025-09-15 17:56:55.742644	39	1
1543	2025-09-15 17:56:55.742644	145	3
1544	2025-09-15 17:56:55.742644	556	2
1545	2025-09-15 17:56:55.742644	523	1
1546	2025-09-15 17:56:55.742644	252	1
1547	2025-09-15 17:56:55.742644	135	1
1548	2025-09-15 17:56:55.742644	228	1
1549	2025-09-15 17:56:55.742644	578	2
1550	2025-09-15 17:56:55.742644	569	2
1551	2025-09-15 17:56:55.742644	626	3
1552	2025-09-15 17:56:55.742644	177	3
1553	2025-09-15 17:56:55.742644	234	3
1554	2025-09-15 17:56:55.742644	186	3
1555	2025-09-15 17:56:55.742644	189	2
1556	2025-09-15 17:56:55.742644	537	1
1557	2025-09-15 17:56:55.742644	624	3
1558	2025-09-15 17:56:55.742644	131	1
1559	2025-09-15 17:56:55.742644	596	2
1560	2025-09-15 17:56:55.742644	559	1
1561	2025-09-15 17:56:55.742644	507	2
1562	2025-09-15 17:56:55.742644	489	1
1563	2025-09-15 17:56:55.742644	508	1
1564	2025-09-15 17:56:55.742644	404	2
1565	2025-09-15 17:56:55.742644	526	1
1566	2025-09-15 17:56:55.742644	533	3
1567	2025-09-15 17:56:55.742644	71	3
1568	2025-09-15 17:56:55.742644	575	2
1569	2025-09-15 17:56:55.742644	333	2
1570	2025-09-15 17:56:55.742644	315	3
1571	2025-09-15 17:56:55.742644	468	2
1572	2025-09-15 17:56:55.742644	102	3
1573	2025-09-15 17:56:55.742644	343	3
1574	2025-09-15 17:56:55.742644	72	3
1575	2025-09-15 17:56:55.742644	484	2
1576	2025-09-15 17:56:55.742644	178	1
1578	2025-09-15 17:56:55.742644	588	3
1579	2025-09-15 17:56:55.742644	348	2
1580	2025-09-15 17:56:55.742644	478	1
1582	2025-09-15 17:56:55.742644	295	3
1583	2025-09-15 17:56:55.742644	64	1
1584	2025-09-15 17:56:55.742644	145	1
1585	2025-09-15 17:56:55.742644	39	3
1586	2025-09-15 17:56:55.742644	332	2
1587	2025-09-15 17:56:55.742644	252	3
1588	2025-09-15 17:56:55.742644	523	3
1589	2025-09-15 17:56:55.742644	228	3
1590	2025-09-15 17:56:55.742644	135	3
1591	2025-09-15 17:56:55.742644	458	1
1592	2025-09-15 17:56:55.742644	579	2
1593	2025-09-15 17:56:55.742644	590	2
1594	2025-09-15 17:56:55.742644	582	1
1595	2025-09-15 17:56:55.742644	554	3
1596	2025-09-15 17:56:55.742644	355	2
1597	2025-09-15 17:56:55.742644	56	2
1598	2025-09-15 17:56:55.742644	40	2
1599	2025-09-15 17:56:55.742644	182	2
1600	2025-09-15 17:56:55.742644	413	1
1601	2025-09-15 17:56:55.742644	163	1
1602	2025-09-15 17:56:55.742644	629	1
1603	2025-09-15 17:56:55.742644	104	1
1604	2025-09-15 17:56:55.742644	123	2
1605	2025-09-15 17:56:55.742644	198	1
1606	2025-09-15 17:56:55.742644	261	2
1607	2025-09-15 17:56:55.742644	191	3
1608	2025-09-15 17:56:55.742644	277	2
1609	2025-09-15 17:56:55.742644	71	1
1610	2025-09-15 17:56:55.742644	533	1
1611	2025-09-15 17:56:55.742644	474	2
1612	2025-09-15 17:56:55.742644	140	2
1613	2025-09-15 17:56:55.742644	315	1
1614	2025-09-15 17:56:55.742644	125	2
1615	2025-09-15 17:56:55.742644	102	1
1616	2025-09-15 17:56:55.742644	77	2
1617	2025-09-15 17:56:55.742644	73	2
1618	2025-09-15 17:56:55.742644	343	1
1619	2025-09-15 17:56:55.742644	72	1
1620	2025-09-15 17:56:55.742644	631	2
1621	2025-09-15 17:56:55.742644	2	1
1622	2025-09-15 17:56:55.742644	178	3
1623	2025-09-15 17:56:55.742644	153	2
1624	2025-09-15 17:56:55.742644	588	1
1625	2025-09-15 17:56:55.742644	626	1
1626	2025-09-15 17:56:55.742644	46	2
1627	2025-09-15 17:56:55.742644	177	1
1628	2025-09-15 17:56:55.742644	186	1
1629	2025-09-15 17:56:55.742644	234	1
1630	2025-09-15 17:56:55.742644	211	2
1631	2025-09-15 17:56:55.742644	624	1
1632	2025-09-15 17:56:55.742644	537	3
1633	2025-09-15 17:56:55.742644	131	3
1634	2025-09-15 17:56:55.742644	361	2
1635	2025-09-15 17:56:55.742644	304	2
1636	2025-09-15 17:56:55.742644	559	3
1637	2025-09-15 17:56:55.742644	15	2
1638	2025-09-15 17:56:55.742644	489	3
1639	2025-09-15 17:56:55.742644	83	2
1640	2025-09-15 17:56:55.742644	526	3
1641	2025-09-15 17:56:55.742644	508	3
1642	2025-09-15 17:56:55.742644	89	3
1643	2025-09-15 17:56:55.742644	640	3
1644	2025-09-15 17:56:55.742644	160	3
1645	2025-09-15 17:56:55.742644	479	3
1646	2025-09-15 17:56:55.742644	34	1
1647	2025-09-15 17:56:55.742644	505	1
1648	2025-09-15 17:56:55.742644	142	3
1649	2025-09-15 17:56:55.742644	563	3
1650	2025-09-15 17:56:55.742644	66	3
1651	2025-09-15 17:56:55.742644	428	1
1652	2025-09-15 17:56:55.742644	33	3
1653	2025-09-15 17:56:55.742644	321	1
1654	2025-09-15 17:56:55.742644	10	1
1655	2025-09-15 17:56:55.742644	512	3
1656	2025-09-15 17:56:55.742644	282	1
1657	2025-09-15 17:56:55.742644	284	3
1658	2025-09-15 17:56:55.742644	504	3
1659	2025-09-15 17:56:55.742644	296	1
1660	2025-09-15 17:56:55.742644	12	1
1661	2025-09-15 17:56:55.742644	18	1
1662	2025-09-15 17:56:55.742644	473	2
1663	2025-09-15 17:56:55.742644	465	3
1664	2025-09-15 17:56:55.742644	636	2
1665	2025-09-15 17:56:55.742644	357	3
1666	2025-09-15 17:56:55.742644	241	3
1667	2025-09-15 17:56:55.742644	255	3
1668	2025-09-15 17:56:55.742644	400	2
1669	2025-09-15 17:56:55.742644	274	2
1670	2025-09-15 17:56:55.742644	391	2
1671	2025-09-15 17:56:55.742644	471	3
1672	2025-09-15 17:56:55.742644	324	1
1673	2025-09-15 17:56:55.742644	444	2
1674	2025-09-15 17:56:55.742644	47	2
1675	2025-09-15 17:56:55.742644	143	1
1676	2025-09-15 17:56:55.742644	412	2
1677	2025-09-15 17:56:55.742644	426	2
1678	2025-09-15 17:56:55.742644	595	2
1679	2025-09-15 17:56:55.742644	320	2
1680	2025-09-15 17:56:55.742644	614	1
1681	2025-09-15 17:56:55.742644	146	1
1682	2025-09-15 17:56:55.742644	139	1
1683	2025-09-15 17:56:55.742644	17	3
1684	2025-09-15 17:56:55.742644	325	3
1685	2025-09-15 17:56:55.742644	381	1
1686	2025-09-15 17:56:55.742644	193	1
1687	2025-09-15 17:56:55.742644	297	2
1688	2025-09-15 17:56:55.742644	524	3
1689	2025-09-15 17:56:55.742644	424	1
1690	2025-09-15 17:56:55.742644	31	3
1691	2025-09-15 17:56:55.742644	594	1
1692	2025-09-15 17:56:55.742644	98	1
1693	2025-09-15 17:56:55.742644	288	3
1694	2025-09-15 17:56:55.742644	239	3
1695	2025-09-15 17:56:55.742644	243	1
1696	2025-09-15 17:56:55.742644	627	2
1697	2025-09-15 17:56:55.742644	314	2
1698	2025-09-15 17:56:55.742644	466	1
1699	2025-09-15 17:56:55.742644	459	2
1700	2025-09-15 17:56:55.742644	419	2
1701	2025-09-15 17:56:55.742644	408	1
1702	2025-09-15 17:56:55.742644	250	1
1703	2025-09-15 17:56:55.742644	337	2
1704	2025-09-15 17:56:55.742644	167	1
1705	2025-09-15 17:56:55.742644	480	2
1706	2025-09-15 17:56:55.742644	346	2
1707	2025-09-15 17:56:55.742644	633	3
1708	2025-09-15 17:56:55.742644	617	1
1709	2025-09-15 17:56:55.742644	109	3
1710	2025-09-15 17:56:55.742644	57	3
1711	2025-09-15 17:56:55.742644	280	2
1712	2025-09-15 17:56:55.742644	442	3
1713	2025-09-15 17:56:55.742644	202	2
1714	2025-09-15 17:56:55.742644	137	3
1715	2025-09-15 17:56:55.742644	216	2
1716	2025-09-15 17:56:55.742644	213	3
1717	2025-09-15 17:56:55.742644	26	3
1718	2025-09-15 17:56:55.742644	265	3
1719	2025-09-15 17:56:55.742644	266	2
1720	2025-09-15 17:56:55.742644	253	1
1721	2025-09-15 17:56:55.742644	25	3
1722	2025-09-15 17:56:55.742644	353	2
1723	2025-09-15 17:56:55.742644	82	3
1724	2025-09-15 17:56:55.742644	384	1
1725	2025-09-15 17:56:55.742644	151	1
1726	2025-09-15 17:56:55.742644	270	1
1727	2025-09-15 17:56:55.742644	256	2
1728	2025-09-15 17:56:55.742644	359	3
1729	2025-09-15 17:56:55.742644	399	1
1730	2025-09-15 17:56:55.742644	119	1
1731	2025-09-15 17:56:55.742644	518	1
1732	2025-09-15 17:56:55.742644	620	1
1733	2025-09-15 17:56:55.742644	218	3
1734	2025-09-15 17:56:55.742644	196	3
1735	2025-09-15 17:56:55.742644	300	2
1736	2025-09-15 17:56:55.742644	128	2
1737	2025-09-15 17:56:55.742644	38	2
1738	2025-09-15 17:56:55.742644	437	1
1739	2025-09-15 17:56:55.742644	456	2
1740	2025-09-15 17:56:55.742644	565	2
1741	2025-09-15 17:56:55.742644	310	1
1742	2025-09-15 17:56:55.742644	214	1
1743	2025-09-15 17:56:55.742644	373	3
1744	2025-09-15 17:56:55.742644	549	1
1745	2025-09-15 17:56:55.742644	268	1
1746	2025-09-15 17:56:55.742644	55	2
1747	2025-09-15 17:56:55.742644	339	1
1748	2025-09-15 17:56:55.742644	20	1
1749	2025-09-15 17:56:55.742644	101	1
1750	2025-09-15 17:56:55.742644	494	2
1751	2025-09-15 17:56:55.742644	397	1
1752	2025-09-15 17:56:55.742644	405	3
1753	2025-09-15 17:56:55.742644	379	3
1754	2025-09-15 17:56:55.742644	170	2
1755	2025-09-15 17:56:55.742644	403	2
1756	2025-09-15 17:56:55.742644	136	3
1757	2025-09-15 17:56:55.742644	244	2
1758	2025-09-15 17:56:55.742644	330	1
1759	2025-09-15 17:56:55.742644	168	3
1760	2025-09-15 17:56:55.742644	535	2
1761	2025-09-15 17:56:55.742644	486	1
1762	2025-09-15 17:56:55.742644	68	2
1763	2025-09-15 17:56:55.742644	292	3
1764	2025-09-15 17:56:55.742644	374	2
1765	2025-09-15 17:56:55.742644	158	2
1766	2025-09-15 17:56:55.742644	285	1
1767	2025-09-15 17:56:55.742644	120	1
1768	2025-09-15 17:56:55.742644	449	3
1769	2025-09-15 17:56:55.742644	427	2
1770	2025-09-15 17:56:55.742644	414	3
1771	2025-09-15 17:56:55.742644	106	1
1772	2025-09-15 17:56:55.742644	251	1
1773	2025-09-15 17:56:55.742644	232	2
1774	2025-09-15 17:56:55.742644	184	2
1775	2025-09-15 17:56:55.742644	24	2
1776	2025-09-15 17:56:55.742644	601	1
1777	2025-09-15 17:56:55.742644	264	1
1778	2025-09-15 17:56:55.742644	377	2
1779	2025-09-15 17:56:55.742644	113	2
1780	2025-09-15 17:56:55.742644	172	2
1781	2025-09-15 17:56:55.742644	279	2
1782	2025-09-15 17:56:55.742644	27	3
1783	2025-09-15 17:56:55.742644	637	2
1784	2025-09-15 17:56:55.742644	289	2
1785	2025-09-15 17:56:55.742644	133	2
1786	2025-09-15 17:56:55.742644	497	1
1787	2025-09-15 17:56:55.742644	238	3
1788	2025-09-15 17:56:55.742644	603	2
1789	2025-09-15 17:56:55.742644	452	1
1790	2025-09-15 17:56:55.742644	230	3
1791	2025-09-15 17:56:55.742644	638	2
1792	2025-09-15 17:56:55.742644	492	2
1793	2025-09-15 17:56:55.742644	416	2
1794	2025-09-15 17:56:55.742644	443	2
1795	2025-09-15 17:56:55.742644	100	2
1796	2025-09-15 17:56:55.742644	326	2
1797	2025-09-15 17:56:55.742644	455	1
1798	2025-09-15 17:56:55.742644	335	3
1799	2025-09-15 17:56:55.742644	496	1
1800	2025-09-15 17:56:55.742644	164	2
1801	2025-09-15 17:56:55.742644	541	3
1802	2025-09-15 17:56:55.742644	209	1
1803	2025-09-15 17:56:55.742644	555	3
1804	2025-09-15 17:56:55.742644	278	2
1805	2025-09-15 17:56:55.742644	78	2
1806	2025-09-15 17:56:55.742644	630	1
1807	2025-09-15 17:56:55.742644	32	2
1808	2025-09-15 17:56:55.742644	421	2
1809	2025-09-15 17:56:55.742644	606	1
1810	2025-09-15 17:56:55.742644	577	1
1811	2025-09-15 17:56:55.742644	85	2
1812	2025-09-15 17:56:55.742644	276	1
1813	2025-09-15 17:56:55.742644	382	3
1814	2025-09-15 17:56:55.742644	358	2
1815	2025-09-15 17:56:55.742644	307	3
1816	2025-09-15 17:56:55.742644	599	1
1817	2025-09-15 17:56:55.742644	93	3
1818	2025-09-15 17:56:55.742644	550	1
1819	2025-09-15 17:56:55.742644	546	2
1820	2025-09-15 17:56:55.742644	149	3
1821	2025-09-15 17:56:55.742644	27	1
1822	2025-09-15 17:56:55.742644	635	2
1823	2025-09-15 17:56:55.742644	366	2
1824	2025-09-15 17:56:55.742644	317	2
1825	2025-09-15 17:56:55.742644	52	2
1826	2025-09-15 17:56:55.742644	238	1
1827	2025-09-15 17:56:55.742644	65	2
1828	2025-09-15 17:56:55.742644	497	3
1829	2025-09-15 17:56:55.742644	37	2
1830	2025-09-15 17:56:55.742644	230	1
1831	2025-09-15 17:56:55.742644	452	3
1832	2025-09-15 17:56:55.742644	440	2
1833	2025-09-15 17:56:55.742644	449	1
1834	2025-09-15 17:56:55.742644	285	3
1835	2025-09-15 17:56:55.742644	120	3
1836	2025-09-15 17:56:55.742644	258	2
1837	2025-09-15 17:56:55.742644	106	3
1838	2025-09-15 17:56:55.742644	414	1
1839	2025-09-15 17:56:55.742644	251	3
1840	2025-09-15 17:56:55.742644	601	3
1841	2025-09-15 17:56:55.742644	215	2
1842	2025-09-15 17:56:55.742644	264	3
1843	2025-09-15 17:56:55.742644	108	2
1844	2025-09-15 17:56:55.742644	19	2
1845	2025-09-15 17:56:55.742644	589	2
1846	2025-09-15 17:56:55.742644	398	2
1847	2025-09-15 17:56:55.742644	435	2
1848	2025-09-15 17:56:55.742644	221	2
1849	2025-09-15 17:56:55.742644	606	3
1850	2025-09-15 17:56:55.742644	577	3
1851	2025-09-15 17:56:55.742644	276	3
1852	2025-09-15 17:56:55.742644	530	2
1853	2025-09-15 17:56:55.742644	382	1
1854	2025-09-15 17:56:55.742644	576	2
1855	2025-09-15 17:56:55.742644	307	1
1856	2025-09-15 17:56:55.742644	550	3
1857	2025-09-15 17:56:55.742644	93	1
1858	2025-09-15 17:56:55.742644	599	3
1859	2025-09-15 17:56:55.742644	149	1
1860	2025-09-15 17:56:55.742644	107	2
1861	2025-09-15 17:56:55.742644	335	1
1862	2025-09-15 17:56:55.742644	455	3
1863	2025-09-15 17:56:55.742644	396	2
1864	2025-09-15 17:56:55.742644	496	3
1865	2025-09-15 17:56:55.742644	555	1
1866	2025-09-15 17:56:55.742644	209	3
1867	2025-09-15 17:56:55.742644	319	2
1868	2025-09-15 17:56:55.742644	541	1
1869	2025-09-15 17:56:55.742644	600	2
1870	2025-09-15 17:56:55.742644	630	3
1871	2025-09-15 17:56:55.742644	493	2
1872	2025-09-15 17:56:55.742644	96	2
1873	2025-09-15 17:56:55.742644	25	1
1874	2025-09-15 17:56:55.742644	253	3
1875	2025-09-15 17:56:55.742644	384	3
1876	2025-09-15 17:56:55.742644	82	1
1877	2025-09-15 17:56:55.742644	151	3
1878	2025-09-15 17:56:55.742644	270	3
1879	2025-09-15 17:56:55.742644	581	2
1880	2025-09-15 17:56:55.742644	359	1
1881	2025-09-15 17:56:55.742644	119	3
1882	2025-09-15 17:56:55.742644	399	3
1883	2025-09-15 17:56:55.742644	432	2
1884	2025-09-15 17:56:55.742644	519	2
1885	2025-09-15 17:56:55.742644	137	1
1886	2025-09-15 17:56:55.742644	429	2
1887	2025-09-15 17:56:55.742644	213	1
1888	2025-09-15 17:56:55.742644	26	1
1889	2025-09-15 17:56:55.742644	265	1
1890	2025-09-15 17:56:55.742644	254	2
1891	2025-09-15 17:56:55.742644	112	2
1892	2025-09-15 17:56:55.742644	625	2
1893	2025-09-15 17:56:55.742644	339	3
1894	2025-09-15 17:56:55.742644	20	3
1895	2025-09-15 17:56:55.742644	101	3
1896	2025-09-15 17:56:55.742644	392	2
1897	2025-09-15 17:56:55.742644	405	1
1898	2025-09-15 17:56:55.742644	379	1
1899	2025-09-15 17:56:55.742644	397	3
1900	2025-09-15 17:56:55.742644	136	1
1901	2025-09-15 17:56:55.742644	168	1
1902	2025-09-15 17:56:55.742644	330	3
1903	2025-09-15 17:56:55.742644	609	2
1904	2025-09-15 17:56:55.742644	298	2
1905	2025-09-15 17:56:55.742644	486	3
1906	2025-09-15 17:56:55.742644	292	1
1907	2025-09-15 17:56:55.742644	620	3
1908	2025-09-15 17:56:55.742644	518	3
1909	2025-09-15 17:56:55.742644	218	1
1910	2025-09-15 17:56:55.742644	196	1
1911	2025-09-15 17:56:55.742644	593	2
1912	2025-09-15 17:56:55.742644	437	3
1913	2025-09-15 17:56:55.742644	340	2
1914	2025-09-15 17:56:55.742644	310	3
1915	2025-09-15 17:56:55.742644	214	3
1916	2025-09-15 17:56:55.742644	367	2
1917	2025-09-15 17:56:55.742644	373	1
1918	2025-09-15 17:56:55.742644	268	3
1919	2025-09-15 17:56:55.742644	549	3
1920	2025-09-15 17:56:55.742644	498	2
1925	\N	648	15
\.


--
-- Data for Name: pais; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pais (id_pais, nombre, url_imagen, estado, fecha_creacion, comentario, id_usr) FROM stdin;
16	Chile	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg	1	2025-09-10 18:05:44.113594	\N	\N
17	PerÔö£Ôòæ	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg	1	2025-09-10 18:05:44.113594	\N	\N
18	Argentina	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg	1	2025-09-10 18:05:44.113594	\N	\N
19	Bolivia	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg	1	2025-09-10 18:05:44.113594	\N	\N
20	Uruguay	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg	1	2025-09-10 18:05:44.113594	\N	\N
21	Paraguay	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg	1	2025-09-10 18:05:44.113594	\N	\N
22	Brasil	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg	1	2025-09-10 18:05:44.113594	\N	\N
23	Ecuador	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg	1	2025-09-10 18:05:44.113594	\N	\N
26	Uruguay Test API	https://example.com/uruguay.jpg	0	2025-10-08 03:56:22.033938	\N	3
27	Colombia Prueba CRUD	https://images.pexels.com/photos/colombia.jpg	0	2025-10-08 11:41:16.339336	\N	3
28	Pais de Prueba Automatizada	\N	0	2025-10-10 01:42:43.331658	\N	\N
29	Pais de Pruebas Automatizadas	https://example.com/flag-test.png	0	2025-10-10 11:06:02.749371	Este es un pais creado automaticamente para pruebas	\N
31	Pais Test 1556736707	\N	1	2025-10-10 12:22:53.219845	\N	\N
32	Pa├¡s Test 1854671487	\N	1	2025-10-10 15:00:52.261858	\N	\N
33	Test Pais	\N	1	2025-10-10 15:12:15.408447	\N	\N
34	Test Debug	\N	1	2025-10-10 15:15:08.194271	\N	\N
36	Test Pais 153029	\N	1	2025-10-10 15:30:29.149922	\N	\N
37	Debug Test	\N	1	2025-10-10 15:30:51.611981	\N	\N
38	Test Debug Pais	\N	1	2025-10-10 15:31:25.405798	\N	\N
40	Test Pais Script	\N	1	2025-10-10 15:38:28.247093	\N	\N
41	TestPais318213938	\N	0	2025-10-10 15:39:28.138506	\N	\N
42	TestPais566887983	\N	0	2025-10-10 15:39:49.086225	\N	\N
43	Test Pais 1517270790	\N	0	2025-10-10 15:50:04.616096	\N	\N
\.


--
-- Data for Name: perfil; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.perfil (id_perfil, nombre) FROM stdin;
3	ADMIN
2	LIDER
1	USER
\.


--
-- Data for Name: receta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.receta (id_receta, nombre, url_imagen, ingrediente, preparacion, estado, id_cat, id_pais, fecha_creacion, id_usr, visitas) FROM stdin;
9	Almuerzo - Chile #1	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	16	2025-09-15	1	0
10	Almuerzo - PerÔö£Ôòæ #1	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	17	2025-09-15	1	0
11	Almuerzo - Argentina #1	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	18	2025-09-15	1	0
13	Almuerzo - Uruguay #1	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	20	2025-09-15	1	0
16	Almuerzo - Ecuador #1	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	23	2025-09-15	1	0
17	Cena - Chile #1	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	16	2025-09-15	1	0
18	Cena - PerÔö£Ôòæ #1	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	17	2025-09-15	1	0
19	Cena - Argentina #1	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	18	2025-09-15	1	0
20	Cena - Bolivia #1	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	19	2025-09-15	1	0
21	Cena - Uruguay #1	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	20	2025-09-15	1	0
22	Cena - Paraguay #1	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	21	2025-09-15	1	0
23	Cena - Brasil #1	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	22	2025-09-15	1	0
24	Cena - Ecuador #1	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	23	2025-09-15	1	0
25	Postres - Chile #1	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	16	2025-09-15	1	0
26	Postres - PerÔö£Ôòæ #1	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	17	2025-09-15	1	0
27	Postres - Argentina #1	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	18	2025-09-15	1	0
28	Postres - Bolivia #1	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	19	2025-09-15	1	0
29	Postres - Uruguay #1	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	20	2025-09-15	1	0
30	Postres - Paraguay #1	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	21	2025-09-15	1	0
31	Postres - Brasil #1	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	22	2025-09-15	1	0
32	Postres - Ecuador #1	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	23	2025-09-15	1	0
33	Bebidas - Chile #1	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	16	2025-09-15	1	0
34	Bebidas - PerÔö£Ôòæ #1	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	17	2025-09-15	1	0
35	Bebidas - Argentina #1	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	18	2025-09-15	1	0
36	Bebidas - Bolivia #1	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	19	2025-09-15	1	0
37	Bebidas - Uruguay #1	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	20	2025-09-15	1	0
38	Bebidas - Paraguay #1	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	21	2025-09-15	1	0
1	Desayuno - Chile #1	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	16	2025-09-15	1	4
14	Almuerzo - Paraguay #1	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	21	2025-09-15	1	2
12	Almuerzo - Bolivia #1	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	19	2025-09-15	1	18
39	Bebidas - Brasil #1	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	22	2025-09-15	1	0
40	Bebidas - Ecuador #1	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	23	2025-09-15	1	0
41	Ensaladas - Chile #1	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	16	2025-09-15	1	0
42	Ensaladas - PerÔö£Ôòæ #1	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	17	2025-09-15	1	0
43	Ensaladas - Argentina #1	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	18	2025-09-15	1	0
44	Ensaladas - Bolivia #1	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	19	2025-09-15	1	0
45	Ensaladas - Uruguay #1	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	20	2025-09-15	1	0
46	Ensaladas - Paraguay #1	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	21	2025-09-15	1	0
47	Ensaladas - Brasil #1	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	22	2025-09-15	1	0
48	Ensaladas - Ecuador #1	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	23	2025-09-15	1	0
49	Sopas - Chile #1	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	16	2025-09-15	1	0
50	Sopas - PerÔö£Ôòæ #1	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	17	2025-09-15	1	0
51	Sopas - Argentina #1	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	18	2025-09-15	1	0
52	Sopas - Bolivia #1	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	19	2025-09-15	1	0
53	Sopas - Uruguay #1	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	20	2025-09-15	1	0
54	Sopas - Paraguay #1	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	21	2025-09-15	1	0
55	Sopas - Brasil #1	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	22	2025-09-15	1	0
56	Sopas - Ecuador #1	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	23	2025-09-15	1	0
57	Vegetariana - Chile #1	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	16	2025-09-15	1	0
58	Vegetariana - PerÔö£Ôòæ #1	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	17	2025-09-15	1	0
59	Vegetariana - Argentina #1	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	18	2025-09-15	1	0
60	Vegetariana - Bolivia #1	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	19	2025-09-15	1	0
61	Vegetariana - Uruguay #1	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	20	2025-09-15	1	0
62	Vegetariana - Paraguay #1	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	21	2025-09-15	1	0
63	Vegetariana - Brasil #1	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	22	2025-09-15	1	0
64	Vegetariana - Ecuador #1	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	23	2025-09-15	1	0
65	Desayuno - Chile #2	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	16	2025-09-15	1	0
66	Desayuno - PerÔö£Ôòæ #2	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	17	2025-09-15	1	0
67	Desayuno - Argentina #2	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	18	2025-09-15	1	0
68	Desayuno - Bolivia #2	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	19	2025-09-15	1	0
69	Desayuno - Uruguay #2	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	20	2025-09-15	1	0
70	Desayuno - Paraguay #2	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	21	2025-09-15	1	0
71	Desayuno - Brasil #2	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	22	2025-09-15	1	0
72	Desayuno - Ecuador #2	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	23	2025-09-15	1	0
73	Almuerzo - Chile #2	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	16	2025-09-15	1	0
74	Almuerzo - PerÔö£Ôòæ #2	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	17	2025-09-15	1	0
75	Almuerzo - Argentina #2	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	18	2025-09-15	1	0
76	Almuerzo - Bolivia #2	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	19	2025-09-15	1	0
77	Almuerzo - Uruguay #2	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	20	2025-09-15	1	0
78	Almuerzo - Paraguay #2	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	21	2025-09-15	1	0
79	Almuerzo - Brasil #2	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	22	2025-09-15	1	0
80	Almuerzo - Ecuador #2	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	23	2025-09-15	1	0
81	Cena - Chile #2	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	16	2025-09-15	1	0
82	Cena - PerÔö£Ôòæ #2	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	17	2025-09-15	1	0
83	Cena - Argentina #2	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	18	2025-09-15	1	0
84	Cena - Bolivia #2	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	19	2025-09-15	1	0
85	Cena - Uruguay #2	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	20	2025-09-15	1	0
86	Cena - Paraguay #2	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	21	2025-09-15	1	0
87	Cena - Brasil #2	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	22	2025-09-15	1	0
88	Cena - Ecuador #2	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	23	2025-09-15	1	0
89	Postres - Chile #2	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	16	2025-09-15	1	0
90	Postres - PerÔö£Ôòæ #2	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	17	2025-09-15	1	0
91	Postres - Argentina #2	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	18	2025-09-15	1	0
92	Postres - Bolivia #2	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	19	2025-09-15	1	0
93	Postres - Uruguay #2	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	20	2025-09-15	1	0
94	Postres - Paraguay #2	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	21	2025-09-15	1	0
95	Postres - Brasil #2	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	22	2025-09-15	1	0
96	Postres - Ecuador #2	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	23	2025-09-15	1	0
97	Bebidas - Chile #2	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	16	2025-09-15	1	0
98	Bebidas - PerÔö£Ôòæ #2	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	17	2025-09-15	1	0
99	Bebidas - Argentina #2	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	18	2025-09-15	1	0
100	Bebidas - Bolivia #2	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	19	2025-09-15	1	0
101	Bebidas - Uruguay #2	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	20	2025-09-15	1	0
102	Bebidas - Paraguay #2	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	21	2025-09-15	1	0
103	Bebidas - Brasil #2	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	22	2025-09-15	1	0
104	Bebidas - Ecuador #2	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	23	2025-09-15	1	0
105	Ensaladas - Chile #2	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	16	2025-09-15	1	0
106	Ensaladas - PerÔö£Ôòæ #2	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	17	2025-09-15	1	0
107	Ensaladas - Argentina #2	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	18	2025-09-15	1	0
108	Ensaladas - Bolivia #2	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	19	2025-09-15	1	0
109	Ensaladas - Uruguay #2	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	20	2025-09-15	1	0
110	Ensaladas - Paraguay #2	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	21	2025-09-15	1	0
111	Ensaladas - Brasil #2	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	22	2025-09-15	1	0
112	Ensaladas - Ecuador #2	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	23	2025-09-15	1	0
113	Sopas - Chile #2	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	16	2025-09-15	1	0
114	Sopas - PerÔö£Ôòæ #2	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	17	2025-09-15	1	0
115	Sopas - Argentina #2	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	18	2025-09-15	1	0
116	Sopas - Bolivia #2	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	19	2025-09-15	1	0
117	Sopas - Uruguay #2	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	20	2025-09-15	1	0
118	Sopas - Paraguay #2	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	21	2025-09-15	1	0
119	Sopas - Brasil #2	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	22	2025-09-15	1	0
120	Sopas - Ecuador #2	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	23	2025-09-15	1	0
121	Vegetariana - Chile #2	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	16	2025-09-15	1	0
122	Vegetariana - PerÔö£Ôòæ #2	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	17	2025-09-15	1	0
123	Vegetariana - Argentina #2	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	18	2025-09-15	1	0
124	Vegetariana - Bolivia #2	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	19	2025-09-15	1	0
125	Vegetariana - Uruguay #2	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	20	2025-09-15	1	0
126	Vegetariana - Paraguay #2	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	21	2025-09-15	1	0
127	Vegetariana - Brasil #2	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	22	2025-09-15	1	0
128	Vegetariana - Ecuador #2	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	23	2025-09-15	1	0
129	Desayuno - Chile #3	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	16	2025-09-15	1	0
161	Bebidas - Chile #3	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	16	2025-09-15	1	0
130	Desayuno - PerÔö£Ôòæ #3	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	17	2025-09-15	1	0
131	Desayuno - Argentina #3	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	18	2025-09-15	1	0
132	Desayuno - Bolivia #3	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	19	2025-09-15	1	0
133	Desayuno - Uruguay #3	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	20	2025-09-15	1	0
134	Desayuno - Paraguay #3	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	21	2025-09-15	1	0
135	Desayuno - Brasil #3	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	22	2025-09-15	1	0
136	Desayuno - Ecuador #3	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	23	2025-09-15	1	0
137	Almuerzo - Chile #3	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	16	2025-09-15	1	0
138	Almuerzo - PerÔö£Ôòæ #3	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	17	2025-09-15	1	0
139	Almuerzo - Argentina #3	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	18	2025-09-15	1	0
140	Almuerzo - Bolivia #3	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	19	2025-09-15	1	0
141	Almuerzo - Uruguay #3	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	20	2025-09-15	1	0
142	Almuerzo - Paraguay #3	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	21	2025-09-15	1	0
143	Almuerzo - Brasil #3	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	22	2025-09-15	1	0
144	Almuerzo - Ecuador #3	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	23	2025-09-15	1	0
145	Cena - Chile #3	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	16	2025-09-15	1	0
146	Cena - PerÔö£Ôòæ #3	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	17	2025-09-15	1	0
147	Cena - Argentina #3	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	18	2025-09-15	1	0
148	Cena - Bolivia #3	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	19	2025-09-15	1	0
149	Cena - Uruguay #3	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	20	2025-09-15	1	0
150	Cena - Paraguay #3	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	21	2025-09-15	1	0
151	Cena - Brasil #3	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	22	2025-09-15	1	0
152	Cena - Ecuador #3	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	23	2025-09-15	1	0
153	Postres - Chile #3	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	16	2025-09-15	1	0
154	Postres - PerÔö£Ôòæ #3	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	17	2025-09-15	1	0
155	Postres - Argentina #3	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	18	2025-09-15	1	0
156	Postres - Bolivia #3	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	19	2025-09-15	1	0
157	Postres - Uruguay #3	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	20	2025-09-15	1	0
158	Postres - Paraguay #3	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	21	2025-09-15	1	0
159	Postres - Brasil #3	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	22	2025-09-15	1	0
160	Postres - Ecuador #3	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	23	2025-09-15	1	0
162	Bebidas - PerÔö£Ôòæ #3	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	17	2025-09-15	1	0
163	Bebidas - Argentina #3	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	18	2025-09-15	1	0
164	Bebidas - Bolivia #3	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	19	2025-09-15	1	0
165	Bebidas - Uruguay #3	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	20	2025-09-15	1	0
166	Bebidas - Paraguay #3	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	21	2025-09-15	1	0
167	Bebidas - Brasil #3	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	22	2025-09-15	1	0
168	Bebidas - Ecuador #3	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	23	2025-09-15	1	0
169	Ensaladas - Chile #3	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	16	2025-09-15	1	0
170	Ensaladas - PerÔö£Ôòæ #3	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	17	2025-09-15	1	0
171	Ensaladas - Argentina #3	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	18	2025-09-15	1	0
172	Ensaladas - Bolivia #3	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	19	2025-09-15	1	0
173	Ensaladas - Uruguay #3	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	20	2025-09-15	1	0
174	Ensaladas - Paraguay #3	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	21	2025-09-15	1	0
175	Ensaladas - Brasil #3	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	22	2025-09-15	1	0
176	Ensaladas - Ecuador #3	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	23	2025-09-15	1	0
177	Sopas - Chile #3	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	16	2025-09-15	1	0
178	Sopas - PerÔö£Ôòæ #3	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	17	2025-09-15	1	0
179	Sopas - Argentina #3	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	18	2025-09-15	1	0
180	Sopas - Bolivia #3	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	19	2025-09-15	1	0
181	Sopas - Uruguay #3	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	20	2025-09-15	1	0
182	Sopas - Paraguay #3	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	21	2025-09-15	1	0
183	Sopas - Brasil #3	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	22	2025-09-15	1	0
184	Sopas - Ecuador #3	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	23	2025-09-15	1	0
185	Vegetariana - Chile #3	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	16	2025-09-15	1	0
186	Vegetariana - PerÔö£Ôòæ #3	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	17	2025-09-15	1	0
187	Vegetariana - Argentina #3	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	18	2025-09-15	1	0
188	Vegetariana - Bolivia #3	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	19	2025-09-15	1	0
189	Vegetariana - Uruguay #3	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	20	2025-09-15	1	0
190	Vegetariana - Paraguay #3	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	21	2025-09-15	1	0
191	Vegetariana - Brasil #3	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	22	2025-09-15	1	0
192	Vegetariana - Ecuador #3	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	23	2025-09-15	1	0
193	Desayuno - Chile #4	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	16	2025-09-15	1	0
194	Desayuno - PerÔö£Ôòæ #4	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	17	2025-09-15	1	0
195	Desayuno - Argentina #4	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	18	2025-09-15	1	0
196	Desayuno - Bolivia #4	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	19	2025-09-15	1	0
197	Desayuno - Uruguay #4	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	20	2025-09-15	1	0
198	Desayuno - Paraguay #4	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	21	2025-09-15	1	0
199	Desayuno - Brasil #4	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	22	2025-09-15	1	0
200	Desayuno - Ecuador #4	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	23	2025-09-15	1	0
201	Almuerzo - Chile #4	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	16	2025-09-15	1	0
202	Almuerzo - PerÔö£Ôòæ #4	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	17	2025-09-15	1	0
203	Almuerzo - Argentina #4	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	18	2025-09-15	1	0
204	Almuerzo - Bolivia #4	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	19	2025-09-15	1	0
205	Almuerzo - Uruguay #4	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	20	2025-09-15	1	0
206	Almuerzo - Paraguay #4	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	21	2025-09-15	1	0
207	Almuerzo - Brasil #4	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	22	2025-09-15	1	0
208	Almuerzo - Ecuador #4	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	23	2025-09-15	1	0
209	Cena - Chile #4	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	16	2025-09-15	1	0
210	Cena - PerÔö£Ôòæ #4	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	17	2025-09-15	1	0
211	Cena - Argentina #4	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	18	2025-09-15	1	0
212	Cena - Bolivia #4	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	19	2025-09-15	1	0
213	Cena - Uruguay #4	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	20	2025-09-15	1	0
214	Cena - Paraguay #4	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	21	2025-09-15	1	0
215	Cena - Brasil #4	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	22	2025-09-15	1	0
216	Cena - Ecuador #4	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	23	2025-09-15	1	0
217	Postres - Chile #4	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	16	2025-09-15	1	0
218	Postres - PerÔö£Ôòæ #4	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	17	2025-09-15	1	0
219	Postres - Argentina #4	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	18	2025-09-15	1	0
220	Postres - Bolivia #4	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	19	2025-09-15	1	0
221	Postres - Uruguay #4	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	20	2025-09-15	1	0
222	Postres - Paraguay #4	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	21	2025-09-15	1	0
223	Postres - Brasil #4	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	22	2025-09-15	1	0
224	Postres - Ecuador #4	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	23	2025-09-15	1	0
225	Bebidas - Chile #4	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	16	2025-09-15	1	0
226	Bebidas - PerÔö£Ôòæ #4	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	17	2025-09-15	1	0
227	Bebidas - Argentina #4	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	18	2025-09-15	1	0
228	Bebidas - Bolivia #4	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	19	2025-09-15	1	0
229	Bebidas - Uruguay #4	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	20	2025-09-15	1	0
230	Bebidas - Paraguay #4	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	21	2025-09-15	1	0
231	Bebidas - Brasil #4	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	22	2025-09-15	1	0
232	Bebidas - Ecuador #4	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	23	2025-09-15	1	0
233	Ensaladas - Chile #4	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	16	2025-09-15	1	0
234	Ensaladas - PerÔö£Ôòæ #4	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	17	2025-09-15	1	0
235	Ensaladas - Argentina #4	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	18	2025-09-15	1	0
236	Ensaladas - Bolivia #4	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	19	2025-09-15	1	0
237	Ensaladas - Uruguay #4	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	20	2025-09-15	1	0
238	Ensaladas - Paraguay #4	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	21	2025-09-15	1	0
239	Ensaladas - Brasil #4	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	22	2025-09-15	1	0
240	Ensaladas - Ecuador #4	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	23	2025-09-15	1	0
241	Sopas - Chile #4	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	16	2025-09-15	1	0
242	Sopas - PerÔö£Ôòæ #4	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	17	2025-09-15	1	0
243	Sopas - Argentina #4	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	18	2025-09-15	1	0
244	Sopas - Bolivia #4	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	19	2025-09-15	1	0
245	Sopas - Uruguay #4	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	20	2025-09-15	1	0
246	Sopas - Paraguay #4	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	21	2025-09-15	1	0
247	Sopas - Brasil #4	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	22	2025-09-15	1	0
248	Sopas - Ecuador #4	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	23	2025-09-15	1	0
249	Vegetariana - Chile #4	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	16	2025-09-15	1	0
250	Vegetariana - PerÔö£Ôòæ #4	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	17	2025-09-15	1	0
251	Vegetariana - Argentina #4	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	18	2025-09-15	1	0
252	Vegetariana - Bolivia #4	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	19	2025-09-15	1	0
253	Vegetariana - Uruguay #4	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	20	2025-09-15	1	0
254	Vegetariana - Paraguay #4	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	21	2025-09-15	1	0
255	Vegetariana - Brasil #4	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	22	2025-09-15	1	0
256	Vegetariana - Ecuador #4	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	23	2025-09-15	1	0
257	Desayuno - Chile #5	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	16	2025-09-15	1	0
258	Desayuno - PerÔö£Ôòæ #5	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	17	2025-09-15	1	0
259	Desayuno - Argentina #5	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	18	2025-09-15	1	0
260	Desayuno - Bolivia #5	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	19	2025-09-15	1	0
261	Desayuno - Uruguay #5	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	20	2025-09-15	1	0
262	Desayuno - Paraguay #5	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	21	2025-09-15	1	0
263	Desayuno - Brasil #5	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	22	2025-09-15	1	0
264	Desayuno - Ecuador #5	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	23	2025-09-15	1	0
265	Almuerzo - Chile #5	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	16	2025-09-15	1	0
266	Almuerzo - PerÔö£Ôòæ #5	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	17	2025-09-15	1	0
267	Almuerzo - Argentina #5	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	18	2025-09-15	1	0
268	Almuerzo - Bolivia #5	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	19	2025-09-15	1	0
269	Almuerzo - Uruguay #5	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	20	2025-09-15	1	0
270	Almuerzo - Paraguay #5	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	21	2025-09-15	1	0
271	Almuerzo - Brasil #5	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	22	2025-09-15	1	0
272	Almuerzo - Ecuador #5	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	23	2025-09-15	1	0
273	Cena - Chile #5	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	16	2025-09-15	1	0
274	Cena - PerÔö£Ôòæ #5	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	17	2025-09-15	1	0
275	Cena - Argentina #5	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	18	2025-09-15	1	0
276	Cena - Bolivia #5	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	19	2025-09-15	1	0
277	Cena - Uruguay #5	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	20	2025-09-15	1	0
278	Cena - Paraguay #5	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	21	2025-09-15	1	0
279	Cena - Brasil #5	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	22	2025-09-15	1	0
280	Cena - Ecuador #5	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	23	2025-09-15	1	0
281	Postres - Chile #5	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	16	2025-09-15	1	0
282	Postres - PerÔö£Ôòæ #5	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	17	2025-09-15	1	0
283	Postres - Argentina #5	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	18	2025-09-15	1	0
284	Postres - Bolivia #5	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	19	2025-09-15	1	0
285	Postres - Uruguay #5	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	20	2025-09-15	1	0
286	Postres - Paraguay #5	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	21	2025-09-15	1	0
287	Postres - Brasil #5	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	22	2025-09-15	1	0
288	Postres - Ecuador #5	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	23	2025-09-15	1	0
289	Bebidas - Chile #5	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	16	2025-09-15	1	0
290	Bebidas - PerÔö£Ôòæ #5	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	17	2025-09-15	1	0
291	Bebidas - Argentina #5	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	18	2025-09-15	1	0
292	Bebidas - Bolivia #5	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	19	2025-09-15	1	0
293	Bebidas - Uruguay #5	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	20	2025-09-15	1	0
294	Bebidas - Paraguay #5	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	21	2025-09-15	1	0
295	Bebidas - Brasil #5	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	22	2025-09-15	1	0
296	Bebidas - Ecuador #5	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	23	2025-09-15	1	0
297	Ensaladas - Chile #5	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	16	2025-09-15	1	0
298	Ensaladas - PerÔö£Ôòæ #5	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	17	2025-09-15	1	0
299	Ensaladas - Argentina #5	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	18	2025-09-15	1	0
300	Ensaladas - Bolivia #5	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	19	2025-09-15	1	0
301	Ensaladas - Uruguay #5	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	20	2025-09-15	1	0
302	Ensaladas - Paraguay #5	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	21	2025-09-15	1	0
303	Ensaladas - Brasil #5	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	22	2025-09-15	1	0
304	Ensaladas - Ecuador #5	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	23	2025-09-15	1	0
305	Sopas - Chile #5	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	16	2025-09-15	1	0
306	Sopas - PerÔö£Ôòæ #5	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	17	2025-09-15	1	0
307	Sopas - Argentina #5	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	18	2025-09-15	1	0
308	Sopas - Bolivia #5	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	19	2025-09-15	1	0
309	Sopas - Uruguay #5	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	20	2025-09-15	1	0
310	Sopas - Paraguay #5	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	21	2025-09-15	1	0
311	Sopas - Brasil #5	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	22	2025-09-15	1	0
312	Sopas - Ecuador #5	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	23	2025-09-15	1	0
313	Vegetariana - Chile #5	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	16	2025-09-15	1	0
314	Vegetariana - PerÔö£Ôòæ #5	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	17	2025-09-15	1	0
315	Vegetariana - Argentina #5	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	18	2025-09-15	1	0
316	Vegetariana - Bolivia #5	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	19	2025-09-15	1	0
317	Vegetariana - Uruguay #5	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	20	2025-09-15	1	0
318	Vegetariana - Paraguay #5	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	21	2025-09-15	1	0
319	Vegetariana - Brasil #5	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	22	2025-09-15	1	0
320	Vegetariana - Ecuador #5	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	23	2025-09-15	1	0
321	Desayuno - Chile #6	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	16	2025-09-15	1	0
322	Desayuno - PerÔö£Ôòæ #6	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	17	2025-09-15	1	0
323	Desayuno - Argentina #6	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	18	2025-09-15	1	0
324	Desayuno - Bolivia #6	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	19	2025-09-15	1	0
325	Desayuno - Uruguay #6	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	20	2025-09-15	1	0
326	Desayuno - Paraguay #6	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	21	2025-09-15	1	0
327	Desayuno - Brasil #6	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	22	2025-09-15	1	0
328	Desayuno - Ecuador #6	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	23	2025-09-15	1	0
329	Almuerzo - Chile #6	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	16	2025-09-15	1	0
330	Almuerzo - PerÔö£Ôòæ #6	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	17	2025-09-15	1	0
331	Almuerzo - Argentina #6	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	18	2025-09-15	1	0
332	Almuerzo - Bolivia #6	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	19	2025-09-15	1	0
333	Almuerzo - Uruguay #6	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	20	2025-09-15	1	0
334	Almuerzo - Paraguay #6	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	21	2025-09-15	1	0
335	Almuerzo - Brasil #6	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	22	2025-09-15	1	0
336	Almuerzo - Ecuador #6	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	23	2025-09-15	1	0
337	Cena - Chile #6	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	16	2025-09-15	1	0
338	Cena - PerÔö£Ôòæ #6	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	17	2025-09-15	1	0
339	Cena - Argentina #6	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	18	2025-09-15	1	0
340	Cena - Bolivia #6	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	19	2025-09-15	1	0
341	Cena - Uruguay #6	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	20	2025-09-15	1	0
342	Cena - Paraguay #6	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	21	2025-09-15	1	0
343	Cena - Brasil #6	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	22	2025-09-15	1	0
344	Cena - Ecuador #6	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	23	2025-09-15	1	0
345	Postres - Chile #6	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	16	2025-09-15	1	0
346	Postres - PerÔö£Ôòæ #6	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	17	2025-09-15	1	0
347	Postres - Argentina #6	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	18	2025-09-15	1	0
348	Postres - Bolivia #6	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	19	2025-09-15	1	0
349	Postres - Uruguay #6	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	20	2025-09-15	1	0
350	Postres - Paraguay #6	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	21	2025-09-15	1	0
351	Postres - Brasil #6	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	22	2025-09-15	1	0
352	Postres - Ecuador #6	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	23	2025-09-15	1	0
353	Bebidas - Chile #6	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	16	2025-09-15	1	0
354	Bebidas - PerÔö£Ôòæ #6	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	17	2025-09-15	1	0
355	Bebidas - Argentina #6	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	18	2025-09-15	1	0
356	Bebidas - Bolivia #6	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	19	2025-09-15	1	0
357	Bebidas - Uruguay #6	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	20	2025-09-15	1	0
358	Bebidas - Paraguay #6	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	21	2025-09-15	1	0
359	Bebidas - Brasil #6	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	22	2025-09-15	1	0
360	Bebidas - Ecuador #6	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	23	2025-09-15	1	0
361	Ensaladas - Chile #6	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	16	2025-09-15	1	0
362	Ensaladas - PerÔö£Ôòæ #6	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	17	2025-09-15	1	0
363	Ensaladas - Argentina #6	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	18	2025-09-15	1	0
364	Ensaladas - Bolivia #6	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	19	2025-09-15	1	0
365	Ensaladas - Uruguay #6	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	20	2025-09-15	1	0
366	Ensaladas - Paraguay #6	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	21	2025-09-15	1	0
367	Ensaladas - Brasil #6	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	22	2025-09-15	1	0
368	Ensaladas - Ecuador #6	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	23	2025-09-15	1	0
369	Sopas - Chile #6	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	16	2025-09-15	1	0
370	Sopas - PerÔö£Ôòæ #6	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	17	2025-09-15	1	0
371	Sopas - Argentina #6	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	18	2025-09-15	1	0
372	Sopas - Bolivia #6	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	19	2025-09-15	1	0
373	Sopas - Uruguay #6	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	20	2025-09-15	1	0
374	Sopas - Paraguay #6	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	21	2025-09-15	1	0
375	Sopas - Brasil #6	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	22	2025-09-15	1	0
376	Sopas - Ecuador #6	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	23	2025-09-15	1	0
377	Vegetariana - Chile #6	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	16	2025-09-15	1	0
378	Vegetariana - PerÔö£Ôòæ #6	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	17	2025-09-15	1	0
379	Vegetariana - Argentina #6	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	18	2025-09-15	1	0
380	Vegetariana - Bolivia #6	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	19	2025-09-15	1	0
381	Vegetariana - Uruguay #6	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	20	2025-09-15	1	0
382	Vegetariana - Paraguay #6	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	21	2025-09-15	1	0
383	Vegetariana - Brasil #6	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	22	2025-09-15	1	0
384	Vegetariana - Ecuador #6	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	23	2025-09-15	1	0
385	Desayuno - Chile #7	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	16	2025-09-15	1	0
386	Desayuno - PerÔö£Ôòæ #7	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	17	2025-09-15	1	0
387	Desayuno - Argentina #7	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	18	2025-09-15	1	0
388	Desayuno - Bolivia #7	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	19	2025-09-15	1	0
389	Desayuno - Uruguay #7	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	20	2025-09-15	1	0
390	Desayuno - Paraguay #7	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	21	2025-09-15	1	0
391	Desayuno - Brasil #7	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	22	2025-09-15	1	0
392	Desayuno - Ecuador #7	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	23	2025-09-15	1	0
393	Almuerzo - Chile #7	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	16	2025-09-15	1	0
394	Almuerzo - PerÔö£Ôòæ #7	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	17	2025-09-15	1	0
395	Almuerzo - Argentina #7	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	18	2025-09-15	1	0
396	Almuerzo - Bolivia #7	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	19	2025-09-15	1	0
397	Almuerzo - Uruguay #7	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	20	2025-09-15	1	0
398	Almuerzo - Paraguay #7	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	21	2025-09-15	1	0
399	Almuerzo - Brasil #7	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	22	2025-09-15	1	0
400	Almuerzo - Ecuador #7	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	23	2025-09-15	1	0
401	Cena - Chile #7	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	16	2025-09-15	1	0
402	Cena - PerÔö£Ôòæ #7	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	17	2025-09-15	1	0
403	Cena - Argentina #7	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	18	2025-09-15	1	0
404	Cena - Bolivia #7	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	19	2025-09-15	1	0
405	Cena - Uruguay #7	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	20	2025-09-15	1	0
406	Cena - Paraguay #7	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	21	2025-09-15	1	0
407	Cena - Brasil #7	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	22	2025-09-15	1	0
408	Cena - Ecuador #7	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	23	2025-09-15	1	0
409	Postres - Chile #7	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	16	2025-09-15	1	0
410	Postres - PerÔö£Ôòæ #7	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	17	2025-09-15	1	0
411	Postres - Argentina #7	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	18	2025-09-15	1	0
412	Postres - Bolivia #7	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	19	2025-09-15	1	0
413	Postres - Uruguay #7	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	20	2025-09-15	1	0
414	Postres - Paraguay #7	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	21	2025-09-15	1	0
415	Postres - Brasil #7	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	22	2025-09-15	1	0
416	Postres - Ecuador #7	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	23	2025-09-15	1	0
417	Bebidas - Chile #7	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	16	2025-09-15	1	0
418	Bebidas - PerÔö£Ôòæ #7	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	17	2025-09-15	1	0
419	Bebidas - Argentina #7	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	18	2025-09-15	1	0
420	Bebidas - Bolivia #7	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	19	2025-09-15	1	0
421	Bebidas - Uruguay #7	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	20	2025-09-15	1	0
422	Bebidas - Paraguay #7	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	21	2025-09-15	1	0
423	Bebidas - Brasil #7	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	22	2025-09-15	1	0
424	Bebidas - Ecuador #7	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	23	2025-09-15	1	0
425	Ensaladas - Chile #7	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	16	2025-09-15	1	0
426	Ensaladas - PerÔö£Ôòæ #7	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	17	2025-09-15	1	0
427	Ensaladas - Argentina #7	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	18	2025-09-15	1	0
428	Ensaladas - Bolivia #7	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	19	2025-09-15	1	0
429	Ensaladas - Uruguay #7	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	20	2025-09-15	1	0
430	Ensaladas - Paraguay #7	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	21	2025-09-15	1	0
431	Ensaladas - Brasil #7	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	22	2025-09-15	1	0
432	Ensaladas - Ecuador #7	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	23	2025-09-15	1	0
433	Sopas - Chile #7	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	16	2025-09-15	1	0
434	Sopas - PerÔö£Ôòæ #7	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	17	2025-09-15	1	0
435	Sopas - Argentina #7	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	18	2025-09-15	1	0
436	Sopas - Bolivia #7	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	19	2025-09-15	1	0
437	Sopas - Uruguay #7	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	20	2025-09-15	1	0
438	Sopas - Paraguay #7	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	21	2025-09-15	1	0
439	Sopas - Brasil #7	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	22	2025-09-15	1	0
440	Sopas - Ecuador #7	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	23	2025-09-15	1	0
441	Vegetariana - Chile #7	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	16	2025-09-15	1	0
442	Vegetariana - PerÔö£Ôòæ #7	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	17	2025-09-15	1	0
443	Vegetariana - Argentina #7	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	18	2025-09-15	1	0
444	Vegetariana - Bolivia #7	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	19	2025-09-15	1	0
445	Vegetariana - Uruguay #7	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	20	2025-09-15	1	0
446	Vegetariana - Paraguay #7	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	21	2025-09-15	1	0
447	Vegetariana - Brasil #7	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	22	2025-09-15	1	0
448	Vegetariana - Ecuador #7	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	23	2025-09-15	1	0
449	Desayuno - Chile #8	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	16	2025-09-15	1	0
450	Desayuno - PerÔö£Ôòæ #8	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	17	2025-09-15	1	0
451	Desayuno - Argentina #8	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	18	2025-09-15	1	0
452	Desayuno - Bolivia #8	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	19	2025-09-15	1	0
453	Desayuno - Uruguay #8	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	20	2025-09-15	1	0
454	Desayuno - Paraguay #8	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	21	2025-09-15	1	0
455	Desayuno - Brasil #8	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	22	2025-09-15	1	0
456	Desayuno - Ecuador #8	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	23	2025-09-15	1	0
457	Almuerzo - Chile #8	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	16	2025-09-15	1	0
458	Almuerzo - PerÔö£Ôòæ #8	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	17	2025-09-15	1	0
459	Almuerzo - Argentina #8	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	18	2025-09-15	1	0
460	Almuerzo - Bolivia #8	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	19	2025-09-15	1	0
461	Almuerzo - Uruguay #8	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	20	2025-09-15	1	0
462	Almuerzo - Paraguay #8	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	21	2025-09-15	1	0
463	Almuerzo - Brasil #8	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	22	2025-09-15	1	0
464	Almuerzo - Ecuador #8	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	23	2025-09-15	1	0
465	Cena - Chile #8	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	16	2025-09-15	1	0
466	Cena - PerÔö£Ôòæ #8	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	17	2025-09-15	1	0
467	Cena - Argentina #8	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	18	2025-09-15	1	0
468	Cena - Bolivia #8	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	19	2025-09-15	1	0
469	Cena - Uruguay #8	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	20	2025-09-15	1	0
470	Cena - Paraguay #8	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	21	2025-09-15	1	0
471	Cena - Brasil #8	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	22	2025-09-15	1	0
472	Cena - Ecuador #8	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	23	2025-09-15	1	0
473	Postres - Chile #8	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	16	2025-09-15	1	0
474	Postres - PerÔö£Ôòæ #8	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	17	2025-09-15	1	0
475	Postres - Argentina #8	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	18	2025-09-15	1	0
476	Postres - Bolivia #8	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	19	2025-09-15	1	0
477	Postres - Uruguay #8	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	20	2025-09-15	1	0
478	Postres - Paraguay #8	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	21	2025-09-15	1	0
479	Postres - Brasil #8	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	22	2025-09-15	1	0
480	Postres - Ecuador #8	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	23	2025-09-15	1	0
481	Bebidas - Chile #8	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	16	2025-09-15	1	0
482	Bebidas - PerÔö£Ôòæ #8	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	17	2025-09-15	1	0
483	Bebidas - Argentina #8	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	18	2025-09-15	1	0
484	Bebidas - Bolivia #8	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	19	2025-09-15	1	0
485	Bebidas - Uruguay #8	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	20	2025-09-15	1	0
486	Bebidas - Paraguay #8	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	21	2025-09-15	1	0
487	Bebidas - Brasil #8	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	22	2025-09-15	1	0
488	Bebidas - Ecuador #8	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	23	2025-09-15	1	0
489	Ensaladas - Chile #8	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	16	2025-09-15	1	0
490	Ensaladas - PerÔö£Ôòæ #8	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	17	2025-09-15	1	0
491	Ensaladas - Argentina #8	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	18	2025-09-15	1	0
492	Ensaladas - Bolivia #8	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	19	2025-09-15	1	0
493	Ensaladas - Uruguay #8	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	20	2025-09-15	1	0
494	Ensaladas - Paraguay #8	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	21	2025-09-15	1	0
495	Ensaladas - Brasil #8	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	22	2025-09-15	1	0
496	Ensaladas - Ecuador #8	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	23	2025-09-15	1	0
497	Sopas - Chile #8	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	16	2025-09-15	1	0
498	Sopas - PerÔö£Ôòæ #8	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	17	2025-09-15	1	0
499	Sopas - Argentina #8	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	18	2025-09-15	1	0
500	Sopas - Bolivia #8	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	19	2025-09-15	1	0
501	Sopas - Uruguay #8	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	20	2025-09-15	1	0
502	Sopas - Paraguay #8	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	21	2025-09-15	1	0
503	Sopas - Brasil #8	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	22	2025-09-15	1	0
504	Sopas - Ecuador #8	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	23	2025-09-15	1	0
505	Vegetariana - Chile #8	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	16	2025-09-15	1	0
506	Vegetariana - PerÔö£Ôòæ #8	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	17	2025-09-15	1	0
507	Vegetariana - Argentina #8	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	18	2025-09-15	1	0
508	Vegetariana - Bolivia #8	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	19	2025-09-15	1	0
509	Vegetariana - Uruguay #8	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	20	2025-09-15	1	0
510	Vegetariana - Paraguay #8	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	21	2025-09-15	1	0
511	Vegetariana - Brasil #8	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	22	2025-09-15	1	0
512	Vegetariana - Ecuador #8	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	23	2025-09-15	1	0
513	Desayuno - Chile #9	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	16	2025-09-15	1	0
514	Desayuno - PerÔö£Ôòæ #9	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	17	2025-09-15	1	0
515	Desayuno - Argentina #9	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	18	2025-09-15	1	0
516	Desayuno - Bolivia #9	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	19	2025-09-15	1	0
517	Desayuno - Uruguay #9	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	20	2025-09-15	1	0
518	Desayuno - Paraguay #9	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	21	2025-09-15	1	0
519	Desayuno - Brasil #9	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	22	2025-09-15	1	0
520	Desayuno - Ecuador #9	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	23	2025-09-15	1	0
521	Almuerzo - Chile #9	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	16	2025-09-15	1	0
522	Almuerzo - PerÔö£Ôòæ #9	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	17	2025-09-15	1	0
523	Almuerzo - Argentina #9	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	18	2025-09-15	1	0
524	Almuerzo - Bolivia #9	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	19	2025-09-15	1	0
525	Almuerzo - Uruguay #9	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	20	2025-09-15	1	0
526	Almuerzo - Paraguay #9	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	21	2025-09-15	1	0
527	Almuerzo - Brasil #9	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	22	2025-09-15	1	0
528	Almuerzo - Ecuador #9	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	23	2025-09-15	1	0
529	Cena - Chile #9	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	16	2025-09-15	1	0
530	Cena - PerÔö£Ôòæ #9	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	17	2025-09-15	1	0
531	Cena - Argentina #9	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	18	2025-09-15	1	0
532	Cena - Bolivia #9	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	19	2025-09-15	1	0
533	Cena - Uruguay #9	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	20	2025-09-15	1	0
534	Cena - Paraguay #9	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	21	2025-09-15	1	0
535	Cena - Brasil #9	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	22	2025-09-15	1	0
536	Cena - Ecuador #9	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	23	2025-09-15	1	0
537	Postres - Chile #9	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	16	2025-09-15	1	0
538	Postres - PerÔö£Ôòæ #9	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	17	2025-09-15	1	0
539	Postres - Argentina #9	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	18	2025-09-15	1	0
540	Postres - Bolivia #9	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	19	2025-09-15	1	0
541	Postres - Uruguay #9	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	20	2025-09-15	1	0
542	Postres - Paraguay #9	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	21	2025-09-15	1	0
543	Postres - Brasil #9	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	22	2025-09-15	1	0
544	Postres - Ecuador #9	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	23	2025-09-15	1	0
545	Bebidas - Chile #9	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	16	2025-09-15	1	0
546	Bebidas - PerÔö£Ôòæ #9	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	17	2025-09-15	1	0
547	Bebidas - Argentina #9	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	18	2025-09-15	1	0
548	Bebidas - Bolivia #9	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	19	2025-09-15	1	0
549	Bebidas - Uruguay #9	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	20	2025-09-15	1	0
550	Bebidas - Paraguay #9	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	21	2025-09-15	1	0
551	Bebidas - Brasil #9	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	22	2025-09-15	1	0
552	Bebidas - Ecuador #9	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	23	2025-09-15	1	0
553	Ensaladas - Chile #9	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	16	2025-09-15	1	0
554	Ensaladas - PerÔö£Ôòæ #9	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	17	2025-09-15	1	0
555	Ensaladas - Argentina #9	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	18	2025-09-15	1	0
556	Ensaladas - Bolivia #9	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	19	2025-09-15	1	0
557	Ensaladas - Uruguay #9	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	20	2025-09-15	1	0
558	Ensaladas - Paraguay #9	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	21	2025-09-15	1	0
559	Ensaladas - Brasil #9	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	22	2025-09-15	1	0
560	Ensaladas - Ecuador #9	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	23	2025-09-15	1	0
561	Sopas - Chile #9	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	16	2025-09-15	1	0
562	Sopas - PerÔö£Ôòæ #9	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	17	2025-09-15	1	0
563	Sopas - Argentina #9	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	18	2025-09-15	1	0
564	Sopas - Bolivia #9	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	19	2025-09-15	1	0
565	Sopas - Uruguay #9	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	20	2025-09-15	1	0
566	Sopas - Paraguay #9	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	21	2025-09-15	1	0
567	Sopas - Brasil #9	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	22	2025-09-15	1	0
568	Sopas - Ecuador #9	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	23	2025-09-15	1	0
569	Vegetariana - Chile #9	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	16	2025-09-15	1	0
570	Vegetariana - PerÔö£Ôòæ #9	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	17	2025-09-15	1	0
571	Vegetariana - Argentina #9	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	18	2025-09-15	1	0
572	Vegetariana - Bolivia #9	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	19	2025-09-15	1	0
573	Vegetariana - Uruguay #9	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	20	2025-09-15	1	0
574	Vegetariana - Paraguay #9	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	21	2025-09-15	1	0
575	Vegetariana - Brasil #9	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	22	2025-09-15	1	0
576	Vegetariana - Ecuador #9	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	23	2025-09-15	1	0
577	Desayuno - Chile #10	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	16	2025-09-15	1	0
578	Desayuno - PerÔö£Ôòæ #10	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	17	2025-09-15	1	0
579	Desayuno - Argentina #10	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	18	2025-09-15	1	0
580	Desayuno - Bolivia #10	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	19	2025-09-15	1	0
581	Desayuno - Uruguay #10	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	20	2025-09-15	1	0
582	Desayuno - Paraguay #10	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	21	2025-09-15	1	0
583	Desayuno - Brasil #10	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	22	2025-09-15	1	0
584	Desayuno - Ecuador #10	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	23	2025-09-15	1	0
585	Almuerzo - Chile #10	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	16	2025-09-15	1	0
586	Almuerzo - PerÔö£Ôòæ #10	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	17	2025-09-15	1	0
587	Almuerzo - Argentina #10	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	18	2025-09-15	1	0
588	Almuerzo - Bolivia #10	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	19	2025-09-15	1	0
589	Almuerzo - Uruguay #10	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	20	2025-09-15	1	0
590	Almuerzo - Paraguay #10	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	21	2025-09-15	1	0
591	Almuerzo - Brasil #10	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	22	2025-09-15	1	0
592	Almuerzo - Ecuador #10	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	23	2025-09-15	1	0
593	Cena - Chile #10	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	16	2025-09-15	1	0
594	Cena - PerÔö£Ôòæ #10	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	17	2025-09-15	1	0
595	Cena - Argentina #10	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	18	2025-09-15	1	0
596	Cena - Bolivia #10	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	19	2025-09-15	1	0
597	Cena - Uruguay #10	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	20	2025-09-15	1	0
598	Cena - Paraguay #10	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	21	2025-09-15	1	0
599	Cena - Brasil #10	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	22	2025-09-15	1	0
600	Cena - Ecuador #10	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Cena en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	27	23	2025-09-15	1	0
601	Postres - Chile #10	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	16	2025-09-15	1	0
602	Postres - PerÔö£Ôòæ #10	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	17	2025-09-15	1	0
603	Postres - Argentina #10	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	18	2025-09-15	1	0
604	Postres - Bolivia #10	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	19	2025-09-15	1	0
619	Ensaladas - Argentina #10	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	18	2025-09-15	1	0
2	Desayuno - PerÔö£Ôòæ #1	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	17	2025-09-15	1	0
4	Desayuno - Bolivia #1	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	19	2025-09-15	1	0
5	Desayuno - Uruguay #1	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	20	2025-09-15	1	0
6	Desayuno - Paraguay #1	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	21	2025-09-15	1	0
7	Desayuno - Brasil #1	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	22	2025-09-15	1	0
8	Desayuno - Ecuador #1	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	23	2025-09-15	1	0
625	Sopas - Chile #10	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	16	2025-09-15	1	0
605	Postres - Uruguay #10	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	20	2025-09-15	1	0
606	Postres - Paraguay #10	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	21	2025-09-15	1	0
607	Postres - Brasil #10	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	22	2025-09-15	1	0
608	Postres - Ecuador #10	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Postres en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	28	23	2025-09-15	1	0
609	Bebidas - Chile #10	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	16	2025-09-15	1	0
610	Bebidas - PerÔö£Ôòæ #10	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	17	2025-09-15	1	0
611	Bebidas - Argentina #10	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	18	2025-09-15	1	0
612	Bebidas - Bolivia #10	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	19	2025-09-15	1	0
613	Bebidas - Uruguay #10	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	20	2025-09-15	1	0
614	Bebidas - Paraguay #10	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	21	2025-09-15	1	0
615	Bebidas - Brasil #10	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	22	2025-09-15	1	0
616	Bebidas - Ecuador #10	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Bebidas en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	29	23	2025-09-15	1	0
617	Ensaladas - Chile #10	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	16	2025-09-15	1	0
618	Ensaladas - PerÔö£Ôòæ #10	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	17	2025-09-15	1	0
621	Ensaladas - Uruguay #10	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	20	2025-09-15	1	0
622	Ensaladas - Paraguay #10	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	21	2025-09-15	1	0
623	Ensaladas - Brasil #10	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	22	2025-09-15	1	0
624	Ensaladas - Ecuador #10	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	23	2025-09-15	1	0
626	Sopas - PerÔö£Ôòæ #10	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	17	2025-09-15	1	0
627	Sopas - Argentina #10	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	18	2025-09-15	1	0
628	Sopas - Bolivia #10	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	19	2025-09-15	1	0
629	Sopas - Uruguay #10	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	20	2025-09-15	1	0
630	Sopas - Paraguay #10	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	21	2025-09-15	1	0
631	Sopas - Brasil #10	https://images.pexels.com/photos/1437267/pexels-photo-1437267.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	22	2025-09-15	1	0
632	Sopas - Ecuador #10	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Sopas en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	31	23	2025-09-15	1	0
633	Vegetariana - Chile #10	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Chile. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	16	2025-09-15	1	0
634	Vegetariana - PerÔö£Ôòæ #10	https://images.pexels.com/photos/2232/vegetables-italian-pizza-restaurant.jpg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en PerÔö£Ôòæ. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	17	2025-09-15	1	0
635	Vegetariana - Argentina #10	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	18	2025-09-15	1	0
636	Vegetariana - Bolivia #10	https://images.pexels.com/photos/357756/pexels-photo-357756.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	19	2025-09-15	1	0
637	Vegetariana - Uruguay #10	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Uruguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	20	2025-09-15	1	0
638	Vegetariana - Paraguay #10	https://images.pexels.com/photos/1279330/pexels-photo-1279330.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Paraguay. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	21	2025-09-15	1	0
639	Vegetariana - Brasil #10	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	22	2025-09-15	1	0
640	Vegetariana - Ecuador #10	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Vegetariana en Ecuador. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	32	23	2025-09-15	1	0
3	Desayuno - Argentina #1	https://images.pexels.com/photos/704569/pexels-photo-704569.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Desayuno en Argentina. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	25	18	2025-09-15	1	4
15	Almuerzo - Brasil #1	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Almuerzo en Brasil. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	26	22	2025-09-15	1	1
643	Paella Valenciana API Test	https://example.com/paella.jpg		1. Calentar aceite en paellera. 2. Sofreir pollo y verduras. 3. Agregar arroz y caldo. 4. Cocinar 18 minutos.	1	26	22	2025-10-08	3	0
644	Pasta Italiana API Test	https://example.com/pasta.jpg		1. Hervir agua con sal. 2. Cocinar pasta al dente. 3. Preparar salsa. 4. Mezclar y servir caliente.	1	26	26	2025-10-08	3	0
620	Ensaladas - Bolivia #10	https://images.pexels.com/photos/461198/pexels-photo-461198.jpeg		PreparaciÔö£Ôöén bÔö£├¡sica de Ensaladas en Bolivia. Paso 1: preparar ingredientes. Paso 2: cocinar. Paso 3: servir.	1	30	19	2025-09-15	1	8
648	Receta Modificada Automatizada	https://example.com/receta-modificada.jpg		Preparacion actualizada por prueba automatizada	0	36	28	2025-10-10	15	0
658	Lasa├▒a Bolo├▒esa Italiana	https://images.pexels.com/photos/4518843/pexels-photo-4518843.jpeg		1. Preparar salsa bolo├▒esa con carne, cebolla, ajo, tomate y vino. 2. Hacer bechamel con mantequilla, harina y leche. 3. Cocer pasta al dente. 4. Armar lasa├▒a alternando capas. 5. Hornear 180┬░C por 45 min. 6. Reposar 10 min antes de servir.	1	26	26	2025-10-10	1	0
\.


--
-- Data for Name: receta_del_dia; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.receta_del_dia (fecha, id_receta) FROM stdin;
2025-10-09	416
2025-10-10	270
2025-10-11	483
\.


--
-- Data for Name: sesion_pago; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sesion_pago (id_sesion, session_id, provider, status, id_donacion, metadata, fecha_creacion, fecha_actualizacion) FROM stdin;
\.


--
-- Data for Name: usuario; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.usuario (id_usr, nombre, apellido, email, password, estado, fecha_creacion, comentario, id_perfil) FROM stdin;
7	PruebaThunder	Usuario	prueba.thunder+1@example.com	$2a$06$3vDleacpE8rP75yBUHBCmuhU8GRRY/t4umAeHEKg3r8mCnGQnyH7W	1	2025-09-08 21:53:46.021986	\N	1
8	APIUser	Test	apitest@example.com	$2a$10$VeBs7norj.6WZdYVUs8SFez6RoL0jvbiqAl5tPponpyjBcjru47xa	1	2025-09-10 11:29:11.221284	\N	1
10	API Insert	Test	castuser@example.com	$2b$12$7sWkQ0gzFZzZr6v1hZkH2eYyHgmLg/9wtnePa4UXlKsZt3Rw7Qod.	1	2025-09-10 14:32:02.56812	\N	1
13	UsuarioAPI	Test	usuario.api.test@example.com	$2a$10$s3XBM./20zAUUoq4213KteExUqJsIUC8U4wMfpZ1vzQc3fPfCK9ou	1	2025-10-08 03:57:04.989975	\N	1
14	Usuario	CRUD Test	usuario.crud@test.com	$2a$10$SoY65leZF5fNwspPtAgSxuQQmNpkvlFVmMWemyLJodhN0P9H8yQo6	1	2025-10-08 11:49:32.848462	\N	1
15	TestUser	Prueba	test@prueba.cl	$2a$10$k/zr1IOT89cgiBOBSENg1OdHj3mYqYYBtgSGTW.N1IUlkR82VPQxq	1	2025-10-10 01:41:18.461249	\N	1
17	Usuario Test	Apellido Test	test240740642@example.com	$2a$10$CgeDQYOuYtki5xMbjJSYpuloxR8onLj2W1Q.0qkqWlFeKjLL0Kdgm	1	2025-10-10 15:00:52.74539	\N	1
18	Test User	Test Last	test151215@test.com	$2a$10$aWxUyKH8zyq3KoImSAIi1..nkGz6FSFe7mTvQaJ9HK.kSXta7ERjK	1	2025-10-10 15:12:15.633962	\N	1
19	Test User	Test Last	test153004@test.com	$2a$10$LOC/RvzfQiSf.tFZaCTY9eLJ2O.DFnyG0zN/77HnFKTpOnuB1U5rS	0	2025-10-10 15:30:04.591098	\N	1
20	Test User	Test Last	test153316@test.com	$2a$10$xOOYuYsVApeVFzGigL4Veuev.dsFWaA5V8AiD9cj.5zJLZiOkULDe	0	2025-10-10 15:33:16.810668	\N	1
21	Test User	Test	testuser1905487739@test.com	$2a$10$3Mtxlb.NqO9hVaPrlbT5lOdwWqYV3MMI6Hhv2z1weBAvmeDusYSwa	1	2025-10-10 15:50:04.545947	\N	1
22	Test User	Auto	testuser155004@auto.com	$2a$10$jxu07m17dfiS9taBi6rTuu0Qo8Oqt6Rw9yVa1auE6yF4pTcULR0tu	0	2025-10-10 15:50:05.045665	\N	1
2	User	Test	user@recetas.com	$2a$06$WKZzXwq8yrrjIGRdfYYzQucfwFH53ssYZ9oKlzuYDZw0GmUVcsbpK	1	2023-06-27 10:00:19	\N	1
3	Claudio	Sanchez	cla.sanchezt@duo	$2a$06$WKZzXwq8yrrjIGRdfYYzQucfwFH53ssYZ9oKlzuYDZw0GmUVcsbpK	1	2024-05-26 17:15:11	\N	2
1	Admin	System	admin@recetas.com	$2a$06$WKZzXwq8yrrjIGRdfYYzQucfwFH53ssYZ9oKlzuYDZw0GmUVcsbpK	1	2023-06-26 23:58:57	\N	3
\.


--
-- (carrusel sequence setval removed)
SELECT pg_catalog.setval('public.carrusel_id_carrusel_seq', 1, false);


--
-- Name: categoria_id_cat_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categoria_id_cat_seq', 45, true);


--
-- Name: comentario_id_comentario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.comentario_id_comentario_seq', 1466, true);


--
-- Name: donacion_id_donacion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.donacion_id_donacion_seq', 3, true);


--
-- Name: estrella_id_estrella_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.estrella_id_estrella_seq', 1282, true);


--
-- Name: favorito_id_fav_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.favorito_id_fav_seq', 647, true);


--
-- Name: ingrediente_new_id_ingrediente_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ingrediente_new_id_ingrediente_seq', 3210, true);


--
-- Name: me_gusta_id_megusta_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.me_gusta_id_megusta_seq', 1925, true);


--
-- Name: pais_id_pais_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pais_id_pais_seq', 43, true);


--
-- Name: perfil_id_perfil_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.perfil_id_perfil_seq', 3, true);


--
-- Name: receta_id_receta_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.receta_id_receta_seq', 658, true);


--
-- Name: sesion_pago_id_sesion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sesion_pago_id_sesion_seq', 1, false);


--
-- Name: usuario_id_usr_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usuario_id_usr_seq', 22, true);


--
-- (carrusel primary key constraint removed)
    -- ADD CONSTRAINT carrusel_pkey PRIMARY KEY (id_carrusel); -- removed (carrusel table eliminated)


--
-- Name: categoria categoria_nombre_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria
    ADD CONSTRAINT categoria_nombre_key UNIQUE (nombre);


--
-- Name: categoria categoria_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria
    ADD CONSTRAINT categoria_pkey PRIMARY KEY (id_cat);


--
-- Name: comentario comentario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comentario
    ADD CONSTRAINT comentario_pkey PRIMARY KEY (id_comentario);


--
-- Name: donacion donacion_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.donacion
    ADD CONSTRAINT donacion_pkey PRIMARY KEY (id_donacion);


--
-- Name: estrella estrella_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estrella
    ADD CONSTRAINT estrella_pkey PRIMARY KEY (id_estrella);


--
-- Name: favorito favorito_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favorito
    ADD CONSTRAINT favorito_pkey PRIMARY KEY (id_fav);


--
-- Name: ingrediente ingrediente_new_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingrediente
    ADD CONSTRAINT ingrediente_new_pkey PRIMARY KEY (id_ingrediente);


--
-- Name: me_gusta me_gusta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.me_gusta
    ADD CONSTRAINT me_gusta_pkey PRIMARY KEY (id_megusta);


--
-- Name: pais pais_nombre_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pais
    ADD CONSTRAINT pais_nombre_key UNIQUE (nombre);


--
-- Name: pais pais_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pais
    ADD CONSTRAINT pais_pkey PRIMARY KEY (id_pais);


--
-- Name: perfil perfil_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.perfil
    ADD CONSTRAINT perfil_pkey PRIMARY KEY (id_perfil);


--
-- Name: receta_del_dia receta_del_dia_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.receta_del_dia
    ADD CONSTRAINT receta_del_dia_pkey PRIMARY KEY (fecha);


--
-- Name: receta receta_nombre_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.receta
    ADD CONSTRAINT receta_nombre_key UNIQUE (nombre);


--
-- Name: receta receta_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.receta
    ADD CONSTRAINT receta_pkey PRIMARY KEY (id_receta);


--
-- Name: sesion_pago sesion_pago_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sesion_pago
    ADD CONSTRAINT sesion_pago_pkey PRIMARY KEY (id_sesion);


--
-- Name: favorito uk887bu4uo8aawt4vqxaf9tgpxu; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favorito
    ADD CONSTRAINT uk887bu4uo8aawt4vqxaf9tgpxu UNIQUE (id_usr, id_receta);


--
-- Name: perfil uk_3b0dloqo94v7r6tjahpid9hc3; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.perfil
    ADD CONSTRAINT uk_3b0dloqo94v7r6tjahpid9hc3 UNIQUE (nombre);


--
-- Name: usuario usuario_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_email_key UNIQUE (email);


--
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id_usr);


--
-- Name: idx_comentario_id_receta; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_comentario_id_receta ON public.comentario USING btree (id_receta);


--
-- Name: idx_ingrediente_id_receta; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_ingrediente_id_receta ON public.ingrediente USING btree (id_receta);


--
-- Name: idx_receta_id_cat; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_receta_id_cat ON public.receta USING btree (id_cat);


--
-- Name: idx_receta_id_pais; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_receta_id_pais ON public.receta USING btree (id_pais);


--
-- Name: idx_receta_id_usr; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_receta_id_usr ON public.receta USING btree (id_usr);


--
-- Name: ux_favorito_usr_receta; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_favorito_usr_receta ON public.favorito USING btree (id_usr, id_receta);


--
-- Name: ux_sesion_pago_sessionid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_sesion_pago_sessionid ON public.sesion_pago USING btree (session_id);


--
-- Name: ux_usuario_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_usuario_email ON public.usuario USING btree (email);


--
-- Name: sesion_pago set_fecha_actualizacion; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER set_fecha_actualizacion BEFORE UPDATE ON public.sesion_pago FOR EACH ROW EXECUTE FUNCTION public.trg_update_fecha_actualizacion();


--
-- (carrusel fk constraint removed)
    -- ADD CONSTRAINT carrusel_id_usr_fkey FOREIGN KEY (id_usr) REFERENCES public.usuario(id_usr); -- removed (carrusel table eliminated)


--
-- Name: categoria categoria_id_usr_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categoria
    ADD CONSTRAINT categoria_id_usr_fkey FOREIGN KEY (id_usr) REFERENCES public.usuario(id_usr);


--
-- Name: comentario comentario_receta_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comentario
    ADD CONSTRAINT comentario_receta_fkey FOREIGN KEY (id_receta) REFERENCES public.receta(id_receta) ON DELETE CASCADE;


--
-- Name: comentario comentario_usuario_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comentario
    ADD CONSTRAINT comentario_usuario_fkey FOREIGN KEY (id_usr) REFERENCES public.usuario(id_usr);


--
-- Name: donacion donacion_id_receta_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.donacion
    ADD CONSTRAINT donacion_id_receta_fk FOREIGN KEY (id_receta) REFERENCES public.receta(id_receta) ON DELETE SET NULL;


--
-- Name: donacion donacion_id_usr_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.donacion
    ADD CONSTRAINT donacion_id_usr_fk FOREIGN KEY (id_usr) REFERENCES public.usuario(id_usr) ON DELETE SET NULL;


--
-- Name: ingrediente fk_ingrediente_receta; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ingrediente
    ADD CONSTRAINT fk_ingrediente_receta FOREIGN KEY (id_receta) REFERENCES public.receta(id_receta) ON DELETE CASCADE;


--
-- Name: sesion_pago fk_sesion_pago_donacion; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sesion_pago
    ADD CONSTRAINT fk_sesion_pago_donacion FOREIGN KEY (id_donacion) REFERENCES public.donacion(id_donacion) ON DELETE SET NULL;


--
-- Name: me_gusta fkeu6k9bc9cdoikmwh3xc81oy48; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.me_gusta
    ADD CONSTRAINT fkeu6k9bc9cdoikmwh3xc81oy48 FOREIGN KEY (id_receta) REFERENCES public.receta(id_receta);


--
-- Name: estrella fkfey8w00kt60dhi2c4i96dj4b2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estrella
    ADD CONSTRAINT fkfey8w00kt60dhi2c4i96dj4b2 FOREIGN KEY (id_usr) REFERENCES public.usuario(id_usr);


--
-- Name: favorito fkh7xyncd05syjb4qbrc87i0da2; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favorito
    ADD CONSTRAINT fkh7xyncd05syjb4qbrc87i0da2 FOREIGN KEY (id_receta) REFERENCES public.receta(id_receta);


--
-- Name: me_gusta fklt9disbee9m0fbsu33vxh7qdy; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.me_gusta
    ADD CONSTRAINT fklt9disbee9m0fbsu33vxh7qdy FOREIGN KEY (id_usr) REFERENCES public.usuario(id_usr);


--
-- Name: favorito fkrq0y1oifowf2v3iu8mtqqidvs; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.favorito
    ADD CONSTRAINT fkrq0y1oifowf2v3iu8mtqqidvs FOREIGN KEY (id_usr) REFERENCES public.usuario(id_usr);


--
-- Name: estrella fkrxcbprpobmiqkdxmoo32ylkld; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.estrella
    ADD CONSTRAINT fkrxcbprpobmiqkdxmoo32ylkld FOREIGN KEY (id_receta) REFERENCES public.receta(id_receta);


--
-- Name: pais pais_id_usr_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.pais
    ADD CONSTRAINT pais_id_usr_fkey FOREIGN KEY (id_usr) REFERENCES public.usuario(id_usr);


--
-- Name: receta receta_id_cat_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.receta
    ADD CONSTRAINT receta_id_cat_fkey FOREIGN KEY (id_cat) REFERENCES public.categoria(id_cat);


--
-- Name: receta receta_id_pais_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.receta
    ADD CONSTRAINT receta_id_pais_fkey FOREIGN KEY (id_pais) REFERENCES public.pais(id_pais);


--
-- Name: receta receta_id_usr_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.receta
    ADD CONSTRAINT receta_id_usr_fkey FOREIGN KEY (id_usr) REFERENCES public.usuario(id_usr);


--
-- Name: usuario usuario_id_perfil_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_id_perfil_fk FOREIGN KEY (id_perfil) REFERENCES public.perfil(id_perfil);


--
-- PostgreSQL database dump complete
--

\unrestrict QjOblnNyCu2vWqJS2YdUrsIes5UbuPto4dtHzP6DHxU2yWOgdHuEITQkE7eEBka

