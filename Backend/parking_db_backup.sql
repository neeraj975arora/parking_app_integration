--
-- PostgreSQL database dump
--

\restrict 4hLS7MjC662FxiIUqNUqVVSMMna9JW0Mn6khTRxMcEe6ZGchm5Ra2XgaOrFYbkG

-- Dumped from database version 17.6 (Debian 17.6-1.pgdg13+1)
-- Dumped by pg_dump version 17.6 (Debian 17.6-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admin_parking_lots; Type: TABLE; Schema: public; Owner: parking_user
--

CREATE TABLE public.admin_parking_lots (
    id integer NOT NULL,
    admin_id integer NOT NULL,
    parking_lot_id integer NOT NULL
);


ALTER TABLE public.admin_parking_lots OWNER TO parking_user;

--
-- Name: admin_parking_lots_id_seq; Type: SEQUENCE; Schema: public; Owner: parking_user
--

CREATE SEQUENCE public.admin_parking_lots_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.admin_parking_lots_id_seq OWNER TO parking_user;

--
-- Name: admin_parking_lots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: parking_user
--

ALTER SEQUENCE public.admin_parking_lots_id_seq OWNED BY public.admin_parking_lots.id;


--
-- Name: admin_payment_ledger; Type: TABLE; Schema: public; Owner: parking_user
--

CREATE TABLE public.admin_payment_ledger (
    id integer NOT NULL,
    admin_id integer NOT NULL,
    date date NOT NULL,
    opening_balance double precision NOT NULL,
    today_collection double precision NOT NULL,
    payment_made double precision NOT NULL,
    closing_balance double precision NOT NULL
);


ALTER TABLE public.admin_payment_ledger OWNER TO parking_user;

--
-- Name: admin_payment_ledger_id_seq; Type: SEQUENCE; Schema: public; Owner: parking_user
--

CREATE SEQUENCE public.admin_payment_ledger_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.admin_payment_ledger_id_seq OWNER TO parking_user;

--
-- Name: admin_payment_ledger_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: parking_user
--

ALTER SEQUENCE public.admin_payment_ledger_id_seq OWNED BY public.admin_payment_ledger.id;


--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: parking_user
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


ALTER TABLE public.alembic_version OWNER TO parking_user;

--
-- Name: floors; Type: TABLE; Schema: public; Owner: parking_user
--

CREATE TABLE public.floors (
    floor_id integer NOT NULL,
    floor_name character varying(50) NOT NULL,
    parkinglot_id integer NOT NULL
);


ALTER TABLE public.floors OWNER TO parking_user;

--
-- Name: floors_floor_id_seq; Type: SEQUENCE; Schema: public; Owner: parking_user
--

CREATE SEQUENCE public.floors_floor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.floors_floor_id_seq OWNER TO parking_user;

--
-- Name: floors_floor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: parking_user
--

ALTER SEQUENCE public.floors_floor_id_seq OWNED BY public.floors.floor_id;


--
-- Name: parking_sessions; Type: TABLE; Schema: public; Owner: parking_user
--

CREATE TABLE public.parking_sessions (
    ticket_id character varying(50) NOT NULL,
    parkinglot_id integer,
    floor_id integer,
    row_id integer,
    slot_id integer,
    vehicle_reg_no character varying(20) NOT NULL,
    user_id integer,
    start_time timestamp without time zone,
    end_time timestamp without time zone,
    duration_hrs numeric,
    vehicle_type character varying(20)
);


ALTER TABLE public.parking_sessions OWNER TO parking_user;

--
-- Name: parkinglots_details; Type: TABLE; Schema: public; Owner: parking_user
--

CREATE TABLE public.parkinglots_details (
    parkinglot_id integer NOT NULL,
    parking_name text,
    city text,
    landmark text,
    address text,
    latitude numeric,
    longitude numeric,
    physical_appearance text,
    parking_ownership text,
    parking_surface text,
    has_cctv text,
    has_boom_barrier text,
    ticket_generated text,
    entry_exit_gates text,
    weekly_off text,
    parking_timing text,
    vehicle_types text,
    car_capacity integer,
    available_car_slots integer,
    two_wheeler_capacity integer,
    available_two_wheeler_slots integer,
    parking_type text,
    payment_modes text,
    car_parking_charge text,
    two_wheeler_parking_charge text,
    allows_prepaid_passes text,
    provides_valet_services text,
    value_added_services text
);


ALTER TABLE public.parkinglots_details OWNER TO parking_user;

--
-- Name: parkinglots_details_parkinglot_id_seq; Type: SEQUENCE; Schema: public; Owner: parking_user
--

CREATE SEQUENCE public.parkinglots_details_parkinglot_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.parkinglots_details_parkinglot_id_seq OWNER TO parking_user;

--
-- Name: parkinglots_details_parkinglot_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: parking_user
--

ALTER SEQUENCE public.parkinglots_details_parkinglot_id_seq OWNED BY public.parkinglots_details.parkinglot_id;


--
-- Name: rows; Type: TABLE; Schema: public; Owner: parking_user
--

CREATE TABLE public.rows (
    row_id integer NOT NULL,
    row_name character varying(50) NOT NULL,
    floor_id integer NOT NULL,
    parkinglot_id integer NOT NULL
);


ALTER TABLE public.rows OWNER TO parking_user;

--
-- Name: rows_row_id_seq; Type: SEQUENCE; Schema: public; Owner: parking_user
--

CREATE SEQUENCE public.rows_row_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.rows_row_id_seq OWNER TO parking_user;

--
-- Name: rows_row_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: parking_user
--

ALTER SEQUENCE public.rows_row_id_seq OWNED BY public.rows.row_id;


--
-- Name: slots; Type: TABLE; Schema: public; Owner: parking_user
--

CREATE TABLE public.slots (
    slot_id integer NOT NULL,
    slot_name character varying(50) NOT NULL,
    status integer,
    vehicle_reg_no character varying(20),
    ticket_id character varying(50),
    row_id integer NOT NULL,
    floor_id integer NOT NULL,
    parkinglot_id integer NOT NULL
);


ALTER TABLE public.slots OWNER TO parking_user;

--
-- Name: slots_slot_id_seq; Type: SEQUENCE; Schema: public; Owner: parking_user
--

CREATE SEQUENCE public.slots_slot_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.slots_slot_id_seq OWNER TO parking_user;

--
-- Name: slots_slot_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: parking_user
--

ALTER SEQUENCE public.slots_slot_id_seq OWNED BY public.slots.slot_id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: parking_user
--

CREATE TABLE public.users (
    user_id integer NOT NULL,
    user_name character varying(100) NOT NULL,
    user_email character varying(100) NOT NULL,
    user_password character varying(255) NOT NULL,
    user_phone_no character varying(15) NOT NULL,
    user_address text,
    role character varying(20) NOT NULL
);


ALTER TABLE public.users OWNER TO parking_user;

--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: parking_user
--

CREATE SEQUENCE public.users_user_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_user_id_seq OWNER TO parking_user;

--
-- Name: users_user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: parking_user
--

ALTER SEQUENCE public.users_user_id_seq OWNED BY public.users.user_id;


--
-- Name: admin_parking_lots id; Type: DEFAULT; Schema: public; Owner: parking_user
--

ALTER TABLE ONLY public.admin_parking_lots ALTER COLUMN id SET DEFAULT nextval('public.admin_parking_lots_id_seq'::regclass);


--
-- Name: admin_payment_ledger id; Type: DEFAULT; Schema: public; Owner: parking_user
--

ALTER TABLE ONLY public.admin_payment_ledger ALTER COLUMN id SET DEFAULT nextval('public.admin_payment_ledger_id_seq'::regclass);


--
-- Name: floors floor_id; Type: DEFAULT; Schema: public; Owner: parking_user
--

ALTER TABLE ONLY public.floors ALTER COLUMN floor_id SET DEFAULT nextval('public.floors_floor_id_seq'::regclass);


--
-- Name: parkinglots_details parkinglot_id; Type: DEFAULT; Schema: public; Owner: parking_user
--

ALTER TABLE ONLY public.parkinglots_details ALTER COLUMN parkinglot_id SET DEFAULT nextval('public.parkinglots_details_parkinglot_id_seq'::regclass);


--
-- Name: rows row_id; Type: DEFAULT; Schema: public; Owner: parking_user
--

ALTER TABLE ONLY public.rows ALTER COLUMN row_id SET DEFAULT nextval('public.rows_row_id_seq'::regclass);


--
-- Name: slots slot_id; Type: DEFAULT; Schema: public; Owner: parking_user
--

ALTER TABLE ONLY public.slots ALTER COLUMN slot_id SET DEFAULT nextval('public.slots_slot_id_seq'::regclass);


--
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: parking_user
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_user_id_seq'::regclass);


--
-- Data for Name: admin_parking_lots; Type: TABLE DATA; Schema: public; Owner: parking_user
--

COPY public.admin_parking_lots (id, admin_id, parking_lot_id) FROM stdin;
\.


--
-- Data for Name: admin_payment_ledger; Type: TABLE DATA; Schema: public; Owner: parking_user
--

COPY public.admin_payment_ledger (id, admin_id, date, opening_balance, today_collection, payment_made, closing_balance) FROM stdin;
\.


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: parking_user
--

COPY public.alembic_version (version_num) FROM stdin;
330a0ce24cd7
\.


--
-- Data for Name: floors; Type: TABLE DATA; Schema: public; Owner: parking_user
--

COPY public.floors (floor_id, floor_name, parkinglot_id) FROM stdin;
1	Floor 1	1
2	Floor 2	1
3	Floor 1	2
4	Floor 2	2
5	Floor 1	3
6	Floor 2	3
7	Floor 1	4
8	Floor 2	4
9	Floor 1	5
10	Floor 2	5
11	Floor 1	6
12	Floor 2	6
13	Floor 1	7
14	Floor 2	7
15	Floor 1	8
16	Floor 2	8
17	Floor 1	9
18	Floor 2	9
19	Floor 1	10
20	Floor 2	10
21	Floor 1	11
22	Floor 2	11
23	Floor 1	12
24	Floor 2	12
25	Floor 1	13
26	Floor 2	13
27	Floor 1	14
28	Floor 2	14
29	Floor 1	15
30	Floor 2	15
31	Floor 1	16
32	Floor 2	16
33	Floor 1	17
34	Floor 2	17
35	Floor 1	18
36	Floor 2	18
37	Floor 1	19
38	Floor 2	19
39	Floor 1	20
40	Floor 2	20
41	Floor 1	21
42	Floor 2	21
43	Floor 1	22
44	Floor 2	22
45	Floor 1	23
46	Floor 2	23
47	Floor 1	24
48	Floor 2	24
49	Floor 1	25
50	Floor 2	25
51	Floor 1	26
52	Floor 2	26
53	Floor 1	27
54	Floor 2	27
55	Floor 1	28
56	Floor 2	28
57	Floor 1	29
58	Floor 2	29
59	Floor 1	30
60	Floor 2	30
61	Floor 1	31
62	Floor 2	31
63	Floor 1	32
64	Floor 2	32
65	Floor 1	33
66	Floor 2	33
67	Floor 1	34
68	Floor 2	34
69	Floor 1	35
70	Floor 2	35
71	Floor 1	36
72	Floor 2	36
73	Floor 1	37
74	Floor 2	37
75	Floor 1	38
76	Floor 2	38
77	Floor 1	39
78	Floor 2	39
79	Floor 1	40
80	Floor 2	40
81	Floor 1	41
82	Floor 2	41
83	Floor 1	42
84	Floor 2	42
85	Floor 1	43
86	Floor 2	43
87	Floor 1	44
88	Floor 2	44
89	Floor 1	45
90	Floor 2	45
91	Floor 1	46
92	Floor 2	46
93	Floor 1	47
94	Floor 2	47
95	Floor 1	48
96	Floor 2	48
97	Floor 1	49
98	Floor 2	49
99	Floor 1	50
100	Floor 2	50
101	Floor 1	51
102	Floor 2	51
103	Floor 1	52
104	Floor 2	52
105	Floor 1	53
106	Floor 2	53
107	Floor 1	54
108	Floor 2	54
109	Floor 1	55
110	Floor 2	55
111	Floor 1	56
112	Floor 2	56
113	Floor 1	57
114	Floor 2	57
115	Floor 1	58
116	Floor 2	58
117	Floor 1	59
118	Floor 2	59
119	Floor 1	60
120	Floor 2	60
121	Floor 1	61
122	Floor 2	61
123	Floor 1	62
124	Floor 2	62
125	Floor 1	63
126	Floor 2	63
127	Floor 1	64
128	Floor 2	64
129	Floor 1	65
130	Floor 2	65
131	Floor 1	66
132	Floor 2	66
133	Floor 1	67
134	Floor 2	67
135	Floor 1	68
136	Floor 2	68
137	Floor 1	69
138	Floor 2	69
139	Floor 1	70
140	Floor 2	70
141	Floor 1	71
142	Floor 2	71
143	Floor 1	72
144	Floor 2	72
145	Floor 1	73
146	Floor 2	73
147	Floor 1	74
148	Floor 2	74
149	Floor 1	75
150	Floor 2	75
151	Floor 1	76
152	Floor 2	76
153	Floor 1	77
154	Floor 2	77
155	Floor 1	78
156	Floor 2	78
157	Floor 1	79
158	Floor 2	79
159	Floor 1	80
160	Floor 2	80
161	Floor 1	81
162	Floor 2	81
163	Floor 1	82
164	Floor 2	82
165	Floor 1	83
166	Floor 2	83
167	Floor 1	84
168	Floor 2	84
169	Floor 1	85
170	Floor 2	85
171	Floor 1	86
172	Floor 2	86
173	Floor 1	87
174	Floor 2	87
\.


--
-- Data for Name: parking_sessions; Type: TABLE DATA; Schema: public; Owner: parking_user
--

COPY public.parking_sessions (ticket_id, parkinglot_id, floor_id, row_id, slot_id, vehicle_reg_no, user_id, start_time, end_time, duration_hrs, vehicle_type) FROM stdin;
\.


--
-- Data for Name: parkinglots_details; Type: TABLE DATA; Schema: public; Owner: parking_user
--

COPY public.parkinglots_details (parkinglot_id, parking_name, city, landmark, address, latitude, longitude, physical_appearance, parking_ownership, parking_surface, has_cctv, has_boom_barrier, ticket_generated, entry_exit_gates, weekly_off, parking_timing, vehicle_types, car_capacity, available_car_slots, two_wheeler_capacity, available_two_wheeler_slots, parking_type, payment_modes, car_parking_charge, two_wheeler_parking_charge, allows_prepaid_passes, provides_valet_services, value_added_services) FROM stdin;
1	Jahangirpuri - Metro Authorised Parking	New Delhi	Jahangirpuri	Jahangir puri metro, Patking agency- m/s manoj computer	28.72542191	77.16333008	Open - Covered bounderies	Govt - Subcontracted	Cemented	No	yes	Stand Alone printer	Multi gates for Entry as well as Exit	Open All Days	06:00:00 AM - 11:00:00 PM	Car, 2 Weelers	200	200	500	500	Paid	Cash	20 up to 6 hours, 30 for 12 hours	10 up to 6 hours, 15 up to 12	Monthly Pass	No	No
2	Azadpur - Commercial Complex	New Delhi	Akash Cinema	Azadpur bus depot, Akash cinema	28.70976257	77.17796326	Open - Covered bounderies	Govt - Open - Not Authorized to anyone	Mud	No	No	No ticket	Multi gates for Entry as well as Exit	Open All Days	12:00:00 AM - 12:00:00 PM	Car, 2 Weelers	200	200	250	250	Free	Free Parking	Free parking	Free parking	No such option	No	No
3	ISBT Kashmere Gate -  Bus Stand	New Delhi	Inter State Bus Stand	Kashmere gate, nan	28.66860771	77.22953796	Open - Covered bounderies	Not known	Cemented	Yes	No	No ticket	Multi gates for Entry as well as Exit	Open All Days	07:00:00 AM - 11:00:00 PM	Car, 2 Weelers	300	300	400	400	Free	Free Parking	Free	Free	No such option	No	Guards.
4	Madhuban Chowk - Bus Stand	New Delhi	Bus Stand	Madhuban chowk, Pitampura metro station	28.703096	77.129779	Open - Road Side	Govt - Open - Not Authorized to anyone	Cemented	No	No	No ticket	Multi gates for Entry as well as Exit	Open All Days	12:00:00 PM - 12:00:00 AM	Car, 2 Weelers	100	100	200	200	Free	Free Parking	Free	Free	No such option	No	No
5	Kohat Enclave - Metro Station	New Delhi	Kohat Enclave Bus Stand	Kohat Enclave Bus Stand & Metro Station, \\Metro Station	28.69658661	77.14331055	Open - Road Side	Govt - Open - Not Authorized to anyone	Cemented	No	No	No ticket	Multi gates for Entry as well as Exit	Open All Days	12:00:00 PM - 12:00:00 AM	Car, 2 Weelers	250	250	300	300	Free	Free Parking	Free	Free	No such option	No	No
6	Netaji Subhash Place -  Bus Stand	New Delhi	Subhash place Pitampura	Subhash Place, PP tower	28.6941169	77.1510655	Open - Road Side	Govt - Subcontracted	Cemented	Yes	No	Manually - Hand written	Multi gates for Entry as well as Exit	Open All Days	09:00:00 AM - 11:00:00 PM	Car, 2 Weelers	25	25	40	40	Paid	Cash	Rs 20 per hour	Rs 10 per hour	No such option	No	No
7	Netaji Subhash place -  Office Parking	New Delhi	Subhash place, pitampura	Subhash place Pitampura  Flow Tech Group of Industries, Flow tech group of idustries	28.692222	77.150673	Open - Covered bounderies	Not known	Pawment	Yes	No	No ticket	Single entry gate and Single exit gate	Open All Days	09:00:00 AM - 10:00:00 PM	Car, 2 Weelers	20	20	25	25	Free	Free Parking	Free	Free	No such option	No	No
8	Netaji Subhash Place	New Delhi	Nsp subhash place, pitampura	nan, Near by PIET institute	28.6961009	77.1527008	Open - Covered bounderies	Govt - Subcontracted	Cemented	No	No	Manually - Hand written	Single entry gate and Single exit gate	Open All Days	09:00:00 AM - 11:00:00 PM	2 Weelers	0	0	40	40	Paid	Cash	Car parking not available	Rs 10 per hour	No such option	No	10 Rs for 1st hour, Rs5/per hour
9	Netaji Subhash Place - Foot Over Bridge	New Delhi	Nsp pitampura	Footover Bridge, Near Zever Jewellery Showroom	28.69384575	77.15020752	Open - Covered bounderies	Not known	Pawment	Yes	No	No ticket	Single entry gate and Single exit gate	Open All Days	12:00:00 PM - 12:00:00 AM	Car	40	40	0	0	Free	Free Parking	Free	Not allowed	No such option	No	No
10	Pitampura - Netaji Subhash Place	New Delhi	Nsp, near by pizza hut and stanmax	Pitampura, In front of pizza hut and stanmax	28.69402122	77.1495285	Open - Covered bounderies	Govt - Open - Not Authorized to anyone	Pawment	Yes	No	No ticket	Multi gates for Entry as well as Exit	Open All Days	12:00:00 PM - 12:00:00 AM	Car, 2 Weelers	30	30	25	25	Free	Free Parking	No charges.	No charges.	No such option	No	No
11	Pitampura - Netaji Subhash Place	New Delhi	Nsp pitampura	Nsp pitampura, beside pizza hut, Road to asia pacific	\N	\N	Open - Road Side	Govt - Subcontracted	Cemented	No	No	Manually - Hand written	Multi gates for Entry as well as Exit	Open All Days	09:00:00 AM - 10:00:00 PM	Car	25	25	0	0	Paid	Cash	Rs 20 per hour	Not applicable.	No such option	No	No
12	Azadpur -  Gupta Tower	New Delhi	Azadpur	Near by Gupta Tower, On road leading to Mukundpur Village	28.71066093	77.17772675	Open - Road Side	Govt - Open - Not Authorized to anyone	Cemented	No	No	No ticket	Multi gates for Entry as well as Exit	Open All Days	12:00:00 PM - 12:00:00 AM	Car, 2 Weelers	30	30	50	50	Free	Free Parking	Free parking.	Free parking.	No such option	No	No
13	Azadpur - Naniwala Bagh Complex	New Delhi	Azadpur	Naniwala Bagh Complex, Behind Aradhana Bhawan	28.71080589	77.17857361	Open - Covered bounderies	Govt - Subcontracted	Pawment	No	No	Manually - Hand written	Multi gates for Entry as well as Exit	Open All Days	09:00:00 AM - 09:00:00 PM	Car, 2 Weelers	50	50	60	60	Paid	Cash	Rs 20 per hour	Rs 10 per hour	No such option	No	No
14	Model town	New Delhi	Model town 2	Near Mcdonald, nan	28.7059	77.1902	Open - Road Side	Govt - Subcontracted	Cemented	No	No	Manually - Hand written	Multi gates for Entry as well as Exit	Open All Days	08:00:00 AM - 10:00:00 PM	Car	50	50	0	0	Paid	Cash	Rs 20 per hour	Not applicable.	No such option	Yes	20rs for first hour, beyond that 10rs hour
15	Connaught Place -  F Block	New Delhi	F-Block, inner circle, gate no. 5, rajiv chowk	F-block, inner circle, gate no.5, near union bank, rajiv chowk, F-block, inner circle,gate no.5, near union bank, opposite public toilet, rajiv chowk	28.63192177	77.22070313	Open - Covered bounderies	Govt - Subcontracted	Cemented	Yes	yes	Stand alone printer	Single entry gate and Single exit gate	Open All Days	09:00:00 AM - 11:00:00 PM	Car, 2 Weelers	200	200	150	150	Paid	Cash	Rs 20 per hour	Rs 10 per hour	Monthly Pass	No	Car wash on demand (extra charges for this service)
16	Connaught Place - B Block	New Delhi	Block-B, RR-3, Metro Station gate no. 1, rajiv chowk	Block-B, RR-3, Metro Station gate no. 1, near wildcraft showroom, rajiv chowk, Block-B, RR-3, Metro Station gate no. 1, near wildcraft and bata showroom, rajiv chowk	28.63390732	77.21897888	Open - Covered bounderies	Govt - Subcontracted	Cemented	Yes	yes	Stand alone printer	Single entry gate and Single exit gate	Open All Days	06:00:00 AM - 11:00:00 PM	Car, 2 Weelers	200	200	130	130	Paid	Cash	Rs 20 per hour	Rs 10 per hour	Monthly Pass	No	No
17	Banglasaheb Gurudwara	New Delhi	Rajiv Chowk	Rajiv Chowk, Banglasaheb gurudwara near YMCA organization	28.62636566	77.21054077	Indoor - Multi Level	Govt - Open - Not Authorized to anyone	Cemented	Yes	No	Manually - Hand written	Single entry gate and Single exit gate	Open All Days	12:00:00 PM - 12:00:00 AM	Car, 2 Weelers	2000	2000	50	50	Free	Free Parking	Free parking	Free parking	No such option	No	No
18	Pitampura - Saraswati vihar	New Delhi	Pitampura, Madhuban Chowk	Saraswati Vihar, Behind Bus Stand, Near Wills lifestyle Metro Station	\N	\N	Open - Road Side	Not known	Cemented	No	No	No ticket	Single entry gate and Single exit gate	Open All Days	12:00:00 PM - 12:00:00 AM	Car, 2 Weelers	60	60	20	20	Free	Free Parking	Free parking.	Free parking.	No such option	No	No
19	Hazarat Nizamuddin Police Station	New Delhi	Nizamuddin	Lodhi Rd, Near Sabz Burj, Nizamuddin West, New Delhi, Delhi 110013, nan	28.59254265	77.24382019	Open - Road Side	Govt - Open - Not Authorized to anyone	Cemented	No	No	No ticket	Multi gates for Entry as well as Exit	Open All Days	12:00:00 AM - 11:59:00 PM	Car, 2 Weelers	40	40	30	30	Free	Free	Free	Free	No such option	No	No
20	Basti Nizamuddin West	New Delhi	Nizamuddin	Basti Hazrat Nizamuddin West 110013, nan	28.59151649	77.24404144	Open - Covered bounderies	Govt - Open - Not Authorized to anyone	Cemented	No	No	No ticket	Single entry gate and Single exit gate	Open All Days	12:00:00 AM - 11:59:00 PM	Car, 2 Weelers	40	40	20	20	Free	Free Parking	Free	Free	No such option	No	No
21	Humayun Tomb Interpretation Center	New Delhi	Nizamuddin	Mathura Road, Opposite Dargah Nizamuddin, New Delhi, Delhi 110013, nan	28.59306717	77.24456787	Open - Covered bounderies	Govt - Subcontracted	Cemented	No	No	Manually - Hand written	Shared Single gate for Entry as well as Exit	Open All Days	06:30:00 AM - 06:30:00 PM	Car, 2 Weelers	80	80	25	25	Paid	Cash	Rs 10 per Parking	Rs 10 per parking	No such option	No	No
22	Humayun Tomb Bus/Travellers	New Delhi	Nizamuddin	Mathura Road, Opposite Dargah Nizamuddin, New Delhi, Delhi 110013, nan	28.59408188	77.24598694	Open - Covered bounderies	Govt - Subcontracted	Cemented	No	No	Manually - Hand written	Single entry gate and Single exit gate	Open All Days	06:30:00 AM - 06:30:00 PM	Bus	0	0	0	0	Paid	Cash	No Cars	No 2 wheelers	No such option	No	No
23	Humayun Tomb	New Delhi	Nizamuddin	Mathura Road, Opposite Dargah Nizamuddin, New Delhi, Delhi 110013, nan	28.5942173	77.24705505	Open - Covered bounderies	Govt - Open - Not Authorized to anyone	Cemented	No	No	No ticket	Multi gates for Entry as well as Exit	Open All Days	12:00:00 AM - 11:59:00 PM	Car, 2 Weelers	50	50	25	25	Free	Free Parking	Free	Free	No such option	No	No
24	Gurudwara Damdama Sahib	New Delhi	Nizamuddin	Block A, Nizamuddin East, Nizamuddin, New Delhi, Delhi 110013, nan	28.59490204	77.25288391	Open - Covered bounderies	Govt - Open - Not Authorized to anyone	Cemented	No	No	No ticket	Multi gates for Entry as well as Exit	Open All Days	12:00:00 AM - 11:59:00 PM	Car, 2 Weelers, Bus	150	150	40	40	Free	Free Parking	Free	Free	No such option	No	No
25	Nizamuddin East Market	New Delhi	Nizamuddin	8, Nizamuddin East Market, New Delhi, Delhi 110003, nan	28.5897007	77.25256348	Open - Road Side	Govt - Open - Not Authorized to anyone	Cemented	No	No	No ticket	Multi gates for Entry as well as Exit	Open All Days	12:00:00 AM - 11:59:00 PM	Car, 2 Weelers	45	45	20	20	Free	Free Parking	Free	Free	No such option	No	No
26	Hazrat Nizamuddin Railway Station	New Delhi	Nizamuddin	Hazrat Nizamuddin Railway Station, New Delhi 110013, nan	28.58990288	77.25291443	Open - Covered bounderies	Not known	Cemented	No	No	No ticket	Single entry gate and Single exit gate	Open All Days	12:00:00 AM - 11:59:00 PM	Car, 2 Weelers	125	125	100	100	Free	Free Parking	Free	Free	No such option	No	No
27	Nizamuddin West Market	New Delhi	Nizamuddin	11, Main Market, Nizamuddin West , Delhi - 110013, nan	28.58945847	77.24544525	Open - Road Side	Govt - Open - Not Authorized to anyone	Cemented	Yes	No	No ticket	Single entry gate and Single exit gate	Open All Days	12:00:00 AM - 11:59:00 PM	Car, 2 Weelers	25	25	15	15	Free	Free Parking	Free	Free	No such option	No	No
28	Community Center Nizamuddin West	New Delhi	Nizamuddin	Community Center Nizamuddin West, New Delhi 110013, nan	28.58946228	77.24516296	Open - Road Side	Govt - Open - Not Authorized to anyone	Cemented	No	No	No ticket	Single entry gate and Single exit gate	Open All Days	12:00:00 AM - 11:59:00 PM	Car, 2 Weelers	25	25	15	15	Free	Free Parking	Free	Free	No such option	No	No
29	Sai Baba Mandir	New Delhi	Lodhi Colony	3, Lodhi Rd, Gokalpuri, Institutional Area, Lodi Colony, New Delhi, Delhi 110003, nan	28.58948898	77.22911835	Open - Road Side	Govt - Open - Not Authorized to anyone	Cemented	No	No	No ticket	Single entry gate and Single exit gate	Open All Days	12:00:00 AM - 11:59:00 PM	Car, 2 Weelers	20	20	10	10	Free	Free Parking	Free	Free	No such option	No	No
30	Sri Sathya Sai International Centre	New Delhi	Lodhi colony	Lodhi Road, Bhishm Pitamah Marg, New Delhi, Delhi 110003, nan	28.58748817	77.23059082	Open - Road Side	Govt - Open - Not Authorized to anyone	Cemented	No	No	No ticket	Single entry gate and Single exit gate	Open All Days	12:00:00 AM - 11:59:00 PM	Car	40	40	20	20	Free	Free Parking	Free	Free	No such option	No	No
31	NBCC Place	New Delhi	Lodhi Colony	Bhisham Pitamah Marg Pragati Vihar, New Delhi 110003, nan	28.5861721	77.23025513	Open - Road Side	Govt - Open - Not Authorized to anyone	Cemented	No	No	No ticket	Single entry gate and Single exit gate	Open All Days	12:00:00 AM - 11:59:00 PM	Car, 2 Weelers	40	40	15	15	Free	Free Parking	Free	Free	No such option	No	No
32	Meharchand Market	New Delhi	Lodhi Colony	Meharchand Market, Lodi Colony, New Delhi, Delhi 110003, nan	28.58507347	77.22645569	Open - Road Side	Govt - Open - Not Authorized to anyone	Cemented	No	No	No ticket	Multi gates for Entry as well as Exit	Open All Days	12:00:00 AM - 11:59:00 PM	Car, 2 Weelers	100	100	30	30	Free	Free Parking	Free	Free	No such option	No	No
33	Palika Maternity Hospital	New Delhi	Lodhi colony	Block 11, Lodhi Colony, Near Khanna Market, New Delhi, Delhi 110003, nan	28.58369255	77.22205353	Open - Road Side	Govt - Open - Not Authorized to anyone	Pawment	No	No	No ticket	Multi gates for Entry as well as Exit	Open All Days	12:00:00 AM - 11:59:00 PM	Car, 2 Weelers	20	20	10	10	Free	Free Parking	Free	Free	No such option	No	No
34	Lodhi Colony Market	New Delhi	Lodhi Colony	Lodi Colony Market, New Delhi, Delhi 110003, nan	28.58461761	77.22367859	Open - Road Side	Govt - Open - Not Authorized to anyone	Cemented	No	No	No ticket	Multi gates for Entry as well as Exit	Open All Days	12:00:00 AM - 11:59:00 PM	Car, 2 Weelers	60	60	25	25	Free	Free Parking	Free	Free	No such option	No	No
35	CGHS Wellness Centre	New Delhi	Lodhi Colony	Block No. 4, Dispensary No. 10, Lodi Road, Lodi Colony, New Delhi, Delhi 110003, nan	28.5823288	77.22488403	Open - Covered bounderies	Not known	Cemented	No	No	No ticket	Shared Single gate for Entry as well as Exit	Sun	08:00:00 AM - 03:00:00 PM	Car	10	10	10	10	Free	Free Parking	Free	Free	No such option	No	No
36	New Khanna Market	New Delhi	Lodhi Colony	New Khanna Market, Lodhi Road, New Delhi 110003, nan	28.58011436	77.22212219	Open - Road Side	Govt - Open - Not Authorized to anyone	Cemented	No	No	No ticket	Multi gates for Entry as well as Exit	Open All Days	12:00:00 AM - 11:59:00 PM	Car, 2 Weelers	30	30	20	20	Free	Free Parking	Free	Free	No such option	No	No
37	Azadpur Metro Station	New Delhi	Azadpur	Azadpur, metro station, Azadpur metro station	28.70660591	77.1820755	Open - Covered bounderies	Govt - Subcontracted	Cemented	No	No	Manually - Hand written	Shared Single gate for Entry as well as Exit	Open All Days	12:00:00 PM - 12:00:00 AM	Car, 2 Weelers	120	120	200	200	Paid	Cash	20rs for first 6 hours, 30 rs beyond that.	10rs for first 6 hours, 15rs beyond that.	Monthly Pass	Yes	Monthly pass on the basis of day and night slots.
38	Rafi Marg - Behind Reserve Bank of India	New Delhi	Central secretariat	Central Secretariat, Rafi Marg, Indian Newspaper Society	28.62007713	77.21264648	Open - Road Side	Not known	Cemented	No	No	No ticket	Multi gates for Entry as well as Exit	Open All Days	12:00:00 AM - 12:00:00 PM	Car, 2 Weelers	250	250	50	50	Free	Free Parking	Free parking.	Free parking.	No such option	No	No
39	Shastri Bhawan	New Delhi	Central secretariat	Central secretariat Shastri Bhawan, Near by Women and child welfare development.	28.61671638	77.21679688	Open - Road Side	Not known	Cemented	No	No	No ticket	Multi gates for Entry as well as Exit	Open All Days	12:00:00 AM - 12:00:00 PM	Car, 2 Weelers	100	100	30	30	Free	Free Parking	Free parking	Free parking	No such option	No	No
40	Rajiv Chowk- Metro Station Gate No. 4	New Delhi	Rajiv Chowk, CP	nan, Near Gate no 4, in front of Farzi cafe	28.63251114	77.22120667	Open - Covered bounderies	Govt - Subcontracted	Cemented	Yes	yes	Manually - Hand written	Multi gates for Entry as well as Exit	Open All Days	06:00:00 AM - 11:59:00 PM	Car, 2 Weelers	70	70	20	20	Paid	Cash	Rs 20 per hour	Rs 10 per hour	Monthly Pass	No	No
41	Connaught Place - C Block	New Delhi	Connaught place	Cannought place, C-block, Near by union bank ATM, and embassy restaurant & bar.	28.63354492	77.22120667	Open - Covered bounderies	Govt - Subcontracted	Cemented	No	No	Manually - Hand written	Shared Single gate for Entry as well as Exit	Open All Days	08:00:00 AM - 11:00:00 PM	2 Weelers	0	0	120	120	Paid	Cash	Not applicable.	10 rs per hour, 50 rs, one hour onwards for the entire day.	No such option	No	No
42	Connaught Place - E Block	New Delhi	Cannought place, E- block	Cannought place, E-block, In front of Equestrain inspired lifestyle  (jump)	28.63348579	77.22109222	Open - Road Side	Govt - Subcontracted	Cemented	No	No	Manually - Hand written	Single entry gate and Single exit gate	Open All Days	06:00:00 AM - 12:00:00 PM	Car	15	15	0	0	Paid	Cash	Rs 20 per hour	Not applicable.	Monthly Pass	No	No
43	Connaught Place - D Block	New Delhi	Cannought place	Cannought place D block, Near by, rajiv chowk metro station gate no 3 and warehouse cafe.	28.63378906	77.22068024	Open - Covered bounderies	Govt - Subcontracted	Cemented	No	No	Mobile App having Blue Tooth Printer	Shared Single gate for Entry as well as Exit	Open All Days	08:00:00 AM - 11:59:00 PM	Car	40	40	0	0	Paid	Cash	Rs 20 per hour	Not applicable.	Monthly Pass	No	No
44	Kohat Enclave Metro Station	New Delhi	Pitampura, near by madhuban chowk	Kohat enclave metro station, Pitampura, near by madhuban chowk.	28.6977005	77.14160156	Open - Covered bounderies	Govt - Subcontracted	Cemented	No	yes	Manually - Hand written	Shared Single gate for Entry as well as Exit	Open All Days	05:00:00 AM - 11:59:00 PM	Car	250	250	200	200	Paid	Cash	Rs 20 per hour	Rs 10 per hour	Monthly Pass	Yes	A printed card to charge for parking
45	Subhash Place Metro Station	New Delhi	Pitampura, nsp	Netaji subhash place metro station, Pitampura near by wazirpur	28.69505692	77.15205383	Open - Covered bounderies	Govt - Subcontracted	Cemented	No	yes	Manually - Hand written	Shared Single gate for Entry as well as Exit	Open All Days	12:00:00 AM - 11:59:00 PM	Car, 2 Weelers	200	200	250	250	Paid	Cash	Rs 20 per hour	Rs 10 per hour	Monthly Pass	No	No
46	HP TWIN Tower Pitampura	New Delhi	Nsp, pitampura	HP twin power, near by Starbucks coffee, Nsp, pitampura	28.69312096	77.1528244	Open - Road Side	Govt - Subcontracted	Cemented	No	No	Manually - Hand written	Multi gates for Entry as well as Exit	Open All Days	09:00:00 AM - 11:00:00 PM	Car, 2 Weelers	10	10	40	40	Paid	Cash	Rs 20 per hour	Rs 10 per hour	No such option	No	No
47	D-Mall Parking	New Delhi	Nsp, pitampura	D-mall parking, beside yes bank ATM, NSP , pitampura	28.692876	77.152637	Indoor - Single Level	Private - self managed	Cemented	Yes	yes	No ticket	Shared Single gate for Entry as well as Exit	Open All Days	10:00:00 AM - 10:00:00 PM	Car, 2 Weelers	100	100	150	150	Free	Free Parking	Free parking.	Free parking.	No such option	No	No
48	Haldiram Parking	New Delhi	Nsp, pitampura	Haldiram, beside D-mall parking, Nsp, pitampura	28.69312096	77.1528244	Open - Road Side	Govt - Subcontracted	Cemented	No	No	Manually - Hand written	Multi gates for Entry as well as Exit	Open All Days	09:00:00 AM - 10:00:00 PM	Car, 2 Weelers	10	10	40	40	Paid	Cash	Rs 20 per hour	Rs 10 per hour	Monthly Pass	No	No
49	Netaji Subhash Place - Agarwal Millenium Tower 2	New Delhi	Nsp pitampura	Agarwal millenium tower 2, Nsp pitampura	28.69314575	77.14974976	Open - Road Side	Private - subcontracted	Cemented	No	No	Manually - Hand written	Multi gates for Entry as well as Exit	Open All Days	09:00:00 AM - 11:00:00 PM	Car, 2 Weelers	10	10	25	25	Paid	Cash	Rs 20 per hour	Rs 10 per hour	No such option	No	No
50	Aggarwal Metro Heights - Mangalam Realtors	New Delhi	Nsp pitampura	Aggarwal metro heights, near by mangalam realtors, Nsp pitampura	28.69327927	77.14957428	Open - Road Side	Govt - Subcontracted	Cemented	No	No	Manually - Hand written	Multi gates for Entry as well as Exit	Open All Days	08:00:00 AM - 10:00:00 PM	2 Weelers	0	0	100	100	Paid	Cash	Not applicable.	10 rs per hours, 15 rs beyond that.	Monthly Pass	No	No
51	Aggarwal Millenium Tower-1	New Delhi	Nsp, pitampura	Aggarwal millenium tower-1, behind pizza hut, Nsp, pitampura	\N	\N	Open - Covered bounderies	Private - subcontracted	Cemented	No	No	Manually - Hand written	Single entry gate and Single exit gate	Open All Days	12:00:00 AM - 11:59:00 PM	Car, 2 Weelers	100	100	150	150	Paid	Cash	20 for first hour, 5rs reduces for next hour.	10 rs for first hour, 5 rs after that.	Monthly Pass	Yes	No
52	Kalyan Jewellers - PP Trade Centre	New Delhi	Nsp, pitampura	Kalyan jewellers, in front of PP trade centre, Nsp, pitampura	28.69447327	77.14904022	Open - Road Side	Not known	Cemented	No	No	No ticket	Multi gates for Entry as well as Exit	Open All Days	12:00:00 AM - 11:59:00 PM	Car	80	80	0	0	Free	Cash	Free parking.	Free parking.	No such option	No	No
53	Shalimar Bagh - Bus Stand	New Delhi	Shalimar bagh	Shalimar bagh bus stand, Near by maruti suzuki showroom, NEXA	28.70342636	77.16918182	Open - Road Side	Not known	Cemented	No	No	No ticket	Multi gates for Entry as well as Exit	Open All Days	12:00:00 AM - 11:59:00 PM	Car, 2 Weelers	50	50	20	20	Free	Free Parking	Free parking.	Free parking.	No such option	No	No
54	Shalimar Bagh - Indian Oil Fuel Pump	New Delhi	Shalimar bagh	Indian oil pump, shalimar bagh, Near Bhavishaya nidhi bhawan.	28.70170975	77.16686249	Open - Covered bounderies	Govt - Subcontracted	Cemented	No	No	Manually - Hand written	Shared Single gate for Entry as well as Exit	Open All Days	08:00:00 AM - 10:00:00 PM	Car, 2 Weelers	100	100	80	80	Paid	Cash	20 for first hour, 10 for next subsequent hours.	10 rs for first hour, 5 rs for next subsequent hours.	Monthly Pass	No	No
55	Shalimar bagh - Industrial Area	New Delhi	Shalimar bagh	Industrial area, v- block, Shalimar bagh	\N	\N	Open - Road Side	Not known	Cemented	No	No	No ticket	Shared Single gate for Entry as well as Exit	Open All Days	12:00:00 AM - 11:59:00 PM	Car, 2 Weelers	120	120	50	50	Free	Free Parking	Free parking.	Free parking.	No such option	No	No
56	Malviya Nagar - Geeta Bhawan Mandir	New Delhi	Malviya nagar	Geeta bhawan mandir, Near by malviya nagar metro station	28.53332138	77.20692444	Open - Road Side	Not known	Mud	No	No	No ticket	Multi gates for Entry as well as Exit	Open All Days	12:00:00 AM - 11:59:00 PM	Car	40	40	0	0	Free	Free Parking	Free parking.	Free parking.	No such option	No	No
57	Paharganj - RG, City Centre	New Delhi	Paharganj	RG city centre, paharganj, Near by police station	28.64648628	77.2080307	Open - Covered bounderies	Govt - Subcontracted	Mud	No	yes	No ticket	Shared Single gate for Entry as well as Exit	Open All Days	12:00:00 AM - 11:59:00 PM	Car, 2 Weelers, Bus	100	100	50	50	Free	Free Parking	Free parking.	Free parking.	No such option	No	No
58	Paharganj - RG, City Centre	New Delhi	Paharganj	RG, centre,  delhi knighter lounge bar, Paharganj bus stand	28.64636993	77.20761871	Indoor - Single Level	Private - subcontracted	Pawment	No	No	No ticket	Shared Single gate for Entry as well as Exit	Open All Days	09:00:00 AM - 07:00:00 PM	Car, 2 Weelers	30	30	15	15	Free	Free Parking	Free parking.	Free parking.	No such option	Yes	No
59	Jhandewalan - Flatted Factories Complex	New Delhi	Jhandewalan FF complex	Flatted factories complex, Rani jhansi road, Paharganj	28.64792442	77.20446777	Indoor - Single Level	Govt - Open - Not Authorized to anyone	Cemented	No	No	No ticket	Shared Single gate for Entry as well as Exit	Open All Days	09:00:00 AM - 09:00:00 PM	Car, 2 Weelers	250	250	100	100	Free	Free Parking	Free parking.	Free parking.	No such option	No	Very much secured parking, car can be left overnight at parking.
60	Jhandewalan - E-block	New Delhi	Jhandewalan, ambedkar bhawan road	E-block jhandewalan, ambedkar bhawan road,  near by Axis bank	28.64511299	77.20410919	Open - Road Side	Govt - Subcontracted	Mud	No	No	Manually - Hand written	Shared Single gate for Entry as well as Exit	Open All Days	12:00:00 AM - 11:59:00 PM	Car, 2 Weelers	200	200	150	150	Paid	Cash	Rs 20 per hour	Rs 10 per hour	No such option	No	No
61	Jhandewalan Extension - Cycle Market	New Delhi	Jhandewalan, karol bagh	Jhandewalan extension, cycle market, Near by videocon tower, karol bagh	28.64567757	77.20406342	Open - Road Side	Private - subcontracted	Cemented	No	No	Manually - Hand written	Shared Single gate for Entry as well as Exit	Open All Days	09:00:00 AM - 10:00:00 PM	Car, 2 Weelers	100	100	20	20	Paid	Cash	Rs 20 per hour	Rs 10 per hour	No such option	No	No
62	Jhandewalan - DDA building Cycle Market	New Delhi	Jhandewalan, near by videocon tower	DDA building, cycle market, Near by videocon tower, jhandewalan	28.64603043	77.20279694	Open - Road Side	Private - subcontracted	Mud	No	No	Manually - Hand written	Shared Single gate for Entry as well as Exit	Open All Days	09:00:00 AM - 07:00:00 PM	Car, 2 Weelers	20	20	60	60	Paid	Cash	Rs 20 per hour	Rs 10 per hour	No such option	Yes	No
63	Jhandewalan - Videocon Tower Parking	New Delhi	Jhandewalan extension	Videocon tower parking, Jhandewalan extension	28.64520454	77.20256042	Open - Road Side	Private - self managed	Cemented	No	No	No ticket	Multi gates for Entry as well as Exit	Open All Days	12:00:00 AM - 11:59:00 PM	Car, 2 Weelers	50	50	30	30	Paid	Cash	Rs 20 per hour	Rs 10 per hour	Monthly Pass	No	No
64	Jhandewalan Extension - Near Income Tax Office	New Delhi	Jhandewalan, karol bagh	Jhandewalan extension, Near income tax office	28.64582062	77.20172882	Open - Road Side	Private - self managed	Cemented	No	No	Manually - Hand written	Multi gates for Entry as well as Exit	Open All Days	10:00:00 AM - 07:00:00 PM	Car	20	20	0	0	Paid	Cash	20 rs for first hour, 10 for the next subsequent hours	Not applicable.	No such option	No	No
65	Jhandewalan Extension -  Alankit Assignment Limited	New Delhi	Jhandewalan extension	Jhandewalan extension, Near by alankit assignment limited	28.64493179	77.20224762	Open - Road Side	Not known	Cemented	No	No	No ticket	Multi gates for Entry as well as Exit	Open All Days	12:00:00 AM - 11:59:00 PM	Car, 2 Weelers	40	40	20	20	Free	Free Parking	Free parking	Free parking.	No such option	No	No
66	Jhandewalan - Anarkali Complex	New Delhi	Jhandewalan	Anarkali complex, jhandewalan, Behind videocon tower	28.64481163	77.20252228	Indoor - Single Level	Private - subcontracted	Cemented	No	No	Manually - Hand written	Single entry gate and Single exit gate	Open All Days	09:00:00 AM - 09:00:00 AM	Car, 2 Weelers	40	40	80	80	Paid	Cash	Rs 20 per hour	Rs 10 per hour	Monthly Pass	No	No
67	Madhuban Chowk	New Delhi	Madhuban chowk, pitampura	Madhuban chowk Red light, Near by govt school, pitampura	28.7034874	77.13260651	Open - Road Side	Not known	Cemented	No	No	No ticket	Multi gates for Entry as well as Exit	Open All Days	12:00:00 AM - 11:59:00 PM	Car, 2 Weelers	100	100	20	20	Free	Free Parking	Free parking.	Free parking.	No such option	No	No
68	Rohini Court	New Delhi	Madhuban chowk, pitampura	Rohini court, madhuban chowk crossing, Pitampura	28.70665741	77.13260651	Open - Road Side	Govt - Open - Not Authorized to anyone	Cemented	No	No	No ticket	Multi gates for Entry as well as Exit	Open All Days	12:00:00 AM - 11:59:00 PM	Car, 2 Weelers	50	50	20	20	Free	Free Parking	Free.	Free.	No such option	No	No
69	Madhuban chowk, Shiva Hardware Market	New Delhi	Madhuban chowk, pitampura	Madhuban chowk, shiva harware market, After crossing madhuban chowk Red light	28.70144272	77.12887573	Open - Covered bounderies	Govt - Subcontracted	Mud	No	No	Manually - Hand written	Shared Single gate for Entry as well as Exit	Open All Days	08:00:00 AM - 10:00:00 PM	Car, 2 Weelers	100	100	20	20	Paid	Cash	Rs 20 per hour	Rs 10 per hour	Monthly Pass	No	No
70	Rani Bagh - Sita Ram Mandir	New Delhi	Rani bagh	Rani bagh, near sita ram mandir, Pitampura	28.68327713	77.13652039	Open - Road Side	Govt - Open - Not Authorized to anyone	Cemented	No	No	No ticket	Multi gates for Entry as well as Exit	Open All Days	12:00:00 AM - 11:59:00 PM	Car	50	50	0	0	Free	Free Parking	Free parking.	Not applicable.	No such option	No	No
71	Karol Bagh - Gupta Market	New Delhi	Karol bagh gupta market	Metro view hotel, gupta market, Karol bagh	\N	\N	Open - Road Side	Private - self managed	Cemented	No	No	No ticket	Multi gates for Entry as well as Exit	Open All Days	12:00:00 AM - 11:59:00 PM	Car, 2 Weelers	40	40	20	20	Free	Free Parking	Free parking.	Free parking.	No such option	No	No
72	Karol Bagh - Baptist Church	New Delhi	Karol bagh	Baptist church, near by police station, Karol bagh	\N	\N	Open - Road Side	Not known	Cemented	No	No	No ticket	Multi gates for Entry as well as Exit	Open All Days	12:00:00 AM - 11:59:00 PM	Car	30	30	0	0	Free	Free Parking	Free parking.	Not applicable.	No such option	No	No
73	Karol Bagh - PC jewellers	New Delhi	Karol bagh, gupta market	PC jewellers, gupta market, Karol bagh	\N	\N	Open - Road Side	Govt - Open - Not Authorized to anyone	Cemented	No	No	No ticket	Multi gates for Entry as well as Exit	Open All Days	12:00:00 AM - 11:59:00 PM	Car, 2 Weelers	50	50	20	20	Free	Free Parking	Free parking.	Free parking.	No such option	No	No
74	Karol Bagh - Punjab National Bank	New Delhi	Karol bagh gupta market	Punjab national bank, beside jagirilaj, Gupta market,  karol bagh	\N	\N	Open - Road Side	Govt - Open - Not Authorized to anyone	Cemented	No	No	No ticket	Multi gates for Entry as well as Exit	Open All Days	12:00:00 AM - 11:59:00 PM	Car, 2 Weelers	40	40	15	15	Free	Free Parking	Free parking.	Free parking.	No such option	No	No
75	Connaught Place - Super Bazar	New Delhi	Super bazar, cannought place	Near Hotel Alka Premier and pizza hut, Near by super market bus stand, CP	\N	\N	Open - Road Side	Private - subcontracted	Cemented	No	yes	Manually - Hand written	Shared Single gate for Entry as well as Exit	Open All Days	08:00:00 AM - 09:00:00 PM	Car	30	30	0	0	Paid	Cash	Rs 20 per hour	Not applicable.	Monthly Pass	No	No
76	Connaught Place - Hdfc bank	New Delhi	Super bazar bus stand Cp	Hotel bright, hdfc bank, Near by super bazar, cannought place	\N	\N	Open - Road Side	Private - subcontracted	Cemented	No	yes	Manually - Hand written	Shared Single gate for Entry as well as Exit	Open All Days	09:00:00 AM - 11:00:00 PM	Car	50	50	0	0	Paid	Cash	Rs 20 per hour	Not applicable.	Monthly Pass	No	No
77	Connaught Place - M - block	New Delhi	M block, outer circle, CP	M - block, near by indian grill company, M- block, outer circle, CP	\N	\N	Open - Covered bounderies	Private - subcontracted	Cemented	No	No	Manually - Hand written	Shared Single gate for Entry as well as Exit	Open All Days	09:00:00 AM - 11:59:00 PM	Car	60	60	0	0	Paid	Cash	20 rs per hour, max 100	Not applicable.	Monthly Pass	No	No
78	Connaught Place M - block	New Delhi	M - block, near  chilis' bar CP	M- BLOCK, near by chilli's bar, Outer circle, CP	\N	\N	Open - Covered bounderies	Govt - Subcontracted	Cemented	No	No	Manually - Hand written	Shared Single gate for Entry as well as Exit	Open All Days	09:00:00 AM - 11:59:00 PM	Car	30	30	0	0	Paid	Cash	Rs 20 per hour	Not applicable.	No such option	No	No
79	Connaught Place M- block	New Delhi	M-block, HP petroleum, CP	M - block, HP Petroleum, Near Oriental Bank of Commerce, Near HP petroleum, CP	\N	\N	Open - Road Side	Private - subcontracted	Cemented	No	No	Manually - Hand written	Shared Single gate for Entry as well as Exit	Open All Days	12:00:00 AM - 11:59:00 PM	Car	50	50	0	0	Free	Free Parking	Free parking.	Not applicable.	No such option	Yes	No
80	Connaught Place N - block	New Delhi	N - block,  near adidas showroom on indira chowk	N - block,  near adidas showroom, On indira chowk, CP	\N	\N	Open - Covered bounderies	Private - subcontracted	Cemented	No	No	Manually - Hand written	Shared Single gate for Entry as well as Exit	Open All Days	11:00:00 AM - 11:59:00 PM	Car	20	20	0	0	Paid	Cash	20 for 1st hour, 100 max	Not applicable. 8	Monthly Pass	No	No
81	Connaught Place F-block	New Delhi	F-block, middle circle,  CP	F-block, middle circle Maruti suzuki showroom, Near by wine and beer shop, CP	\N	\N	Open - Road Side	Not known	Cemented	No	No	No ticket	Multi gates for Entry as well as Exit	Open All Days	12:00:00 AM - 11:59:00 PM	Car	50	50	10	10	Free	Free Parking	Free parking.	Free parking.	No such option	No	No
82	Connaught Place M - block Indira Chowk	New Delhi	M - Block, on indira chowk beside adidas	M - block,  on indira chowk, In front of statesman house,  CP	\N	\N	Open - Covered bounderies	Govt - Subcontracted	Cemented	No	No	Mobile App having Blue Tooth Printer	Single entry gate and Single exit gate	Open All Days	09:00:00 AM - 09:00:00 PM	Car	40	40	0	0	Paid	Cash	Rs 20 per hour	Not applicable.	Monthly Pass	No	No
83	Connaught Place N-block, Punjab National Bank	New Delhi	Cannought Place, n - block	N - block, near punjab national bank,  on indira chowk,  CP	\N	\N	Open - Covered bounderies	Govt - Subcontracted	Cemented	No	No	Mobile App having Blue Tooth Printer	Shared Single gate for Entry as well as Exit	Open All Days	09:00:00 AM - 11:59:00 PM	Car	50	50	0	0	Paid	Cash	Rs 20 per hour	Not applicable.	Monthly Pass	No	No
84	Barakhamba Road - New Delhi House Building	New Delhi	New Delhi House Building, Barakhamba	New delhi house building, behind the building, Barakhamba road, CP	\N	\N	Open - Road Side	Not known	Cemented	No	No	No ticket	Multi gates for Entry as well as Exit	Open All Days	12:00:00 AM - 11:59:00 PM	Car, 2 Weelers	50	50	20	20	Free	Free Parking	Free parking.	Free parking.	No such option	No	No
85	Barakhamba Road - ECE House	New Delhi	Barakhamba Road, CP	ECE house, near by HDFC bank, Barakhamba road, CP	28.629724	77.225735	Open - Road Side	Not known	Cemented	No	No	No ticket	Multi gates for Entry as well as Exit	Open All Days	12:00:00 AM - 11:59:00 AM	Car	30	30	0	0	Free	Free Parking	Free parking.	Free parking.	No such option	No	No
86	Barakhamba Road - Statesmen House	New Delhi	Barakhamba Road	Statesmen house back, near by axis bank, Barakhamba road,  CP	28.6305245	77.2241101	Open - Covered bounderies	Govt - Subcontracted	Cemented	No	No	Mobile App having Blue Tooth Printer	Single entry gate and Single exit gate	Open All Days	08:00:00 AM - 11:00:00 PM	Car, 2 Weelers	80	80	150	150	Paid	Cash	20 per hour, max 100	Rs 10 per hour, max 100	Monthly Pass	No	Charges on monthly passes only for 22 days, not for the  entire month.
87	Gopaldas ARDEE -  Indira Red Light	New Delhi	Barakhamba Road, CP	Gopaldas ARDEE, on Indira red light, Barakhamba road, CP	28.631343	77.223397	Open - Road Side	Govt - Subcontracted	Cemented	No	No	Mobile App having Blue Tooth Printer	Multi gates for Entry as well as Exit	Open All Days	08:00:00 AM - 11:00:00 PM	Car, 2 Weelers	60	60	10	10	Paid	Cash	20 rs for 1st hour, max 100	10rs for 1st hour, 50 max	Monthly Pass	No	Charges on monthly passes only for 22 days, not for the entire month.
\.


--
-- Data for Name: rows; Type: TABLE DATA; Schema: public; Owner: parking_user
--

COPY public.rows (row_id, row_name, floor_id, parkinglot_id) FROM stdin;
1	Row 1	1	1
2	Row 2	1	1
3	Row 1	2	1
4	Row 2	2	1
5	Row 1	3	2
6	Row 2	3	2
7	Row 1	4	2
8	Row 2	4	2
9	Row 1	5	3
10	Row 2	5	3
11	Row 1	6	3
12	Row 2	6	3
13	Row 1	7	4
14	Row 2	7	4
15	Row 1	8	4
16	Row 2	8	4
17	Row 1	9	5
18	Row 2	9	5
19	Row 1	10	5
20	Row 2	10	5
21	Row 1	11	6
22	Row 2	11	6
23	Row 1	12	6
24	Row 2	12	6
25	Row 1	13	7
26	Row 2	13	7
27	Row 1	14	7
28	Row 2	14	7
29	Row 1	15	8
30	Row 2	15	8
31	Row 1	16	8
32	Row 2	16	8
33	Row 1	17	9
34	Row 2	17	9
35	Row 1	18	9
36	Row 2	18	9
37	Row 1	19	10
38	Row 2	19	10
39	Row 1	20	10
40	Row 2	20	10
41	Row 1	21	11
42	Row 2	21	11
43	Row 1	22	11
44	Row 2	22	11
45	Row 1	23	12
46	Row 2	23	12
47	Row 1	24	12
48	Row 2	24	12
49	Row 1	25	13
50	Row 2	25	13
51	Row 1	26	13
52	Row 2	26	13
53	Row 1	27	14
54	Row 2	27	14
55	Row 1	28	14
56	Row 2	28	14
57	Row 1	29	15
58	Row 2	29	15
59	Row 1	30	15
60	Row 2	30	15
61	Row 1	31	16
62	Row 2	31	16
63	Row 1	32	16
64	Row 2	32	16
65	Row 1	33	17
66	Row 2	33	17
67	Row 1	34	17
68	Row 2	34	17
69	Row 1	35	18
70	Row 2	35	18
71	Row 1	36	18
72	Row 2	36	18
73	Row 1	37	19
74	Row 2	37	19
75	Row 1	38	19
76	Row 2	38	19
77	Row 1	39	20
78	Row 2	39	20
79	Row 1	40	20
80	Row 2	40	20
81	Row 1	41	21
82	Row 2	41	21
83	Row 1	42	21
84	Row 2	42	21
85	Row 1	43	22
86	Row 2	43	22
87	Row 1	44	22
88	Row 2	44	22
89	Row 1	45	23
90	Row 2	45	23
91	Row 1	46	23
92	Row 2	46	23
93	Row 1	47	24
94	Row 2	47	24
95	Row 1	48	24
96	Row 2	48	24
97	Row 1	49	25
98	Row 2	49	25
99	Row 1	50	25
100	Row 2	50	25
101	Row 1	51	26
102	Row 2	51	26
103	Row 1	52	26
104	Row 2	52	26
105	Row 1	53	27
106	Row 2	53	27
107	Row 1	54	27
108	Row 2	54	27
109	Row 1	55	28
110	Row 2	55	28
111	Row 1	56	28
112	Row 2	56	28
113	Row 1	57	29
114	Row 2	57	29
115	Row 1	58	29
116	Row 2	58	29
117	Row 1	59	30
118	Row 2	59	30
119	Row 1	60	30
120	Row 2	60	30
121	Row 1	61	31
122	Row 2	61	31
123	Row 1	62	31
124	Row 2	62	31
125	Row 1	63	32
126	Row 2	63	32
127	Row 1	64	32
128	Row 2	64	32
129	Row 1	65	33
130	Row 2	65	33
131	Row 1	66	33
132	Row 2	66	33
133	Row 1	67	34
134	Row 2	67	34
135	Row 1	68	34
136	Row 2	68	34
137	Row 1	69	35
138	Row 2	69	35
139	Row 1	70	35
140	Row 2	70	35
141	Row 1	71	36
142	Row 2	71	36
143	Row 1	72	36
144	Row 2	72	36
145	Row 1	73	37
146	Row 2	73	37
147	Row 1	74	37
148	Row 2	74	37
149	Row 1	75	38
150	Row 2	75	38
151	Row 1	76	38
152	Row 2	76	38
153	Row 1	77	39
154	Row 2	77	39
155	Row 1	78	39
156	Row 2	78	39
157	Row 1	79	40
158	Row 2	79	40
159	Row 1	80	40
160	Row 2	80	40
161	Row 1	81	41
162	Row 2	81	41
163	Row 1	82	41
164	Row 2	82	41
165	Row 1	83	42
166	Row 2	83	42
167	Row 1	84	42
168	Row 2	84	42
169	Row 1	85	43
170	Row 2	85	43
171	Row 1	86	43
172	Row 2	86	43
173	Row 1	87	44
174	Row 2	87	44
175	Row 1	88	44
176	Row 2	88	44
177	Row 1	89	45
178	Row 2	89	45
179	Row 1	90	45
180	Row 2	90	45
181	Row 1	91	46
182	Row 2	91	46
183	Row 1	92	46
184	Row 2	92	46
185	Row 1	93	47
186	Row 2	93	47
187	Row 1	94	47
188	Row 2	94	47
189	Row 1	95	48
190	Row 2	95	48
191	Row 1	96	48
192	Row 2	96	48
193	Row 1	97	49
194	Row 2	97	49
195	Row 1	98	49
196	Row 2	98	49
197	Row 1	99	50
198	Row 2	99	50
199	Row 1	100	50
200	Row 2	100	50
201	Row 1	101	51
202	Row 2	101	51
203	Row 1	102	51
204	Row 2	102	51
205	Row 1	103	52
206	Row 2	103	52
207	Row 1	104	52
208	Row 2	104	52
209	Row 1	105	53
210	Row 2	105	53
211	Row 1	106	53
212	Row 2	106	53
213	Row 1	107	54
214	Row 2	107	54
215	Row 1	108	54
216	Row 2	108	54
217	Row 1	109	55
218	Row 2	109	55
219	Row 1	110	55
220	Row 2	110	55
221	Row 1	111	56
222	Row 2	111	56
223	Row 1	112	56
224	Row 2	112	56
225	Row 1	113	57
226	Row 2	113	57
227	Row 1	114	57
228	Row 2	114	57
229	Row 1	115	58
230	Row 2	115	58
231	Row 1	116	58
232	Row 2	116	58
233	Row 1	117	59
234	Row 2	117	59
235	Row 1	118	59
236	Row 2	118	59
237	Row 1	119	60
238	Row 2	119	60
239	Row 1	120	60
240	Row 2	120	60
241	Row 1	121	61
242	Row 2	121	61
243	Row 1	122	61
244	Row 2	122	61
245	Row 1	123	62
246	Row 2	123	62
247	Row 1	124	62
248	Row 2	124	62
249	Row 1	125	63
250	Row 2	125	63
251	Row 1	126	63
252	Row 2	126	63
253	Row 1	127	64
254	Row 2	127	64
255	Row 1	128	64
256	Row 2	128	64
257	Row 1	129	65
258	Row 2	129	65
259	Row 1	130	65
260	Row 2	130	65
261	Row 1	131	66
262	Row 2	131	66
263	Row 1	132	66
264	Row 2	132	66
265	Row 1	133	67
266	Row 2	133	67
267	Row 1	134	67
268	Row 2	134	67
269	Row 1	135	68
270	Row 2	135	68
271	Row 1	136	68
272	Row 2	136	68
273	Row 1	137	69
274	Row 2	137	69
275	Row 1	138	69
276	Row 2	138	69
277	Row 1	139	70
278	Row 2	139	70
279	Row 1	140	70
280	Row 2	140	70
281	Row 1	141	71
282	Row 2	141	71
283	Row 1	142	71
284	Row 2	142	71
285	Row 1	143	72
286	Row 2	143	72
287	Row 1	144	72
288	Row 2	144	72
289	Row 1	145	73
290	Row 2	145	73
291	Row 1	146	73
292	Row 2	146	73
293	Row 1	147	74
294	Row 2	147	74
295	Row 1	148	74
296	Row 2	148	74
297	Row 1	149	75
298	Row 2	149	75
299	Row 1	150	75
300	Row 2	150	75
301	Row 1	151	76
302	Row 2	151	76
303	Row 1	152	76
304	Row 2	152	76
305	Row 1	153	77
306	Row 2	153	77
307	Row 1	154	77
308	Row 2	154	77
309	Row 1	155	78
310	Row 2	155	78
311	Row 1	156	78
312	Row 2	156	78
313	Row 1	157	79
314	Row 2	157	79
315	Row 1	158	79
316	Row 2	158	79
317	Row 1	159	80
318	Row 2	159	80
319	Row 1	160	80
320	Row 2	160	80
321	Row 1	161	81
322	Row 2	161	81
323	Row 1	162	81
324	Row 2	162	81
325	Row 1	163	82
326	Row 2	163	82
327	Row 1	164	82
328	Row 2	164	82
329	Row 1	165	83
330	Row 2	165	83
331	Row 1	166	83
332	Row 2	166	83
333	Row 1	167	84
334	Row 2	167	84
335	Row 1	168	84
336	Row 2	168	84
337	Row 1	169	85
338	Row 2	169	85
339	Row 1	170	85
340	Row 2	170	85
341	Row 1	171	86
342	Row 2	171	86
343	Row 1	172	86
344	Row 2	172	86
345	Row 1	173	87
346	Row 2	173	87
347	Row 1	174	87
348	Row 2	174	87
\.


--
-- Data for Name: slots; Type: TABLE DATA; Schema: public; Owner: parking_user
--

COPY public.slots (slot_id, slot_name, status, vehicle_reg_no, ticket_id, row_id, floor_id, parkinglot_id) FROM stdin;
1	Slot1	0	\N	\N	1	1	1
2	Slot2	0	\N	\N	1	1	1
3	Slot3	0	\N	\N	1	1	1
4	Slot4	0	\N	\N	1	1	1
5	Slot5	0	\N	\N	1	1	1
6	Slot1	0	\N	\N	2	1	1
7	Slot2	0	\N	\N	2	1	1
8	Slot3	0	\N	\N	2	1	1
9	Slot4	0	\N	\N	2	1	1
10	Slot5	0	\N	\N	2	1	1
11	Slot1	0	\N	\N	3	2	1
12	Slot2	0	\N	\N	3	2	1
13	Slot3	0	\N	\N	3	2	1
14	Slot4	0	\N	\N	3	2	1
15	Slot5	0	\N	\N	3	2	1
16	Slot1	0	\N	\N	4	2	1
17	Slot2	0	\N	\N	4	2	1
18	Slot3	0	\N	\N	4	2	1
19	Slot4	0	\N	\N	4	2	1
20	Slot5	0	\N	\N	4	2	1
21	Slot1	0	\N	\N	5	3	2
22	Slot2	0	\N	\N	5	3	2
23	Slot3	0	\N	\N	5	3	2
24	Slot4	0	\N	\N	5	3	2
25	Slot5	0	\N	\N	5	3	2
26	Slot1	0	\N	\N	6	3	2
27	Slot2	0	\N	\N	6	3	2
28	Slot3	0	\N	\N	6	3	2
29	Slot4	0	\N	\N	6	3	2
30	Slot5	0	\N	\N	6	3	2
31	Slot1	0	\N	\N	7	4	2
32	Slot2	0	\N	\N	7	4	2
33	Slot3	0	\N	\N	7	4	2
34	Slot4	0	\N	\N	7	4	2
35	Slot5	0	\N	\N	7	4	2
36	Slot1	0	\N	\N	8	4	2
37	Slot2	0	\N	\N	8	4	2
38	Slot3	0	\N	\N	8	4	2
39	Slot4	0	\N	\N	8	4	2
40	Slot5	0	\N	\N	8	4	2
41	Slot1	0	\N	\N	9	5	3
42	Slot2	0	\N	\N	9	5	3
43	Slot3	0	\N	\N	9	5	3
44	Slot4	0	\N	\N	9	5	3
45	Slot5	0	\N	\N	9	5	3
46	Slot1	0	\N	\N	10	5	3
47	Slot2	0	\N	\N	10	5	3
48	Slot3	0	\N	\N	10	5	3
49	Slot4	0	\N	\N	10	5	3
50	Slot5	0	\N	\N	10	5	3
51	Slot1	0	\N	\N	11	6	3
52	Slot2	0	\N	\N	11	6	3
53	Slot3	0	\N	\N	11	6	3
54	Slot4	0	\N	\N	11	6	3
55	Slot5	0	\N	\N	11	6	3
56	Slot1	0	\N	\N	12	6	3
57	Slot2	0	\N	\N	12	6	3
58	Slot3	0	\N	\N	12	6	3
59	Slot4	0	\N	\N	12	6	3
60	Slot5	0	\N	\N	12	6	3
61	Slot1	0	\N	\N	13	7	4
62	Slot2	0	\N	\N	13	7	4
63	Slot3	0	\N	\N	13	7	4
64	Slot4	0	\N	\N	13	7	4
65	Slot5	0	\N	\N	13	7	4
66	Slot1	0	\N	\N	14	7	4
67	Slot2	0	\N	\N	14	7	4
68	Slot3	0	\N	\N	14	7	4
69	Slot4	0	\N	\N	14	7	4
70	Slot5	0	\N	\N	14	7	4
71	Slot1	0	\N	\N	15	8	4
72	Slot2	0	\N	\N	15	8	4
73	Slot3	0	\N	\N	15	8	4
74	Slot4	0	\N	\N	15	8	4
75	Slot5	0	\N	\N	15	8	4
76	Slot1	0	\N	\N	16	8	4
77	Slot2	0	\N	\N	16	8	4
78	Slot3	0	\N	\N	16	8	4
79	Slot4	0	\N	\N	16	8	4
80	Slot5	0	\N	\N	16	8	4
81	Slot1	0	\N	\N	17	9	5
82	Slot2	0	\N	\N	17	9	5
83	Slot3	0	\N	\N	17	9	5
84	Slot4	0	\N	\N	17	9	5
85	Slot5	0	\N	\N	17	9	5
86	Slot1	0	\N	\N	18	9	5
87	Slot2	0	\N	\N	18	9	5
88	Slot3	0	\N	\N	18	9	5
89	Slot4	0	\N	\N	18	9	5
90	Slot5	0	\N	\N	18	9	5
91	Slot1	0	\N	\N	19	10	5
92	Slot2	0	\N	\N	19	10	5
93	Slot3	0	\N	\N	19	10	5
94	Slot4	0	\N	\N	19	10	5
95	Slot5	0	\N	\N	19	10	5
96	Slot1	0	\N	\N	20	10	5
97	Slot2	0	\N	\N	20	10	5
98	Slot3	0	\N	\N	20	10	5
99	Slot4	0	\N	\N	20	10	5
100	Slot5	0	\N	\N	20	10	5
101	Slot1	0	\N	\N	21	11	6
102	Slot2	0	\N	\N	21	11	6
103	Slot3	0	\N	\N	21	11	6
104	Slot4	0	\N	\N	21	11	6
105	Slot5	0	\N	\N	21	11	6
106	Slot1	0	\N	\N	22	11	6
107	Slot2	0	\N	\N	22	11	6
108	Slot3	0	\N	\N	22	11	6
109	Slot4	0	\N	\N	22	11	6
110	Slot5	0	\N	\N	22	11	6
111	Slot1	0	\N	\N	23	12	6
112	Slot2	0	\N	\N	23	12	6
113	Slot3	0	\N	\N	23	12	6
114	Slot4	0	\N	\N	23	12	6
115	Slot5	0	\N	\N	23	12	6
116	Slot1	0	\N	\N	24	12	6
117	Slot2	0	\N	\N	24	12	6
118	Slot3	0	\N	\N	24	12	6
119	Slot4	0	\N	\N	24	12	6
120	Slot5	0	\N	\N	24	12	6
121	Slot1	0	\N	\N	25	13	7
122	Slot2	0	\N	\N	25	13	7
123	Slot3	0	\N	\N	25	13	7
124	Slot4	0	\N	\N	25	13	7
125	Slot5	0	\N	\N	25	13	7
126	Slot1	0	\N	\N	26	13	7
127	Slot2	0	\N	\N	26	13	7
128	Slot3	0	\N	\N	26	13	7
129	Slot4	0	\N	\N	26	13	7
130	Slot5	0	\N	\N	26	13	7
131	Slot1	0	\N	\N	27	14	7
132	Slot2	0	\N	\N	27	14	7
133	Slot3	0	\N	\N	27	14	7
134	Slot4	0	\N	\N	27	14	7
135	Slot5	0	\N	\N	27	14	7
136	Slot1	0	\N	\N	28	14	7
137	Slot2	0	\N	\N	28	14	7
138	Slot3	0	\N	\N	28	14	7
139	Slot4	0	\N	\N	28	14	7
140	Slot5	0	\N	\N	28	14	7
141	Slot1	0	\N	\N	29	15	8
142	Slot2	0	\N	\N	29	15	8
143	Slot3	0	\N	\N	29	15	8
144	Slot4	0	\N	\N	29	15	8
145	Slot5	0	\N	\N	29	15	8
146	Slot1	0	\N	\N	30	15	8
147	Slot2	0	\N	\N	30	15	8
148	Slot3	0	\N	\N	30	15	8
149	Slot4	0	\N	\N	30	15	8
150	Slot5	0	\N	\N	30	15	8
151	Slot1	0	\N	\N	31	16	8
152	Slot2	0	\N	\N	31	16	8
153	Slot3	0	\N	\N	31	16	8
154	Slot4	0	\N	\N	31	16	8
155	Slot5	0	\N	\N	31	16	8
156	Slot1	0	\N	\N	32	16	8
157	Slot2	0	\N	\N	32	16	8
158	Slot3	0	\N	\N	32	16	8
159	Slot4	0	\N	\N	32	16	8
160	Slot5	0	\N	\N	32	16	8
161	Slot1	0	\N	\N	33	17	9
162	Slot2	0	\N	\N	33	17	9
163	Slot3	0	\N	\N	33	17	9
164	Slot4	0	\N	\N	33	17	9
165	Slot5	0	\N	\N	33	17	9
166	Slot1	0	\N	\N	34	17	9
167	Slot2	0	\N	\N	34	17	9
168	Slot3	0	\N	\N	34	17	9
169	Slot4	0	\N	\N	34	17	9
170	Slot5	0	\N	\N	34	17	9
171	Slot1	0	\N	\N	35	18	9
172	Slot2	0	\N	\N	35	18	9
173	Slot3	0	\N	\N	35	18	9
174	Slot4	0	\N	\N	35	18	9
175	Slot5	0	\N	\N	35	18	9
176	Slot1	0	\N	\N	36	18	9
177	Slot2	0	\N	\N	36	18	9
178	Slot3	0	\N	\N	36	18	9
179	Slot4	0	\N	\N	36	18	9
180	Slot5	0	\N	\N	36	18	9
181	Slot1	0	\N	\N	37	19	10
182	Slot2	0	\N	\N	37	19	10
183	Slot3	0	\N	\N	37	19	10
184	Slot4	0	\N	\N	37	19	10
185	Slot5	0	\N	\N	37	19	10
186	Slot1	0	\N	\N	38	19	10
187	Slot2	0	\N	\N	38	19	10
188	Slot3	0	\N	\N	38	19	10
189	Slot4	0	\N	\N	38	19	10
190	Slot5	0	\N	\N	38	19	10
191	Slot1	0	\N	\N	39	20	10
192	Slot2	0	\N	\N	39	20	10
193	Slot3	0	\N	\N	39	20	10
194	Slot4	0	\N	\N	39	20	10
195	Slot5	0	\N	\N	39	20	10
196	Slot1	0	\N	\N	40	20	10
197	Slot2	0	\N	\N	40	20	10
198	Slot3	0	\N	\N	40	20	10
199	Slot4	0	\N	\N	40	20	10
200	Slot5	0	\N	\N	40	20	10
201	Slot1	0	\N	\N	41	21	11
202	Slot2	0	\N	\N	41	21	11
203	Slot3	0	\N	\N	41	21	11
204	Slot4	0	\N	\N	41	21	11
205	Slot5	0	\N	\N	41	21	11
206	Slot1	0	\N	\N	42	21	11
207	Slot2	0	\N	\N	42	21	11
208	Slot3	0	\N	\N	42	21	11
209	Slot4	0	\N	\N	42	21	11
210	Slot5	0	\N	\N	42	21	11
211	Slot1	0	\N	\N	43	22	11
212	Slot2	0	\N	\N	43	22	11
213	Slot3	0	\N	\N	43	22	11
214	Slot4	0	\N	\N	43	22	11
215	Slot5	0	\N	\N	43	22	11
216	Slot1	0	\N	\N	44	22	11
217	Slot2	0	\N	\N	44	22	11
218	Slot3	0	\N	\N	44	22	11
219	Slot4	0	\N	\N	44	22	11
220	Slot5	0	\N	\N	44	22	11
221	Slot1	0	\N	\N	45	23	12
222	Slot2	0	\N	\N	45	23	12
223	Slot3	0	\N	\N	45	23	12
224	Slot4	0	\N	\N	45	23	12
225	Slot5	0	\N	\N	45	23	12
226	Slot1	0	\N	\N	46	23	12
227	Slot2	0	\N	\N	46	23	12
228	Slot3	0	\N	\N	46	23	12
229	Slot4	0	\N	\N	46	23	12
230	Slot5	0	\N	\N	46	23	12
231	Slot1	0	\N	\N	47	24	12
232	Slot2	0	\N	\N	47	24	12
233	Slot3	0	\N	\N	47	24	12
234	Slot4	0	\N	\N	47	24	12
235	Slot5	0	\N	\N	47	24	12
236	Slot1	0	\N	\N	48	24	12
237	Slot2	0	\N	\N	48	24	12
238	Slot3	0	\N	\N	48	24	12
239	Slot4	0	\N	\N	48	24	12
240	Slot5	0	\N	\N	48	24	12
241	Slot1	0	\N	\N	49	25	13
242	Slot2	0	\N	\N	49	25	13
243	Slot3	0	\N	\N	49	25	13
244	Slot4	0	\N	\N	49	25	13
245	Slot5	0	\N	\N	49	25	13
246	Slot1	0	\N	\N	50	25	13
247	Slot2	0	\N	\N	50	25	13
248	Slot3	0	\N	\N	50	25	13
249	Slot4	0	\N	\N	50	25	13
250	Slot5	0	\N	\N	50	25	13
251	Slot1	0	\N	\N	51	26	13
252	Slot2	0	\N	\N	51	26	13
253	Slot3	0	\N	\N	51	26	13
254	Slot4	0	\N	\N	51	26	13
255	Slot5	0	\N	\N	51	26	13
256	Slot1	0	\N	\N	52	26	13
257	Slot2	0	\N	\N	52	26	13
258	Slot3	0	\N	\N	52	26	13
259	Slot4	0	\N	\N	52	26	13
260	Slot5	0	\N	\N	52	26	13
261	Slot1	0	\N	\N	53	27	14
262	Slot2	0	\N	\N	53	27	14
263	Slot3	0	\N	\N	53	27	14
264	Slot4	0	\N	\N	53	27	14
265	Slot5	0	\N	\N	53	27	14
266	Slot1	0	\N	\N	54	27	14
267	Slot2	0	\N	\N	54	27	14
268	Slot3	0	\N	\N	54	27	14
269	Slot4	0	\N	\N	54	27	14
270	Slot5	0	\N	\N	54	27	14
271	Slot1	0	\N	\N	55	28	14
272	Slot2	0	\N	\N	55	28	14
273	Slot3	0	\N	\N	55	28	14
274	Slot4	0	\N	\N	55	28	14
275	Slot5	0	\N	\N	55	28	14
276	Slot1	0	\N	\N	56	28	14
277	Slot2	0	\N	\N	56	28	14
278	Slot3	0	\N	\N	56	28	14
279	Slot4	0	\N	\N	56	28	14
280	Slot5	0	\N	\N	56	28	14
281	Slot1	0	\N	\N	57	29	15
282	Slot2	0	\N	\N	57	29	15
283	Slot3	0	\N	\N	57	29	15
284	Slot4	0	\N	\N	57	29	15
285	Slot5	0	\N	\N	57	29	15
286	Slot1	0	\N	\N	58	29	15
287	Slot2	0	\N	\N	58	29	15
288	Slot3	0	\N	\N	58	29	15
289	Slot4	0	\N	\N	58	29	15
290	Slot5	0	\N	\N	58	29	15
291	Slot1	0	\N	\N	59	30	15
292	Slot2	0	\N	\N	59	30	15
293	Slot3	0	\N	\N	59	30	15
294	Slot4	0	\N	\N	59	30	15
295	Slot5	0	\N	\N	59	30	15
296	Slot1	0	\N	\N	60	30	15
297	Slot2	0	\N	\N	60	30	15
298	Slot3	0	\N	\N	60	30	15
299	Slot4	0	\N	\N	60	30	15
300	Slot5	0	\N	\N	60	30	15
301	Slot1	0	\N	\N	61	31	16
302	Slot2	0	\N	\N	61	31	16
303	Slot3	0	\N	\N	61	31	16
304	Slot4	0	\N	\N	61	31	16
305	Slot5	0	\N	\N	61	31	16
306	Slot1	0	\N	\N	62	31	16
307	Slot2	0	\N	\N	62	31	16
308	Slot3	0	\N	\N	62	31	16
309	Slot4	0	\N	\N	62	31	16
310	Slot5	0	\N	\N	62	31	16
311	Slot1	0	\N	\N	63	32	16
312	Slot2	0	\N	\N	63	32	16
313	Slot3	0	\N	\N	63	32	16
314	Slot4	0	\N	\N	63	32	16
315	Slot5	0	\N	\N	63	32	16
316	Slot1	0	\N	\N	64	32	16
317	Slot2	0	\N	\N	64	32	16
318	Slot3	0	\N	\N	64	32	16
319	Slot4	0	\N	\N	64	32	16
320	Slot5	0	\N	\N	64	32	16
321	Slot1	0	\N	\N	65	33	17
322	Slot2	0	\N	\N	65	33	17
323	Slot3	0	\N	\N	65	33	17
324	Slot4	0	\N	\N	65	33	17
325	Slot5	0	\N	\N	65	33	17
326	Slot1	0	\N	\N	66	33	17
327	Slot2	0	\N	\N	66	33	17
328	Slot3	0	\N	\N	66	33	17
329	Slot4	0	\N	\N	66	33	17
330	Slot5	0	\N	\N	66	33	17
331	Slot1	0	\N	\N	67	34	17
332	Slot2	0	\N	\N	67	34	17
333	Slot3	0	\N	\N	67	34	17
334	Slot4	0	\N	\N	67	34	17
335	Slot5	0	\N	\N	67	34	17
336	Slot1	0	\N	\N	68	34	17
337	Slot2	0	\N	\N	68	34	17
338	Slot3	0	\N	\N	68	34	17
339	Slot4	0	\N	\N	68	34	17
340	Slot5	0	\N	\N	68	34	17
341	Slot1	0	\N	\N	69	35	18
342	Slot2	0	\N	\N	69	35	18
343	Slot3	0	\N	\N	69	35	18
344	Slot4	0	\N	\N	69	35	18
345	Slot5	0	\N	\N	69	35	18
346	Slot1	0	\N	\N	70	35	18
347	Slot2	0	\N	\N	70	35	18
348	Slot3	0	\N	\N	70	35	18
349	Slot4	0	\N	\N	70	35	18
350	Slot5	0	\N	\N	70	35	18
351	Slot1	0	\N	\N	71	36	18
352	Slot2	0	\N	\N	71	36	18
353	Slot3	0	\N	\N	71	36	18
354	Slot4	0	\N	\N	71	36	18
355	Slot5	0	\N	\N	71	36	18
356	Slot1	0	\N	\N	72	36	18
357	Slot2	0	\N	\N	72	36	18
358	Slot3	0	\N	\N	72	36	18
359	Slot4	0	\N	\N	72	36	18
360	Slot5	0	\N	\N	72	36	18
361	Slot1	0	\N	\N	73	37	19
362	Slot2	0	\N	\N	73	37	19
363	Slot3	0	\N	\N	73	37	19
364	Slot4	0	\N	\N	73	37	19
365	Slot5	0	\N	\N	73	37	19
366	Slot1	0	\N	\N	74	37	19
367	Slot2	0	\N	\N	74	37	19
368	Slot3	0	\N	\N	74	37	19
369	Slot4	0	\N	\N	74	37	19
370	Slot5	0	\N	\N	74	37	19
371	Slot1	0	\N	\N	75	38	19
372	Slot2	0	\N	\N	75	38	19
373	Slot3	0	\N	\N	75	38	19
374	Slot4	0	\N	\N	75	38	19
375	Slot5	0	\N	\N	75	38	19
376	Slot1	0	\N	\N	76	38	19
377	Slot2	0	\N	\N	76	38	19
378	Slot3	0	\N	\N	76	38	19
379	Slot4	0	\N	\N	76	38	19
380	Slot5	0	\N	\N	76	38	19
381	Slot1	0	\N	\N	77	39	20
382	Slot2	0	\N	\N	77	39	20
383	Slot3	0	\N	\N	77	39	20
384	Slot4	0	\N	\N	77	39	20
385	Slot5	0	\N	\N	77	39	20
386	Slot1	0	\N	\N	78	39	20
387	Slot2	0	\N	\N	78	39	20
388	Slot3	0	\N	\N	78	39	20
389	Slot4	0	\N	\N	78	39	20
390	Slot5	0	\N	\N	78	39	20
391	Slot1	0	\N	\N	79	40	20
392	Slot2	0	\N	\N	79	40	20
393	Slot3	0	\N	\N	79	40	20
394	Slot4	0	\N	\N	79	40	20
395	Slot5	0	\N	\N	79	40	20
396	Slot1	0	\N	\N	80	40	20
397	Slot2	0	\N	\N	80	40	20
398	Slot3	0	\N	\N	80	40	20
399	Slot4	0	\N	\N	80	40	20
400	Slot5	0	\N	\N	80	40	20
401	Slot1	0	\N	\N	81	41	21
402	Slot2	0	\N	\N	81	41	21
403	Slot3	0	\N	\N	81	41	21
404	Slot4	0	\N	\N	81	41	21
405	Slot5	0	\N	\N	81	41	21
406	Slot1	0	\N	\N	82	41	21
407	Slot2	0	\N	\N	82	41	21
408	Slot3	0	\N	\N	82	41	21
409	Slot4	0	\N	\N	82	41	21
410	Slot5	0	\N	\N	82	41	21
411	Slot1	0	\N	\N	83	42	21
412	Slot2	0	\N	\N	83	42	21
413	Slot3	0	\N	\N	83	42	21
414	Slot4	0	\N	\N	83	42	21
415	Slot5	0	\N	\N	83	42	21
416	Slot1	0	\N	\N	84	42	21
417	Slot2	0	\N	\N	84	42	21
418	Slot3	0	\N	\N	84	42	21
419	Slot4	0	\N	\N	84	42	21
420	Slot5	0	\N	\N	84	42	21
421	Slot1	0	\N	\N	85	43	22
422	Slot2	0	\N	\N	85	43	22
423	Slot3	0	\N	\N	85	43	22
424	Slot4	0	\N	\N	85	43	22
425	Slot5	0	\N	\N	85	43	22
426	Slot1	0	\N	\N	86	43	22
427	Slot2	0	\N	\N	86	43	22
428	Slot3	0	\N	\N	86	43	22
429	Slot4	0	\N	\N	86	43	22
430	Slot5	0	\N	\N	86	43	22
431	Slot1	0	\N	\N	87	44	22
432	Slot2	0	\N	\N	87	44	22
433	Slot3	0	\N	\N	87	44	22
434	Slot4	0	\N	\N	87	44	22
435	Slot5	0	\N	\N	87	44	22
436	Slot1	0	\N	\N	88	44	22
437	Slot2	0	\N	\N	88	44	22
438	Slot3	0	\N	\N	88	44	22
439	Slot4	0	\N	\N	88	44	22
440	Slot5	0	\N	\N	88	44	22
441	Slot1	0	\N	\N	89	45	23
442	Slot2	0	\N	\N	89	45	23
443	Slot3	0	\N	\N	89	45	23
444	Slot4	0	\N	\N	89	45	23
445	Slot5	0	\N	\N	89	45	23
446	Slot1	0	\N	\N	90	45	23
447	Slot2	0	\N	\N	90	45	23
448	Slot3	0	\N	\N	90	45	23
449	Slot4	0	\N	\N	90	45	23
450	Slot5	0	\N	\N	90	45	23
451	Slot1	0	\N	\N	91	46	23
452	Slot2	0	\N	\N	91	46	23
453	Slot3	0	\N	\N	91	46	23
454	Slot4	0	\N	\N	91	46	23
455	Slot5	0	\N	\N	91	46	23
456	Slot1	0	\N	\N	92	46	23
457	Slot2	0	\N	\N	92	46	23
458	Slot3	0	\N	\N	92	46	23
459	Slot4	0	\N	\N	92	46	23
460	Slot5	0	\N	\N	92	46	23
461	Slot1	0	\N	\N	93	47	24
462	Slot2	0	\N	\N	93	47	24
463	Slot3	0	\N	\N	93	47	24
464	Slot4	0	\N	\N	93	47	24
465	Slot5	0	\N	\N	93	47	24
466	Slot1	0	\N	\N	94	47	24
467	Slot2	0	\N	\N	94	47	24
468	Slot3	0	\N	\N	94	47	24
469	Slot4	0	\N	\N	94	47	24
470	Slot5	0	\N	\N	94	47	24
471	Slot1	0	\N	\N	95	48	24
472	Slot2	0	\N	\N	95	48	24
473	Slot3	0	\N	\N	95	48	24
474	Slot4	0	\N	\N	95	48	24
475	Slot5	0	\N	\N	95	48	24
476	Slot1	0	\N	\N	96	48	24
477	Slot2	0	\N	\N	96	48	24
478	Slot3	0	\N	\N	96	48	24
479	Slot4	0	\N	\N	96	48	24
480	Slot5	0	\N	\N	96	48	24
481	Slot1	0	\N	\N	97	49	25
482	Slot2	0	\N	\N	97	49	25
483	Slot3	0	\N	\N	97	49	25
484	Slot4	0	\N	\N	97	49	25
485	Slot5	0	\N	\N	97	49	25
486	Slot1	0	\N	\N	98	49	25
487	Slot2	0	\N	\N	98	49	25
488	Slot3	0	\N	\N	98	49	25
489	Slot4	0	\N	\N	98	49	25
490	Slot5	0	\N	\N	98	49	25
491	Slot1	0	\N	\N	99	50	25
492	Slot2	0	\N	\N	99	50	25
493	Slot3	0	\N	\N	99	50	25
494	Slot4	0	\N	\N	99	50	25
495	Slot5	0	\N	\N	99	50	25
496	Slot1	0	\N	\N	100	50	25
497	Slot2	0	\N	\N	100	50	25
498	Slot3	0	\N	\N	100	50	25
499	Slot4	0	\N	\N	100	50	25
500	Slot5	0	\N	\N	100	50	25
501	Slot1	0	\N	\N	101	51	26
502	Slot2	0	\N	\N	101	51	26
503	Slot3	0	\N	\N	101	51	26
504	Slot4	0	\N	\N	101	51	26
505	Slot5	0	\N	\N	101	51	26
506	Slot1	0	\N	\N	102	51	26
507	Slot2	0	\N	\N	102	51	26
508	Slot3	0	\N	\N	102	51	26
509	Slot4	0	\N	\N	102	51	26
510	Slot5	0	\N	\N	102	51	26
511	Slot1	0	\N	\N	103	52	26
512	Slot2	0	\N	\N	103	52	26
513	Slot3	0	\N	\N	103	52	26
514	Slot4	0	\N	\N	103	52	26
515	Slot5	0	\N	\N	103	52	26
516	Slot1	0	\N	\N	104	52	26
517	Slot2	0	\N	\N	104	52	26
518	Slot3	0	\N	\N	104	52	26
519	Slot4	0	\N	\N	104	52	26
520	Slot5	0	\N	\N	104	52	26
521	Slot1	0	\N	\N	105	53	27
522	Slot2	0	\N	\N	105	53	27
523	Slot3	0	\N	\N	105	53	27
524	Slot4	0	\N	\N	105	53	27
525	Slot5	0	\N	\N	105	53	27
526	Slot1	0	\N	\N	106	53	27
527	Slot2	0	\N	\N	106	53	27
528	Slot3	0	\N	\N	106	53	27
529	Slot4	0	\N	\N	106	53	27
530	Slot5	0	\N	\N	106	53	27
531	Slot1	0	\N	\N	107	54	27
532	Slot2	0	\N	\N	107	54	27
533	Slot3	0	\N	\N	107	54	27
534	Slot4	0	\N	\N	107	54	27
535	Slot5	0	\N	\N	107	54	27
536	Slot1	0	\N	\N	108	54	27
537	Slot2	0	\N	\N	108	54	27
538	Slot3	0	\N	\N	108	54	27
539	Slot4	0	\N	\N	108	54	27
540	Slot5	0	\N	\N	108	54	27
541	Slot1	0	\N	\N	109	55	28
542	Slot2	0	\N	\N	109	55	28
543	Slot3	0	\N	\N	109	55	28
544	Slot4	0	\N	\N	109	55	28
545	Slot5	0	\N	\N	109	55	28
546	Slot1	0	\N	\N	110	55	28
547	Slot2	0	\N	\N	110	55	28
548	Slot3	0	\N	\N	110	55	28
549	Slot4	0	\N	\N	110	55	28
550	Slot5	0	\N	\N	110	55	28
551	Slot1	0	\N	\N	111	56	28
552	Slot2	0	\N	\N	111	56	28
553	Slot3	0	\N	\N	111	56	28
554	Slot4	0	\N	\N	111	56	28
555	Slot5	0	\N	\N	111	56	28
556	Slot1	0	\N	\N	112	56	28
557	Slot2	0	\N	\N	112	56	28
558	Slot3	0	\N	\N	112	56	28
559	Slot4	0	\N	\N	112	56	28
560	Slot5	0	\N	\N	112	56	28
561	Slot1	0	\N	\N	113	57	29
562	Slot2	0	\N	\N	113	57	29
563	Slot3	0	\N	\N	113	57	29
564	Slot4	0	\N	\N	113	57	29
565	Slot5	0	\N	\N	113	57	29
566	Slot1	0	\N	\N	114	57	29
567	Slot2	0	\N	\N	114	57	29
568	Slot3	0	\N	\N	114	57	29
569	Slot4	0	\N	\N	114	57	29
570	Slot5	0	\N	\N	114	57	29
571	Slot1	0	\N	\N	115	58	29
572	Slot2	0	\N	\N	115	58	29
573	Slot3	0	\N	\N	115	58	29
574	Slot4	0	\N	\N	115	58	29
575	Slot5	0	\N	\N	115	58	29
576	Slot1	0	\N	\N	116	58	29
577	Slot2	0	\N	\N	116	58	29
578	Slot3	0	\N	\N	116	58	29
579	Slot4	0	\N	\N	116	58	29
580	Slot5	0	\N	\N	116	58	29
581	Slot1	0	\N	\N	117	59	30
582	Slot2	0	\N	\N	117	59	30
583	Slot3	0	\N	\N	117	59	30
584	Slot4	0	\N	\N	117	59	30
585	Slot5	0	\N	\N	117	59	30
586	Slot1	0	\N	\N	118	59	30
587	Slot2	0	\N	\N	118	59	30
588	Slot3	0	\N	\N	118	59	30
589	Slot4	0	\N	\N	118	59	30
590	Slot5	0	\N	\N	118	59	30
591	Slot1	0	\N	\N	119	60	30
592	Slot2	0	\N	\N	119	60	30
593	Slot3	0	\N	\N	119	60	30
594	Slot4	0	\N	\N	119	60	30
595	Slot5	0	\N	\N	119	60	30
596	Slot1	0	\N	\N	120	60	30
597	Slot2	0	\N	\N	120	60	30
598	Slot3	0	\N	\N	120	60	30
599	Slot4	0	\N	\N	120	60	30
600	Slot5	0	\N	\N	120	60	30
601	Slot1	0	\N	\N	121	61	31
602	Slot2	0	\N	\N	121	61	31
603	Slot3	0	\N	\N	121	61	31
604	Slot4	0	\N	\N	121	61	31
605	Slot5	0	\N	\N	121	61	31
606	Slot1	0	\N	\N	122	61	31
607	Slot2	0	\N	\N	122	61	31
608	Slot3	0	\N	\N	122	61	31
609	Slot4	0	\N	\N	122	61	31
610	Slot5	0	\N	\N	122	61	31
611	Slot1	0	\N	\N	123	62	31
612	Slot2	0	\N	\N	123	62	31
613	Slot3	0	\N	\N	123	62	31
614	Slot4	0	\N	\N	123	62	31
615	Slot5	0	\N	\N	123	62	31
616	Slot1	0	\N	\N	124	62	31
617	Slot2	0	\N	\N	124	62	31
618	Slot3	0	\N	\N	124	62	31
619	Slot4	0	\N	\N	124	62	31
620	Slot5	0	\N	\N	124	62	31
621	Slot1	0	\N	\N	125	63	32
622	Slot2	0	\N	\N	125	63	32
623	Slot3	0	\N	\N	125	63	32
624	Slot4	0	\N	\N	125	63	32
625	Slot5	0	\N	\N	125	63	32
626	Slot1	0	\N	\N	126	63	32
627	Slot2	0	\N	\N	126	63	32
628	Slot3	0	\N	\N	126	63	32
629	Slot4	0	\N	\N	126	63	32
630	Slot5	0	\N	\N	126	63	32
631	Slot1	0	\N	\N	127	64	32
632	Slot2	0	\N	\N	127	64	32
633	Slot3	0	\N	\N	127	64	32
634	Slot4	0	\N	\N	127	64	32
635	Slot5	0	\N	\N	127	64	32
636	Slot1	0	\N	\N	128	64	32
637	Slot2	0	\N	\N	128	64	32
638	Slot3	0	\N	\N	128	64	32
639	Slot4	0	\N	\N	128	64	32
640	Slot5	0	\N	\N	128	64	32
641	Slot1	0	\N	\N	129	65	33
642	Slot2	0	\N	\N	129	65	33
643	Slot3	0	\N	\N	129	65	33
644	Slot4	0	\N	\N	129	65	33
645	Slot5	0	\N	\N	129	65	33
646	Slot1	0	\N	\N	130	65	33
647	Slot2	0	\N	\N	130	65	33
648	Slot3	0	\N	\N	130	65	33
649	Slot4	0	\N	\N	130	65	33
650	Slot5	0	\N	\N	130	65	33
651	Slot1	0	\N	\N	131	66	33
652	Slot2	0	\N	\N	131	66	33
653	Slot3	0	\N	\N	131	66	33
654	Slot4	0	\N	\N	131	66	33
655	Slot5	0	\N	\N	131	66	33
656	Slot1	0	\N	\N	132	66	33
657	Slot2	0	\N	\N	132	66	33
658	Slot3	0	\N	\N	132	66	33
659	Slot4	0	\N	\N	132	66	33
660	Slot5	0	\N	\N	132	66	33
661	Slot1	0	\N	\N	133	67	34
662	Slot2	0	\N	\N	133	67	34
663	Slot3	0	\N	\N	133	67	34
664	Slot4	0	\N	\N	133	67	34
665	Slot5	0	\N	\N	133	67	34
666	Slot1	0	\N	\N	134	67	34
667	Slot2	0	\N	\N	134	67	34
668	Slot3	0	\N	\N	134	67	34
669	Slot4	0	\N	\N	134	67	34
670	Slot5	0	\N	\N	134	67	34
671	Slot1	0	\N	\N	135	68	34
672	Slot2	0	\N	\N	135	68	34
673	Slot3	0	\N	\N	135	68	34
674	Slot4	0	\N	\N	135	68	34
675	Slot5	0	\N	\N	135	68	34
676	Slot1	0	\N	\N	136	68	34
677	Slot2	0	\N	\N	136	68	34
678	Slot3	0	\N	\N	136	68	34
679	Slot4	0	\N	\N	136	68	34
680	Slot5	0	\N	\N	136	68	34
681	Slot1	0	\N	\N	137	69	35
682	Slot2	0	\N	\N	137	69	35
683	Slot3	0	\N	\N	137	69	35
684	Slot4	0	\N	\N	137	69	35
685	Slot5	0	\N	\N	137	69	35
686	Slot1	0	\N	\N	138	69	35
687	Slot2	0	\N	\N	138	69	35
688	Slot3	0	\N	\N	138	69	35
689	Slot4	0	\N	\N	138	69	35
690	Slot5	0	\N	\N	138	69	35
691	Slot1	0	\N	\N	139	70	35
692	Slot2	0	\N	\N	139	70	35
693	Slot3	0	\N	\N	139	70	35
694	Slot4	0	\N	\N	139	70	35
695	Slot5	0	\N	\N	139	70	35
696	Slot1	0	\N	\N	140	70	35
697	Slot2	0	\N	\N	140	70	35
698	Slot3	0	\N	\N	140	70	35
699	Slot4	0	\N	\N	140	70	35
700	Slot5	0	\N	\N	140	70	35
701	Slot1	0	\N	\N	141	71	36
702	Slot2	0	\N	\N	141	71	36
703	Slot3	0	\N	\N	141	71	36
704	Slot4	0	\N	\N	141	71	36
705	Slot5	0	\N	\N	141	71	36
706	Slot1	0	\N	\N	142	71	36
707	Slot2	0	\N	\N	142	71	36
708	Slot3	0	\N	\N	142	71	36
709	Slot4	0	\N	\N	142	71	36
710	Slot5	0	\N	\N	142	71	36
711	Slot1	0	\N	\N	143	72	36
712	Slot2	0	\N	\N	143	72	36
713	Slot3	0	\N	\N	143	72	36
714	Slot4	0	\N	\N	143	72	36
715	Slot5	0	\N	\N	143	72	36
716	Slot1	0	\N	\N	144	72	36
717	Slot2	0	\N	\N	144	72	36
718	Slot3	0	\N	\N	144	72	36
719	Slot4	0	\N	\N	144	72	36
720	Slot5	0	\N	\N	144	72	36
721	Slot1	0	\N	\N	145	73	37
722	Slot2	0	\N	\N	145	73	37
723	Slot3	0	\N	\N	145	73	37
724	Slot4	0	\N	\N	145	73	37
725	Slot5	0	\N	\N	145	73	37
726	Slot1	0	\N	\N	146	73	37
727	Slot2	0	\N	\N	146	73	37
728	Slot3	0	\N	\N	146	73	37
729	Slot4	0	\N	\N	146	73	37
730	Slot5	0	\N	\N	146	73	37
731	Slot1	0	\N	\N	147	74	37
732	Slot2	0	\N	\N	147	74	37
733	Slot3	0	\N	\N	147	74	37
734	Slot4	0	\N	\N	147	74	37
735	Slot5	0	\N	\N	147	74	37
736	Slot1	0	\N	\N	148	74	37
737	Slot2	0	\N	\N	148	74	37
738	Slot3	0	\N	\N	148	74	37
739	Slot4	0	\N	\N	148	74	37
740	Slot5	0	\N	\N	148	74	37
741	Slot1	0	\N	\N	149	75	38
742	Slot2	0	\N	\N	149	75	38
743	Slot3	0	\N	\N	149	75	38
744	Slot4	0	\N	\N	149	75	38
745	Slot5	0	\N	\N	149	75	38
746	Slot1	0	\N	\N	150	75	38
747	Slot2	0	\N	\N	150	75	38
748	Slot3	0	\N	\N	150	75	38
749	Slot4	0	\N	\N	150	75	38
750	Slot5	0	\N	\N	150	75	38
751	Slot1	0	\N	\N	151	76	38
752	Slot2	0	\N	\N	151	76	38
753	Slot3	0	\N	\N	151	76	38
754	Slot4	0	\N	\N	151	76	38
755	Slot5	0	\N	\N	151	76	38
756	Slot1	0	\N	\N	152	76	38
757	Slot2	0	\N	\N	152	76	38
758	Slot3	0	\N	\N	152	76	38
759	Slot4	0	\N	\N	152	76	38
760	Slot5	0	\N	\N	152	76	38
761	Slot1	0	\N	\N	153	77	39
762	Slot2	0	\N	\N	153	77	39
763	Slot3	0	\N	\N	153	77	39
764	Slot4	0	\N	\N	153	77	39
765	Slot5	0	\N	\N	153	77	39
766	Slot1	0	\N	\N	154	77	39
767	Slot2	0	\N	\N	154	77	39
768	Slot3	0	\N	\N	154	77	39
769	Slot4	0	\N	\N	154	77	39
770	Slot5	0	\N	\N	154	77	39
771	Slot1	0	\N	\N	155	78	39
772	Slot2	0	\N	\N	155	78	39
773	Slot3	0	\N	\N	155	78	39
774	Slot4	0	\N	\N	155	78	39
775	Slot5	0	\N	\N	155	78	39
776	Slot1	0	\N	\N	156	78	39
777	Slot2	0	\N	\N	156	78	39
778	Slot3	0	\N	\N	156	78	39
779	Slot4	0	\N	\N	156	78	39
780	Slot5	0	\N	\N	156	78	39
781	Slot1	0	\N	\N	157	79	40
782	Slot2	0	\N	\N	157	79	40
783	Slot3	0	\N	\N	157	79	40
784	Slot4	0	\N	\N	157	79	40
785	Slot5	0	\N	\N	157	79	40
786	Slot1	0	\N	\N	158	79	40
787	Slot2	0	\N	\N	158	79	40
788	Slot3	0	\N	\N	158	79	40
789	Slot4	0	\N	\N	158	79	40
790	Slot5	0	\N	\N	158	79	40
791	Slot1	0	\N	\N	159	80	40
792	Slot2	0	\N	\N	159	80	40
793	Slot3	0	\N	\N	159	80	40
794	Slot4	0	\N	\N	159	80	40
795	Slot5	0	\N	\N	159	80	40
796	Slot1	0	\N	\N	160	80	40
797	Slot2	0	\N	\N	160	80	40
798	Slot3	0	\N	\N	160	80	40
799	Slot4	0	\N	\N	160	80	40
800	Slot5	0	\N	\N	160	80	40
801	Slot1	0	\N	\N	161	81	41
802	Slot2	0	\N	\N	161	81	41
803	Slot3	0	\N	\N	161	81	41
804	Slot4	0	\N	\N	161	81	41
805	Slot5	0	\N	\N	161	81	41
806	Slot1	0	\N	\N	162	81	41
807	Slot2	0	\N	\N	162	81	41
808	Slot3	0	\N	\N	162	81	41
809	Slot4	0	\N	\N	162	81	41
810	Slot5	0	\N	\N	162	81	41
811	Slot1	0	\N	\N	163	82	41
812	Slot2	0	\N	\N	163	82	41
813	Slot3	0	\N	\N	163	82	41
814	Slot4	0	\N	\N	163	82	41
815	Slot5	0	\N	\N	163	82	41
816	Slot1	0	\N	\N	164	82	41
817	Slot2	0	\N	\N	164	82	41
818	Slot3	0	\N	\N	164	82	41
819	Slot4	0	\N	\N	164	82	41
820	Slot5	0	\N	\N	164	82	41
821	Slot1	0	\N	\N	165	83	42
822	Slot2	0	\N	\N	165	83	42
823	Slot3	0	\N	\N	165	83	42
824	Slot4	0	\N	\N	165	83	42
825	Slot5	0	\N	\N	165	83	42
826	Slot1	0	\N	\N	166	83	42
827	Slot2	0	\N	\N	166	83	42
828	Slot3	0	\N	\N	166	83	42
829	Slot4	0	\N	\N	166	83	42
830	Slot5	0	\N	\N	166	83	42
831	Slot1	0	\N	\N	167	84	42
832	Slot2	0	\N	\N	167	84	42
833	Slot3	0	\N	\N	167	84	42
834	Slot4	0	\N	\N	167	84	42
835	Slot5	0	\N	\N	167	84	42
836	Slot1	0	\N	\N	168	84	42
837	Slot2	0	\N	\N	168	84	42
838	Slot3	0	\N	\N	168	84	42
839	Slot4	0	\N	\N	168	84	42
840	Slot5	0	\N	\N	168	84	42
841	Slot1	0	\N	\N	169	85	43
842	Slot2	0	\N	\N	169	85	43
843	Slot3	0	\N	\N	169	85	43
844	Slot4	0	\N	\N	169	85	43
845	Slot5	0	\N	\N	169	85	43
846	Slot1	0	\N	\N	170	85	43
847	Slot2	0	\N	\N	170	85	43
848	Slot3	0	\N	\N	170	85	43
849	Slot4	0	\N	\N	170	85	43
850	Slot5	0	\N	\N	170	85	43
851	Slot1	0	\N	\N	171	86	43
852	Slot2	0	\N	\N	171	86	43
853	Slot3	0	\N	\N	171	86	43
854	Slot4	0	\N	\N	171	86	43
855	Slot5	0	\N	\N	171	86	43
856	Slot1	0	\N	\N	172	86	43
857	Slot2	0	\N	\N	172	86	43
858	Slot3	0	\N	\N	172	86	43
859	Slot4	0	\N	\N	172	86	43
860	Slot5	0	\N	\N	172	86	43
861	Slot1	0	\N	\N	173	87	44
862	Slot2	0	\N	\N	173	87	44
863	Slot3	0	\N	\N	173	87	44
864	Slot4	0	\N	\N	173	87	44
865	Slot5	0	\N	\N	173	87	44
866	Slot1	0	\N	\N	174	87	44
867	Slot2	0	\N	\N	174	87	44
868	Slot3	0	\N	\N	174	87	44
869	Slot4	0	\N	\N	174	87	44
870	Slot5	0	\N	\N	174	87	44
871	Slot1	0	\N	\N	175	88	44
872	Slot2	0	\N	\N	175	88	44
873	Slot3	0	\N	\N	175	88	44
874	Slot4	0	\N	\N	175	88	44
875	Slot5	0	\N	\N	175	88	44
876	Slot1	0	\N	\N	176	88	44
877	Slot2	0	\N	\N	176	88	44
878	Slot3	0	\N	\N	176	88	44
879	Slot4	0	\N	\N	176	88	44
880	Slot5	0	\N	\N	176	88	44
881	Slot1	0	\N	\N	177	89	45
882	Slot2	0	\N	\N	177	89	45
883	Slot3	0	\N	\N	177	89	45
884	Slot4	0	\N	\N	177	89	45
885	Slot5	0	\N	\N	177	89	45
886	Slot1	0	\N	\N	178	89	45
887	Slot2	0	\N	\N	178	89	45
888	Slot3	0	\N	\N	178	89	45
889	Slot4	0	\N	\N	178	89	45
890	Slot5	0	\N	\N	178	89	45
891	Slot1	0	\N	\N	179	90	45
892	Slot2	0	\N	\N	179	90	45
893	Slot3	0	\N	\N	179	90	45
894	Slot4	0	\N	\N	179	90	45
895	Slot5	0	\N	\N	179	90	45
896	Slot1	0	\N	\N	180	90	45
897	Slot2	0	\N	\N	180	90	45
898	Slot3	0	\N	\N	180	90	45
899	Slot4	0	\N	\N	180	90	45
900	Slot5	0	\N	\N	180	90	45
901	Slot1	0	\N	\N	181	91	46
902	Slot2	0	\N	\N	181	91	46
903	Slot3	0	\N	\N	181	91	46
904	Slot4	0	\N	\N	181	91	46
905	Slot5	0	\N	\N	181	91	46
906	Slot1	0	\N	\N	182	91	46
907	Slot2	0	\N	\N	182	91	46
908	Slot3	0	\N	\N	182	91	46
909	Slot4	0	\N	\N	182	91	46
910	Slot5	0	\N	\N	182	91	46
911	Slot1	0	\N	\N	183	92	46
912	Slot2	0	\N	\N	183	92	46
913	Slot3	0	\N	\N	183	92	46
914	Slot4	0	\N	\N	183	92	46
915	Slot5	0	\N	\N	183	92	46
916	Slot1	0	\N	\N	184	92	46
917	Slot2	0	\N	\N	184	92	46
918	Slot3	0	\N	\N	184	92	46
919	Slot4	0	\N	\N	184	92	46
920	Slot5	0	\N	\N	184	92	46
921	Slot1	0	\N	\N	185	93	47
922	Slot2	0	\N	\N	185	93	47
923	Slot3	0	\N	\N	185	93	47
924	Slot4	0	\N	\N	185	93	47
925	Slot5	0	\N	\N	185	93	47
926	Slot1	0	\N	\N	186	93	47
927	Slot2	0	\N	\N	186	93	47
928	Slot3	0	\N	\N	186	93	47
929	Slot4	0	\N	\N	186	93	47
930	Slot5	0	\N	\N	186	93	47
931	Slot1	0	\N	\N	187	94	47
932	Slot2	0	\N	\N	187	94	47
933	Slot3	0	\N	\N	187	94	47
934	Slot4	0	\N	\N	187	94	47
935	Slot5	0	\N	\N	187	94	47
936	Slot1	0	\N	\N	188	94	47
937	Slot2	0	\N	\N	188	94	47
938	Slot3	0	\N	\N	188	94	47
939	Slot4	0	\N	\N	188	94	47
940	Slot5	0	\N	\N	188	94	47
941	Slot1	0	\N	\N	189	95	48
942	Slot2	0	\N	\N	189	95	48
943	Slot3	0	\N	\N	189	95	48
944	Slot4	0	\N	\N	189	95	48
945	Slot5	0	\N	\N	189	95	48
946	Slot1	0	\N	\N	190	95	48
947	Slot2	0	\N	\N	190	95	48
948	Slot3	0	\N	\N	190	95	48
949	Slot4	0	\N	\N	190	95	48
950	Slot5	0	\N	\N	190	95	48
951	Slot1	0	\N	\N	191	96	48
952	Slot2	0	\N	\N	191	96	48
953	Slot3	0	\N	\N	191	96	48
954	Slot4	0	\N	\N	191	96	48
955	Slot5	0	\N	\N	191	96	48
956	Slot1	0	\N	\N	192	96	48
957	Slot2	0	\N	\N	192	96	48
958	Slot3	0	\N	\N	192	96	48
959	Slot4	0	\N	\N	192	96	48
960	Slot5	0	\N	\N	192	96	48
961	Slot1	0	\N	\N	193	97	49
962	Slot2	0	\N	\N	193	97	49
963	Slot3	0	\N	\N	193	97	49
964	Slot4	0	\N	\N	193	97	49
965	Slot5	0	\N	\N	193	97	49
966	Slot1	0	\N	\N	194	97	49
967	Slot2	0	\N	\N	194	97	49
968	Slot3	0	\N	\N	194	97	49
969	Slot4	0	\N	\N	194	97	49
970	Slot5	0	\N	\N	194	97	49
971	Slot1	0	\N	\N	195	98	49
972	Slot2	0	\N	\N	195	98	49
973	Slot3	0	\N	\N	195	98	49
974	Slot4	0	\N	\N	195	98	49
975	Slot5	0	\N	\N	195	98	49
976	Slot1	0	\N	\N	196	98	49
977	Slot2	0	\N	\N	196	98	49
978	Slot3	0	\N	\N	196	98	49
979	Slot4	0	\N	\N	196	98	49
980	Slot5	0	\N	\N	196	98	49
981	Slot1	0	\N	\N	197	99	50
982	Slot2	0	\N	\N	197	99	50
983	Slot3	0	\N	\N	197	99	50
984	Slot4	0	\N	\N	197	99	50
985	Slot5	0	\N	\N	197	99	50
986	Slot1	0	\N	\N	198	99	50
987	Slot2	0	\N	\N	198	99	50
988	Slot3	0	\N	\N	198	99	50
989	Slot4	0	\N	\N	198	99	50
990	Slot5	0	\N	\N	198	99	50
991	Slot1	0	\N	\N	199	100	50
992	Slot2	0	\N	\N	199	100	50
993	Slot3	0	\N	\N	199	100	50
994	Slot4	0	\N	\N	199	100	50
995	Slot5	0	\N	\N	199	100	50
996	Slot1	0	\N	\N	200	100	50
997	Slot2	0	\N	\N	200	100	50
998	Slot3	0	\N	\N	200	100	50
999	Slot4	0	\N	\N	200	100	50
1000	Slot5	0	\N	\N	200	100	50
1001	Slot1	0	\N	\N	201	101	51
1002	Slot2	0	\N	\N	201	101	51
1003	Slot3	0	\N	\N	201	101	51
1004	Slot4	0	\N	\N	201	101	51
1005	Slot5	0	\N	\N	201	101	51
1006	Slot1	0	\N	\N	202	101	51
1007	Slot2	0	\N	\N	202	101	51
1008	Slot3	0	\N	\N	202	101	51
1009	Slot4	0	\N	\N	202	101	51
1010	Slot5	0	\N	\N	202	101	51
1011	Slot1	0	\N	\N	203	102	51
1012	Slot2	0	\N	\N	203	102	51
1013	Slot3	0	\N	\N	203	102	51
1014	Slot4	0	\N	\N	203	102	51
1015	Slot5	0	\N	\N	203	102	51
1016	Slot1	0	\N	\N	204	102	51
1017	Slot2	0	\N	\N	204	102	51
1018	Slot3	0	\N	\N	204	102	51
1019	Slot4	0	\N	\N	204	102	51
1020	Slot5	0	\N	\N	204	102	51
1021	Slot1	0	\N	\N	205	103	52
1022	Slot2	0	\N	\N	205	103	52
1023	Slot3	0	\N	\N	205	103	52
1024	Slot4	0	\N	\N	205	103	52
1025	Slot5	0	\N	\N	205	103	52
1026	Slot1	0	\N	\N	206	103	52
1027	Slot2	0	\N	\N	206	103	52
1028	Slot3	0	\N	\N	206	103	52
1029	Slot4	0	\N	\N	206	103	52
1030	Slot5	0	\N	\N	206	103	52
1031	Slot1	0	\N	\N	207	104	52
1032	Slot2	0	\N	\N	207	104	52
1033	Slot3	0	\N	\N	207	104	52
1034	Slot4	0	\N	\N	207	104	52
1035	Slot5	0	\N	\N	207	104	52
1036	Slot1	0	\N	\N	208	104	52
1037	Slot2	0	\N	\N	208	104	52
1038	Slot3	0	\N	\N	208	104	52
1039	Slot4	0	\N	\N	208	104	52
1040	Slot5	0	\N	\N	208	104	52
1041	Slot1	0	\N	\N	209	105	53
1042	Slot2	0	\N	\N	209	105	53
1043	Slot3	0	\N	\N	209	105	53
1044	Slot4	0	\N	\N	209	105	53
1045	Slot5	0	\N	\N	209	105	53
1046	Slot1	0	\N	\N	210	105	53
1047	Slot2	0	\N	\N	210	105	53
1048	Slot3	0	\N	\N	210	105	53
1049	Slot4	0	\N	\N	210	105	53
1050	Slot5	0	\N	\N	210	105	53
1051	Slot1	0	\N	\N	211	106	53
1052	Slot2	0	\N	\N	211	106	53
1053	Slot3	0	\N	\N	211	106	53
1054	Slot4	0	\N	\N	211	106	53
1055	Slot5	0	\N	\N	211	106	53
1056	Slot1	0	\N	\N	212	106	53
1057	Slot2	0	\N	\N	212	106	53
1058	Slot3	0	\N	\N	212	106	53
1059	Slot4	0	\N	\N	212	106	53
1060	Slot5	0	\N	\N	212	106	53
1061	Slot1	0	\N	\N	213	107	54
1062	Slot2	0	\N	\N	213	107	54
1063	Slot3	0	\N	\N	213	107	54
1064	Slot4	0	\N	\N	213	107	54
1065	Slot5	0	\N	\N	213	107	54
1066	Slot1	0	\N	\N	214	107	54
1067	Slot2	0	\N	\N	214	107	54
1068	Slot3	0	\N	\N	214	107	54
1069	Slot4	0	\N	\N	214	107	54
1070	Slot5	0	\N	\N	214	107	54
1071	Slot1	0	\N	\N	215	108	54
1072	Slot2	0	\N	\N	215	108	54
1073	Slot3	0	\N	\N	215	108	54
1074	Slot4	0	\N	\N	215	108	54
1075	Slot5	0	\N	\N	215	108	54
1076	Slot1	0	\N	\N	216	108	54
1077	Slot2	0	\N	\N	216	108	54
1078	Slot3	0	\N	\N	216	108	54
1079	Slot4	0	\N	\N	216	108	54
1080	Slot5	0	\N	\N	216	108	54
1081	Slot1	0	\N	\N	217	109	55
1082	Slot2	0	\N	\N	217	109	55
1083	Slot3	0	\N	\N	217	109	55
1084	Slot4	0	\N	\N	217	109	55
1085	Slot5	0	\N	\N	217	109	55
1086	Slot1	0	\N	\N	218	109	55
1087	Slot2	0	\N	\N	218	109	55
1088	Slot3	0	\N	\N	218	109	55
1089	Slot4	0	\N	\N	218	109	55
1090	Slot5	0	\N	\N	218	109	55
1091	Slot1	0	\N	\N	219	110	55
1092	Slot2	0	\N	\N	219	110	55
1093	Slot3	0	\N	\N	219	110	55
1094	Slot4	0	\N	\N	219	110	55
1095	Slot5	0	\N	\N	219	110	55
1096	Slot1	0	\N	\N	220	110	55
1097	Slot2	0	\N	\N	220	110	55
1098	Slot3	0	\N	\N	220	110	55
1099	Slot4	0	\N	\N	220	110	55
1100	Slot5	0	\N	\N	220	110	55
1101	Slot1	0	\N	\N	221	111	56
1102	Slot2	0	\N	\N	221	111	56
1103	Slot3	0	\N	\N	221	111	56
1104	Slot4	0	\N	\N	221	111	56
1105	Slot5	0	\N	\N	221	111	56
1106	Slot1	0	\N	\N	222	111	56
1107	Slot2	0	\N	\N	222	111	56
1108	Slot3	0	\N	\N	222	111	56
1109	Slot4	0	\N	\N	222	111	56
1110	Slot5	0	\N	\N	222	111	56
1111	Slot1	0	\N	\N	223	112	56
1112	Slot2	0	\N	\N	223	112	56
1113	Slot3	0	\N	\N	223	112	56
1114	Slot4	0	\N	\N	223	112	56
1115	Slot5	0	\N	\N	223	112	56
1116	Slot1	0	\N	\N	224	112	56
1117	Slot2	0	\N	\N	224	112	56
1118	Slot3	0	\N	\N	224	112	56
1119	Slot4	0	\N	\N	224	112	56
1120	Slot5	0	\N	\N	224	112	56
1121	Slot1	0	\N	\N	225	113	57
1122	Slot2	0	\N	\N	225	113	57
1123	Slot3	0	\N	\N	225	113	57
1124	Slot4	0	\N	\N	225	113	57
1125	Slot5	0	\N	\N	225	113	57
1126	Slot1	0	\N	\N	226	113	57
1127	Slot2	0	\N	\N	226	113	57
1128	Slot3	0	\N	\N	226	113	57
1129	Slot4	0	\N	\N	226	113	57
1130	Slot5	0	\N	\N	226	113	57
1131	Slot1	0	\N	\N	227	114	57
1132	Slot2	0	\N	\N	227	114	57
1133	Slot3	0	\N	\N	227	114	57
1134	Slot4	0	\N	\N	227	114	57
1135	Slot5	0	\N	\N	227	114	57
1136	Slot1	0	\N	\N	228	114	57
1137	Slot2	0	\N	\N	228	114	57
1138	Slot3	0	\N	\N	228	114	57
1139	Slot4	0	\N	\N	228	114	57
1140	Slot5	0	\N	\N	228	114	57
1141	Slot1	0	\N	\N	229	115	58
1142	Slot2	0	\N	\N	229	115	58
1143	Slot3	0	\N	\N	229	115	58
1144	Slot4	0	\N	\N	229	115	58
1145	Slot5	0	\N	\N	229	115	58
1146	Slot1	0	\N	\N	230	115	58
1147	Slot2	0	\N	\N	230	115	58
1148	Slot3	0	\N	\N	230	115	58
1149	Slot4	0	\N	\N	230	115	58
1150	Slot5	0	\N	\N	230	115	58
1151	Slot1	0	\N	\N	231	116	58
1152	Slot2	0	\N	\N	231	116	58
1153	Slot3	0	\N	\N	231	116	58
1154	Slot4	0	\N	\N	231	116	58
1155	Slot5	0	\N	\N	231	116	58
1156	Slot1	0	\N	\N	232	116	58
1157	Slot2	0	\N	\N	232	116	58
1158	Slot3	0	\N	\N	232	116	58
1159	Slot4	0	\N	\N	232	116	58
1160	Slot5	0	\N	\N	232	116	58
1161	Slot1	0	\N	\N	233	117	59
1162	Slot2	0	\N	\N	233	117	59
1163	Slot3	0	\N	\N	233	117	59
1164	Slot4	0	\N	\N	233	117	59
1165	Slot5	0	\N	\N	233	117	59
1166	Slot1	0	\N	\N	234	117	59
1167	Slot2	0	\N	\N	234	117	59
1168	Slot3	0	\N	\N	234	117	59
1169	Slot4	0	\N	\N	234	117	59
1170	Slot5	0	\N	\N	234	117	59
1171	Slot1	0	\N	\N	235	118	59
1172	Slot2	0	\N	\N	235	118	59
1173	Slot3	0	\N	\N	235	118	59
1174	Slot4	0	\N	\N	235	118	59
1175	Slot5	0	\N	\N	235	118	59
1176	Slot1	0	\N	\N	236	118	59
1177	Slot2	0	\N	\N	236	118	59
1178	Slot3	0	\N	\N	236	118	59
1179	Slot4	0	\N	\N	236	118	59
1180	Slot5	0	\N	\N	236	118	59
1181	Slot1	0	\N	\N	237	119	60
1182	Slot2	0	\N	\N	237	119	60
1183	Slot3	0	\N	\N	237	119	60
1184	Slot4	0	\N	\N	237	119	60
1185	Slot5	0	\N	\N	237	119	60
1186	Slot1	0	\N	\N	238	119	60
1187	Slot2	0	\N	\N	238	119	60
1188	Slot3	0	\N	\N	238	119	60
1189	Slot4	0	\N	\N	238	119	60
1190	Slot5	0	\N	\N	238	119	60
1191	Slot1	0	\N	\N	239	120	60
1192	Slot2	0	\N	\N	239	120	60
1193	Slot3	0	\N	\N	239	120	60
1194	Slot4	0	\N	\N	239	120	60
1195	Slot5	0	\N	\N	239	120	60
1196	Slot1	0	\N	\N	240	120	60
1197	Slot2	0	\N	\N	240	120	60
1198	Slot3	0	\N	\N	240	120	60
1199	Slot4	0	\N	\N	240	120	60
1200	Slot5	0	\N	\N	240	120	60
1201	Slot1	0	\N	\N	241	121	61
1202	Slot2	0	\N	\N	241	121	61
1203	Slot3	0	\N	\N	241	121	61
1204	Slot4	0	\N	\N	241	121	61
1205	Slot5	0	\N	\N	241	121	61
1206	Slot1	0	\N	\N	242	121	61
1207	Slot2	0	\N	\N	242	121	61
1208	Slot3	0	\N	\N	242	121	61
1209	Slot4	0	\N	\N	242	121	61
1210	Slot5	0	\N	\N	242	121	61
1211	Slot1	0	\N	\N	243	122	61
1212	Slot2	0	\N	\N	243	122	61
1213	Slot3	0	\N	\N	243	122	61
1214	Slot4	0	\N	\N	243	122	61
1215	Slot5	0	\N	\N	243	122	61
1216	Slot1	0	\N	\N	244	122	61
1217	Slot2	0	\N	\N	244	122	61
1218	Slot3	0	\N	\N	244	122	61
1219	Slot4	0	\N	\N	244	122	61
1220	Slot5	0	\N	\N	244	122	61
1221	Slot1	0	\N	\N	245	123	62
1222	Slot2	0	\N	\N	245	123	62
1223	Slot3	0	\N	\N	245	123	62
1224	Slot4	0	\N	\N	245	123	62
1225	Slot5	0	\N	\N	245	123	62
1226	Slot1	0	\N	\N	246	123	62
1227	Slot2	0	\N	\N	246	123	62
1228	Slot3	0	\N	\N	246	123	62
1229	Slot4	0	\N	\N	246	123	62
1230	Slot5	0	\N	\N	246	123	62
1231	Slot1	0	\N	\N	247	124	62
1232	Slot2	0	\N	\N	247	124	62
1233	Slot3	0	\N	\N	247	124	62
1234	Slot4	0	\N	\N	247	124	62
1235	Slot5	0	\N	\N	247	124	62
1236	Slot1	0	\N	\N	248	124	62
1237	Slot2	0	\N	\N	248	124	62
1238	Slot3	0	\N	\N	248	124	62
1239	Slot4	0	\N	\N	248	124	62
1240	Slot5	0	\N	\N	248	124	62
1241	Slot1	0	\N	\N	249	125	63
1242	Slot2	0	\N	\N	249	125	63
1243	Slot3	0	\N	\N	249	125	63
1244	Slot4	0	\N	\N	249	125	63
1245	Slot5	0	\N	\N	249	125	63
1246	Slot1	0	\N	\N	250	125	63
1247	Slot2	0	\N	\N	250	125	63
1248	Slot3	0	\N	\N	250	125	63
1249	Slot4	0	\N	\N	250	125	63
1250	Slot5	0	\N	\N	250	125	63
1251	Slot1	0	\N	\N	251	126	63
1252	Slot2	0	\N	\N	251	126	63
1253	Slot3	0	\N	\N	251	126	63
1254	Slot4	0	\N	\N	251	126	63
1255	Slot5	0	\N	\N	251	126	63
1256	Slot1	0	\N	\N	252	126	63
1257	Slot2	0	\N	\N	252	126	63
1258	Slot3	0	\N	\N	252	126	63
1259	Slot4	0	\N	\N	252	126	63
1260	Slot5	0	\N	\N	252	126	63
1261	Slot1	0	\N	\N	253	127	64
1262	Slot2	0	\N	\N	253	127	64
1263	Slot3	0	\N	\N	253	127	64
1264	Slot4	0	\N	\N	253	127	64
1265	Slot5	0	\N	\N	253	127	64
1266	Slot1	0	\N	\N	254	127	64
1267	Slot2	0	\N	\N	254	127	64
1268	Slot3	0	\N	\N	254	127	64
1269	Slot4	0	\N	\N	254	127	64
1270	Slot5	0	\N	\N	254	127	64
1271	Slot1	0	\N	\N	255	128	64
1272	Slot2	0	\N	\N	255	128	64
1273	Slot3	0	\N	\N	255	128	64
1274	Slot4	0	\N	\N	255	128	64
1275	Slot5	0	\N	\N	255	128	64
1276	Slot1	0	\N	\N	256	128	64
1277	Slot2	0	\N	\N	256	128	64
1278	Slot3	0	\N	\N	256	128	64
1279	Slot4	0	\N	\N	256	128	64
1280	Slot5	0	\N	\N	256	128	64
1281	Slot1	0	\N	\N	257	129	65
1282	Slot2	0	\N	\N	257	129	65
1283	Slot3	0	\N	\N	257	129	65
1284	Slot4	0	\N	\N	257	129	65
1285	Slot5	0	\N	\N	257	129	65
1286	Slot1	0	\N	\N	258	129	65
1287	Slot2	0	\N	\N	258	129	65
1288	Slot3	0	\N	\N	258	129	65
1289	Slot4	0	\N	\N	258	129	65
1290	Slot5	0	\N	\N	258	129	65
1291	Slot1	0	\N	\N	259	130	65
1292	Slot2	0	\N	\N	259	130	65
1293	Slot3	0	\N	\N	259	130	65
1294	Slot4	0	\N	\N	259	130	65
1295	Slot5	0	\N	\N	259	130	65
1296	Slot1	0	\N	\N	260	130	65
1297	Slot2	0	\N	\N	260	130	65
1298	Slot3	0	\N	\N	260	130	65
1299	Slot4	0	\N	\N	260	130	65
1300	Slot5	0	\N	\N	260	130	65
1301	Slot1	0	\N	\N	261	131	66
1302	Slot2	0	\N	\N	261	131	66
1303	Slot3	0	\N	\N	261	131	66
1304	Slot4	0	\N	\N	261	131	66
1305	Slot5	0	\N	\N	261	131	66
1306	Slot1	0	\N	\N	262	131	66
1307	Slot2	0	\N	\N	262	131	66
1308	Slot3	0	\N	\N	262	131	66
1309	Slot4	0	\N	\N	262	131	66
1310	Slot5	0	\N	\N	262	131	66
1311	Slot1	0	\N	\N	263	132	66
1312	Slot2	0	\N	\N	263	132	66
1313	Slot3	0	\N	\N	263	132	66
1314	Slot4	0	\N	\N	263	132	66
1315	Slot5	0	\N	\N	263	132	66
1316	Slot1	0	\N	\N	264	132	66
1317	Slot2	0	\N	\N	264	132	66
1318	Slot3	0	\N	\N	264	132	66
1319	Slot4	0	\N	\N	264	132	66
1320	Slot5	0	\N	\N	264	132	66
1321	Slot1	0	\N	\N	265	133	67
1322	Slot2	0	\N	\N	265	133	67
1323	Slot3	0	\N	\N	265	133	67
1324	Slot4	0	\N	\N	265	133	67
1325	Slot5	0	\N	\N	265	133	67
1326	Slot1	0	\N	\N	266	133	67
1327	Slot2	0	\N	\N	266	133	67
1328	Slot3	0	\N	\N	266	133	67
1329	Slot4	0	\N	\N	266	133	67
1330	Slot5	0	\N	\N	266	133	67
1331	Slot1	0	\N	\N	267	134	67
1332	Slot2	0	\N	\N	267	134	67
1333	Slot3	0	\N	\N	267	134	67
1334	Slot4	0	\N	\N	267	134	67
1335	Slot5	0	\N	\N	267	134	67
1336	Slot1	0	\N	\N	268	134	67
1337	Slot2	0	\N	\N	268	134	67
1338	Slot3	0	\N	\N	268	134	67
1339	Slot4	0	\N	\N	268	134	67
1340	Slot5	0	\N	\N	268	134	67
1341	Slot1	0	\N	\N	269	135	68
1342	Slot2	0	\N	\N	269	135	68
1343	Slot3	0	\N	\N	269	135	68
1344	Slot4	0	\N	\N	269	135	68
1345	Slot5	0	\N	\N	269	135	68
1346	Slot1	0	\N	\N	270	135	68
1347	Slot2	0	\N	\N	270	135	68
1348	Slot3	0	\N	\N	270	135	68
1349	Slot4	0	\N	\N	270	135	68
1350	Slot5	0	\N	\N	270	135	68
1351	Slot1	0	\N	\N	271	136	68
1352	Slot2	0	\N	\N	271	136	68
1353	Slot3	0	\N	\N	271	136	68
1354	Slot4	0	\N	\N	271	136	68
1355	Slot5	0	\N	\N	271	136	68
1356	Slot1	0	\N	\N	272	136	68
1357	Slot2	0	\N	\N	272	136	68
1358	Slot3	0	\N	\N	272	136	68
1359	Slot4	0	\N	\N	272	136	68
1360	Slot5	0	\N	\N	272	136	68
1361	Slot1	0	\N	\N	273	137	69
1362	Slot2	0	\N	\N	273	137	69
1363	Slot3	0	\N	\N	273	137	69
1364	Slot4	0	\N	\N	273	137	69
1365	Slot5	0	\N	\N	273	137	69
1366	Slot1	0	\N	\N	274	137	69
1367	Slot2	0	\N	\N	274	137	69
1368	Slot3	0	\N	\N	274	137	69
1369	Slot4	0	\N	\N	274	137	69
1370	Slot5	0	\N	\N	274	137	69
1371	Slot1	0	\N	\N	275	138	69
1372	Slot2	0	\N	\N	275	138	69
1373	Slot3	0	\N	\N	275	138	69
1374	Slot4	0	\N	\N	275	138	69
1375	Slot5	0	\N	\N	275	138	69
1376	Slot1	0	\N	\N	276	138	69
1377	Slot2	0	\N	\N	276	138	69
1378	Slot3	0	\N	\N	276	138	69
1379	Slot4	0	\N	\N	276	138	69
1380	Slot5	0	\N	\N	276	138	69
1381	Slot1	0	\N	\N	277	139	70
1382	Slot2	0	\N	\N	277	139	70
1383	Slot3	0	\N	\N	277	139	70
1384	Slot4	0	\N	\N	277	139	70
1385	Slot5	0	\N	\N	277	139	70
1386	Slot1	0	\N	\N	278	139	70
1387	Slot2	0	\N	\N	278	139	70
1388	Slot3	0	\N	\N	278	139	70
1389	Slot4	0	\N	\N	278	139	70
1390	Slot5	0	\N	\N	278	139	70
1391	Slot1	0	\N	\N	279	140	70
1392	Slot2	0	\N	\N	279	140	70
1393	Slot3	0	\N	\N	279	140	70
1394	Slot4	0	\N	\N	279	140	70
1395	Slot5	0	\N	\N	279	140	70
1396	Slot1	0	\N	\N	280	140	70
1397	Slot2	0	\N	\N	280	140	70
1398	Slot3	0	\N	\N	280	140	70
1399	Slot4	0	\N	\N	280	140	70
1400	Slot5	0	\N	\N	280	140	70
1401	Slot1	0	\N	\N	281	141	71
1402	Slot2	0	\N	\N	281	141	71
1403	Slot3	0	\N	\N	281	141	71
1404	Slot4	0	\N	\N	281	141	71
1405	Slot5	0	\N	\N	281	141	71
1406	Slot1	0	\N	\N	282	141	71
1407	Slot2	0	\N	\N	282	141	71
1408	Slot3	0	\N	\N	282	141	71
1409	Slot4	0	\N	\N	282	141	71
1410	Slot5	0	\N	\N	282	141	71
1411	Slot1	0	\N	\N	283	142	71
1412	Slot2	0	\N	\N	283	142	71
1413	Slot3	0	\N	\N	283	142	71
1414	Slot4	0	\N	\N	283	142	71
1415	Slot5	0	\N	\N	283	142	71
1416	Slot1	0	\N	\N	284	142	71
1417	Slot2	0	\N	\N	284	142	71
1418	Slot3	0	\N	\N	284	142	71
1419	Slot4	0	\N	\N	284	142	71
1420	Slot5	0	\N	\N	284	142	71
1421	Slot1	0	\N	\N	285	143	72
1422	Slot2	0	\N	\N	285	143	72
1423	Slot3	0	\N	\N	285	143	72
1424	Slot4	0	\N	\N	285	143	72
1425	Slot5	0	\N	\N	285	143	72
1426	Slot1	0	\N	\N	286	143	72
1427	Slot2	0	\N	\N	286	143	72
1428	Slot3	0	\N	\N	286	143	72
1429	Slot4	0	\N	\N	286	143	72
1430	Slot5	0	\N	\N	286	143	72
1431	Slot1	0	\N	\N	287	144	72
1432	Slot2	0	\N	\N	287	144	72
1433	Slot3	0	\N	\N	287	144	72
1434	Slot4	0	\N	\N	287	144	72
1435	Slot5	0	\N	\N	287	144	72
1436	Slot1	0	\N	\N	288	144	72
1437	Slot2	0	\N	\N	288	144	72
1438	Slot3	0	\N	\N	288	144	72
1439	Slot4	0	\N	\N	288	144	72
1440	Slot5	0	\N	\N	288	144	72
1441	Slot1	0	\N	\N	289	145	73
1442	Slot2	0	\N	\N	289	145	73
1443	Slot3	0	\N	\N	289	145	73
1444	Slot4	0	\N	\N	289	145	73
1445	Slot5	0	\N	\N	289	145	73
1446	Slot1	0	\N	\N	290	145	73
1447	Slot2	0	\N	\N	290	145	73
1448	Slot3	0	\N	\N	290	145	73
1449	Slot4	0	\N	\N	290	145	73
1450	Slot5	0	\N	\N	290	145	73
1451	Slot1	0	\N	\N	291	146	73
1452	Slot2	0	\N	\N	291	146	73
1453	Slot3	0	\N	\N	291	146	73
1454	Slot4	0	\N	\N	291	146	73
1455	Slot5	0	\N	\N	291	146	73
1456	Slot1	0	\N	\N	292	146	73
1457	Slot2	0	\N	\N	292	146	73
1458	Slot3	0	\N	\N	292	146	73
1459	Slot4	0	\N	\N	292	146	73
1460	Slot5	0	\N	\N	292	146	73
1461	Slot1	0	\N	\N	293	147	74
1462	Slot2	0	\N	\N	293	147	74
1463	Slot3	0	\N	\N	293	147	74
1464	Slot4	0	\N	\N	293	147	74
1465	Slot5	0	\N	\N	293	147	74
1466	Slot1	0	\N	\N	294	147	74
1467	Slot2	0	\N	\N	294	147	74
1468	Slot3	0	\N	\N	294	147	74
1469	Slot4	0	\N	\N	294	147	74
1470	Slot5	0	\N	\N	294	147	74
1471	Slot1	0	\N	\N	295	148	74
1472	Slot2	0	\N	\N	295	148	74
1473	Slot3	0	\N	\N	295	148	74
1474	Slot4	0	\N	\N	295	148	74
1475	Slot5	0	\N	\N	295	148	74
1476	Slot1	0	\N	\N	296	148	74
1477	Slot2	0	\N	\N	296	148	74
1478	Slot3	0	\N	\N	296	148	74
1479	Slot4	0	\N	\N	296	148	74
1480	Slot5	0	\N	\N	296	148	74
1481	Slot1	0	\N	\N	297	149	75
1482	Slot2	0	\N	\N	297	149	75
1483	Slot3	0	\N	\N	297	149	75
1484	Slot4	0	\N	\N	297	149	75
1485	Slot5	0	\N	\N	297	149	75
1486	Slot1	0	\N	\N	298	149	75
1487	Slot2	0	\N	\N	298	149	75
1488	Slot3	0	\N	\N	298	149	75
1489	Slot4	0	\N	\N	298	149	75
1490	Slot5	0	\N	\N	298	149	75
1491	Slot1	0	\N	\N	299	150	75
1492	Slot2	0	\N	\N	299	150	75
1493	Slot3	0	\N	\N	299	150	75
1494	Slot4	0	\N	\N	299	150	75
1495	Slot5	0	\N	\N	299	150	75
1496	Slot1	0	\N	\N	300	150	75
1497	Slot2	0	\N	\N	300	150	75
1498	Slot3	0	\N	\N	300	150	75
1499	Slot4	0	\N	\N	300	150	75
1500	Slot5	0	\N	\N	300	150	75
1501	Slot1	0	\N	\N	301	151	76
1502	Slot2	0	\N	\N	301	151	76
1503	Slot3	0	\N	\N	301	151	76
1504	Slot4	0	\N	\N	301	151	76
1505	Slot5	0	\N	\N	301	151	76
1506	Slot1	0	\N	\N	302	151	76
1507	Slot2	0	\N	\N	302	151	76
1508	Slot3	0	\N	\N	302	151	76
1509	Slot4	0	\N	\N	302	151	76
1510	Slot5	0	\N	\N	302	151	76
1511	Slot1	0	\N	\N	303	152	76
1512	Slot2	0	\N	\N	303	152	76
1513	Slot3	0	\N	\N	303	152	76
1514	Slot4	0	\N	\N	303	152	76
1515	Slot5	0	\N	\N	303	152	76
1516	Slot1	0	\N	\N	304	152	76
1517	Slot2	0	\N	\N	304	152	76
1518	Slot3	0	\N	\N	304	152	76
1519	Slot4	0	\N	\N	304	152	76
1520	Slot5	0	\N	\N	304	152	76
1521	Slot1	0	\N	\N	305	153	77
1522	Slot2	0	\N	\N	305	153	77
1523	Slot3	0	\N	\N	305	153	77
1524	Slot4	0	\N	\N	305	153	77
1525	Slot5	0	\N	\N	305	153	77
1526	Slot1	0	\N	\N	306	153	77
1527	Slot2	0	\N	\N	306	153	77
1528	Slot3	0	\N	\N	306	153	77
1529	Slot4	0	\N	\N	306	153	77
1530	Slot5	0	\N	\N	306	153	77
1531	Slot1	0	\N	\N	307	154	77
1532	Slot2	0	\N	\N	307	154	77
1533	Slot3	0	\N	\N	307	154	77
1534	Slot4	0	\N	\N	307	154	77
1535	Slot5	0	\N	\N	307	154	77
1536	Slot1	0	\N	\N	308	154	77
1537	Slot2	0	\N	\N	308	154	77
1538	Slot3	0	\N	\N	308	154	77
1539	Slot4	0	\N	\N	308	154	77
1540	Slot5	0	\N	\N	308	154	77
1541	Slot1	0	\N	\N	309	155	78
1542	Slot2	0	\N	\N	309	155	78
1543	Slot3	0	\N	\N	309	155	78
1544	Slot4	0	\N	\N	309	155	78
1545	Slot5	0	\N	\N	309	155	78
1546	Slot1	0	\N	\N	310	155	78
1547	Slot2	0	\N	\N	310	155	78
1548	Slot3	0	\N	\N	310	155	78
1549	Slot4	0	\N	\N	310	155	78
1550	Slot5	0	\N	\N	310	155	78
1551	Slot1	0	\N	\N	311	156	78
1552	Slot2	0	\N	\N	311	156	78
1553	Slot3	0	\N	\N	311	156	78
1554	Slot4	0	\N	\N	311	156	78
1555	Slot5	0	\N	\N	311	156	78
1556	Slot1	0	\N	\N	312	156	78
1557	Slot2	0	\N	\N	312	156	78
1558	Slot3	0	\N	\N	312	156	78
1559	Slot4	0	\N	\N	312	156	78
1560	Slot5	0	\N	\N	312	156	78
1561	Slot1	0	\N	\N	313	157	79
1562	Slot2	0	\N	\N	313	157	79
1563	Slot3	0	\N	\N	313	157	79
1564	Slot4	0	\N	\N	313	157	79
1565	Slot5	0	\N	\N	313	157	79
1566	Slot1	0	\N	\N	314	157	79
1567	Slot2	0	\N	\N	314	157	79
1568	Slot3	0	\N	\N	314	157	79
1569	Slot4	0	\N	\N	314	157	79
1570	Slot5	0	\N	\N	314	157	79
1571	Slot1	0	\N	\N	315	158	79
1572	Slot2	0	\N	\N	315	158	79
1573	Slot3	0	\N	\N	315	158	79
1574	Slot4	0	\N	\N	315	158	79
1575	Slot5	0	\N	\N	315	158	79
1576	Slot1	0	\N	\N	316	158	79
1577	Slot2	0	\N	\N	316	158	79
1578	Slot3	0	\N	\N	316	158	79
1579	Slot4	0	\N	\N	316	158	79
1580	Slot5	0	\N	\N	316	158	79
1581	Slot1	0	\N	\N	317	159	80
1582	Slot2	0	\N	\N	317	159	80
1583	Slot3	0	\N	\N	317	159	80
1584	Slot4	0	\N	\N	317	159	80
1585	Slot5	0	\N	\N	317	159	80
1586	Slot1	0	\N	\N	318	159	80
1587	Slot2	0	\N	\N	318	159	80
1588	Slot3	0	\N	\N	318	159	80
1589	Slot4	0	\N	\N	318	159	80
1590	Slot5	0	\N	\N	318	159	80
1591	Slot1	0	\N	\N	319	160	80
1592	Slot2	0	\N	\N	319	160	80
1593	Slot3	0	\N	\N	319	160	80
1594	Slot4	0	\N	\N	319	160	80
1595	Slot5	0	\N	\N	319	160	80
1596	Slot1	0	\N	\N	320	160	80
1597	Slot2	0	\N	\N	320	160	80
1598	Slot3	0	\N	\N	320	160	80
1599	Slot4	0	\N	\N	320	160	80
1600	Slot5	0	\N	\N	320	160	80
1601	Slot1	0	\N	\N	321	161	81
1602	Slot2	0	\N	\N	321	161	81
1603	Slot3	0	\N	\N	321	161	81
1604	Slot4	0	\N	\N	321	161	81
1605	Slot5	0	\N	\N	321	161	81
1606	Slot1	0	\N	\N	322	161	81
1607	Slot2	0	\N	\N	322	161	81
1608	Slot3	0	\N	\N	322	161	81
1609	Slot4	0	\N	\N	322	161	81
1610	Slot5	0	\N	\N	322	161	81
1611	Slot1	0	\N	\N	323	162	81
1612	Slot2	0	\N	\N	323	162	81
1613	Slot3	0	\N	\N	323	162	81
1614	Slot4	0	\N	\N	323	162	81
1615	Slot5	0	\N	\N	323	162	81
1616	Slot1	0	\N	\N	324	162	81
1617	Slot2	0	\N	\N	324	162	81
1618	Slot3	0	\N	\N	324	162	81
1619	Slot4	0	\N	\N	324	162	81
1620	Slot5	0	\N	\N	324	162	81
1621	Slot1	0	\N	\N	325	163	82
1622	Slot2	0	\N	\N	325	163	82
1623	Slot3	0	\N	\N	325	163	82
1624	Slot4	0	\N	\N	325	163	82
1625	Slot5	0	\N	\N	325	163	82
1626	Slot1	0	\N	\N	326	163	82
1627	Slot2	0	\N	\N	326	163	82
1628	Slot3	0	\N	\N	326	163	82
1629	Slot4	0	\N	\N	326	163	82
1630	Slot5	0	\N	\N	326	163	82
1631	Slot1	0	\N	\N	327	164	82
1632	Slot2	0	\N	\N	327	164	82
1633	Slot3	0	\N	\N	327	164	82
1634	Slot4	0	\N	\N	327	164	82
1635	Slot5	0	\N	\N	327	164	82
1636	Slot1	0	\N	\N	328	164	82
1637	Slot2	0	\N	\N	328	164	82
1638	Slot3	0	\N	\N	328	164	82
1639	Slot4	0	\N	\N	328	164	82
1640	Slot5	0	\N	\N	328	164	82
1641	Slot1	0	\N	\N	329	165	83
1642	Slot2	0	\N	\N	329	165	83
1643	Slot3	0	\N	\N	329	165	83
1644	Slot4	0	\N	\N	329	165	83
1645	Slot5	0	\N	\N	329	165	83
1646	Slot1	0	\N	\N	330	165	83
1647	Slot2	0	\N	\N	330	165	83
1648	Slot3	0	\N	\N	330	165	83
1649	Slot4	0	\N	\N	330	165	83
1650	Slot5	0	\N	\N	330	165	83
1651	Slot1	0	\N	\N	331	166	83
1652	Slot2	0	\N	\N	331	166	83
1653	Slot3	0	\N	\N	331	166	83
1654	Slot4	0	\N	\N	331	166	83
1655	Slot5	0	\N	\N	331	166	83
1656	Slot1	0	\N	\N	332	166	83
1657	Slot2	0	\N	\N	332	166	83
1658	Slot3	0	\N	\N	332	166	83
1659	Slot4	0	\N	\N	332	166	83
1660	Slot5	0	\N	\N	332	166	83
1661	Slot1	0	\N	\N	333	167	84
1662	Slot2	0	\N	\N	333	167	84
1663	Slot3	0	\N	\N	333	167	84
1664	Slot4	0	\N	\N	333	167	84
1665	Slot5	0	\N	\N	333	167	84
1666	Slot1	0	\N	\N	334	167	84
1667	Slot2	0	\N	\N	334	167	84
1668	Slot3	0	\N	\N	334	167	84
1669	Slot4	0	\N	\N	334	167	84
1670	Slot5	0	\N	\N	334	167	84
1671	Slot1	0	\N	\N	335	168	84
1672	Slot2	0	\N	\N	335	168	84
1673	Slot3	0	\N	\N	335	168	84
1674	Slot4	0	\N	\N	335	168	84
1675	Slot5	0	\N	\N	335	168	84
1676	Slot1	0	\N	\N	336	168	84
1677	Slot2	0	\N	\N	336	168	84
1678	Slot3	0	\N	\N	336	168	84
1679	Slot4	0	\N	\N	336	168	84
1680	Slot5	0	\N	\N	336	168	84
1681	Slot1	0	\N	\N	337	169	85
1682	Slot2	0	\N	\N	337	169	85
1683	Slot3	0	\N	\N	337	169	85
1684	Slot4	0	\N	\N	337	169	85
1685	Slot5	0	\N	\N	337	169	85
1686	Slot1	0	\N	\N	338	169	85
1687	Slot2	0	\N	\N	338	169	85
1688	Slot3	0	\N	\N	338	169	85
1689	Slot4	0	\N	\N	338	169	85
1690	Slot5	0	\N	\N	338	169	85
1691	Slot1	0	\N	\N	339	170	85
1692	Slot2	0	\N	\N	339	170	85
1693	Slot3	0	\N	\N	339	170	85
1694	Slot4	0	\N	\N	339	170	85
1695	Slot5	0	\N	\N	339	170	85
1696	Slot1	0	\N	\N	340	170	85
1697	Slot2	0	\N	\N	340	170	85
1698	Slot3	0	\N	\N	340	170	85
1699	Slot4	0	\N	\N	340	170	85
1700	Slot5	0	\N	\N	340	170	85
1701	Slot1	0	\N	\N	341	171	86
1702	Slot2	0	\N	\N	341	171	86
1703	Slot3	0	\N	\N	341	171	86
1704	Slot4	0	\N	\N	341	171	86
1705	Slot5	0	\N	\N	341	171	86
1706	Slot1	0	\N	\N	342	171	86
1707	Slot2	0	\N	\N	342	171	86
1708	Slot3	0	\N	\N	342	171	86
1709	Slot4	0	\N	\N	342	171	86
1710	Slot5	0	\N	\N	342	171	86
1711	Slot1	0	\N	\N	343	172	86
1712	Slot2	0	\N	\N	343	172	86
1713	Slot3	0	\N	\N	343	172	86
1714	Slot4	0	\N	\N	343	172	86
1715	Slot5	0	\N	\N	343	172	86
1716	Slot1	0	\N	\N	344	172	86
1717	Slot2	0	\N	\N	344	172	86
1718	Slot3	0	\N	\N	344	172	86
1719	Slot4	0	\N	\N	344	172	86
1720	Slot5	0	\N	\N	344	172	86
1721	Slot1	0	\N	\N	345	173	87
1722	Slot2	0	\N	\N	345	173	87
1723	Slot3	0	\N	\N	345	173	87
1724	Slot4	0	\N	\N	345	173	87
1725	Slot5	0	\N	\N	345	173	87
1726	Slot1	0	\N	\N	346	173	87
1727	Slot2	0	\N	\N	346	173	87
1728	Slot3	0	\N	\N	346	173	87
1729	Slot4	0	\N	\N	346	173	87
1730	Slot5	0	\N	\N	346	173	87
1731	Slot1	0	\N	\N	347	174	87
1732	Slot2	0	\N	\N	347	174	87
1733	Slot3	0	\N	\N	347	174	87
1734	Slot4	0	\N	\N	347	174	87
1735	Slot5	0	\N	\N	347	174	87
1736	Slot1	0	\N	\N	348	174	87
1737	Slot2	0	\N	\N	348	174	87
1738	Slot3	0	\N	\N	348	174	87
1739	Slot4	0	\N	\N	348	174	87
1740	Slot5	0	\N	\N	348	174	87
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: parking_user
--

COPY public.users (user_id, user_name, user_email, user_password, user_phone_no, user_address, role) FROM stdin;
1	super_admin	superadmin@parking.com	scrypt:32768:8:1$hJCCJX5y0pVKJK5V$cd3063a7c4b8935af58e4617a4196540fc75b2eb1ce579c9ee2b5a3b487281bc48484072647445dce3ad83808ba816ee46ed1c9b75920731cb1f01450e9c1356	08126674126	Kalindi Kunj	super_admin
\.


--
-- Name: admin_parking_lots_id_seq; Type: SEQUENCE SET; Schema: public; Owner: parking_user
--

SELECT pg_catalog.setval('public.admin_parking_lots_id_seq', 1, false);


--
-- Name: admin_payment_ledger_id_seq; Type: SEQUENCE SET; Schema: public; Owner: parking_user
--

SELECT pg_catalog.setval('public.admin_payment_ledger_id_seq', 1, false);


--
-- Name: floors_floor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: parking_user
--

SELECT pg_catalog.setval('public.floors_floor_id_seq', 1, false);


--
-- Name: parkinglots_details_parkinglot_id_seq; Type: SEQUENCE SET; Schema: public; Owner: parking_user
--

SELECT pg_catalog.setval('public.parkinglots_details_parkinglot_id_seq', 1, false);


--
-- Name: rows_row_id_seq; Type: SEQUENCE SET; Schema: public; Owner: parking_user
--

SELECT pg_catalog.setval('public.rows_row_id_seq', 1, false);


--
-- Name: slots_slot_id_seq; Type: SEQUENCE SET; Schema: public; Owner: parking_user
--

SELECT pg_catalog.setval('public.slots_slot_id_seq', 1, false);


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: parking_user
--

SELECT pg_catalog.setval('public.users_user_id_seq', 1, true);


--
-- Name: admin_parking_lots admin_parking_lots_pkey; Type: CONSTRAINT; Schema: public; Owner: parking_user
--

ALTER TABLE ONLY public.admin_parking_lots
    ADD CONSTRAINT admin_parking_lots_pkey PRIMARY KEY (id);


--
-- Name: admin_payment_ledger admin_payment_ledger_pkey; Type: CONSTRAINT; Schema: public; Owner: parking_user
--

ALTER TABLE ONLY public.admin_payment_ledger
    ADD CONSTRAINT admin_payment_ledger_pkey PRIMARY KEY (id);


--
-- Name: alembic_version alembic_version_pkc; Type: CONSTRAINT; Schema: public; Owner: parking_user
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkc PRIMARY KEY (version_num);


--
-- Name: floors floors_pkey; Type: CONSTRAINT; Schema: public; Owner: parking_user
--

ALTER TABLE ONLY public.floors
    ADD CONSTRAINT floors_pkey PRIMARY KEY (floor_id);


--
-- Name: parking_sessions parking_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: parking_user
--

ALTER TABLE ONLY public.parking_sessions
    ADD CONSTRAINT parking_sessions_pkey PRIMARY KEY (ticket_id);


--
-- Name: parkinglots_details parkinglots_details_pkey; Type: CONSTRAINT; Schema: public; Owner: parking_user
--

ALTER TABLE ONLY public.parkinglots_details
    ADD CONSTRAINT parkinglots_details_pkey PRIMARY KEY (parkinglot_id);


--
-- Name: rows rows_pkey; Type: CONSTRAINT; Schema: public; Owner: parking_user
--

ALTER TABLE ONLY public.rows
    ADD CONSTRAINT rows_pkey PRIMARY KEY (row_id);


--
-- Name: slots slots_pkey; Type: CONSTRAINT; Schema: public; Owner: parking_user
--

ALTER TABLE ONLY public.slots
    ADD CONSTRAINT slots_pkey PRIMARY KEY (slot_id);


--
-- Name: admin_payment_ledger uix_admin_date; Type: CONSTRAINT; Schema: public; Owner: parking_user
--

ALTER TABLE ONLY public.admin_payment_ledger
    ADD CONSTRAINT uix_admin_date UNIQUE (admin_id, date);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: parking_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: users users_user_email_key; Type: CONSTRAINT; Schema: public; Owner: parking_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_user_email_key UNIQUE (user_email);


--
-- Name: users users_user_phone_no_key; Type: CONSTRAINT; Schema: public; Owner: parking_user
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_user_phone_no_key UNIQUE (user_phone_no);


--
-- Name: admin_parking_lots admin_parking_lots_admin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: parking_user
--

ALTER TABLE ONLY public.admin_parking_lots
    ADD CONSTRAINT admin_parking_lots_admin_id_fkey FOREIGN KEY (admin_id) REFERENCES public.users(user_id);


--
-- Name: admin_parking_lots admin_parking_lots_parking_lot_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: parking_user
--

ALTER TABLE ONLY public.admin_parking_lots
    ADD CONSTRAINT admin_parking_lots_parking_lot_id_fkey FOREIGN KEY (parking_lot_id) REFERENCES public.parkinglots_details(parkinglot_id);


--
-- Name: admin_payment_ledger admin_payment_ledger_admin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: parking_user
--

ALTER TABLE ONLY public.admin_payment_ledger
    ADD CONSTRAINT admin_payment_ledger_admin_id_fkey FOREIGN KEY (admin_id) REFERENCES public.users(user_id);


--
-- Name: floors floors_parkinglot_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: parking_user
--

ALTER TABLE ONLY public.floors
    ADD CONSTRAINT floors_parkinglot_id_fkey FOREIGN KEY (parkinglot_id) REFERENCES public.parkinglots_details(parkinglot_id);


--
-- Name: parking_sessions parking_sessions_slot_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: parking_user
--

ALTER TABLE ONLY public.parking_sessions
    ADD CONSTRAINT parking_sessions_slot_id_fkey FOREIGN KEY (slot_id) REFERENCES public.slots(slot_id);


--
-- Name: parking_sessions parking_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: parking_user
--

ALTER TABLE ONLY public.parking_sessions
    ADD CONSTRAINT parking_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id);


--
-- Name: rows rows_floor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: parking_user
--

ALTER TABLE ONLY public.rows
    ADD CONSTRAINT rows_floor_id_fkey FOREIGN KEY (floor_id) REFERENCES public.floors(floor_id);


--
-- Name: slots slots_row_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: parking_user
--

ALTER TABLE ONLY public.slots
    ADD CONSTRAINT slots_row_id_fkey FOREIGN KEY (row_id) REFERENCES public.rows(row_id);


--
-- PostgreSQL database dump complete
--

\unrestrict 4hLS7MjC662FxiIUqNUqVVSMMna9JW0Mn6khTRxMcEe6ZGchm5Ra2XgaOrFYbkG

