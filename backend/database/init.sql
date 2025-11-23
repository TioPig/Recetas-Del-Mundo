--
-- PostgreSQL database dump
--

\restrict S9tMk1vvFdekt6UIu6jh3Qw3cfkYq364TiedTBODe6e5t0LdhQWIhoyuW9DA5T4

-- Dumped from database version 15.14 (Debian 15.14-1.pgdg13+1)
-- Dumped by pg_dump version 15.14 (Debian 15.14-1.pgdg13+1)

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
    nombre text NOT NULL,
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
    preparacion text NOT NULL,
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
    session_id text NOT NULL,
    provider text DEFAULT 'unknown'::character varying NOT NULL,
    status text DEFAULT 'PENDING'::character varying NOT NULL,
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
    fecha_creacion timestamp(6) without time zone DEFAULT now(),
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
-- Data for Name: categoria; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.categoria (id_cat, nombre, url_imagen, estado, fecha_creacion, comentario, id_usr) FROM stdin;
19	Desayuno	https://encrypted-tbn3.gstatic.com/licensed-image?q=tbn:ANd9GcQ8n5bxzJh1iU5oECdzL6GYrRFGr_wRXXAWxKmmb01zMyClpmakwc9KzSG9DghIbd3CNI3gxKeBgY24b3lKK_m-cD8bBqLZPPMpSS28huHdLZ1TsIE	1	2023-06-27 11:19:33	\N	2
20	Vacuno	https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcSxnHB9EC9gM34d7riLzUtok1ybFtIBvUQvK6KviPJcK7PmaaCoMI_PuAxd8BD0	1	2023-06-27 11:20:20	\N	2
21	Pollo	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSyt2bNhPv4BuesF75CjDINvXhUktsKg8dgLh1WEyQ7CNWznZCL97Ro7NtHVR4Z	1	2023-06-27 11:20:29	\N	2
22	Postre	https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcRuLl2x45bEiqADcQkcm8nDEsBdZOQFMvs0SsaU1UEjjssvkLkGMDUl5AnfGQw4	1	2023-06-27 11:20:44	\N	2
23	Cabrito	https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcQzGJFzf15arOu0xT1y_l7ctYfoGjAM824dYSRHqpcuyEwQd2TFxqmevo3Q7kRq	1	2023-06-27 11:21:03	\N	2
24	Cordero	https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcSlFHNtVRgs1TS5IZxGTysDVahTdjQfRkLMkFxnrtRIY1jOsak8E8ya3Ef3osuw	1	2023-06-27 11:21:15	\N	2
25	Varios	https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcS9oL4ZVJlvXljE5dxE_ViPiFbj8E7seEhatStw7kVk149PIpctkM_Rpbptff0U	1	2023-06-27 11:21:24	\N	2
26	Pasta	https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcQvCQyQA_BVHk1rURehN9xZ62ah3i2en2jzafekEXjOg5Q-hHZMuEfEMdwLs_Gi	1	2023-06-27 11:21:37	\N	2
27	Cerdo	https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcSWzY1BD8vpeLMduroA3uyY2BaWP-2454t6LuHLGpbeu8uBMzPzS5WE2oq0c4rR	1	2023-06-27 11:21:52	\N	2
28	Mariscos	https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcRzP4mM7nKue5Q-mL2GdkB6j2ZNasRAibXWcNJgIifafb-toiMB3NTdT-LHFBg4	1	2023-06-27 11:22:05	\N	2
29	Acompañamiento	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcST8g6ipCC437gi4Mk-tppWofcx5VLAT7HgmVA45DlZ1R7nxO2OdOs7nu9pIPdL	1	2023-06-27 11:22:15	\N	2
30	Entrada	https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcTutGyFTaGbUo4VM90u67PbXbJpZf0Qk9prBsfbPE2jyLNbM9-yyVZwtvYXwn7e	1	2023-06-27 11:40:32	\N	2
31	Vegano	https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcSlmX6KvR3REikLwp4segzREuuT5UCkFhcgKS-i0_Wz-UWgrZDszSlGCO0h4d9U	1	2023-06-27 11:40:43	\N	2
32	Vegetariano	https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcQwLWDbuFf4QSLIBzdXq4UIgEoL56LUIUfnU94Bxz2t7NzlAvhiw07NUIn72_Ng	1	2023-06-27 11:40:50	\N	2
1	Café y Bebidas	\N	1	2025-11-07 01:29:44.85785	\N	\N
2	Niños - Comida	\N	1	2025-11-07 01:29:44.85785	\N	\N
3	México Tradicional	\N	1	2025-11-07 01:29:44.85785	\N	\N
\.


--
-- Data for Name: comentario; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.comentario (id_comentario, fecha_creacion, id_receta, texto, id_usr) FROM stdin;
1480	2025-11-02 14:04:41.646716	8	Comentario final de prueba	68
1481	2025-11-02 14:52:11.273404	8	Comentario habilitado exitosamente	68
1484	2025-11-03 23:44:48.480696	8	Comentario de prueba 20:44:48	1
1485	2025-11-04 02:09:31.283405	8	test desde powershell	1
1486	2025-11-04 02:09:31.425657	8	test desde proxy	1
1487	2025-11-04 02:12:32.195821	8	test con usuario 3	1
1488	2025-11-04 02:15:22.937585	8	test sin id_usr	1
1489	2025-11-04 04:02:22.908744	12	perrororororororororo	3
1490	2025-11-04 20:37:39.68209	9	buena la receta, que tal la preparacion	3
1491	2025-11-04 20:44:58.302915	10	prueba de comentario 1	3
1492	2025-11-04 20:45:05.002878	10	prueba de comentario 2	3
1493	2025-11-04 21:01:42.995418	10	otro comentario ver como se ve	3
1494	2025-11-04 21:03:14.478006	10	otro mas comentario	3
1495	2025-11-04 21:12:01.329721	10	prueba de comentario 5	3
1496	2025-11-04 21:14:05.102733	10	prueba de comentario 6	3
\.


--
-- Data for Name: donacion; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.donacion (id_donacion, amount, currency, fecha_actualizacion, fecha_creacion, id_receta, id_usr, status, stripe_payment_intent, stripe_session_id) FROM stdin;
\.


--
-- Data for Name: estrella; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.estrella (id_estrella, fecha_creacion, valor, id_receta, id_usr) FROM stdin;
1	2025-11-02 03:10:19.49803	4	12	55
2	2025-11-02 10:56:33.946176	4	12	67
7	2025-11-02 13:42:36.891516	3	8	68
13	2025-11-04 03:53:33.881084	5	12	3
14	2025-11-04 20:37:45.71205	3	9	3
15	2025-11-04 20:44:08.494475	5	10	3
\.


--
-- Data for Name: favorito; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.favorito (id_fav, fecha_creacion, id_receta, id_usr) FROM stdin;
1	2025-11-02 02:58:17.025785	12	55
14	2025-11-03 00:28:14.089603	8	78
18	2025-11-03 23:44:48.338187	8	1
23	2025-11-04 00:09:30.222345	8	3
24	2025-11-04 21:00:55.543619	10	3
\.


--
-- Data for Name: ingrediente; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ingrediente (id_ingrediente, nombre, id_receta) FROM stdin;
17	2 plátanos bien maduros (mientras más manchas negras, más dulces).\n\nHarina: 1 ½ tazas de harina sin polvos de hornear (harina común).\n\nPolvos de hornear: 1 ½ cucharaditas.\n\nHuevo: 1 huevo grande.\n\nLeche: 1 taza (puede ser leche de vaca o vegetal).\n\nMantequilla: 2 cucharadas de mantequilla derretida (o aceite vegetal).\n\nAzúcar (Opcional): 1 a 2 cucharadas (los plátanos maduros ya aportan dulzor).\n\nExtracto de vainilla: 1 cucharadita.\n\nSal: ¼ cucharadita.\n\nOpcional: ½ cucharadita de canela en polvo.\n\nPara cocinar: Mantequilla o aceite para el sartén.	3
18	(Para 2 tazas)\n\nLeche entera: 2 tazas (480 ml).\n\nChocolate semiamargo: 100 g (aprox. 3.5 onzas), de buena calidad, troceado fino.\n\nCacao en polvo: 2 cucharadas, sin azúcar.\n\nAzúcar: 2 a 3 cucharadas (ajusta a tu gusto).\n\nExtracto de vainilla: ½ cucharadita.\n\nSal: Una pizca.\n\nOpcional: Crema batida (whipped cream) para decorar.	4
51	• 250g de mote de trigo pelado\n• 250g de huesillos (duraznos deshidratados)\n• 1 taza de azúcar (200g)\n• 1 rama de canela\n• 2 clavos de olor\n• 8 tazas de agua (2 litros)\n• Hielo para servir\n\nOpcional:\n• Ralladura de naranja\n• Agua de azahar (unas gotas)	36
25	Filete de Vacuno: 1 pieza central de 800g a 1kg (un corte cilíndrico y parejo). Ideal: lomo liso (tenderloin/filet mignon). Pide a tu carnicero que lo ate con cordel si es necesario.\n\nSal y Pimienta Negra: Abundante, para sellar.\n\nAceite vegetal (alto punto de humo): 2 cucharadas (para dorar).\n\nMostaza de Dijon: 2-3 cucharadas (capa para proteger y dar sabor).\n\nChampiñones: 400g, picados finos (usa varietales como portobello, cremini o shiitake para más sabor).\n\nChalotes (o cebolla morada): 2 grandes, picados finos.\n\nAjo: 2 dientes, picados finos.\n\nTomillo Fresco: 1 cucharada de hojas (o 1 cucharadita de tomillo seco).\n\nVino tinto o brandy: ¼ taza (para deglasar).\n\nMantequilla: 1 cucharada.\n\nJamón Serrano o Prosciutto: 8-10 lonchas finas (deben cubrir todo el filete).\n\nMasa de Hojaldre: 1 lámina grande (aprox. 500g), comprada o casera, descongelada si es congelada.\n\nHuevo: 1, batido (para pintar la masa).	11
27	Tomates: 1 kg de tomates maduros (tipo Roma o pera), cortados en cuartos. O 1 lata grande (800 g) de tomates pelados enteros.\n\nCebolla: 1 grande, picada en cubos medianos.\n\nAjo: 4 dientes, picados finos.\n\nZanahoria: 1 mediana, picada en cubos (le da dulzor natural).\n\nApio: 1 tallo, picado (opcional, pero suma profundidad).\n\nAceite de Oliva: 3 cucharadas.\n\nPasta de Tomate (Concentrado): 2 cucharadas (intensifica el sabor).\n\nCaldo de Verduras o Pollo: 3 tazas (720 ml).\n\nAzúcar: 1 cucharada (equilibra la acidez natural del tomate).\n\nAlbahaca Fresca: ¼ taza de hojas (o 1 cucharadita de albahaca seca).\n\nHojas de Laurel: 2.\n\nSal y Pimienta: Al gusto.\n\nCrema de Leche (Nata): ½ taza (120 ml), para terminar (opcional, pero clásico).\n\nMantequilla: 2 cucharadas (opcional, para enriquecer).	13
19	Para la Carne:\n\nTapapecho (Brisket): 1 pieza de 1.5 a 2 kg. (Pídelo con su capa de grasa, ya que esta da mucho sabor).\n\nSal y Pimienta Negra: Para sellar generosamente.\n\nAceite vegetal: 2 cucharadas (para dorar).\n\nPara la Base Aromática:\n\nCebollas: 2 grandes, cortadas en rodajas gruesas.\n\nZanahorias: 2 grandes, cortadas en trozos grandes.\n\nApio: 2 tallos, cortados en trozos grandes.\n\nAjo: 6-8 dientes, picados finos.\n\nPara el Líquido de Braseado:\n\nPasta de Tomate (Concentrado): 2 cucharadas.\n\nCerveza Negra o Caldo de Vacuno: 2 tazas (aprox. 500 ml). La cerveza le da un sabor increíble.\n\nSalsa Worcestershire: 2 cucharadas.\n\nAzúcar Morena (Opcional): 1 cucharada (equilibra la acidez).\n\nHojas de Laurel: 2.\n\nTomillo Fresco: 4-5 ramitas (o 1 cucharadita de tomillo seco).	5
20	Para el Pollo y la Marinada:\n\nPollo: 1 pollo entero, cortado en 8 piezas (presas): 2 pechugas (cada una cortada por la mitad), 2 muslos, 2 piernas, 2 alas.\n\nSuero de leche (Buttermilk): 2 tazas. Si no tienes, mezcla 2 tazas de leche con 2 cucharadas de jugo de limón o vinagre blanco. Deja reposar 10 minutos.\n\nSalsa Picante (tipo Tabasco o Louisiana): 2 cucharadas (opcional, para darle un toque picante).\n\nSal: 2 cucharaditas.\n\nPimienta Negra: 1 cucharadita.\n\nPara el Empanizado:\n\nHarina: 2 ½ tazas.\n\nMaicena (Fécula de maíz): ½ taza (esto hace el crocante extra).\n\nSal: 2 cucharaditas.\n\nPimienta Negra: 1 cucharadita.\n\nAjo en Polvo: 1 cucharada.\n\nCebolla en Polvo: 1 cucharada.\n\nPimentón (Paprika): 1 cucharada.\n\nTomillo Seco: 1 cucharadita.\n\nAlbahaca Seca: 1 cucharadita.\n\nOrégano Seco: 1 cucharadita.\n\nPimienta de Cayena (Cayenne Pepper): ½ cucharadita (o al gusto).\n\nJengibre en Polvo: ½ cucharadita (el secreto del KFC).\n\nGlutamato Monosódico (MSG - Opcional): ½ cucharadita (potencia el sabor umami).\n\nPara Freír:\n\nAceite vegetal: Suficiente para cubrir el pollo a la mitad (aprox. 4-6 tazas, dependiendo del tamaño de tu olla).	6
21	Para la Base:\n\nCarne Molida de Cerdo (Chancho): 500 g (1 libra).\n\nCebolla: 1 grande, picada en cubos finos (brunoise).\n\nAjo: 3 dientes, picados finos.\n\nPimentón (Pimiento Morrón): 1 mediano (rojo o verde), picado en cubos pequeños.\n\nAceite vegetal: 1 cucharada (para saltear).\n\nPara la Salsa (El Alma del Plato):\n\nSalsa de Tomate (Ketchup): ½ taza (120 ml).\n\nSalsa Barbacoa: ¼ taza (60 ml).\n\nSalsa Worcestershire: 2 cucharadas.\n\nMostaza Amarilla: 1 cucharada.\n\nVinagre de Manzana: 1 cucharada (para equilibrar dulzor).\n\nAzúcar Morena: 2 cucharadas.\n\nPasta de Tomate (Concentrado): 2 cucharadas.\n\nCaldo de Cerdo o Vacuno (o agua): ½ taza (120 ml).\n\nPara el Sazón:\n\nComino Molido: 1 cucharadita.\n\nPimentón Ahumado (Smoked Paprika): 1 cucharadita.\n\nAjí en Polvo (Chili Powder): ½ cucharadita (opcional, si quieres picante).\n\nSal: 1 cucharadita (ajustar al final).\n\nPimienta Negra: ½ cucharadita.\n\nPara Servir:\n\nPanes para hamburguesa (Buns): 4-6 unidades, ligeramente tostados.\n\nPepinillos en rodajas (Pickles): Opcionales, pero muy recomendados.\n\nCebolla morada picada: Para topping.\n\nQueso cheddar: Opcional.	7
23	1. Para las Berenjenas Asadas:\n\nBerenjenas: 2 grandes (tipo berenjena globo).\n\nAceite de Oliva: 3 cucharadas.\n\nSal y Pimienta: Al gusto.\n\nComino Molido: 1 cucharadita.\n\nPimentón Ahumado (Smoked Paprika): ½ cucharadita.\n\n2. Para las Lentejas:\n\nLentejas Verdes o Pardinas: 1 taza (200 g), crudas.\n\nCaldo de Verduras (o Agua): 2 ½ tazas.\n\nAjo: 2 dientes, picados finos.\n\nComino Molido: ½ cucharadita.\n\nSal: Al gusto.\n\n3. Para la Salsa de Tahini (El Alma del Plato):\n\nTahini (Pasta de Sésamo): ¼ taza (60 ml).\n\nJugo de Limón: 3 cucharadas (de 1-2 limones).\n\nAjo: 1 diente pequeño, rallado o prensado.\n\nAgua Fría: 3-4 cucharadas (para diluir).\n\nSal: ½ cucharadita (o al gusto).\n\n4. Para el Acabado y Decoración:\n\nPiñones: ¼ taza (40 g), tostados en sartén seca hasta dorados.\n\nPerejil Fresco: ¼ taza, picado (hojas).\n\nGranada (Opcional): ¼ taza de arilos (semillas) para un toque fresco y colorido.\n\nAceite de Oliva Extra Virgen: Un chorrito para terminar.\n\nPimentón Ahumado: Una pizca para decorar.\n\n5. Para Servir (Opcional):\n\nPan Pita o Pan Árabe: Tibio, para acompañar.	9
31	Arvejas Partidas Verdes (Split Peas): 2 tazas (400 g), secas. No necesitan remojo previo.\n\nHueso de Jamón (Ham Hock o Ham Bone): 1 pieza (aprox. 500-700 g). Si no consigues, usa 200-300 g de jamón ahumado cortado en cubos.\n\nCaldo de Pollo o Verduras (o Agua): 8 tazas (2 litros).\n\nCebolla: 1 grande, picada en cubos medianos.\n\nZanahoria: 2 medianas, picadas en cubos.\n\nApio: 2 tallos, picados.\n\nAjo: 3 dientes, picados finos.\n\nHojas de Laurel: 2.\n\nTomillo Seco: 1 cucharadita (o 2-3 ramitas de tomillo fresco).\n\nAceite de Oliva: 2 cucharadas.\n\nSal: 1 cucharadita (ajustar al final, el jamón ya aporta sal).\n\nPimienta Negra: ½ cucharadita.\n\nPimentón Ahumado (Smoked Paprika): ½ cucharadita (opcional, pero le da un toque increíble).	17
26	1. Ingredientes para el Puré (El Topping)\n\nPapas: 1 kg (idealmente papas para puré, como Russet o Yukon Gold), peladas y cortadas en cubos.\n\nMantequilla: 50 g (¼ taza).\n\nLeche: ¼ taza (60 ml), tibia.\n\nSal y Pimienta: Al gusto.\n\nQueso Cheddar Rallado (Opcional): ½ taza (para gratinar).\n\n2. Ingredientes para el Relleno de Pescado\n\nPescado Blanco: 600 g de filetes sin piel ni espinas (merluza, bacalao, eglefino, o una mezcla). Cortar en trozos de 3-4 cm.\n\nCamarones (Opcional): 200 g, pelados y limpios (puedes omitirlos o reemplazarlos por más pescado).\n\nLeche: 2 tazas (480 ml).\n\nHojas de Laurel: 2.\n\nPimienta Negra en Grano: 5-6 granos.\n\n3. Ingredientes para la Salsa Bechamel (Blanca)\n\nMantequilla: 50 g (¼ taza).\n\nHarina: ¼ taza (30 g).\n\nLeche (la misma donde se cocinó el pescado): 1 ½ tazas (reservada del paso anterior).\n\nQueso Cheddar Rallado: ½ taza (opcional, pero le da mucho sabor).\n\nMostaza de Dijon: 1 cucharadita.\n\nSal y Pimienta: Al gusto.\n\n4. Ingredientes para Completar el Relleno\n\nArvejas (Guisantes) Congeladas: 1 taza.\n\nMaíz (Choclo) en Grano: ½ taza (opcional).\n\nPerejil Fresco Picado: 2 cucharadas.\n\nJugo de Limón: 1 cucharada (para avivar el sabor).	12
28	Para el Pastel de Pavo:\n\nPavo Molido (Carne molida de pavo): 1 kg (2 libras).\n\nCebolla: 1 grande, picada fina (brunoise).\n\nAjo: 3 dientes, picados finos.\n\nZanahoria: 1 grande, rallada o picada muy fina.\n\nPimentón (Pimiento Morrón): ½, picado fino (opcional, para color).\n\nPan Rallado (Pan Molido): ½ taza (60 g).\n\nLeche: ¼ taza (para hidratar el pan rallado y dar jugosidad).\n\nHuevo: 1 grande.\n\nSalsa Worcestershire: 2 cucharadas.\n\nMostaza de Dijon: 1 cucharada.\n\nKetchup: 3 cucharadas (para la mezcla).\n\nTomillo Seco: 1 cucharadita.\n\nPerejil Fresco Picado: 2 cucharadas (o 1 cucharadita seco).\n\nSal: 1 cucharadita.\n\nPimienta Negra: ½ cucharadita.\n\nPara el Glaseado (Topping):\n\nKetchup: ¼ taza.\n\nAzúcar Morena: 2 cucharadas.\n\nVinagre de Manzana: 1 cucharada.\n\nMostaza de Dijon: 1 cucharadita.	14
29	Arroz Blanco: 1 taza (200 g), crudo (preferiblemente grano largo).\n\nAgua: 2 tazas (para cocinar el arroz).\n\nBrócoli: 1 cabeza grande (aprox. 400 g), cortado en floretes pequeños.\n\nCebolla: 1 mediana, picada fina (brunoise).\n\nAjo: 2 dientes, picados finos.\n\nMantequilla: 3 cucharadas.\n\nHarina: 3 cucharadas (para la salsa bechamel).\n\nLeche: 2 tazas (480 ml).\n\nQueso Cheddar Rallado: 2 tazas (200 g), dividido (1 ½ tazas para la mezcla, ½ taza para gratinar).\n\nCrema de Leche (Nata): ½ taza (120 ml), opcional pero recomendado.\n\nHuevo: 1 grande, ligeramente batido (para unir).\n\nSal: 1 cucharadita (o al gusto).\n\nPimienta Negra: ½ cucharadita.\n\nNuez Moscada: ¼ cucharadita (opcional, pero le da un toque especial).\n\nPan Rallado: ¼ taza (para el topping crocante, opcional).	15
30	Para el Relleno:\n\nFrutillas (Fresas): 3 tazas (aprox. 450 g), limpias, sin hojas, cortadas en mitades o cuartos si son grandes.\n\nRuibarbo: 3 tazas (aprox. 450 g), lavado, sin hojas (las hojas son tóxicas), cortado en trozos de 1-2 cm.\n\nAzúcar: 1 taza (200 g). El ruibarbo es muy ácido, así que necesita endulzarse bien.\n\nMaicena (Fécula de maíz): ¼ taza (30 g), para espesar el jugo.\n\nJugo de Limón: 1 cucharada (aviva el sabor).\n\nRalladura de Naranja: 1 cucharadita (opcional, pero combina hermoso).\n\nExtracto de Vainilla: 1 cucharadita.\n\nSal: Una pizca.\n\nPara la Masa (si haces casera, para 2 discos):\n\nHarina: 2 ½ tazas (315 g).\n\nAzúcar: 2 cucharadas.\n\nSal: 1 cucharadita.\n\nMantequilla Fría: 225 g (1 taza), cortada en cubos.\n\nAgua Helada: 6-8 cucharadas (agregar de a poco).\n\nAlternativa rápida: Usa 2 masas quebradas compradas (1 para la base, 1 para la tapa).\n\nPara el Acabado:\n\nMantequilla: 2 cucharadas, cortada en cubitos (se distribuyen sobre el relleno).\n\nHuevo: 1, batido con 1 cucharada de leche (para pintar la tapa).\n\nAzúcar Gruesa: 1 cucharada, para espolvorear (opcional, da brillo y crocancia).	16
32	Para el Pastel de Carne:\n\nCarne Molida de Vacuno: 800 g (1.75 libras). Ideal 80/20 grasa/carne para jugosidad.\n\nCebolla: 1 grande, picada fina (brunoise).\n\nAjo: 3 dientes, picados finos.\n\nZanahoria: 1 mediana, rallada o picada muy fina.\n\nPan Rallado (Pan Molido): ¾ taza (90 g).\n\nLeche: ½ taza (120 ml), para hidratar el pan rallado.\n\nHuevo: 1 grande.\n\nSalsa Worcestershire: 2 cucharadas.\n\nKetchup: 3 cucharadas (para la mezcla).\n\nMostaza de Dijon: 1 cucharada.\n\nSal: 1 cucharadita.\n\nPimienta Negra: ½ cucharadita.\n\nTomillo Seco: 1 cucharadita.\n\nPerejil Fresco Picado: 2 cucharadas (o 1 cucharadita seco).\n\nPara el Glaseado (Topping):\n\nKetchup: ½ taza.\n\nAzúcar Morena: 2 cucharadas.\n\nVinagre de Manzana: 1 cucharada.\n\nMostaza Amarilla: 1 cucharadita.	18
33	Tapapecho (Brisket): 1 pieza plana (flat cut) de 1.5 a 2 kg, sin curar (carne fresca).\n\nPara la Salmuera (El Curado):\n\nAgua: 4 litros.\n\nSal de Curado (Curing Salt/Prague Powder #1): 2 cucharaditas. Esto contiene nitrito de sodio (da el color rosado y preserva).\n\nSal Kosher: ½ taza (120 g).\n\nAzúcar Morena: ½ taza (100 g).\n\nPimienta Negra en Grano: 2 cucharadas.\n\nSemillas de Mostaza: 2 cucharadas.\n\nSemillas de Cilantro (Coriandro): 2 cucharadas.\n\nAjo: 6 dientes, machacados.\n\nHojas de Laurel: 4.\n\nClavo de Olor: 6.\n\nJengibre Fresco: 1 trozo de 5 cm, en rodajas.\n\nPara el "Montreal Spice Rub" (Frotado Seco):\n\nPimienta Negra Triturada (gruesa): 3 cucharadas.\n\nSemillas de Cilantro Molidas: 2 cucharadas.\n\nAjo en Polvo: 1 cucharada.\n\nCebolla en Polvo: 1 cucharada.\n\nPimentón (Paprika): 1 cucharada.\n\nSemillas de Mostaza Trituradas: 1 cucharada.\n\nHojuelas de Pimiento Rojo (Red Pepper Flakes): 1 cucharadita.	19
36	Para la Masa (aprox. 30-40 Timbits):\n\nHarina: 2 ½ tazas (aprox. 300 g).\n\nAzúcar: ½ taza (100 g).\n\nPolvo de Hornear: 2 cucharaditas.\n\nBicarbonato de Sodio: ½ cucharadita.\n\nSal: ½ cucharadita.\n\nNuez Moscada Molida: ½ cucharadita (el toque secreto).\n\nCanela en Polvo: ½ cucharadita (opcional, pero recomendada).\n\nLeche: ¾ taza (180 ml), a temperatura ambiente.\n\nHuevo: 1 grande.\n\nMantequilla: 4 cucharadas (60 g), derretida y enfriada.\n\nExtracto de Vainilla: 1 cucharadita.\n\nPara Freír:\n\nAceite Vegetal: Suficiente para cubrir los Timbits a la mitad (aprox. 4-6 tazas, dependiendo del tamaño de tu olla o freidora).\n\nPara el Recubrimiento (Elige tu favorito):\n\nOpción 1 - Azúcar Granulada: ½ taza (para espolvorear calientes).\n\nOpción 2 - Azúcar Canela: ½ taza de azúcar + 1 cucharada de canela.\n\nOpción 3 - Azúcar Flor (Impalpable): ½ taza.\n\nOpción 4 - Glaseado de Chocolate: 1 taza de chocolate semiamargo derretido con 2 cucharadas de mantequilla.	20
37	Para el Relleno:\n\nPapas: 6-7 grandes (aprox. 1.5 kg), peladas y cortadas en rodajas muy finas (2-3 mm). Usa una mandolina si tienes.\n\nCebolla: 1 grande, picada fina (brunoise).\n\nTocino (Bacon): 200 g, cortado en trozos pequeños (lardons).\n\nSal y Pimienta: Al gusto.\n\nPara la Masa (Pâte Brisée):\n\nHarina: 3 tazas (375 g).\n\nManteca de Cerdo (Lard) o Mantequilla Fría: 200 g (¾ taza + 2 cucharadas), cortada en cubos. La manteca de cerdo es tradicional.\n\nPolvo de Hornear: 1 cucharadita.\n\nSal: 1 cucharadita.\n\nAgua Helada: ½ taza (120 ml), aproximadamente (agregar de a poco).\n\nPara el Acabado:\n\nMantequilla: 3 cucharadas, cortada en cubitos (se distribuyen sobre el relleno antes de tapar).\n\nHuevo: 1, batido con 1 cucharada de leche (para pintar la tapa).	21
38	Para la Masa (Base):\n\nMasa Quebrada (Pâte Brisée): 1 disco (suficiente para forrar un molde de tarta de 23 cm / 9 pulgadas). Puedes usar masa comprada o hacerla casera.\n\nReceta rápida de masa: Mezcla 1 ¼ tazas de harina, ½ cucharadita de sal, 125 g de mantequilla fría en cubos, y 3-4 cucharadas de agua helada. Trabaja hasta formar una masa, refrigera 30 minutos, estira y forra el molde.\n\nPara el Relleno (El Alma del Pastel):\n\nAzúcar Morena (Brown Sugar): 2 tazas (400 g), bien compactada. Este es el protagonista.\n\nCrema de Leche (Nata para Cocinar / Heavy Cream): 1 taza (240 ml).\n\nJarabe de Arce Puro (Maple Syrup): ½ taza (120 ml). Este le da el toque canadiense inconfundible.\n\nMantequilla: 3 cucharadas (45 g).\n\nHarina: 3 cucharadas (para espesar el relleno).\n\nExtracto de Vainilla: 1 cucharadita.\n\nSal: Una pizca.	22
39	Papas: 800 g (aprox. 4-5 papas medianas). Ideal: papas cerosas (tipo Yukon Gold o rojas), que tienen menos almidón y quedan más crujientes.\n\nCebolla: 1 grande, picada en cubos medianos.\n\nPimentón (Pimiento Morrón): 1 (rojo o verde), picado en cubos.\n\nAjo: 2 dientes, picados finos.\n\nAceite Vegetal (o mantequilla): 4 cucharadas.\n\nPimentón Ahumado (Smoked Paprika): 1 cucharadita (el toque especial).\n\nAjo en Polvo: ½ cucharadita.\n\nCebolla en Polvo: ½ cucharadita.\n\nSal: 1 cucharadita (o al gusto).\n\nPimienta Negra: ½ cucharadita.\n\nPerejil Fresco Picado: 2 cucharadas (para decorar, opcional).	23
40	Fideos (Fideuá): 400 g. Idealmente fideos cortos tipo cabello de ángel o fideos #2 (fideua pasta). Si no encuentras, puedes partir espaguetis en trozos de 2-3 cm.\n\nCaldo de Pescado o Marisco: 4 tazas (1 litro), caliente. Puedes usar pastillas de caldo, pero el casero es mejor.\n\nCalamares: 300 g, limpios, cortados en anillos.\n\nCamarones (Langostinos): 300 g, pelados y desvenados.\n\nMejillones: 200 g, limpios y con cáscara.\n\nAlmejas (Opcional): 200 g, limpias.\n\nTomate: 2 maduros, rallados (descartar la piel), o ½ taza de salsa de tomate.\n\nCebolla: 1 mediana, picada fina.\n\nAjo: 4 dientes, picados finos.\n\nPimentón (Pimiento Morrón Rojo): 1, cortado en tiras.\n\nAzafrán: Una pizca de hebras (remojadas en 2 cucharadas de caldo caliente), o ½ cucharadita de colorante amarillo.\n\nPimentón Dulce (Paprika): 1 cucharadita.\n\nAceite de Oliva: 4 cucharadas.\n\nPerejil Fresco: ¼ taza, picado.\n\nLimón: 1, cortado en gajos (para servir).\n\nSal y Pimienta: Al gusto.	24
41	Papas (Patatas): 4 grandes (aprox. 800 g), peladas y cortadas en rodajas finas (2-3 mm). Ideal: papas cerosas como las blancas o Yukon Gold.\n\nCebolla: 1 grande, cortada en juliana fina (opcional, pero muy tradicional). Si no te gusta la cebolla, omítela.\n\nHuevos: 6 grandes.\n\nAceite de Oliva: Aprox. 1 ½ tazas (350 ml). Parece mucho, pero es para confitar las papas. Luego se escurre y se puede reutilizar.\n\nSal: 1 cucharadita (o al gusto).	25
42	Arroz: 2 tazas (400 g), tipo bomba o arroz de grano corto (ideal para paella). Si no consigues, usa arroz arborio.\n\nCaldo de Verduras: 4 tazas (1 litro), caliente.\n\nHinojo: 2 bulbos grandes, cortados en gajos (aprox. 400 g).\n\nBerenjena: 1 grande, cortada en cubos de 2 cm.\n\nPimentón (Pimiento Morrón): 1 rojo, cortado en tiras.\n\nTomate: 2 maduros, rallados (descartar la piel), o ½ taza de salsa de tomate triturada.\n\nCebolla: 1 mediana, picada fina.\n\nAjo: 4 dientes, picados finos.\n\nAzafrán: Una pizca de hebras (remojadas en 2 cucharadas de caldo caliente), o ½ cucharadita de colorante amarillo.\n\nPimentón Ahumado (Smoked Paprika): 1 cucharadita.\n\nAceite de Oliva: 5 cucharadas.\n\nPerejil Fresco: ¼ taza, picado.\n\nLimón: 1, cortado en gajos (para servir).\n\nAlcaparras: 2 cucharadas (opcional, para un toque ácido).\n\nSal y Pimienta: Al gusto.	26
50	• 500g de zapallo cocido y molido\n• 4 tazas de harina\n• 1 cucharadita de polvos de hornear\n• 1 cucharadita de sal\n• 2 cucharadas de manteca o mantequilla derretida\n• Agua tibia (cantidad necesaria)\n• Aceite para freír\n\nPara servir (opcional):\n• Pebre (salsa chilena)\n• Mostaza\n• Ketchup\n• Chancaca (jarabe de panela)	35
43	Para el Relleno de Pollo:\n\nPechugas de Pollo: 600 g (aprox. 3 pechugas), cocidas y desmenuzadas. Puedes hervirlas con sal, ajo y cebolla, o usar pollo rostizado comprado.\n\nQueso Rallado: 2 tazas (200 g), tipo mezcla mexicana (Monterey Jack + Cheddar), dividido (1 taza para el relleno, 1 taza para gratinar).\n\nCrema Agria (Sour Cream): ½ taza (120 g).\n\nCebolla: ½, picada fina.\n\nCilantro Fresco: ¼ taza, picado.\n\nSal y Pimienta: Al gusto.\n\nPara las Tortillas:\n\nTortillas de Maíz o Harina: 10-12 unidades (de 15 cm / 6 pulgadas).\n\nPara la Salsa:\n\nSalsa Verde (Tomatillo Salsa) o Salsa Roja Enchilada: 2 tazas (480 ml). Puedes usar comprada o hacer casera.\n\nReceta rápida de salsa verde: Licúa 500 g de tomatillos cocidos, 1 chile jalapeño, ½ cebolla, 2 dientes de ajo, cilantro, sal y jugo de limón.\n\nPara Completar:\n\nAceite Vegetal: Para pasar las tortillas (opcional, pero las hace más flexibles y evita que se rompan).	27
44	Para el Pescado:\n\nFiletes de Pescado Blanco: 500 g (tipo tilapia, merluza, bacalao o mahi-mahi), sin piel ni espinas, cortados en tiras de 2-3 cm de ancho.\n\nHarina: ½ taza (para rebozar).\n\nMaicena (Fécula de maíz): ¼ taza (hace el rebozado extra crujiente).\n\nHuevo: 1, batido con 2 cucharadas de leche.\n\nPan Rallado (Panko, si consigues): 1 taza (para el empanizado crocante).\n\nAceite Vegetal: Para freír (aprox. 3-4 tazas, dependiendo del tamaño de tu sartén).\n\nPara el Sazón Cajún (El Alma del Sabor):\n\nAjí en Polvo (Chili Powder): 1 cucharada.\n\nPimentón (Paprika): 1 cucharada.\n\nPimentón Ahumado (Smoked Paprika): 1 cucharadita.\n\nAjo en Polvo: 1 cucharadita.\n\nCebolla en Polvo: 1 cucharadita.\n\nOrégano Seco: 1 cucharadita.\n\nTomillo Seco: ½ cucharadita.\n\nPimienta de Cayena: ½ cucharadita (ajusta según tu tolerancia al picante).\n\nSal: 1 cucharadita.\n\nPimienta Negra: ½ cucharadita.\n\nPara el Slaw (Ensalada de Repollo):\n\nRepollo Morado: 2 tazas, rallado fino (col lombarda).\n\nZanahoria: 1 mediana, rallada.\n\nCilantro Fresco: ¼ taza, picado.\n\nMayonesa: ¼ taza.\n\nCrema Agria (Sour Cream): 2 cucharadas.\n\nJugo de Limón: 2 cucharadas.\n\nMiel: 1 cucharadita.\n\nSal y Pimienta: Al gusto.\n\nPara Armar los Tacos:\n\nTortillas de Maíz o Harina: 8-10 unidades, tibias.\n\nPalta (Aguacate): 1, en rodajas.\n\nSalsa Picante: Al gusto.\n\nLimón: En gajos, para servir.	28
45	Para la Carne (El Corazón):\n\nTapapecho (Brisket) o Paleta de Vacuno (Chuck Roast): 1.5 kg, cortado en cubos de 3-4 cm. Usa un corte con grasa y tejido conectivo, que se deshará durante el braseado.\n\nSal y Pimienta Negra: Para sellar generosamente.\n\nAceite Vegetal: 3 cucharadas (para dorar).\n\nPara la Base Aromática:\n\nCebollas: 2 grandes, picadas en cubos medianos.\n\nAjo: 6-8 dientes, picados finos.\n\nPasta de Tomate (Concentrado): 2 cucharadas.\n\nPara el Alma Picante:\n\nAjí en Polvo (Chili Powder): 3-4 cucharadas (¡el corazón del plato!).\n\nComino Molido: 1 cucharada.\n\nPimentón Ahumado (Smoked Paprika): 1 cucharada.\n\nOrégano Seco: 1 cucharada.\n\nPara el Braseado (El Líquido):\n\nCerveza Negra (tipo Stout o Bock): 1 lata o botella (aprox. 330 ml).\n\nCaldo de Vacuno: 3-4 tazas.\n\nTomates Triturados (o en Cubos): 1 lata grande (800g / 28 oz).\n\nHojas de Laurel: 2.\n\nIngrediente Secreto (Opcional): 2 cucharadas de cacao en polvo (sin azúcar) o 30g de chocolate amargo (sobre 70%).\n\nPara Terminar:\n\nPorotos Negros (Frijoles): 1 lata (425g), enjuagados y escurridos (Opcional, el chili estilo Texas no lleva, pero son un buen añadido).\n\nMaicena (Fécula de maíz) o Masa Harina: 2 cucharadas (disueltas en 2 cucharadas de agua), para espesar.\n\nJugo de Limón Sutil o Vinagre de Manzana: 1 chorrito (para "despertar" los sabores).\n\nAcompañamientos Clásicos (Toppings):\n\nCrema agria (Sour cream)\n\nQueso cheddar rallado\n\nPalta (aguacate) en cubos\n\nCilantro fresco\n\nCebollín picado	29
46	Esta receta tiene dos partes: preparar el pollo en la olla lenta (que puedes hacer con horas de anticipación) y luego el armado y horneado rápido.\n\n1. Ingredientes: Para el Pollo en Olla Lenta (Crock-Pot)\n\nPechugas de Pollo: 1 kg (aprox. 3-4 pechugas sin hueso y sin piel).\n\nSalsa (tipo mexicana, de frasco): 1 frasco de 450g (16 oz).\n\nSazonador de Tacos (Taco Seasoning): 1 sobre (o 3 cucharadas de sazonador casero).\n\nCaldo de Pollo (Opcional): ¼ taza, si la salsa es muy espesa.\n\n2. Ingredientes: Para el Armado y Horneado\n\nTaco Shells (Tacos rígidos): 12 unidades (los que vienen con fondo plano, tipo "Stand N Stuff", son los más fáciles para esto).\n\nPorotos Refritos (Frijoles Refritos): 1 lata (opcional, pero muy recomendado).\n\nQueso Rallado (Mezcla Mexicana o Cheddar): 2 tazas.\n\n3. Ingredientes: Para los Acompañamientos (Toppings)\n\nCrema agria (Sour cream)\n\nLechuga picada fina\n\nTomates en cubos\n\nPalta (aguacate) o Guacamole\n\nCilantro fresco	30
47	1. Ingredientes: Sazonador de Fajitas (El Sabor)\n\nMezcla esto primero en un bol pequeño. (O usa un sobre de sazón para fajitas comprado).\n\nAjí en Polvo (Chili Powder): 2 cucharaditas.\n\nComino Molido: 1 ½ cucharaditas.\n\nPimentón Ahumado (Smoked Paprika): 1 ½ cucharaditas (¡este es el secreto!).\n\nAjo en Polvo: 1 cucharadita.\n\nCebolla en Polvo: 1 cucharadita.\n\nOrégano Seco: 1 cucharadita.\n\nPimienta de Cayena: ¼ cucharadita (o al gusto).\n\nSal: 1 cucharadita.\n\nPimienta Negra: ½ cucharadita.\n\n2. Ingredientes: Para la Bandeja de Fajitas\n\nGarbanzos: 1 lata (425g / 15 oz), enjuagados y escurridos.\n\nPimentón (Pimiento Morrón): 2 grandes, de colores (rojo y amarillo), cortados en tiras.\n\nCebolla Morada: 1 grande, cortada en tiras gruesas (pluma).\n\nAceite de Oliva: 3 cucharadas.\n\nJugo de Limón Sutil (Lima): 1 (entero).\n\n3. Ingredientes: Para Servir\n\nTortillas: 8-10 tortillas (de harina o maíz).\n\nPalta (Aguacate): En rodajas o como guacamole.\n\nSalsa: Pico de Gallo o tu salsa roja favorita.\n\nCrema Agria (Sour Cream): O yogur griego natural.\n\nCilantro Fresco: Picado.	31
48	Para los Pimentones:\n\nPimentones (Bell Peppers): 4 grandes, de cualquier color (los rojos, amarillos o naranjas son más dulces).\n\nAceite de Oliva: 1 cucharada.\n\nSal y Pimienta: A gusto.\n\nPara el Relleno:\n\nQuinoa: 1 taza, cruda.\n\nCaldo de Verduras (o Agua): 2 tazas.\n\nPorotos Negros (Frijoles Negros): 1 lata (425g), enjuagados y escurridos.\n\nChoclo (Maíz Dulce): 1 lata (425g), escurrido.\n\nCebolla: 1 mediana, picada fina (brunoise).\n\nAjo: 3 dientes, picados finos.\n\nAceite de Oliva: 1 cucharada.\n\nSalsa de Tomate (Triturada): 1 taza.\n\nCilantro Fresco: ½ manojo, picado.\n\nJugo de Limón Sutil (Lima): 1 (entero).\n\nSazonador (La Clave del Sabor):\n\nComino Molido: 2 cucharaditas.\n\nPimentón Ahumado (Smoked Paprika): 1 cucharadita (¡no lo omitas!).\n\nAjí en Polvo (Chili Powder): 1 cucharadita (opcional, para un toque picante).\n\nSal: 1 cucharadita (o al gusto).\n\nPimienta Negra: ½ cucharadita.\n\nPara el Acabado (Opcional):\n\nQueso Rallado: 1 taza (tipo Monterey Jack, Cheddar o Queso Mantecoso).\n\nAlternativa Vegana: Levadura nutricional o queso vegano.\n\nPara Servir:\n\nPalta (aguacate) en rodajas.\n\nCrema agria (o yogur griego).	32
49	• 1 kg de carne molida de vacuno\n• 6 cebollas grandes picadas\n• 3 dientes de ajo picados\n• 2 cucharadas de ají de color\n• 1 cucharadita de comino\n• 8 aceitunas negras\n• 2 huevos duros en rodajas\n• 200g de pasas\n• Sal y pimienta al gusto\n\nPara el choclo:\n• 8 choclos desgranados (aproximadamente 1 kg)\n• 1 taza de leche\n• 3 cucharadas de mantequilla\n• 2 cucharadas de albahaca fresca picada\n• Sal al gusto\n• Azúcar al gusto (opcional)	34
22	1. Ingredientes para la "Salsa Especial" (El Secreto)\n\nMayonesa: ½ taza (la base cremososa).\n\nRelish de Pepinillos Dulces: 2 cucharadas (el toque dulce y ácido).\n\nMostaza Amarilla: 2 cucharaditas (el carácter).\n\nVinagre Blanco: 1 cucharadita (equilibrio).\n\nAjo en Polvo: ½ cucharadita.\n\nCebolla en Polvo: ½ cucharadita.\n\nPimentón (Paprika): ¼ cucharadita.\n\nSal: Una pizca.\n\nAzúcar: Una pizca (opcional, si el relish no es muy dulce).\n\n2. Ingredientes para las Hamburguesas\n\nCarne Molida de Vacuno: 400-500 g (80/20 o 85/15 grasa/carne, para jugosidad).\n\nSal y Pimienta: Al gusto.\n\nPan Big Mac (o Pan de Hamburguesa con Semillas de Sésamo): 3 rodajas por hamburguesa (superior, media y base). Si no encuentras panes "triple", usa panes normales y córtalos.\n\n3. Ingredientes para el Armado\n\nLechuga Iceberg: 1 taza, picada en tiras finas (juliana).\n\nQueso Americano (American Cheese): 2 rebanadas por hamburguesa.\n\nCebolla: ¼ de cebolla blanca, picada en cubos muy finos (brunoise).\n\nPepinillos en Rodajas (Pickles): 4-6 rodajas por hamburguesa.	8
24	Paso 1: Preparar y Pre-hornear la Masa\n\nHacer la Masa (si es casera): En un bol, mezcla la harina, azúcar flor y sal. Agrega la mantequilla fría cortada en cubos y trabaja con los dedos (o un procesador) hasta obtener una textura arenosa. Añade agua helada (2-3 cucharadas) de a poco, hasta que la masa se una (debe estar firme, no pegajosa). Forma un disco, envuélvelo en film y refrigera por 30 minutos.\n\nAlternativa rápida: Usa 1 masa quebrada comprada, lista para usar.\n\nEstirar y Forrar: Estira la masa sobre superficie enharinada hasta 3 mm de espesor. Forra un molde para tarta de 23-25 cm (9-10 pulgadas) con borde desmontable. Pincha el fondo con un tenedor. Refrigera 15 minutos.\n\nPre-hornear (Horneado a Ciegas): Precalienta el horno a 180°C (350°F). Cubre la masa con papel mantequilla, rellena con peso para hornear (o porotos secos). Hornea 15 minutos. Retira el peso y el papel, hornea 5 minutos más hasta que esté ligeramente dorada. Reserva.\n\nPaso 2: Preparar el Frangipane (Crema de Almendras)\n\nIngredientes:\n\nMantequilla sin sal: 100 g (½ taza), a temperatura ambiente.\nAzúcar: 100 g (½ taza).\nHuevos: 2 grandes.\nHarina de almendras: 100 g (1 taza).\nExtracto de almendra (o vainilla): 1 cucharadita.\nSal: Una pizca.\n\nProcedimiento:\n\nEn un bol, bate la mantequilla con el azúcar hasta que esté cremososa y pálida (3-4 minutos). Agrega los huevoss de a uno, batiendo bien tras cada adición. Incorpora la harina de almendras, el extracto y la sal. Mezcla hasta integrar (la mezcla debe ser suave y homogénea). Reserva.\n\nPaso 3: Preparar las Manzanas\n\nIngredientes:\n\nManzanas: 3-4 grandes (tipo Granny Smith o Golden), peladas, sin corazón, cortadas en rodajas finas (2-3 mm).\nJugo de limón: 1 cucharada (para evitar oxidación).\nAzúcar: 2 cucharadas.\nCanela en polvo: ½ cucharadita (opcional).\n\nProcedimiento:\n\nEn un bol, mezcla las manzanas con el jugo de limón, azúcar y canela. Reserva.\n\nPaso 4: Armar la Tarta\n\nEsparce el frangipane uniformemente sobre la base de masa pre-horneada. Acomoda las rodajas de manzana sobre el frangipane, formando círculos concéntricos (empezando desde el borde hacia el centro), superponiéndolas ligeramente. Espolvorea con 1 cucharada de azúcar por encima de las manzanas.\n\nPaso 5: Hornear\n\nHornea a 180°C (350°F) durante 40-45 minutos, hasta que el frangipane esté inflado y dorado, y las manzanas estén tiernas (prueba con un palillo: debe salir limpio del frangipane). Si los bordes se doran demasiado rápido, cúbrelos con papel aluminio. Deja enfriar en el molde sobre una rejilla durante 15 minutos antes de desmoldar.\n\nPaso 6: Glaseado Final (Opcional, pero recomendado)\n\nIngredientes:\n\nMermelada de damasco (o durazno): 3 cucharadas.\nAgua: 1 cucharada.\n\nProcedimiento:\n\nCalienta la mermelada con el agua en el microondas (15 segundos) o en un cazo pequeño, hasta que esté líquida. Cuela si tiene trozos. Pincela las manzanas con la mermelada tibia usando una brocha de cocina (esto les da brillo y sella la humedad).	10
\.


--
-- Data for Name: me_gusta; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.me_gusta (id_megusta, fecha_creacion, id_receta, id_usr) FROM stdin;
2	2025-11-01 18:46:19.772205	8	1
1	2025-11-01 18:30:11.484725	8	2
3	2025-11-02 02:58:13.842658	12	55
9	2025-11-03 00:03:13.634768	8	72
10	2025-11-03 00:03:20.607135	8	73
11	2025-11-03 00:06:07.304679	8	74
19	2025-11-04 00:00:45.863062	8	3
21	2025-11-04 21:00:52.866597	10	3
\.


--
-- Data for Name: pais; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.pais (id_pais, nombre, url_imagen, estado, fecha_creacion, comentario, id_usr) FROM stdin;
89	EEUU	https://flagcdn.com/w320/us.png	1	2023-06-26 23:58:57	\N	1
90	Inglaterra	https://flagcdn.com/w320/gb.png	1	2023-06-27 10:00:19	\N	1
91	Canadá	https://flagcdn.com/w320/ca.png	1	2023-06-27 10:55:58	\N	1
92	España	https://flagcdn.com/w320/es.png	1	2023-06-27 10:57:06	\N	1
93	México	https://flagcdn.com/w320/mx.png	1	2023-06-27 10:57:47	\N	1
94	Argentina	https://flagcdn.com/w320/ar.png	1	2023-06-27 10:59:34	\N	1
95	Chile	https://flagcdn.com/w320/cl.png	1	2025-11-07 03:48:30.706252	Pa??s de Sudam??rica con rica gastronom??a	\N
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
36	Mote con Huesillo	https://www.recetasdemama.cl/wp-content/uploads/2020/11/mote-con-huesillos.jpg	\N	1. Preparar el mote: Lavar el mote bajo agua fría. Colocarlo en una olla con agua abundante y cocinar por 1-2 horas hasta que está tierno pero firme. Escurrir y reservar.\n\n2. Preparar los huesillos: Lavar los huesillos y colocarlos en una olla con 8 tazas de agua fría.\n\n3. Agregar el azúcar, la rama de canela y los clavos de olor. Si se desea, agregar ralladura de naranja.\n\n4. Llevar a ebullición y luego reducir el fuego. Cocinar a fuego lento por 30-40 minutos hasta que los huesillos están suaves y el líquido está ligeramente espeso y dorado.\n\n5. Retirar del fuego y dejar enfriar completamente. Si se desea, agregar unas gotas de agua de azahar.\n\n6. Refrigerar el almíbar con los huesillos por al menos 2 horas (mejor si es toda la noche).\n\n7. Para servir: En un vaso alto, colocar 2-3 cucharadas de mote en el fondo. Agregar 1-2 huesillos.\n\n8. Completar con el almíbar frío y agregar hielo picado o cubitos de hielo.\n\n9. Servir bien frío. Es la bebida tradicional chilena perfecta para los días calurosos de verano.	1	1	95	2025-11-07	1	0
4	Chocolate Caliente estilo Fudge	https://www.themealdb.com/images/media/meals/xrysxr1483568462.jpg		Hacer una "pasta": En un bol pequeño, mezcla la maicena, el cacao en polvo, el azúcar y la pizca de sal. Agrega 3-4 cucharadas de la leche (fría) y bate bien hasta formar una pasta suave y sin grumos.\n\nCalentar la leche: Calienta el resto de la leche en una olla a fuego medio, justo hasta que empiece a humear por los bordes (no dejes que hierva).\n\nAgregar el chocolate: Baja el fuego y agrega el chocolate troceado. Bate constantemente hasta que el chocolate esté completamente derretido.\n\nEspesar: Sube un poco el fuego (a medio-bajo) y vierte la "pasta" de cacao y maicena que preparaste.\n\nBatir y cocinar: Sigue batiendo constantemente. La mezcla debe llegar a un hervor muy suave y cocinarse por 1-2 minutos. Notarís que espesa visiblemente, adquiriendo una textura similar a la de un postre.\n\nFinalizar: Retira del fuego, agrega la vainilla y sirve inmediatamente.	1	22	89	2023-06-27	1	0
10	Tarta de Manzana y Frangipane	https://www.themealdb.com/images/media/meals/wxywrq1468235067.jpg		Paso 1: Preparar y Pre-hornear la Masa\n\nHacer la Masa (si es casera): En un bol, mezcla la harina, azúcar flor y sal. Agrega la mantequilla fría y usa las yemas de tus dedos (o un procesador de alimentos) para "frotar" la mantequilla hasta que parezca arena gruesa.\n\nAgrega la yema de huevo y 1 cucharada de agua helada. Mezcla justo hasta que la masa se una. No la amases.\n\nEnvuelve la masa en plístico y refrigérala por al menos 30 minutos.\n\nPre-hornear (Blind Bake): Precalienta el horno a 180°C (350°F).\n\nEstira la masa fría sobre una superficie enharinada y forra un molde de tarta (idealmente de 23 cm / 9 pulgadas con fondo removible). Pincha el fondo con un tenedor.\n\nCubre la masa con papel de hornear (mantequilla) y llénalo con "pesos para hornear" (garbanzos o porotos secos funcionan perfecto).\n\nHornea por 15 minutos. Retira el papel y los pesos, y hornea por 5-10 minutos más, hasta que la base esté seca y ligeramente dorada. Reserva.\n\nPaso 2: Hacer el Frangipane\n\nMientras la masa se enfría, prepara el relleno.\n\nEn un bol, bate la mantequilla blanda y el azúcar granulada con una batidora eléctrica hasta que esté pálida y esponjosa (cremada).\n\nAñade el huevo y los extractos (vainilla y almendra). Bate bien.\n\nAgrega la harina de almendras, las 2 cucharadas de harina común y la sal. Mezcla con una espátula (no batas en exceso) hasta que esté todo combinado. Tendrís una pasta espesa.\n\nPaso 3: Preparar las Manzanas\n\nCorta las manzanas en líminas finas (gajos).\n\nPonlas en un bol y rocáalas con el jugo de limón para evitar que se pongan marrones.\n\nPaso 4: Armado y Horneado Final\n\nBaja la temperatura del horno a 175°C (350°F).\n\nToma tu base de tarta pre-horneada. Extiende el relleno de frangipane en una capa uniforme sobre el fondo.\n\nArreglar las Manzanas: Coloca las líminas de manzana sobre el frangipane. El diseño clásico es en círculos concéntricos, superponiendo las líminas, comenzando desde el borde exterior hacia el centro (como una rosa).\n\nHornear: Hornea la tarta durante 40 a 50 minutos.\n\nEstarí lista cuando el frangipane esté inflado, dorado oscuro y firme al tacto (un palillo insertado en el centro debe salir limpio), y los bordes de las manzanas comiencen a caramelizarse.\n\nPaso 5: El Glaseado Brillante (El Toque Profesional)\n\nSaca la tarta del horno y déjala enfriar un poco.\n\nEn un tazón pequeño, calienta la mermelada de damasco en el microondas (o en una olla pequeña) con 1 cucharadita de agua hasta que esté láquida.\n\nCon una brocha de cocina, pinta suavemente la parte superior de las manzanas y la tarta con la mermelada caliente. Esto le da un brillo de pasteleráa profesional y un toque extra de sabor.\n\nDéjala enfriar antes de desmoldar y servir. Es deliciosa tibia o a temperatura ambiente, acompañada de helado de vainilla.	1	22	90	2023-06-27	1	0
11	Filete Wellington	https://www.themealdb.com/images/media/meals/vvpprx1487325699.jpg		Fase 1: El Filete (Hacer con anticipación)\nSazonar: Saca el filete del refrigerador 30 minutos antes de cocinar. Sécalo muy bien con toalla de papel y sazónalo generosamente por todos sus lados con sal y pimienta.\n\nSellar: Calienta un sartén muy grande a fuego alto con el aceite. Sella el filete por todos sus lados (incluyendo las puntas) muy rípidamente, solo 1-2 minutos por lado. Buscas un color dorado oscuro, no cocinarlo por dentro.\n\nLa Mostaza: Retira el filete del fuego e, inmediatamente mientras está caliente, pántalo por completo con la mostaza Dijon.\n\nEnfriar: Coloca el filete sobre una rejilla y déjalo enfriar a temperatura ambiente. Luego, llévalo al refrigerador por al menos 30 minutos. Debe estar completamente fráo.\n\nFase 2: El Duxelles (Hacer mientras el filete se enfráa)\nProcesar: Pon los champiñones, chalotas, ajo y tomillo en un procesador de alimentos. Pulsa hasta que tengas una pasta muy fina.\n\nSecar (Paso Crítico): Pon la mantequilla en un sartén a fuego medio-alto. Agrega la pasta de champiñones y una pizca de sal.\n\nCocina, revolviendo constantemente, durante 10-15 minutos. La mezcla soltarí mucha agua. Sigue cocinando hasta que toda el agua se haya evaporado y tengas una pasta oscura y densa que se separa del sartén.\n\nEnfriar: Extiende el duxelles en un plato y déjalo enfriar completamente (puedes meterlo al refrigerador). Si está caliente, arruinarí la masa.\n\nFase 3: El Pre-armado (La chaqueta de Prosciutto)\nLa Cama: Extiende una pieza grande de film plístico (alusa plast) sobre tu mesa de trabajo.\n\nArmar: Superpón las líminas de prosciutto sobre el plístico, creando un rectíngulo que sea lo suficientemente grande como para envolver todo el filete.\n\nLa Capa: Con una espátula, extiende el duxelles fráo en una capa fina y uniforme sobre el prosciutto.\n\nEnrollar: Coloca el filete fráo en el borde inferior del rectíngulo. Usando el film plístico para ayudarte, enrolla el prosciutto y el duxelles firmemente alrededor del filete, como si fuera un sushi.\n\nSellar: Gira las puntas del film plístico (como un dulce) para apretar el rollo y que quede muy compacto.\n\nRefrigerar: Lleva este "paquete" al refrigerador por al menos 30 minutos (o incluso de un día para otro). Esto le da su forma cilándrica perfecta.\n\nFase 4: Armado Final y Horneado\nPrecalentar: Precalienta tu horno a 200°C (400°F) y prepara una bandeja de horno con papel mantequilla.\n\nLa Masa: Extiende la masa de hojaldre fráa sobre una superficie ligeramente enharinada (o sobre un nuevo trozo de film plístico).\n\nEnvolver: Saca el filete del film plístico y ponlo en el centro de la masa.\n\nSellar: Pinta los bordes de la masa con el huevo batido. Envuelve la masa alrededor del filete, cortando cualquier exceso grande de masa (especialmente en las puntas). Pellizca las uniones para sellarlas muy bien.\n\nPosición: Coloca el Wellington en la bandeja de horno con la unión de la masa hacia abajo.\n\nGlasear y Decorar: Pinta toda la superficie con el huevo batido. Si lo deseas, puedes hacer cortes superficiales y decorativos (como un enrejado) con la punta de un cuchillo (¡con cuidado de no cortar la masa!). Espolvorea con sal gruesa.\n\n(Opcional pero recomendado): Refrigera el Wellington completo por 15 minutos más antes de hornear.\n\nHorneado y Reposo (El Final)\nHorneado: Hornea a 200°C (400°F) durante 20-25 minutos. La masa debe estar dorada e inflada.\n\nBajar Temperatura: Baja el horno a 180°C (350°F) y hornea por 10-15 minutos más.\n\nTemperatura Interna (La única forma de saber):\n\nPunto Rojo (Inglesa/Rare): 48-50°C (120°F)\n\nPunto Medio-Rojo (Medium-Rare): 52-54°C (125-130°F) - Este es el punto recomendado.\n\nA Punto (Medium): 57-60°C (135-140°F)\n\n¡REPOSO OBLIGATORIO!: Saca el Wellington del horno y colócalo en una tabla de cortar. Déjalo reposar sin tapar durante 10 a 15 minutos. Si lo cortas de inmediato, todos los jugos se escaparín y arruinarís el plato. El reposo es vital.\n\nCortar: Usa un cuchillo de sierra (cuchillo de pan) para cortar rodajas gruesas y servir inmediatamente.	1	20	90	2023-06-27	1	0
12	Pastel de Pescado	https://www.themealdb.com/images/media/meals/ysxwuq1487323065.jpg		Fase 1: Preparar los Componentes\n\nHacer el Puré: Pela las papas, córtalas en cubos iguales y ponlas en una olla con agua fráa y sal. Llévalas a ebullición y cocínalas hasta que estén muy tiernas (15-20 minutos).\n\nPochar el Pescado (El Secreto del Sabor): Mientras las papas hierven, calienta la leche, la hoja de laurel y los granos de pimienta en un sartén grande a fuego medio. Justo antes de que hierva, baja el fuego.\n\nAgrega los trozos de pescado (blanco y ahumado) a la leche caliente. Cocina a fuego muy bajo (sin hervir) durante 5-7 minutos, o hasta que el pescado esté casi cocido.\n\nCon una espumadera, saca con cuidado el pescado y ponlo en una fuente o plato. ¡Guarda esa leche! Cuela la leche (para sacar el laurel y la pimienta) y resérvala.\n\nTerminar el Puré: Cuela las papas y devuélvelas a la olla caliente (sin agua) por 1 minuto para que se evapore el exceso de humedad. Muélelas bien. Agrega la mantequilla, la leche tibia, sal y pimienta blanca. Bate hasta que esté cremososo y resérvalo.\n\nFase 2: Hacer la Salsa y el Relleno\n\nSofreír la Base: En una olla mediana, derrite 3 cucharadas de mantequilla a fuego medio. Agrega el puerro (o cebolla) y sofríe por 5-8 minutos hasta que esté muy blando, pero sin dorarse.\n\nHacer el Roux: Agrega las 3 cucharadas de harina al puerro y revuelve constantemente durante 1-2 minutos. Esto cocina la harina cruda.\n\nHacer la Salsa (Bechamel): Retira la olla del fuego. Agrega un chorrito de la leche que reservaste (donde cociste el pescado) y bate vigorosamente hasta que se integre.\n\nVuelve al fuego bajo y sigue agregando la leche de a poco, batiendo sin parar para que no se formen grumos.\n\nUna vez que toda la leche esté incorporada, sube el fuego a medio y sigue batiendo hasta que la salsa hierva y espese. Sazona con sal, pimienta y la pizca de nuez moscada.\n\nFase 3: Armado y Horneado\n\nPrecalentar: Precalienta el horno a 190°C (375°F).\n\nCombinar el Relleno: Toma una fuente apta para horno (fuente de pyrex o greda).\n\nDesmenuza el pescado cocido en trozos grandes (no lo muelas). Agrégalo a la fuente.\n\nAñade los camarones crudos, las arvejas congeladas, el perejil picado y los huevos duros (si usas).\n\nVierte la salsa blanca (bechamel) caliente sobre toda la mezcla de pescado y revuelve suavemente para combinar.\n\nLa Cubierta: Cubre todo el relleno con el puré de papas, esparciéndolo con una cuchara desde los bordes hacia el centro (para sellar).\n\nCon un tenedor, "raspa" la superficie del puré para crear textura (esas puntas se dorarín maravillosamente).\n\nGratinar (Opcional): Espolvorea el queso parmesano o cheddar sobre el puré.\n\nHornear: Coloca la fuente sobre una bandeja de horno (por si burbujea y se derrama). Hornea por 30-40 minutos, o hasta que el puré esté dorado y el relleno esté burbujeando caliente por los bordes.\n\nDeja reposar 10 minutos antes de servir. Es un plato completo en sá mismo.	1	28	90	2023-06-27	1	0
23	Papas de Desayuno Crujientes	https://www.themealdb.com/images/media/meals/yrstur1511816601.jpg		El Secreto (Doble Cocción):\n\nMétodo A (Hervido - Tradicional): Lava las papas y córtalas en cubos de 1.5 cm (aprox.). Ponlas en una olla con agua fráa y sal. Hiérvelas solo hasta que estén casi tiernas (unos 7-10 minutos). Deben estar firmes, si las pinchas, el tenedor debe encontrar resistencia.\n\nMétodo B (Microondas - Rípido): Pon los cubos de papa en un bol apto para microondas con 2 cucharadas de agua. Tapa y cocina a alta potencia por 4-5 minutos.\n\nPaso Crítico: Sea cual sea el método, escurre muy bien las papas y sécalas con toalla de papel. Si están húmedas, se cocinarín al vapor en el sartén en vez de freírse.\n\nCalentar el Sartén: En un sartén grande (idealmente de hierro fundido o acero inoxidable) a fuego medio-alto, calienta el aceite y la mantequilla juntos.\n\nFreár las Papas (Paciencia):\n\nAgrega las papas secas al sartén caliente. Espárcelas en una sola capa.\n\n¡No las muevas! Déjalas freír sin tocarlas durante 4-5 minutos. Esto es esencial para que formen la costra dorada.\n\nVoltéalas con una espátula y déjalas quietas por otros 4-5 minutos. Repite hasta que estén doradas y crujientes por todos lados.\n\nAñadir los Vegetales: Cuando las papas estén casi listas (80% doradas), agrega la cebolla y el pimentón picados.\n\nSazonar: Agrega la sal, la pimienta, el pimentón (paprika) y el ajo en polvo. Revuelve todo junto y cocina por 4-5 minutos más, hasta que las verduras estén tiernas y las papas completamente crujientes.\n\nServir: Retira del fuego, espolvorea con perejil fresco y sirve inmediatamente.\n\nVariación "Diner Style": Si te gustan más blandas (estilo diner), simplemente pica las papas crudas y cocínalas en el sartén tapado a fuego medio-bajo durante 15 minutos (para que se cuezan al vapor), y luego destapa, sube el fuego y añade las verduras para dorar.	1	19	91	2023-06-27	1	0
17	Sopa de Arvejas Partidas y Jamón	https://www.themealdb.com/images/media/meals/xxtsvx1511814083.jpg		Enjuagar las Arvejas: Pon las arvejas partidas en un colador y enjuígalas bien bajo el chorro de agua fría hasta que el agua salga clara. Revisa si hay alguna piedrecita y descártala.\n\nPreparar la Base de Sabor:\n\nSi usas Codillo de Cerdo: Calienta el aceite de oliva en una olla grande o "Dutch oven" a fuego medio.\n\nSi usas Tocino: Pon el tocino picado en la olla fría y cocinalo a fuego medio hasta que esté crujiente y haya soltado su grasa. Retira el tocino con una espumadera y resérvalo (lo usarís para decorar). Deja la grasa en la olla.\n\nEl Sofrito (Mirepoix): Agrega la cebolla, las zanahorias y el apio a la olla (con el aceite o la grasa del tocino). Sofráe durante 8-10 minutos, revolviendo, hasta que las verduras estén blandas y la cebolla traslúcida.\n\nAgrega el ajo picado y cocina por 1 minuto más, hasta que suelte su aroma.\n\nArmar la Sopa: Añade a la olla las arvejas partidas (enjuagadas), el caldo de pollo, las hojas de laurel y el tomillo.\n\nEl Cerdo: Si usas el codillo de cerdo, añádelo en el centro de la sopa, asegurándote de que esté mayormente cubierto por el líquido.\n\nHervor Lento (El Paso Clave): Lleva la sopa a ebullición. Luego, baja el fuego de inmediato, tapa la olla parcialmente y deja que hierva muy suavemente (simmer) durante 1 a 1.5 horas.\n\nRevuelve cada 15-20 minutos, raspando el fondo para asegurarte de que las arvejas no se peguen.\n\nLa sopa está lista cuando las arvejas estén completamente deshechas y la sopa esté espesa.\n\nDesmechar el Cerdo: Retira con cuidado el codillo de cerdo de la sopa (estarí muy caliente) y ponlo en una tabla de cortar. Saca las hojas de laurel de la sopa y descártalas.\n\nCuando el codillo esté lo suficientemente frío para manipularlo, usa dos tenedores para desmechar la carne, descartando el hueso, el cuero y el exceso de grasa.\n\nTerminar la Sopa: Vuelve a poner toda la carne desmechada en la olla.\n\nTextura (Opcional):\n\nSi la prefieres rústica, la sopa está lista.\n\nSi la prefieres cremososa, usa una licuadora de inmersión (minipimer) y dale solo unos pocos pulsos para espesar y cremar una parte, dejando aún trozos de vegetales (esta es mi forma favorita).\n\nSi la quieres totalmente suave, licúala por completo.\n\nSazonar (Importante): Ahora es el momento de probar. El codillo y el caldo aportan mucha sal. Agrega abundante pimienta negra y prueba. Añade sal solo si es necesario.\n\nServir: Sirve la sopa bien caliente. Si usaste tocino, decora con los trocitos crujientes que reservaste, crutones o un chorrito de aceite de oliva.	1	29	91	2023-06-27	1	0
34	Pastel de Choclo	https://www.gourmet.cl/wp-content/uploads/2016/09/Pastel-de-Choclo-edit.jpg	\N	1. Preparar el pino: En una olla grande, dorar la carne molida con las cebollas y el ajo hasta que están cocidos.\n\n2. Agregar el ají de color, comino, sal y pimienta. Cocinar por 10 minutos más hasta que el líquido se reduzca.\n\n3. Preparar el choclo: Moler los granos de choclo con la leche hasta obtener una pasta suave.\n\n4. En una olla, cocinar la pasta de choclo con la mantequilla, removiendo constantemente por 10-15 minutos hasta que espese. Agregar albahaca, sal y un poco de azúcar si se desea.\n\n5. En una fuente para horno enmantequillada, colocar el pino como base. Distribuir las aceitunas, huevos duros en rodajas y pasas.\n\n6. Cubrir con la pasta de choclo, esparciendo uniformemente. Pintar con mantequilla derretida y espolvorear azúcar si se desea.\n\n7. Hornear a 180°C por 30-40 minutos hasta que la superficie está dorada.\n\n8. Servir caliente, idealmente acompañado con ensalada chilena (tomate y cebolla) o ensalada verde.	1	20	95	2025-11-07	1	0
35	Sopaipillas	https://www.recetasderechupete.com/wp-content/uploads/2020/06/Sopaipillas-chilenas.jpg	\N	1. En un bowl grande, mezclar el zapallo cocido y molido aún tibio con la manteca derretida.\n\n2. Agregar la harina cernida con los polvos de hornear y la sal. Mezclar bien.\n\n3. Ir agregando agua tibia de a poco mientras se amasa, hasta formar una masa suave y no pegajosa. Amasar por 5-7 minutos.\n\n4. Dejar reposar la masa cubierta con un paño húmedo por 20 minutos.\n\n5. Estirar la masa con un rodillo sobre una superficie enharinada hasta que tenga aproximadamente 3-4 mm de espesor.\n\n6. Cortar círculos de aproximadamente 10 cm de diámetro. Hacer 2-3 perforaciones en el centro de cada sopaipilla con un tenedor.\n\n7. Calentar abundante aceite en una olla o sartén honda a fuego medio-alto.\n\n8. Freír las sopaipillas por ambos lados hasta que están doradas e infladas (aproximadamente 2-3 minutos por lado).\n\n9. Escurrir sobre papel absorbente.\n\n10. Servir calientes con pebre, mostaza o chancaca según preferencia. Las sopaipillas con chancaca se llaman "sopaipillas pasadas".	1	19	95	2025-11-07	1	0
5	Asado a la Olla de Tapapecho	https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcRX5IlLANtrdF5CfGNbuKCzWh5_-bU2EN3pOEvL6pqt7ClITa9Pcfc5wzXxnIRv		Preparar la Carne (Crucial): Seca muy bien la pieza de carne con toalla de papel. Sazona generosamente por todos los lados con sal y pimienta. Pasa la carne ligeramente por harina (esto ayudará a dorar y a espesar la salsa después).\n\nSellar la Carne: Calienta el aceite o manteca en una olla grande y de fondo grueso (idealmente de hierro fundido) a fuego alto. Sella la carne por todos sus lados hasta que esté muy dorada (marrón oscuro). No la muevas mientras se sella. Retira la carne de la olla y resérvala en un plato.\n\nEl Sofrito (Base del sabor): En la misma olla, baja el fuego a medio. Agrega la cebolla, las zanahorias y el apio. Sofráe por 8-10 minutos, raspando el fondo de la olla con una cuchara de madera para soltar los trocitos dorados de la carne.\n\nAñadir Aromíticos: Agrega el ajo y la pasta de tomate. Revuelve y cocina por 2 minutos más, hasta que la pasta de tomate cambie a un color más oscuro.\n\nDesglasar con Vino: Sube el fuego y vierte el vino tinto. Deja que hierva fuerte, raspando el fondo vigorosamente. Deja que el vino se reduzca a la mitad (unos 3-4 minutos).\n\nEl Braseado (Cocción Lenta): Regresa la carne a la olla (con el lado de la grasa hacia arriba). Agrega el caldo de vacuno (debe llegar hasta la mitad de la carne, no cubrirla por completo), las hojas de laurel y el tomillo.\n\nCocinar: Lleva la olla a un hervor suave, luego baja el fuego al mánimo posible, tapa la olla herméticamente y deja cocinar.\n\nTiempo de cocción: De 3 a 4 horas. La carne estarí lista cuando puedas insertar un tenedor y sacarlo sin ninguna resistencia.\n\nAgregar las Papas (Opcional): Si vas a usar papas, agrégalas a la olla durante los últimos 45-60 minutos de cocción, para que se cocinen en el caldo pero no se desarmen.\n\nReposar la Carne (¡Importante!): Con mucho cuidado, saca la carne de la olla y ponla en una tabla de cortar. Cúbrela con papel aluminio y déjala reposar por 15 minutos. No te saltes este paso, es vital para que los jugos se redistribuyan y quede tierna.\n\nHacer la Salsa (Gravy): Cuela el líquido que quedó en la olla (puedes dejar algunos vegetales si prefieres). Vuelve a poner el líquido en la olla a fuego medio. Si la salsa está muy láquida, espesa agregando la mezcla de maicena disuelta en agua fráa y batiendo hasta que hierva y espese.\n\nServir: Corta la carne. Importante: El tapapecho tiene una veta (fibra) muy marcada; debes cortarlo siempre en contra de la veta para asegurar la míxima ternura. Sirve la carne bañada en su salsa (gravy) y acompañada de los vegetales.	1	20	89	2023-06-27	1	0
8	Big Mac	https://www.themealdb.com/images/media/meals/urzj1d1587670726.jpg		Hacer la Salsa (Hacer primero): En un bol pequeño, mezcla TODOS los ingredientes de la "Salsa Especial". Bate bien, cúbrelo y refrigera por al menos 1 hora. Este reposo es fundamental.\n\nPreparar los Vegetales: Pica la lechuga iceberg muy fina. Pica la cebolla blanca lo más fino que puedas (casi polvo).\n\nPro-Tip: Para imitar el sabor suave de la cebolla de McDonald's, remoja la cebolla picada en un bol con agua fría por 10 minutos y luego escúrrela bien.\n\nPreparar los Panes: Tuesta las 3 piezas de pan (la tapa con sésamo, la base del medio y la base de abajo) en un sartén con un poco de mantequilla o en una plancha hasta que estén dorados.\n\nCocinar las Hamburguesas:\n\nForma 2 hamburguesas muy delgadas y planas, un poco más anchas que el pan (se encogerín al cocinarlas).\n\nCalienta un sartén o plancha a fuego alto.\n\nCocina las hamburguesas 1-2 minutos por lado. No las sazones antes.\n\nAl voltearlas, sazónalas en el sartén con sal y pimienta.\n\nEn los últimos 30 segundos, pon la límina de queso sobre una de las hamburguesas para que se derrita.\n\n5. El Montaje (El Ritual)\nAquá es donde se crea la magia, de abajo hacia arriba:\n\nPan de Abajo (Base):\n\nUna cucharada generosa de Salsa Especial.\n\nUna pizca de cebolla picada.\n\nUn puñado de lechuga picada.\n\nLa hamburguesa que tiene el queso derretido.\n\nPan del Medio:\n\nColoca la base del segundo pan encima de la primera hamburguesa.\n\nUna cucharada de Salsa Especial.\n\nUna pizca de cebolla picada.\n\nUn puñado de lechuga picada.\n\nLas rodajas de pepinillo.\n\nLa segunda hamburguesa (sin queso).\n\nTapa:\n\nColoca la tapa del pan (la que tiene sésamo) encima de todo.	1	20	89	2023-06-27	1	0
19	Tapapecho Curado a la Montreal	https://www.themealdb.com/images/media/meals/uttupv1511815050.jpg		Desalinado (¡Paso Crítico!):\n\nSaca el tapapecho del envase y descarta la salmuera (y la bolsita de especias que a veces trae).\n\nColoca la carne en una olla o contenedor grande y cúbrela completamente con agua fráa.\n\nRefrigérala y déjala remojar por al menos 8 horas (idealmente 12-24 horas), cambiando el agua 2 o 3 veces.\n\n¿Por qué?: El corned beef está diseñado para hervirse, por lo que es extremadamente salado. Si no lo desalas, quedarí incomible después de ahumarlo.\n\nPreparar el Rub:\n\nEn un sartén seco a fuego medio, tuesta ligeramente los granos de pimienta y las semillas de coriandro (2-3 minutos, hasta que suelten su aroma).\n\nMuele las especias tostadas en un moledor de especias o en un mortero. No busques un polvo fino; quieres una molienda gruesa y rústica.\n\nMezcla esta molienda con el resto de los ingredientes del rub (paprika, ajo, cebolla).\n\nAplicar el Rub:\n\nSaca la carne del agua y sécala muy bien con toalla de papel.\n\nUnta toda la superficie de la carne con una capa fina de mostaza amarilla (esto solo ayuda a que el rub se pegue).\n\nAplica el rub generosamente por todos lados, presionando para que se adhiera.\n\nEl Ahumado (Fase 1):\n\nPrecalienta tu ahumador (smoker) o parrilla para cocción indirecta a 135°C (275°F).\n\nColoca la carne en el ahumador. Ahúma durante 4 a 5 horas.\n\nLo que buscas es que la carne alcance una temperatura interna de 70°C (160°F) y haya desarrollado una costra oscura (el bark).\n\nEl Vapor (Fase 2 - El Secreto):\n\nTransfiere la carne ahumada a una bandeja de aluminio.\n\nAgrega 1 taza de líquido a la bandeja (puede ser caldo de vacuno, cerveza o simplemente agua).\n\nCubre la bandeja herméticamente con papel de aluminio.\n\nVuelve a poner la bandeja en el ahumador (o en un horno convencional, ya no necesita humo).\n\nSigue cocinando hasta que la temperatura interna de la carne alcance los 95°C (203°F). La carne debe estar "probe tender" (un termómetro debe entrar y salir sin ninguna resistencia, como si fuera mantequilla). Esto puede tomar 3-4 horas adicionales.\n\nEl Reposo:\n\nSaca la bandeja del ahumador/horno y deja reposar la carne (aún envuelta) durante al menos 1 hora. Esto es vital para que los jugos se redistribuyan.\n\nCómo Servir (El Ritual)\nLa "Montreal Smoked Meat" no se sirve como un asado cualquiera.\n\nEl Corte: Se corta en contra de la veta de la carne. A diferencia del brisket texano, el corte de Montreal es tradicionalmente más grueso (aprox. 0.5 cm).\n\nEl Síndwich: Se sirve apilado ridículamente alto sobre pan de centeno (rye bread).\n\nEl ÜNICO Aderezo: Mostaza amarilla. Nada más. (Quizís un pepinillo dill al lado).\n\nEs un proyecto de todo un día, ¡pero el resultado es una de las mejores carnes que probarís en tu vida!	1	20	91	2023-06-27	1	0
25	Tortilla de Patatas Española	https://www.themealdb.com/images/media/meals/quuxsx1511476154.jpg		La receta tiene 3 fases: la cocción de las papas, el reposo con el huevo y el cuajado (la parte más rípida).\n\nFase 1: El Confitado (La Paciencia)\n\nPelar y Cortar: Pela las papas. El corte tradicional es en "lascas" o líminas finas e irregulares, no en cubos perfectos. Corta la cebolla en juliana fina.\n\nLa Sartén: Pon el sartén a fuego medio con una cantidad generosa de aceite de oliva (debe ser suficiente para cubrir las papas).\n\nCocción Lenta (El Secreto): Cuando el aceite esté caliente (pero no humeando), añade las papas y la cebolla. Espolvorea un poco de sal.\n\nBaja el fuego a medio-bajo. La clave aquá es confitar, no freír. Las papas deben cocerse lentamente en el aceite, revolviendo de vez en cuando con cuidado para que no se peguen, durante unos 20-25 minutos.\n\nEstarín listas cuando, al pinchar una papa con la espátula, se rompa fácilmente. No deben estar doradas, sino tiernas y blandas.\n\nFase 2: El Reposo (El Sabor)\n\nEscurrir: Coloca un colador grande sobre un bol. Vierte con cuidado el contenido del sartén (papas, cebolla y aceite) sobre el colador. Deja que escurra muy bien todo el aceite (este aceite puedes guardarlo, tiene un sabor increáble para futuras preparaciones).\n\nBatir Huevos: Mientras se escurren, bate los 6 huevos en un bol grande. Añade una buena pizca de sal.\n\nLa Mezcla: Añade las papas y cebollas (ya escurridas y aún tibias) al bol con los huevos batidos.\n\n¡El Reposo Mágico!: Este es el truco para una tortilla jugosa. Deja que la mezcla de papa y huevo repose junta durante al menos 15 minutos (idealmente 30). Las papas absorberín el huevo y el almidón espesarí la mezcla.\n\nFase 3: El Cuajado y "El Volteo" (La Técnica)\n\nCalentar el Sartén: Limpia el sartén donde confitaste las papas. Ponlo a fuego medio-alto con solo una cucharadita del aceite que escurriste.\n\nVerter: Cuando el sartén esté bien caliente, vierte toda la mezcla del bol. Usa la espátula para esparcirla uniformemente y "sellar" los bordes, empujíndolos ligeramente hacia adentro.\n\nCuajar (Lado 1): Baja el fuego a medio-bajo. Cocina durante 3-4 minutos. Mueve el sartén en cárculos pequeños para evitar que se pegue el centro.\n\nEl Volteo (El Momento de la Verdad):\n\nToma el plato llano grande y ponlo boca abajo sobre el sartén, como si fuera una tapa.\n\nSujeta el mango del sartén con una mano y presiona el plato firmemente contra el sartén con la otra.\n\nCon un movimiento rípido, seguro y fluido, gira el sartén 180 grados sobre el plato (hazlo sobre el lavaplatos si es tu primera vez, por si acaso).\n\nLa tortilla caerí sobre el plato, con el lado cocido hacia arriba.\n\nCuajar (Lado 2): Desliza la tortilla suavemente desde el plato de vuelta al sartén (con el lado crudo hacia abajo).\n\nVuelve a usar la espátula para redondear los bordes y darle su forma clásica.\n\nCocina por 2-3 minutos más (si te gusta muy jugosa) o 4-5 minutos (si la prefieres más cuajada).\n\nDéjala reposar 5 minutos en el plato antes de cortar. ¡Se disfruta caliente, tibia o incluso fráa al día siguiente!	1	32	92	2023-06-27	1	0
27	Enchiladas de Pollo (Estilo Casserole)	https://www.themealdb.com/images/media/meals/qtuwxu1468233098.jpg		Precalentar y Preparar: Precalienta el horno a 180°C (350°F). Engrasa una fuente de horno grande (tamaño Pyrex de 9x13 pulgadas / 23x33 cm).\n\nEl Relleno Cremoso:\n\nEn un bol grande, mezcla el pollo deshebrado, los frijoles negros, el choclo, la cebolla picada (si usas) y la mitad (2 tazas) del queso rallado.\n\nAgrega el queso crema ablandado y 1 taza de la salsa de enchilada. Revuelve bien. Esta mezcla serí el relleno.\n\nEl Paso Clave (Evitar que se ponga blando):\n\nCalienta el aceite vegetal en un sartén a fuego medio-alto.\n\nPasa cada tortilla de maáz por el aceite caliente, solo por 10-15 segundos por lado. No quieres que queden crujientes, solo que se "sellen" y queden flexibles.\n\nSícalas y déjalas escurrir en un plato con toallas de papel. Este paso evita que las tortillas se desintegren y absorban toda la salsa.\n\nEl Armado (Como una Lasaña):\n\nCapa 1 (Base): Vierte ½ taza de salsa de enchilada en el fondo de la fuente y espírcela (esto evita que se pegue).\n\nCapa 2 (Tortillas): Coloca una capa de tortillas fritas sobre la salsa, cubriendo el fondo. Puedes romperlas o superponerlas para que encajen.\n\nCapa 3 (Relleno): Esparce la mitad de la mezcla del relleno de pollo y frijoles sobre las tortillas.\n\nCapa 4 (Salsa): Vierte 1 taza de salsa de enchilada sobre el relleno.\n\nCapa 5 (Tortillas): Coloca otra capa de tortillas.\n\nCapa 6 (Relleno): Esparce la otra mitad del relleno.\n\nCapa 7 (Tortillas): Coloca la última capa de tortillas por encima.\n\nCapa 8 (Final): Vierte toda la salsa restante sobre la parte superior, aseguríndote de que cubra todo.\n\nCapa 9 (Queso): Cubre generosamente con la otra mitad (2 tazas) de queso rallado.\n\nHornear:\n\nTapado: Cubre la fuente con papel de aluminio y hornea durante 25 minutos.\n\nDestapado: Retira el papel de aluminio y hornea por 10-15 minutos más, o hasta que el queso esté dorado, burbujeante y el pastel esté caliente en el centro.\n\n¡Reposo Obligatorio!:\n\nSaca el pastel del horno y déjalo reposar sobre una rejilla durante 10-15 minutos. Al igual que la lasaña, esto es vital para que los jugos se asienten y puedas cortar porciones limpias.\n\nServir: Corta en cuadrados y sirve caliente, decorado con crema agria, cilantro y palta.	1	21	93	2023-06-27	1	0
28	Tacos de Pescado al Estilo Cajún	https://www.themealdb.com/images/media/meals/uvuyxu1503067369.jpg		Prepara los Aderezos (Mise en Place):\n\nLa Ensalada (Slaw): En un bol, mezcla el repollo, la zanahoria (si usas) y el cilantro. Aliña con el jugo de limón y la sal. Revuelve bien y refrigera. Esta acidez es clave.\n\nLa Crema de Palta: En una licuadora o procesadora, pon la palta, el yogur, el manojo de cilantro, el jugo de limón, el ajo (si usas) y la sal. Licúa hasta que esté muy suave. Agrega 1-2 cucharadas de agua si está muy espesa. Reserva.\n\nPrepara el Pescado:\n\nSeca los trozos de pescado muy bien con toalla de papel (esto es vital para que se dore y no se cueza).\n\nPon todo el sazonador Cajún casero en un plato hondo.\n\nPasa cada trozo de pescado por el sazonador, cubriéndolo generosamente por todos lados.\n\nCocina el Pescado (El "Ennegrecido"):\n\nCalienta el aceite en un sartén grande (idealmente de hierro fundido) a fuego medio-alto. El sartén debe estar bien caliente.\n\nColoca los trozos de pescado en el sartén. No los muevas.\n\nCocina durante 2-3 minutos por lado. Las especias se tostarín y se pondrín de un color marrón oscuro (casi negro, de ahá el nombre "blackened"). El pescado debe quedar cocido pero jugoso por dentro.\n\nRetira el pescado y desmenúzalo ligeramente con un tenedor si los trozos son muy grandes.\n\nCalienta las Tortillas:\n\nEn el mismo sartén (ya sin el pescado) o en un comal, calienta las tortillas de maáz 30 segundos por lado hasta que estén blandas y con algunas manchas tostadas. Guírdalas en un paño limpio para mantener el calor.\n\nArma los Tacos:\n\nToma una tortilla caliente.\n\nPon una cama de la ensalada (slaw).\n\nAgrega una porción generosa del pescado Cajún.\n\nTermina con un chorrito abundante de la crema de palta y cilantro.\n\nSirve inmediatamente con gajos de limón al lado.\n\n¡Son picantes, ahumados, frescos, ácidos y cremososos, todo en un solo bocado!	1	28	93	2023-06-27	1	0
3	Panqueques de plátano	https://www.themealdb.com/images/media/meals/sywswr1511383814.jpg		Preparar ingredientes húmedos: En un bol grande, muele muy bien los plátanos maduros con un tenedor hasta hacerlos puré. Agrega el huevo, la leche, la mantequilla derretida y la vainilla. Bate hasta que esté todo bien combinado.\n\nPreparar ingredientes secos: En un bol aparte, mezcla la harina, los polvos de hornear, la sal y (si usas) el azúcar y la canela.\n\nCombinar las mezclas: Vierte los ingredientes secos sobre el bol de los ingredientes húmedos (el plátano, leche, etc.).\n\nNo sobrebatir (El secreto): Mezcla con un batidor de mano o una espátula solo hasta que se integren. Es normal y deseable que queden algunos grumos; si bates demasiado, los panqueques quedarán duros en lugar de esponjosos.\n\nCalentar el sartén: Calienta un sartén o plancha a fuego medio. Agrega un poco de mantequilla o aceite.\n\nCocinar: Vierte aproximadamente ¼ de taza de la mezcla por cada panqueque en el sartén caliente.\n\nDar vuelta: Cocina durante 2-3 minutos. Sabrís que es hora de voltear cuando veas burbujas que se forman y revientan en la superficie, y los bordes se vean dorados.\n\nTerminar: Voltea el panqueque con cuidado y cocina por 1-2 minutos más por el otro lado, hasta que esté dorado.\n\nServir: Repite con el resto de la masa (agregando más mantequilla al sartén si es necesario) y sirve los panqueques calientes con tus acompañamientos favoritos.	1	22	89	2023-06-27	1	0
7	Sloppy Joes de Cerdo a la Barbacoa	https://www.themealdb.com/images/media/meals/atd5sh1583188467.jpg		Sellar la Carne: Calienta el aceite en un sartén grande u olla a fuego medio-alto. Agrega la carne molida de cerdo y sepárala con una cuchara de madera. Cocina hasta que se dore (unos 5-7 minutos).\n\nEl Sofrito: Agrega la cebolla picada y el pimentón verde (si usas). Cocina todo junto por 5-8 minutos, hasta que la cebolla esté blanda y transparente.\n\nAromíticos: Añade el ajo picado y cocina por 1 minuto más, solo hasta que suelte su aroma (que no se queme).\n\nDrenar (Opcional): Si el cerdo soltó demasiada grasa, puedes inclinar el sartén y retirar el exceso con una cuchara, pero deja un poco para el sabor.\n\nConstruir la Salsa: Baja el fuego a medio-bajo. Agrega al sartén TODOS los ingredientes de la salsa: el ketchup, el azúcar rubia, el vinagre, la salsa inglesa, la mostaza, el pimentón ahumado y el comino. Revuelve todo vigorosamente.\n\nHervor Lento (El Secreto): Añade el caldo o agua (esto ayudará a que todo se integre) y revuelve bien. Deja que la mezcla hierva suavemente (a fuego bajo) y sin tapar, durante 15 a 20 minutos.\n\nEspesar: La salsa debe reducirse y espesar hasta tener una consistencia "descuidada" (sloppy), que se mantenga unida pero siga jugosa. Revuelve de vez en cuando.\n\nRectificar Sabor: Prueba la salsa. ¿Le falta sal? ¿Un poco más de dulzor (azúcar) o acidez (vinagre)? Ajústala a tu gusto y sazona con pimienta negra.\n\nTostar los Panes: Mientras la salsa reposa, unta el interior de los panes de hamburguesa con mantequilla y tuéstalos en un sartén o plancha hasta que estén dorados.\n\nServir: Sirve una porción generosa de la mezcla de cerdo BBQ caliente sobre la base del pan.\n\nSugerencia de Oro: Sárvelo cubierto con una cucharada de ensalada Coleslaw (ensalada de repollo agridulce). El contraste del cerdo caliente y la ensalada fráa y crujiente es la combinación perfecta.	1	27	89	2023-06-27	1	0
18	Pastel de Carne	https://www.themealdb.com/images/media/meals/ytpstt1511814614.jpg		Fase 1: El Relleno (Debe hacerse con anticipación)\n\nCocinar la Carne: En una olla grande o sartén profundo a fuego medio-alto, derrite la mantequilla. Agrega el cerdo molido y el vacuno molido.\n\nCocina la carne, desmenuzíndola con una cuchara de madera, hasta que esté dorada. Quieres que la textura quede fina, asá que rómpela bien.\n\nEl Sofrito: Agrega la cebolla picada y el ajo. Cocina por 5-8 minutos más, hasta que la cebolla esté completamente blanda y traslúcida.\n\nAñadir Sabor: Escurre el exceso de grasa de la carne (si hay mucho). Agrega todas las especias (canela, nuez moscada, clavo, tomillo, salvia), junto con la sal y la pimienta. Revuelve y cocina por 1 minuto para tostar las especias.\n\nEl Aglutinante (Binding): Agrega la papa rallada fina y el caldo de vacuno. Revuelve todo muy bien.\n\nHervor Lento: Lleva la mezcla a ebullición, luego baja el fuego al mánimo. Deja que hierva suavemente (simmer), sin tapar, durante 30-45 minutos.\n\nEl objetivo es que el líquido se evapore casi por completo y la papa se deshaga, creando un relleno espeso y unido, no líquido.\n\n¡ENFRIAR! (Paso Crítico): Retira el relleno del fuego y viértelo en una fuente o bol. Deja que se enfráe completamente a temperatura ambiente (o incluso refrigéralo). Si pones el relleno caliente en la masa, derretirí la mantequilla de la masa y el fondo quedarí remojado.\n\nFase 2: Armado y Horneado\n\nPrecalentar: Precalienta el horno a 200°C (400°F).\n\nBase: Forra un molde de pie de 23 cm (9 pulgadas) con uno de los discos de masa.\n\nRellenar: Vierte el relleno de carne fráo dentro de la base y espírcelo de manera uniforme.\n\nTapa: Cubre el relleno con el segundo disco de masa. Sella los bordes pellizcíndolos (puedes usar un tenedor o hacer un repulgue).\n\nAcabado: Haz 4-5 cortes en la parte superior de la masa para que escape el vapor. (Opcional: puedes decorar con recortes de masa, como hojas).\n\nBarniza toda la superficie con el huevo batido.\n\nHornear:\n\nHornea a 200°C (400°F) durante 15 minutos.\n\nBaja la temperatura a 180°C (350°F) y continúa horneando por 30-40 minutos más, o hasta que la masa esté dorada oscura y el relleno esté burbujeando por los cortes.\n\nReposo (Obligatorio): Saca el Tourti¿re del horno y déjalo reposar sobre una rejilla durante al menos 20 minutos antes de cortarlo. Esto permite que el relleno se asiente.\n\nSe sirve tradicionalmente con un "fruit ketchup" (ketchup de frutas), "chow-chow" (un encurtido agridulce) o, más comúnmente, solo con ketchup regular.	1	27	91	2023-06-27	1	0
22	Pastel de Azúcar de Québec	https://www.themealdb.com/images/media/meals/yrstur1511816601.jpg		Precalentar y Preparar la Masa:\n\nPrecalienta el horno a 190°C (375°F).\n\nForra un molde de pie de 9 pulgadas (23 cm) con tu disco de masa. Pellizca o repulga los bordes. No es necesario pre-hornear la masa.\n\nPreparar el Relleno:\n\nEn un bol grande, combina el azúcar rubia compactada, la harina y la sal. Bítelos bien con un batidor de mano para deshacer cualquier grumo de azúcar.\n\nEn un bol mediano, bate la crema de leche, la mantequilla derretida y la vainilla. (Si usas el sirope de maple, agrégalo aquá).\n\nVierte la mezcla de crema sobre la mezcla de azúcar.\n\nBate suavemente, solo hasta que todo esté combinado y no queden grumos secos. No batas en exceso.\n\nLlenar y Hornear:\n\nVierte el relleno líquido directamente sobre la base de masa cruda.\n\nColoca el molde de pie sobre una bandeja de horno (esto es para atrapar cualquier goteo accidental, ¡te salvará el horno!).\n\nHornea a 190°C (375°F) durante 15 minutos. Este calor inicial ayuda a "sellar" la base de la masa.\n\nBajar la Temperatura:\n\nDespués de 15 minutos, baja la temperatura del horno a 175°C (350°F).\n\nContinúa horneando por 30 a 40 minutos más.\n\nPrueba de Cocción (¡El Paso Crítico!):\n\nEl pie estarí listo cuando los bordes estén inflados y la superficie esté dorada y burbujeante.\n\nEl centro (un cárculo de unos 10 cm) debe seguir temblando visiblemente (como una jalea o un flan) cuando muevas el molde suavemente.\n\nSi esperas a que el centro esté firme, lo habrís cocinado demasiado y la textura no serí la correcta.\n\nEnfriamiento Obligatorio (El Secreto Final):\n\nSaca el pie del horno y colócalo en una rejilla.\n\nDebe enfriarse completamente a temperatura ambiente. Esto toma al menos 3 a 4 horas.\n\nDurante este tiempo, el relleno se asentarí y tomarí esa textura densa y perfecta de caramelo. Si lo cortas caliente, serí una sopa.\n\nSárvelo a temperatura ambiente o fráo, idealmente con una cucharada de crema batida sin azúcar para cortar el intenso dulzor.	1	22	91	2023-06-27	1	0
26	Paella de Hinojo y Berenjena Asados	https://www.themealdb.com/images/media/meals/1520081754.jpg		Necesitarís una paellera o un sartén muy grande y ancho (de unos 35-40 cm).\n\nAsar las Verduras (Fase 1):\n\nPrecalienta el horno a 200°C (400°F).\n\nEn una bandeja de horno, mezcla los cubos de berenjena y los gajos de hinojo con 3-4 cucharadas de aceite de oliva, sal y pimienta.\n\nExtiéndelos en una sola capa.\n\nHornea durante 25-30 minutos, díndoles la vuelta a mitad de camino, hasta que estén tiernos y bien caramelizados (dorados oscuros en los bordes). Resérvalos.\n\nPreparar el Caldo:\n\nEn una olla aparte, calienta el caldo de verduras. Añade las hebras de azafrín y una pizca de sal.\n\nMantenlo caliente a fuego muy bajo (es crucial que el caldo esté caliente al añadirlo al arroz).\n\nEl Sofrito (Fase 2):\n\nColoca la paellera a fuego medio. Añade las 4 cucharadas de aceite de oliva.\n\nSofráe la cebolla y el pimentón rojo. Cocina lentamente, revolviendo, durante 10-15 minutos hasta que estén muy blandos y dulces.\n\nAñade el ajo picado y cocina 1 minuto más.\n\nAgrega el tomate rallado y cocina por 5-8 minutos, hasta que el agua se evapore y se forme una pasta oscura.\n\n¡Importante! Retira la paellera del fuego. Añade el pimentón ahumado (asá no se quema) y revuelve bien.\n\nEl Arroz (Fase 3):\n\nVuelve a poner la paellera a fuego medio-alto. Añade el arroz (en forma de cruz, según la tradición, o simplemente espírcelo).\n\n"Nacara" el arroz: revuélvelo durante 1-2 minutos para que se impregne bien del aceite y el sofrito.\n\nLa Cocción (¡No Revolver!):\n\nVierte todo el caldo caliente con azafrín sobre el arroz.\n\nRevuelve una sola vez para distribuir el arroz uniformemente por toda la paellera. A partir de este punto, no la revuelvas más.\n\nCocina a fuego vivo (alto) durante los primeros 8-10 minutos.\n\nCuando el arroz empiece a asomar por la superficie del caldo, baja el fuego a medio-bajo.\n\nCocina por 10-12 minutos más, hasta que el arroz haya absorbido casi todo el líquido.\n\nEl Armado Final:\n\nCuando falten 5 minutos de cocción, coloca las verduras asadas (el hinojo y la berenjena) por encima del arroz de forma decorativa.\n\nEl Socarrat (Opcional pero recomendado): Sube el fuego a alto durante el último minuto. Escucha con atención: oirís cómo el arroz del fondo empieza a "freírse" y olerí a tostado. Ese es el socarrat (la costra crujiente del fondo). Retira del fuego justo antes de que se queme.\n\n¡El Reposo Obligatorio!:\n\nRetira la paellera del fuego. Cúbrela con un paño de cocina limpio y seco (o papel de aluminio).\n\nDeja que repose durante 5 a 10 minutos antes de servir. Este paso es vital para que el arroz termine de cocerse con el vapor y los sabores se asienten.\n\nServir: Espolvorea con perejil fresco y lleva la paellera directamente a la mesa. Sirve con gajos de limón al lado.	1	31	92	2023-06-27	1	0
21	Pastel de Papas de Québec	https://www.themealdb.com/images/media/meals/yyrrxr1511816289.jpg		Preparar el Puré:\n\nPon las papas en cubos en una olla con agua fráa y sal. Llévalas a ebullición y cocínalas hasta que estén muy tiernas (15-20 minutos).\n\nEscúrrelas bien y devuélvelas a la olla caliente por 1 minuto para que se evapore el exceso de humedad.\n\nMuélelas bien. Agrega la mantequilla, la leche tibia, sal y pimienta. Bate hasta que esté cremososo y suave. Reserva.\n\nPreparar la Carne:\n\nPrecalienta el horno a 180°C (350°F).\n\nEn un sartén grande a fuego medio-alto, calienta el aceite o la mantequilla.\n\nAgrega la cebolla picada y sofríe por 5 minutos hasta que esté blanda.\n\nAñade la carne molida. Cocina, desmenuzíndola con una cuchara, hasta que esté completamente dorada.\n\nSazona con sal, pimienta y (si usas) el ketchup o salsa inglesa. Escurre el exceso de grasa.\n\nArmar el Pastel (El Orden es Clave):\n\nBusca una fuente para horno (Pyrex o similar) de tamaño mediano (aprox. 20x30 cm).\n\nCapa 1 (Abajo): Extiende toda la mezcla de carne cocida en el fondo de la fuente y presiona ligeramente para compactar.\n\nCapa 2 (Medio): Vierte la lata de choclo en crema y espírcela uniformemente sobre la carne. (Si usas choclo en grano extra, mézclalo con el choclo en crema primero).\n\nCapa 3 (Arriba): Con cuidado, pon el puré de papas sobre la capa de choclo. Extiéndelo suavemente con una espátula para cubrir todo y sellar los bordes.\n\nAcabado: Con un tenedor, "raspa" la superficie del puré para crear crestas (esto las pondrí crujientes). Espolvorea con pimentón (paprika) y, si lo deseas, pon los cubitos de mantequilla extra encima.\n\nHornear:\n\nHornea durante 30-35 minutos. El objetivo es que se caliente por completo y que el puré se dore ligeramente por encima.\n\nSi la parte de arriba no está dorada, puedes ponerla bajo el "grill" (gratinador) del horno durante los últimos 2-3 minutos (¡vigilando que no se queme!).\n\nServir:\n\nDeja reposar 10 minutos antes de servir.\n\n¿El toque final y 100% auténtico de Québec? Se sirve directamente en el plato y se acompaña con... ¡Ketchup!	1	20	91	2023-06-27	1	0
15	Budín Cremoso de Arroz y Brócoli	https://www.themealdb.com/images/media/meals/vptwyt1511450962.jpg		Preparar los Componentes:\n\nArroz: Cocina el arroz como lo harías normalmente (1 taza de arroz por 2 de agua) y resérvalo.\n\nHorno: Precalienta el horno a 180°C (350°F) y enmantequilla una fuente o Pyrex grande.\n\nBrócoli: Blanquea el brócoli. Pon los floretes en agua hirviendo con sal por solo 2-3 minutos. Escúrrelos inmediatamente y písalos por agua fráa para detener la cocción (asá queda verde brillante y tierno).\n\nEl Sofrito: En un sartén, calienta el aceite de oliva a fuego medio. Añade la cebolla y la zanahoria rallada. Sofráe por 8-10 minutos hasta que estén muy blandas y dulces.\n\nHacer la Salsa de Queso (Mornay):\n\nEn una olla mediana a fuego medio, derrite las 3 cucharadas de mantequilla.\n\nAgrega la harina y revuelve constantemente por 1 minuto (esto es un roux).\n\nVierte la leche de a poco, batiendo vigorosamente para que no se formen grumos.\n\nSigue batiendo a fuego medio hasta que la salsa hierva suavemente y espese (debe cubrir la parte de atrís de una cuchara).\n\nBaja el fuego al mánimo. Agrega la mostaza, nuez moscada, sal y pimienta.\n\nAñade 1 ½ tazas del queso cheddar rallado (reserva la otra ½ taza) y revuelve solo hasta que se derrita. Retira del fuego.\n\nCombinar Todo:\n\nEn un bol muy grande, pon el arroz cocido, el brócoli blanqueado y el sofrito de cebolla/zanahoria.\n\nVierte la salsa de queso caliente sobre la mezcla.\n\nRevuelve suavemente con una espátula hasta que todo esté bien combinado. Prueba y ajusta la sal si es necesario.\n\nArmar y Hornear:\n\nVierte toda la mezcla en la fuente para horno que preparaste y espírcela de forma pareja.\n\nEn un bol pequeño, mezcla el pan rallado (Panko), la mantequilla derretida y el queso parmesano (si usas).\n\nEspolvorea la mezcla de pan rallado y el queso cheddar restante (la ½ taza que guardaste) sobre la superficie.\n\nHornea por 25 a 30 minutos, o hasta que esté burbujeante por los bordes y la cubierta esté dorada y crujiente.\n\nDeja reposar 10 minutos antes de servir. ¡Es un plato principal completo y delicioso!	1	32	90	2023-06-27	1	0
31	Fajitas de Garbanzos	https://www.themealdb.com/images/media/meals/tvtxpq1511464705.jpg		Precalentar y Preparar: Precalienta el horno a 200°C (400°F). Prepara una bandeja de horno grande.\n\nSecar los Garbanzos (¡Importante!): Después de enjuagar y escurrir los garbanzos, sécalos muy bien con toallas de papel. Si están húmedos, se cocinarín al vapor en lugar de asarse.\n\nSazonar: En un bol grande, pon los garbanzos secos, las tiras de pimentón y las tiras de cebolla.\n\nRocíalos con las 3 cucharadas de aceite de oliva y espolvorea todo el sazonador de fajitas por encima. Revuelve muy bien con las manos o una espátula hasta que todo esté uniformemente cubierto.\n\nAsar (Roast): Extiende la mezcla en la bandeja del horno en una sola capa uniforme. (No amontones las verduras, o se cocerín al vapor. Usa dos bandejas si es necesario).\n\nHornea durante 20-25 minutos. Revuélvelas a mitad de camino (a los 10-12 minutos).\n\nEstarín listas cuando las verduras estén tiernas, los garbanzos estén ligeramente crujientes y todo tenga bordes tostados (carbonizados).\n\nEl Toque Final: Saca la bandeja del horno. Exprime inmediatamente el jugo de limón sutil sobre todas las verduras y garbanzos calientes. (¡Escucharís el "sizzle"!).\n\nCalentar Tortillas: Mientras se asa la mezcla, calienta las tortillas en un comal, sartén o en el microondas.\n\nSirve todo al centro de la mesa (la bandeja de horno, las tortillas calientes y los acompañamientos) y deja que cada persona arme sus propias fajitas.	1	32	93	2023-06-27	1	0
32	Pimentones Rellenos con Quinoa y Porotos Negros	https://www.themealdb.com/images/media/meals/b66myb1683207208.jpg		Cocinar la Quinoa: En una olla, pon la taza de quinoa cruda y las 2 tazas de caldo de verduras. Lleva a ebullición, baja el fuego, tapa y cocina por 15-20 minutos, o hasta que el líquido se absorba y la quinoa esté cocida. Reserva.\n\nPreparar los Pimentones (Pre-cocción):\n\nPrecalienta el horno a 200°C (400°F).\n\nCorta los pimentones por la mitad a lo largo (desde el tallo hasta la base). Retira las semillas y las venas blancas.\n\nColoca las mitades de pimentón (con el corte hacia arriba) en una bandeja de horno. Rocíalos con 1 cucharada de aceite de oliva, sal y pimienta.\n\nPre-hornea los pimentones vacíos durante 15 minutos. Esto asegura que queden tiernos y no crudos.\n\nHacer el Relleno (Mientras se hornean los pimentones):\n\nEn un sartén grande a fuego medio, calienta 1 cucharada de aceite. Añade la cebolla y sofríe por 5-7 minutos, hasta que esté blanda.\n\nAgrega el ajo y todos los sazonadores (comino, pimentón ahumado, ajá en polvo, sal, pimienta). Revuelve por 1 minuto hasta que suelten su aroma.\n\nAñade los porotos negros, el choclo y la salsa de tomate. Revuelve bien y cocina por 3-4 minutos hasta que esté todo caliente.\n\nRetira del fuego.\n\nCombinar el Relleno:\n\nEn un bol grande, mezcla la quinoa cocida con la mezcla de porotos y verduras del sartén.\n\nAgrega el cilantro picado y el jugo de limón sutil. Revuelve bien y prueba. Ajusta la sal si es necesario.\n\nArmar y Hornear:\n\nSaca la bandeja con los pimentones pre-horneados del horno. (Baja la temperatura del horno a 190°C (375°F)).\n\nRellena generosamente cada mitad de pimentón con la mezcla de quinoa.\n\n(Opcional): Cubre cada pimentón relleno con una buena cantidad de queso rallado.\n\nVierte ¼ taza de agua en el fondo de la bandeja (esto crea vapor y ayuda a la cocción).\n\nHorneado Final:\n\nCubre la bandeja con papel de aluminio.\n\nHornea por 20 minutos.\n\nRetira el papel de aluminio y hornea por 10-15 minutos más, o hasta que el queso esté derretido y burbujeante, y los bordes del pimentón estén tiernos.\n\nSirve caliente, decorado con palta en rodajas, un toque de crema agria o más cilantro.	1	32	93	2023-06-27	1	0
29	Chili de Carne de Vacuno Braseada	https://www.themealdb.com/images/media/meals/uuqvwu1504629254.jpg		Este plato requiere paciencia. El tiempo de cocción es de 3 a 4 horas.\n\nPreparar la Carne (El Sabor):\n\nCorta la carne en cubos grandes (de unos 3-4 cm). Sazónalos generosamente con sal y pimienta.\n\nPasa los cubos por harina, sacudiendo el exceso.\n\nCalienta el aceite en una olla grande y de fondo grueso (idealmente de hierro fundido) a fuego alto.\n\nSella la carne en tandas. No sobrecargues la olla. Dora los cubos por todos lados hasta que tengan una costra marrón oscura. Retira la carne a un bol y reserva.\n\nEl Sofrito:\n\nEn la misma olla, baja el fuego a medio. Agrega un poco más de aceite si es necesario.\n\nAñade la cebolla, el pimentón y el jalapeño (si usas). Sofráe por 8-10 minutos, raspando el fondo para soltar los trozos dorados de la carne (fond), hasta que las verduras estén muy blandas.\n\nAgrega el ajo y la pasta de tomate. Cocina por 2 minutos más, revolviendo constantemente.\n\nLas Especias (El "Bloom"):\n\nAñade todas las especias secas (ajá en polvo, comino, pimentón ahumado, orégano). Revuelve todo por 1 minuto sin parar. Esto "despierta" las especias y es crucial para el sabor.\n\nDesglasar:\n\nVierte la cerveza negra para desglasar. Hierve fuerte por 2 minutos, raspando vigorosamente el fondo de la olla hasta que no quede nada pegado.\n\nEl Braseado (Cocción Lenta):\n\nRegresa la carne (y todos sus jugos) a la olla.\n\nAñade los tomates triturados, el caldo de vacuno, las hojas de laurel y el ingrediente secreto (cacao o chocolate).\n\nLleva a ebullición, luego baja el fuego al mánimo absoluto.\n\nCocción: Tapa la olla y deja que hierva muy suavemente (simmer) durante 3 a 3.5 horas. (Alternativa: Mételo a un horno precalentado a 160°C / 325°F por el mismo tiempo).\n\nEstarí listo cuando la carne esté tan tierna que puedas desmecharla fácilmente con un tenedor.\n\nTerminar el Chili:\n\nRetira las hojas de laurel. Puedes usar dos tenedores para desmechar la carne dentro de la misma olla, o dejar los trozos enteros si lo prefieres.\n\n(Opcional): Si vas a usar porotos negros, añídelos ahora.\n\nEspesar: Si el chili está muy líquido, agrega la mezcla de maicena/agua fría y revuelve. Deja hervir suavemente 5 minutos más hasta que espese.\n\nAjustar Sabor: Agrega el chorrito de jugo de limón o vinagre (esto balancea la riqueza del plato). Prueba y ajusta la sal.\n\nSirve el chili bien caliente en boles, cubierto generosamente con tus toppings favoritos (la crema agria y el queso son casi obligatorios).	1	20	93	2023-06-27	1	0
20	Timbits	https://www.themealdb.com/images/media/meals/txsupu1511815755.jpg		Preparar el Aceite: En una olla grande y pesada (idealmente de hierro fundido o un "Dutch oven"), vierte el aceite (debe tener al menos 5 cm de profundidad). Caliéntalo a fuego medio hasta que alcance 180°C (360°F). Usa un termómetro de cocina; la temperatura es clave.\n\nPreparar los Secos: En un bol grande, mezcla la harina, azúcar, polvos de hornear, nuez moscada y sal.\n\nPreparar los Húmedos: En un bol mediano, bate los huevos. Luego agrega la mantequilla derretida, el buttermilk (o tu sustituto) y la vainilla. Bate hasta combinar.\n\nCombinar (¡No sobre-mezcles!): Vierte los ingredientes húmedos sobre los secos. Usa una espátula para mezclar justo hasta que estén combinados. La masa serí espesa y pegajosa, similar a una masa de queque denso. ¡No la batas!\n\nFormar los Timbits: La forma más fácil es usar dos cucharas pequeñas (cucharas de té). Toma una cucharada de masa con una y usa la otra para empujarla y redondearla un poco antes de dejarla caer con cuidado en el aceite caliente.\n\nFreár en TANDAS:\n\nFráe solo 6-8 bolitas a la vez (si pones muchas, el aceite se enfriarí y quedarán aceitosas).\n\nSe inflarín y flotarín. Fráe durante 2-3 minutos por lado. A menudo se dan vuelta solas, pero ayúdalas si es necesario.\n\nDeben quedar de un color dorado oscuro y profundo.\n\nEscurrir: Usa una espumadera para sacar los Timbits del aceite y ponlos sobre una rejilla o plato con toallas de papel absorbente.\n\n¡Cubrir en Caliente! (El Secreto):\n\nDeja que se enfráen solo por 1 minuto (deben seguir calientes, pero no hirviendo).\n\nPara Canela: Pasa las bolitas calientes por la mezcla de azúcar y canela.\n\nPara Glaseado: Sumerge cada bolita caliente en el glaseado y ponla en una rejilla para que el exceso escurra.\n\nSárvelos lo antes posible. ¡Son mucho mejores tibios!	1	22	91	2023-06-27	1	0
30	Tacos Horneados con Pollo a la Olla Lenta	https://www.themealdb.com/images/media/meals/ypxvwv1505333929.jpg		Fase 1: El Pollo en la Olla Lenta (Crock-Pot)\n\nColocar: Pon las pechugas de pollo en el fondo de la olla de cocción lenta.\n\nSazonar: Espolvorea todo el sazonador de tacos sobre el pollo.\n\nCubrir: Vierte la salsa (y el caldo, si lo usas) sobre el pollo.\n\nCocinar: Tapa la olla y cocina a fuego BAJO (LOW) durante 4-6 horas o a fuego ALTO (HIGH) durante 3-4 horas. El pollo debe estar completamente cocido y tierno.\n\nDeshebrar: Saca las pechugas de pollo y ponlas en un bol grande. Usa dos tenedores para deshebrarlas (debería ser muy fácil).\n\nRemezclar: Vuelve a poner el pollo deshebrado en la olla con la salsa que quedó y revuelve bien. Deja que absorba el jugo por unos 10 minutos.\n\nFase 2: El Armado y Horneado de los Tacos\n\nPrecalentar: Precalienta el horno a 190°C (375°F).\n\nPreparar los Tacos: Coloca los "taco shells" de pie en una fuente para horno grande (tipo Pyrex de 9x13 pulgadas).\n\nPro-Tip: Si usas tacos comunes, puedes apoyarlos uno contra el otro para que no se caigan.\n\nLa Base (El Secreto): Con una cuchara, unta una capa delgada de porotos refritos en el fondo de cada taco shell. Esto actúa como un "pegamento" y evita que el jugo del pollo ablande la base del taco.\n\nRellenar: Con una cuchara ranurada (para escurrir el exceso de líquido), toma una porción generosa del pollo deshebrado y rellena cada taco.\n\nCubrir con Queso: Cubre generosamente la parte superior de todos los tacos con el queso rallado (¡no seas tímido!).\n\nHornear: Hornea durante 12 a 15 minutos. El objetivo es que los tacos se calienten por completo, la base quede crujiente y el queso se derrita y burbujee.\n\nServir: Saca la fuente del horno con cuidado. Lleva la fuente directamente a la mesa y deja que cada persona agregue sus toppings fráos (lechuga, crema agria, palta, etc.) por encima.\n\n¡Son deliciosos, crujientes y una comida muy entretenida!	1	21	93	2023-06-27	1	0
16	Pie de Frutilla y Ruibarbo	https://www.themealdb.com/images/media/meals/178z5o1585514569.jpg		Preparar las Frutas: En un bol muy grande, combina las frutillas en cuartos y el ruibarbo en trozos.\n\nPreparar la Mezcla Seca: En un bol pequeño aparte, mezcla el azúcar, la maicena y la sal. (Mezclarlos antes de agregarlos a la fruta evita que la maicena se apelmace).\n\nCombinar el Relleno: Vierte la mezcla de azúcar/maicena sobre la fruta. Agrega el jugo de limón y la vainilla. Revuelve suavemente con una espátula hasta que toda la fruta esté cubierta. Deja reposar 15 minutos mientras preparas la masa.\n\nPrecalentar y Preparar la Base:\n\nPrecalienta el horno a 200°C (400°F).\n\nColoca una bandeja de horno en la rejilla inferior del horno (esto ayudará a dorar la base y atraparí cualquier goteo).\n\nForra un molde para pie de 23 cm (9 pulgadas) con uno de los discos de masa.\n\nArmar el Pie:\n\nVierte todo el relleno (incluidos los jugos que se formaron) dentro de la base de masa.\n\nEsparce los cubitos de mantequilla fráa sobre el relleno (esto añade riqueza).\n\nCubre el pie con el segundo disco de masa. Puedes hacerlo de dos maneras:\n\nTapa Sólida: Cúbrelo y haz 4-5 cortes en el centro para que escape el vapor.\n\nEnrejado (Lattice): Corta la masa en tiras y teje un enrejado (esta es la forma clásica, ya que ayuda a evaporar más líquido).\n\nSellar: Pellizca los bordes de la masa superior e inferior para sellar bien el pie.\n\nTerminación: Barniza toda la superficie de la masa con el huevo batido (la egg wash). Espolvorea generosamente con el azúcar gruesa (esto le da un toque crujiente y profesional).\n\nHornear (El Paso Crítico):\n\nColoca el pie sobre la bandeja que precalentaste en la rejilla inferior del horno.\n\nHornea a 200°C (400°F) durante 20 minutos. (Este golpe de calor inicial ayuda a cocinar la masa inferior).\n\nBaja la temperatura a 180°C (350°F).\n\nHornea por 30-40 minutos más.\n\n¿Cómo saber si está listo?: El pie está listo cuando la masa esté dorada oscura y, lo más importante, el relleno esté burbujeando vigorosamente en el centro. Si solo burbujea en los bordes, la maicena no se ha activado y el relleno quedarí líquido.\n\n¡ENFRIAR! (Paso Obligatorio):\n\nEste es el paso más importante que la gente ignora. Saca el pie del horno y déjalo enfriar sobre una rejilla.\n\nDebe enfriarse por un mánimo de 3 a 4 horas a temperatura ambiente.\n\nSi lo cortas caliente, el relleno serí una sopa. Durante el enfriamiento, la maicena hace su trabajo y el relleno se gelifica perfectamente.\n\nSárvelo solo o, aún mejor, con una bola de helado de vainilla.	1	22	90	2023-06-27	1	0
24	Paella de Fideos y Mariscos	https://www.themealdb.com/images/media/meals/wqqvyq1511179730.jpg		Necesitarís una paellera o un sartén muy grande, ancho y poco profundo.\n\nPreparar el Caldo y los Mariscos (Fase 1):\n\nCalienta el caldo de pescado en una olla. Añade las hebras de azafrín, revuelve y mantenlo caliente a fuego bajo.\n\nEn un sartén aparte con un chorrito de aceite, cocina los mejillones y las almejas (puedes añadir un chorrito de vino blanco). Tapa y cocina solo hasta que se abran. Retira los mariscos (descarta los cerrados) y reserva el líquido colado (puedes añadirlo al caldo principal).\n\nEn la paellera, calienta aceite de oliva. Sella las gambas/langostinos 1 minuto por lado. Retáralos y resérvalos.\n\nEl Sofrito (Base del Sabor):\n\nEn esa misma paellera (con el aceite de las gambas), baja el fuego a medio. Agrega la cebolla y sofríe por 8-10 minutos hasta que esté blanda.\n\nAñade el ajo y el calamar/sepia. Cocina por 5 minutos más hasta que el calamar esté tierno.\n\nAgrega el tomate rallado y sofríe hasta que el agua se evapore y se forme una pasta oscura (unos 5-8 minutos).\n\n¡Paso Crítico!: Retira la paellera del fuego. Añade el pimentón dulce (paprika) y revuelve rípidamente. (Esto evita que el pimentón se queme y amargue).\n\nTostar los Fideos (El Secreto):\n\nVuelve a poner la paellera a fuego medio-alto. Agrega un chorro más de aceite de oliva si es necesario.\n\nVierte los fideos secos en la paellera, sobre el sofrito.\n\nRevuelve constantemente durante 3-5 minutos. Los fideos deben "freírse" en el aceite y el sofrito, cambiando de color pálido a un tono dorado/tostado. ¡No dejes que se quemen!\n\nLa Cocción:\n\nVierte el caldo caliente con azafrín sobre los fideos tostados. El caldo debe cubrir generosamente los fideos.\n\nSazona con sal y pimienta. Revuelve una sola vez para distribuir los fideos uniformemente en la paellera.\n\n¡No la revuelvas más! (Al igual que la paella).\n\nCocina a fuego medio-alto durante unos 10-12 minutos, o lo que indique el paquete de fideos.\n\nEl Acabado (Puntaeta):\n\nCuando falten unos 3-4 minutos y la mayoráa del caldo se haya absorbido, coloca decorativamente las gambas, mejillones y almejas que tenáas reservados por encima.\n\nSube el fuego al míximo durante el último minuto para crear el socarrat (la parte tostada del fondo).\n\nVariación Opcional: Algunos cocineros meten la paellera en el horno (precalentado a 200°C) durante los últimos 5 minutos. Esto hace que los fideos se sequen y se pongan "de punta" (puntaeta).\n\nReposo y Servicio:\n\nRetira del fuego y deja reposar la Fideuá durante 5 minutos antes de servir.\n\nLlévala a la mesa en la misma paellera y sárvela con gajos de limón y un bol generoso de allioli al lado.	1	28	92	2023-06-27	1	0
9	Berenjena Asada con Tahini, Piñones y Lentejas	https://www.themealdb.com/images/media/meals/ysqrus1487425681.jpg		Asar las Berenjenas (El Paso más largo):\n\nPrecalienta el horno a 200°C (400°F).\n\nCorta las berenjenas por la mitad, a lo largo.\n\nCon un cuchillo, haz cortes diagonales en la pulpa de la berenjena (en forma de diamante), pero sin cortar la piel. Esto ayuda a que se cocine de manera uniforme.\n\nColoca las mitades de berenjena en una bandeja de horno, con la pulpa hacia arriba.\n\nRocáalas generosamente con aceite de oliva, sal, pimienta y el pimentón ahumado (si usas).\n\nHornea durante 35-45 minutos. Estarín listas cuando la pulpa esté muy tierna (casi deshaciéndose) y los bordes estén caramelizados y dorados.\n\nCocinar las Lentejas (Mientras se hornea la berenjena):\n\nEnjuaga las lentejas.\n\nPonlas en una olla con el agua (o caldo) y la hoja de laurel.\n\nLleva a ebullición, luego baja el fuego y cocina a fuego lento (semitapado) durante 20-25 minutos. Deben estar tiernas pero firmes, no deshechas (al dente).\n\nEscurre bien cualquier exceso de líquido.\n\nEn un bol, aliña las lentejas calientes con 1 cucharada de aceite de oliva, el jugo de limón, el perejil picado, sal y pimienta. Reserva.\n\nHacer la Salsa de Tahini:\n\nEn un bol, mezcla el tahini, el jugo de limón y el ajo picado. Al principio, la mezcla se pondrí muy espesa (se "agarrotarí").\n\nAgrega el agua fráa, de a poco, mientras bates constantemente.\n\nSigue batiendo hasta que la salsa se vuelva pálida, suave y cremososa, con una consistencia similar al yogur líquido o miel ligera. Ajusta con sal.\n\nTostar los Piñones:\n\nEn un sartén seco (sin aceite) a fuego medio-bajo, tuesta los piñones.\n\nMuévelos constantemente durante 2-3 minutos. No les quites el ojo de encima, ya que pasan de dorados a quemados en segundos.\n\nEn cuanto tomen un color dorado y suelten aroma, retáralos del fuego inmediatamente.\n\nMontaje del Plato:\n\nColoca las mitades de berenjena asada en un plato grande o fuente (puedes aplastar ligeramente la pulpa con un tenedor si lo deseas).\n\nVierte una generosa cantidad de la salsa de tahini sobre cada mitad de berenjena.\n\nCubre con una porción de las lentejas aliñadas.\n\nEspolvorea por encima los piñones tostados y las semillas de granada.\n\nTermina con las hojas de menta o perejil fresco y un último chorrito de aceite de oliva virgen extra.\n\nSe sirve tibio o a temperatura ambiente. ¡Es un plato espectacular!	1	32	89	2023-06-27	1	0
13	Sopa Crema de Tomate	https://www.themealdb.com/images/media/meals/stpuws1511191310.jpg		El Sofrito (Base del Sabor): En una olla grande o "Dutch oven" a fuego medio, derrite la mantequilla junto con el aceite de oliva (el aceite evita que la mantequilla se queme).\n\nAgrega la cebolla picada y la zanahoria (si la usas). Sofráe lentamente durante 8-10 minutos, revolviendo ocasionalmente, hasta que estén muy blandas y la cebolla esté traslúcida.\n\nAñade el ajo picado y el orégano seco (si usas albahaca fresca, guárdala para el final). Cocina por 1 minuto más, solo hasta que el ajo suelte su aroma.\n\nConstruir la Sopa: Agrega la lata de tomates enteros (con todo su jugo) y el caldo de verduras. Usa una cuchara de madera para romper los tomates grandes.\n\nAñade la cucharadita de azúcar, una buena pizca de sal y pimienta negra.\n\nHervor Lento: Lleva la sopa a ebullición, luego baja el fuego, tapa la olla y deja que hierva suavemente (simmer) durante al menos 20 minutos (30 minutos es aún mejor). Esto permite que todos los sabores se conozcan y se profundicen.\n\nLicuar (El Paso Clave): Aquá es donde se crea la magia cremososa.\n\nOpción A (Ideal): Usa una licuadora de inmersión (minipimer) directamente en la olla. Licúa hasta que la sopa esté completamente suave y sedosa.\n\nOpción B (Con cuidado): Transfiere la sopa en tandas a una licuadora de vaso. ¡Con mucho cuidado! El vapor caliente puede ser peligroso. Licúa hasta que esté suave y devuelve todo a la olla.\n\nTerminar con la Crema: Pon la olla de nuevo a fuego bajo. Vierte la crema de leche y revuelve. (Si usas albahaca fresca, añídela ahora).\n\nCalienta la sopa suavemente por 5 minutos más. No dejes que vuelva a hervir después de agregar la crema.\n\nAjustar: Prueba la sopa. ¿Necesita más sal? ¿Un poco más de pimienta? Ajústala a tu gusto.\n\nSárvela bien caliente, idealmente junto a un sándwich de queso derretido para la experiencia completa.\n\nVariación (Sabor Ahumado): Si quieres un sabor más profundo, puedes usar tomates frescos (tipo Roma) y asarlos en el horno junto con la cebolla y el ajo antes de ponerlos en la olla.	1	30	90	2023-06-27	1	0
6	Pollo Frito Estilo "KFC"	https://www.themealdb.com/images/media/meals/xqusqy1487348868.jpg		Marinar (Paso Clave): En un bol grande, mezcla el buttermilk (o tu sustituto de leche y limón), el huevo batido y la salsa picante. Sumerge todas las piezas de pollo, aseguríndote de que queden bien cubiertas. Tapa el bol y refrigera por un mánimo de 4 horas (idealmente, déjalo de un día para otro). Esto ablanda la carne y la hace increáblemente jugosa.\n\nPreparar la Harina Sazonada: En otro bol muy grande (o una bolsa de papel resistente), mezcla la harina, la maicena y TODAS las 11 hierbas y especias (del pimentón hasta la sal de apio). Revuelve muy bien para que los condimentos se distribuyan de forma pareja.\n\nEl Doble Rebozado (El secreto de la costra):\n\nSaca una pieza de pollo de la marinada, dejando que el exceso de líquido escurra un poco.\n\nPísala por la mezcla de harina sazonada, cubriéndola completamente.\n\n(Importante) Vuelve a sumergir la pieza de pollo rípidamente en la marinada de buttermilk.\n\nPísala por segunda vez por la harina sazonada. Presiona bien la harina contra el pollo para que se forme una costra gruesa.\n\nColoca la pieza enharinada sobre una rejilla.\n\nReposo: Repite el paso 3 con todas las piezas. Deja que el pollo repose sobre la rejilla durante 15-20 minutos. Esto ayuda a que la costra se "pegue" al pollo y no se caiga al freír.\n\nCalentar el Aceite: En una olla grande y pesada (idealmente de hierro fundido) o un sartén profundo, calienta el aceite hasta que alcance los 175°C (350°F). Es muy recomendable usar un termómetro de cocina para esto.\n\nFreár en TANDAS:\n\nCon cuidado, coloca 3 o 4 piezas de pollo en el aceite caliente. No sobrecargues la olla, ya que esto bajarí la temperatura del aceite y el pollo quedarí grasoso en vez de crujiente.\n\nFráe el pollo, díndolo vuelta ocasionalmente, hasta que esté dorado oscuro y bien cocido por dentro.\n\nTiempos aproximados:\n\nAlas: 8-10 minutos.\n\nPechugas: 12-15 minutos.\n\nMuslos y Trutros (piernas): 15-18 minutos.\n\nConfirmación: La forma más segura de saber es que la temperatura interna del pollo (lejos del hueso) alcance los 74°C (165°F).\n\nEscurrir: Saca el pollo del aceite y déjalo escurrir sobre una rejilla limpia (no sobre papel de cocina, ya que el vapor lo ablandarí).\n\nSirve caliente. ¡El resultado es espectacular!	1	21	89	2023-06-27	1	0
14	Pastel de Pavo Jugoso	https://www.themealdb.com/images/media/meals/ypuxtw1511297463.jpg		El Secreto de la Humedad (Sofrito): Este es el paso más importante. Calienta el aceite de oliva en un sartén a fuego medio. Agrega la cebolla, el apio y la zanahoria rallada.\n\nSofráe durante 8-10 minutos, revolviendo, hasta que las verduras estén muy blandas y la cebolla esté traslúcida. Agrega el ajo y cocina por 1 minuto más.\n\nRetira del fuego y deja que esta mezcla de verduras se enfráe por completo. (No la agregues caliente a la carne cruda).\n\nPrecalentar: Precalienta el horno a 180°C (350°F). Prepara una bandeja de horno forrada con papel de aluminio o papel mantequilla.\n\nHacer la "Panade" (El 2do Secreto): En un bol muy grande, mezcla el pan rallado y la leche. Deja que repose 5 minutos para que el pan absorba el líquido. Esto garantiza un pastel de carne tierno.\n\nCombinar (Sin Sobre-mezclar): Al bol grande con la "panade", agrega el pavo molido, la mezcla de verduras fráa, los huevos batidos, las 2 cucharadas de salsa inglesa, las 2 cucharadas de ketchup, el perejil, la sal, la pimienta y el tomillo (si usas).\n\nUsando tus manos (es la mejor forma), mezcla todo suavemente solo hasta que esté combinado. No lo amases ni lo sobre-mezcles, o el pastel quedarí denso y duro.\n\nFormar el Pastel: Vuelca la mezcla en la bandeja de horno preparada y dale forma de un "pan" ovalado (aproximadamente 25 cm de largo y 12 cm de ancho).\n\nPreparar el Glaseado: En un bol pequeño, bate todos los ingredientes del glaseado (ketchup, azúcar rubia, vinagre y salsa inglesa) hasta que estén bien combinados.\n\nHornear (en dos etapas):\n\nEtapa 1: Unta la mitad del glaseado sobre la parte superior y los lados del pastel de pavo.\n\nHornea durante 40 minutos.\n\nEtapa 2: Saca el pastel del horno y unta con cuidado el resto del glaseado por encima.\n\nVuelve a hornear por 15 a 20 minutos más.\n\nVerificar Cocción: El pastel de carne está listo cuando el glaseado esté caramelizado y burbujeante, y un termómetro de carne insertado en el centro marque 74°C (165°F). (El pavo debe estar completamente cocido).\n\n¡Reposo Obligatorio!: Saca el pastel del horno y déjalo reposar en la bandeja durante 10 minutos antes de cortarlo en rodajas. Esto permite que los jugos se reabsorban y evita que se desarme.\n\nSárvelo caliente. Combina perfectamente con puré de papas y porotos verdes (judías verdes).	1	25	90	2023-06-27	1	0
\.


--
-- Data for Name: receta_del_dia; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.receta_del_dia (fecha, id_receta) FROM stdin;
2025-11-01	18
2025-11-02	30
2025-11-03	26
2025-11-04	22
2025-11-05	20
2025-11-07	15
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
3	Claudio	Sanchez	cla.sanchezt@duo	$2a$06$WKZzXwq8yrrjIGRdfYYzQucfwFH53ssYZ9oKlzuYDZw0GmUVcsbpK	1	2024-05-26 17:15:11	\N	2
1	Admin	System	admin@recetas.com	$2a$06$WKZzXwq8yrrjIGRdfYYzQucfwFH53ssYZ9oKlzuYDZw0GmUVcsbpK	1	2023-06-26 23:58:57	\N	3
2	Usuario	Test	user@recetas.com	$2a$06$WKZzXwq8yrrjIGRdfYYzQucfwFH53ssYZ9oKlzuYDZw0GmUVcsbpK	1	2023-06-27 10:00:19	\N	1
47	PruebaThunder	Usuario	prueba.thunder+1@example.com	$2a$10$otBcZQ1QmlBSqcXbsBafzukdUDsg.XSVCbg6kYQYa00fyzAFHsZ0W	1	2025-11-02 02:18:24.65951	\N	1
48	Test3	User3	test.user.with.pass2@example.com	$2a$10$EPGlt99wQGqP09fusLuHNOyzHdIitUSGjKaTjFC5t/hVCJ3AD6kXK	1	2025-11-02 02:18:38.421064	\N	1
49	TestOK	UserOK	test.register.success@example.com	$2a$10$pV3BWD6rCAFINsvFU.UEZ.yBPGyAVopz.C/QblhEQebwddJqtd9e.	1	2025-11-02 02:18:50.533084	\N	1
50	Test	Usuario	test+20251101235000@example.com	$2a$10$L0BD2UtGWIE7f46fxmzunOGE6dip5w5HAT.fVEp0tJtLCPE2fwGNu	1	2025-11-02 02:50:01.575253	registro prueba	1
51	Test	Usuario	test+20251101235012@example.com	$2a$10$GJf2PtkQYwB3rE44dWDXSuoPJanmX/HgjXtS.XlgCDzDyhSgSAelG	1	2025-11-02 02:50:12.211913	registro prueba	1
52	TestFix	Usuario	testfix+20251101235330@example.com	$2a$10$WUELn1dGkJ4mBq4Z9U9xWuBAM2jax520FfLA5tQWaqzgBCPNqqKWe	1	2025-11-02 02:53:30.812559	prueba backend arreglado	1
53	AutoLogin	User	autologin+20251101235533@example.com	$2a$10$OgbJlbq116lNb1RG6y8R8OvsLGwzwNR2wEAILv08nrSUNGzOmudFG	1	2025-11-02 02:55:34.072244	prueba autologin	1
54	AutoLogin	User	autologin+20251101235609@example.com	$2a$10$ZYgfqjkacuU9TM9Zqg6MUuktUR22LBC0aBVFVulelLc7iFuGcYGy6	1	2025-11-02 02:56:09.978438	prueba autologin	1
55	ariel	palma	apalma@duo.cl	$2a$10$X98LoKMPJ9vJv1CzI9zapu9xUkse0P8.femNpmsgZBMGvyGJw7rre	1	2025-11-02 02:57:53.147369		1
56	QA	Auto	qa+1762054086830@example.com	$2a$10$gLv6A2JCZ0TsqCEcx4Dxne0NgcseXIfUIDbbms8nMfIH4wN0owVou	1	2025-11-02 03:28:07.402016	Registro autom├ítico QA	1
57	QA	Auto	qa+1762054210747@example.com	$2a$10$UkoKiTrOIhKpboJ7KIFxCO8W.GJeOzNjeE7z.zpeySpDcG2TKgEp6	1	2025-11-02 03:30:10.982025	Registro autom├ítico QA	1
58	QA	Auto	qa+1762054255720@example.com	$2a$10$TfK.3PV8e.SEau6TAcqYqe5hbAb535vHaX0aPZsI5UnHbJuS0swIi	1	2025-11-02 03:30:55.936621	Registro autom├ítico QA	1
59	QA	Auto	qa+1762054324293@example.com	$2a$10$ixc8XGnC.UYW4z/QUQ3Ss.Rig5MrfSPlQdNInhkNJhpJX73LUT6P2	1	2025-11-02 03:32:04.513302	Registro autom├ítico QA	1
60	QA	Auto	qa+1762054351402@example.com	$2a$10$b2/Fh/CJlEbsVGhfCDaACecjKIGQAetQhzwxyafstJmy0d7t2tDPm	1	2025-11-02 03:32:31.642135	Registro autom├ítico QA	1
68	Test	User	test@example.com	$2a$10$at4BB.t0kktrb7106jhEEeaS5psrE1pTKKLOvdiTT1SpvOnLFQoki	1	2025-11-02 11:27:45.611338	\N	1
61	QA	Auto	qa+1762054395265@example.com	$2a$10$66LaEmId05TyHYhl7UOM2.5prTa7E8QG37ZFjo1WON/.CTeVtlH0q	1	2025-11-02 03:33:15.554575	Registro autom├ítico QA	1
62	QA	Auto	qa+1762054415607@example.com	$2a$10$DBMpP7Z3s84Tb8kytHtVAuqS/qq1S6jCm9h2dZfqRVB8UKjgC8saG	1	2025-11-02 03:33:35.818041	Registro autom├ítico QA	1
63	QA	Auto	qa+1762054448648@example.com	$2a$10$wY2n8ucT7xH99uSzFW1X5OxyE.wm8HXy1NfQinKkp55gdQOjLMzWK	1	2025-11-02 03:34:08.85669	Registro autom├ítico QA	1
64	QA	Auto	qa+1762054543214@example.com	$2a$10$rw.Aupoy6HTtYjCWq7e/euD/uogZoUu4kuN4NZHIS7oRTM3ihVAa.	1	2025-11-02 03:35:43.459743	Registro autom├ítico QA	1
65	QA	Auto	qa+1762080071507@example.com	$2a$10$PtWeSSxE9GaH7duA2MmU/uLIknQCxTTSPBLlj4ZIPud/wuJ9EADTS	1	2025-11-02 10:41:12.231171	Registro autom├ítico QA	1
66	QA	Auto	qa+1762080166164@example.com	$2a$10$GKwdoed65tRwpyg6fZsU2.jTTcXpCL0talVXq9BLo9RqAGlbwWKgO	1	2025-11-02 10:42:46.407102	Registro autom├ítico QA	1
67	QA	Auto	qa+1762080992634@example.com	$2a$10$mJjHB82Wua5xr9zlzzifNusCEGXAHIluT8Jh9EwTt2zgc6NReZUhq	1	2025-11-02 10:56:33.17585	Registro autom├ítico QA	1
69	TestMG	UserMG	test.megusta.20251102_194213@example.com	$2a$10$u4bKMCaVLeIVTSF2IaHmPeXWCzweOcQGohUsoIeQySxAa7XbW6GNy	1	2025-11-02 22:42:14.446434	\N	1
70	TestMG	UserMG	test.megusta.20251102_195321@example.com	$2a$10$7CGNsAlYls48bWOVZ4/pXOSw6njR1sO.ExciRVnRrcoREFtoZxfmW	1	2025-11-02 22:53:21.664994	\N	1
71	TestMG	UserMG	test.megusta.20251102_200212@example.com	$2a$10$etazw0RbrFp1fBaTzq7YSe3qQh07r7.RiDsFREb6aAC6wEx9pfzQG	1	2025-11-02 23:02:12.29238	\N	1
72	TestMG	UserMG	test.megusta.20251102_210313@example.com	$2a$10$FvVhzH/jdPsMRttaKGcVEeJVapbDiEE/VfHCenMz3BHbgANVfyRN.	1	2025-11-03 00:03:13.483015	\N	1
73	TestMG	UserMG	test.megusta.20251102_210320@example.com	$2a$10$6rp.CkAFD0ej8OtMiVGEq.Ueo33NYM5id58ER2CtxJjiFp.rGLO9u	1	2025-11-03 00:03:20.472773	\N	1
74	TestMG	UserMG	test.megusta.20251102_210606@example.com	$2a$10$9wsI5i/XnUluNeKb8SAjAO.pI7iMSOr3us0/w3pXjlonvIZVU/WGq	1	2025-11-03 00:06:06.889529	\N	1
75	TestMG	UserMG	test.megusta.20251102_210802@example.com	$2a$10$hTjRU5UNUjen66Wd8Y0gzuiEerNSVxdGp49yTPVZqWEqmJY0oDTAq	1	2025-11-03 00:08:02.569631	\N	1
76	TestMG	UserMG	test.megusta.20251102_212106@example.com	$2a$10$mMIZK8JvkTJj1k..WVK.Qe9I2oOybZXkQp5iW9xmdSCK3z8DKdy9W	1	2025-11-03 00:21:06.375746	\N	1
77	TestFav	UserFav	test.favoritos.20251102_212734@example.com	$2a$10$otcPZPCJBzL9UnHTEB4teOIAozQgBBXOGUjDYp7CrXrjvane6FxBW	1	2025-11-03 00:27:35.080798	\N	1
78	TestFav	UserFav	test.favoritos.20251102_212813@example.com	$2a$10$DpAf8D6ghqfttieU6H.Qv.JHN0phpRW5o2BYwIaTOIMqiDsfBYpgm	1	2025-11-03 00:28:13.928581	\N	1
79	TestFav	UserFav	test.favoritos.20251102_212829@example.com	$2a$10$Pkhi6mn2Md0bQR7I0u95hOQTVDDjtSq8ZHhTSE3YCbaRGJ2J4BoWK	1	2025-11-03 00:28:29.696775	\N	1
80	TestFav	UserFav	test.favoritos.20251103_002414@example.com	$2a$10$.DL8gQF/rT5kDzRtvJ/uYOqh/MePjvrJg8tF7JAe41ysHF2D8OK4a	1	2025-11-03 03:24:15.164842	\N	1
81	TestMG	UserMG	test.megusta.20251103_002425@example.com	$2a$10$Q56iRKxT4mfpwuhJGRt3Iumh0nctGIU0sjggBgF9eWoUJpScjNwvK	1	2025-11-03 03:24:25.521016	\N	1
82	TestMG	UserMG	test.megusta.20251103_005721@example.com	$2a$10$5J0j9BsuCR6jE9y43SIvsuejdlU1Aooe0stgqZCTz8M/LbpIF2cU6	1	2025-11-03 03:57:22.394344	\N	1
83	TestFav	UserFav	test.favoritos.20251103_143356@example.com	$2a$10$B/VLxqLTt1RD5UduZiMz0OubkqRV7U6G6NsT4462kAFoAXCa7WipO	1	2025-11-03 17:33:53.009374	\N	1
84	TestFav	UserFav	test.favoritos.20251103_144020@example.com	$2a$10$HUoSbEV/pbufp/r87PS0o.0sFGqELe4MMzW0g7m3i/rG2nqDzzwgy	1	2025-11-03 17:40:20.39375	\N	1
\.


--
-- Name: categoria_id_cat_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categoria_id_cat_seq', 63, true);


--
-- Name: comentario_id_comentario_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.comentario_id_comentario_seq', 1496, true);


--
-- Name: donacion_id_donacion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.donacion_id_donacion_seq', 1, false);


--
-- Name: estrella_id_estrella_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.estrella_id_estrella_seq', 15, true);


--
-- Name: favorito_id_fav_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.favorito_id_fav_seq', 24, true);


--
-- Name: ingrediente_new_id_ingrediente_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.ingrediente_new_id_ingrediente_seq', 48, true);


--
-- Name: me_gusta_id_megusta_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.me_gusta_id_megusta_seq', 21, true);


--
-- Name: pais_id_pais_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.pais_id_pais_seq', 95, true);


--
-- Name: perfil_id_perfil_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.perfil_id_perfil_seq', 3, true);


--
-- Name: receta_id_receta_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.receta_id_receta_seq', 36, true);


--
-- Name: sesion_pago_id_sesion_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.sesion_pago_id_sesion_seq', 1, false);


--
-- Name: usuario_id_usr_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.usuario_id_usr_seq', 84, true);


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
-- Name: me_gusta uq_megusta_receta_usuario; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.me_gusta
    ADD CONSTRAINT uq_megusta_receta_usuario UNIQUE (id_receta, id_usr);


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
-- Name: ingrediente_nombre_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ingrediente_nombre_key ON public.ingrediente USING btree (lower(TRIM(BOTH FROM nombre)));


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

\unrestrict S9tMk1vvFdekt6UIu6jh3Qw3cfkYq364TiedTBODe6e5t0LdhQWIhoyuW9DA5T4

