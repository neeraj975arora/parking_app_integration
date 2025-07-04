--
-- PostgreSQL database dump
--

-- Dumped from database version 17.4
-- Dumped by pg_dump version 17.4

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
-- Name: floors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.floors (
    parkinglot_id integer NOT NULL,
    floor_id integer NOT NULL,
    floor_name character varying(50) NOT NULL
);


ALTER TABLE public.floors OWNER TO postgres;

--
-- Name: parking_sessions; Type: TABLE; Schema: public; Owner: postgres
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
    duration_hrs numeric GENERATED ALWAYS AS (round((EXTRACT(epoch FROM (end_time - start_time)) / 3600.0), 1)) STORED
);


ALTER TABLE public.parking_sessions OWNER TO postgres;

--
-- Name: parkinglots_details; Type: TABLE; Schema: public; Owner: postgres
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


ALTER TABLE public.parkinglots_details OWNER TO postgres;

--
-- Name: rows; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rows (
    parkinglot_id integer NOT NULL,
    floor_id integer NOT NULL,
    row_id integer NOT NULL,
    row_name character varying(50) NOT NULL
);


ALTER TABLE public.rows OWNER TO postgres;

--
-- Name: slots; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.slots (
    parkinglot_id integer NOT NULL,
    floor_id integer NOT NULL,
    row_id integer NOT NULL,
    slot_id integer NOT NULL,
    slot_name character varying(50) NOT NULL,
    status integer DEFAULT 0,
    vehicle_reg_no character varying(20),
    ticket_id character varying(50),
    CONSTRAINT slots_occupied_check CHECK ((((status = 1) AND (vehicle_reg_no IS NOT NULL) AND (ticket_id IS NOT NULL)) OR ((status = 0) AND (vehicle_reg_no IS NULL) AND (ticket_id IS NULL)))),
    CONSTRAINT slots_status_check CHECK ((status = ANY (ARRAY[0, 1])))
);


ALTER TABLE public.slots OWNER TO postgres;

--
-- Name: users_user_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_user_id_seq OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    user_id integer DEFAULT nextval('public.users_user_id_seq'::regclass) NOT NULL,
    user_name character varying(100) NOT NULL,
    user_email character varying(100) NOT NULL,
    user_password character varying(100) NOT NULL,
    user_phone_no character varying(15) NOT NULL,
    user_address text
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Data for Name: floors; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.floors (parkinglot_id, floor_id, floor_name) FROM stdin;
1	1	1st floor
1	2	2nd floor
1	3	3rd floor
1	4	4th floor
1	5	5th floor
2	1	1st floor
2	2	2nd floor
2	3	3rd floor
2	4	4th floor
2	5	5th floor
\.


--
-- Data for Name: parking_sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.parking_sessions (ticket_id, parkinglot_id, floor_id, row_id, slot_id, vehicle_reg_no, user_id, start_time, end_time) FROM stdin;
\.


--
-- Data for Name: parkinglots_details; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.parkinglots_details (parkinglot_id, parking_name, city, landmark, address, latitude, longitude, physical_appearance, parking_ownership, parking_surface, has_cctv, has_boom_barrier, ticket_generated, entry_exit_gates, weekly_off, parking_timing, vehicle_types, car_capacity, available_car_slots, two_wheeler_capacity, available_two_wheeler_slots, parking_type, payment_modes, car_parking_charge, two_wheeler_parking_charge, allows_prepaid_passes, provides_valet_services, value_added_services) FROM stdin;
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
1	Jahangirpuri - Metro Authorised Parking	New Delhi	Jahangirpuri	Jahangir puri metro, Patking agency- m/s manoj computer	28.72542191	77.16333008	Open - Covered bounderies	Govt - Subcontracted	Cemented	No	yes	Stand Alone printer	Multi gates for Entry as well as Exit	Open All Days	06:00:00 AM - 11:00:00 PM	Car, 2 Weelers	200	200	500	500	Paid	Cash	20 up to 6 hours, 30 for 12 hours	10 up to 6 hours, 15 up to 12	Monthly Pass	No	No
\.


--
-- Data for Name: rows; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rows (parkinglot_id, floor_id, row_id, row_name) FROM stdin;
1	1	1	A row
1	1	2	B row
1	2	1	A row
1	2	2	B row
1	3	1	A row
1	3	2	B row
1	4	1	A row
1	4	2	B row
1	5	1	A row
1	5	2	B row
2	1	1	A row
2	1	2	B row
2	2	1	A row
2	2	2	B row
2	3	1	A row
2	3	2	B row
2	4	1	A row
2	4	2	B row
2	5	1	A row
2	5	2	B row
\.


--
-- Data for Name: slots; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.slots (parkinglot_id, floor_id, row_id, slot_id, slot_name, status, vehicle_reg_no, ticket_id) FROM stdin;
1	1	1	2	A2	0	\N	\N
1	1	1	3	A3	0	\N	\N
1	1	1	1	A1	0	\N	\N
1	1	1	4	A4	0	\N	\N
1	1	1	5	A5	0	\N	\N
1	1	1	7	A7	0	\N	\N
1	1	1	6	A6	0	\N	\N
1	1	1	8	A8	0	\N	\N
1	1	1	9	A9	0	\N	\N
1	1	1	10	A10	0	\N	\N
1	1	1	11	A11	0	\N	\N
1	1	1	12	A12	0	\N	\N
1	1	1	13	A13	0	\N	\N
1	1	1	14	A14	0	\N	\N
1	1	1	15	A15	0	\N	\N
1	1	1	16	A16	0	\N	\N
1	1	1	17	A17	0	\N	\N
1	1	1	18	A18	0	\N	\N
1	1	1	19	A19	0	\N	\N
1	1	1	20	A20	0	\N	\N
1	1	2	1	B1	0	\N	\N
1	1	2	2	B2	0	\N	\N
1	1	2	3	B3	0	\N	\N
1	1	2	4	B4	0	\N	\N
1	1	2	5	B5	0	\N	\N
1	1	2	6	B6	0	\N	\N
1	1	2	7	B7	0	\N	\N
1	1	2	8	B8	0	\N	\N
1	1	2	9	B9	0	\N	\N
1	1	2	10	B10	0	\N	\N
1	1	2	11	B11	0	\N	\N
1	1	2	12	B12	0	\N	\N
1	1	2	13	B13	0	\N	\N
1	1	2	14	B14	0	\N	\N
1	1	2	15	B15	0	\N	\N
1	1	2	16	B16	0	\N	\N
1	1	2	17	B17	0	\N	\N
1	1	2	18	B18	0	\N	\N
1	1	2	19	B19	0	\N	\N
1	1	2	20	B20	0	\N	\N
1	2	1	1	A1	0	\N	\N
1	2	1	2	A2	0	\N	\N
1	2	1	3	A3	0	\N	\N
1	2	1	4	A4	0	\N	\N
1	2	1	5	A5	0	\N	\N
1	2	1	6	A6	0	\N	\N
1	2	1	7	A7	0	\N	\N
1	2	1	8	A8	0	\N	\N
1	2	1	9	A9	0	\N	\N
1	2	1	10	A10	0	\N	\N
1	2	1	11	A11	0	\N	\N
1	2	1	12	A12	0	\N	\N
1	2	1	13	A13	0	\N	\N
1	2	1	14	A14	0	\N	\N
1	2	1	15	A15	0	\N	\N
1	2	1	16	A16	0	\N	\N
1	2	1	17	A17	0	\N	\N
1	2	1	18	A18	0	\N	\N
1	2	1	19	A19	0	\N	\N
1	2	1	20	A20	0	\N	\N
1	2	2	1	B1	0	\N	\N
1	2	2	2	B2	0	\N	\N
1	2	2	3	B3	0	\N	\N
1	2	2	4	B4	0	\N	\N
1	2	2	5	B5	0	\N	\N
1	2	2	6	B6	0	\N	\N
1	2	2	7	B7	0	\N	\N
1	2	2	8	B8	0	\N	\N
1	2	2	9	B9	0	\N	\N
1	2	2	10	B10	0	\N	\N
1	2	2	11	B11	0	\N	\N
1	2	2	12	B12	0	\N	\N
1	2	2	13	B13	0	\N	\N
1	2	2	14	B14	0	\N	\N
1	2	2	15	B15	0	\N	\N
1	2	2	16	B16	0	\N	\N
1	2	2	17	B17	0	\N	\N
1	2	2	18	B18	0	\N	\N
1	2	2	19	B19	0	\N	\N
1	2	2	20	B20	0	\N	\N
1	3	1	1	A1	0	\N	\N
1	3	1	2	A2	0	\N	\N
1	3	1	3	A3	0	\N	\N
1	3	1	4	A4	0	\N	\N
1	3	1	5	A5	0	\N	\N
1	3	1	6	A6	0	\N	\N
1	3	1	7	A7	0	\N	\N
1	3	1	8	A8	0	\N	\N
1	3	1	9	A9	0	\N	\N
1	3	1	10	A10	0	\N	\N
1	3	1	11	A11	0	\N	\N
1	3	1	12	A12	0	\N	\N
1	3	1	13	A13	0	\N	\N
1	3	1	14	A14	0	\N	\N
1	3	1	15	A15	0	\N	\N
1	3	1	16	A16	0	\N	\N
1	3	1	17	A17	0	\N	\N
1	3	1	18	A18	0	\N	\N
1	3	1	19	A19	0	\N	\N
1	3	1	20	A20	0	\N	\N
1	3	2	1	B1	0	\N	\N
1	3	2	2	B2	0	\N	\N
1	3	2	3	B3	0	\N	\N
1	3	2	4	B4	0	\N	\N
1	3	2	5	B5	0	\N	\N
1	3	2	6	B6	0	\N	\N
1	3	2	7	B7	0	\N	\N
1	3	2	8	B8	0	\N	\N
1	3	2	9	B9	0	\N	\N
1	3	2	10	B10	0	\N	\N
1	3	2	11	B11	0	\N	\N
1	3	2	12	B12	0	\N	\N
1	3	2	13	B13	0	\N	\N
1	3	2	14	B14	0	\N	\N
1	3	2	15	B15	0	\N	\N
1	3	2	16	B16	0	\N	\N
1	3	2	17	B17	0	\N	\N
1	3	2	18	B18	0	\N	\N
1	3	2	19	B19	0	\N	\N
1	3	2	20	B20	0	\N	\N
1	4	1	1	A1	0	\N	\N
1	4	1	2	A2	0	\N	\N
1	4	1	3	A3	0	\N	\N
1	4	1	4	A4	0	\N	\N
1	4	1	5	A5	0	\N	\N
1	4	1	6	A6	0	\N	\N
1	4	1	7	A7	0	\N	\N
1	4	1	8	A8	0	\N	\N
1	4	1	9	A9	0	\N	\N
1	4	1	10	A10	0	\N	\N
1	4	1	11	A11	0	\N	\N
1	4	1	12	A12	0	\N	\N
1	4	1	13	A13	0	\N	\N
1	4	1	14	A14	0	\N	\N
1	4	1	15	A15	0	\N	\N
1	4	1	16	A16	0	\N	\N
1	4	1	17	A17	0	\N	\N
1	4	1	18	A18	0	\N	\N
1	4	1	19	A19	0	\N	\N
1	4	1	20	A20	0	\N	\N
1	4	2	1	B1	0	\N	\N
1	4	2	2	B2	0	\N	\N
1	4	2	3	B3	0	\N	\N
1	4	2	4	B4	0	\N	\N
1	4	2	5	B5	0	\N	\N
1	4	2	6	B6	0	\N	\N
1	4	2	7	B7	0	\N	\N
1	4	2	8	B8	0	\N	\N
1	4	2	9	B9	0	\N	\N
1	4	2	10	B10	0	\N	\N
1	4	2	11	B11	0	\N	\N
1	4	2	12	B12	0	\N	\N
1	4	2	13	B13	0	\N	\N
1	4	2	14	B14	0	\N	\N
1	4	2	15	B15	0	\N	\N
1	4	2	16	B16	0	\N	\N
1	4	2	17	B17	0	\N	\N
1	4	2	18	B18	0	\N	\N
1	4	2	19	B19	0	\N	\N
1	4	2	20	B20	0	\N	\N
1	5	1	1	A1	0	\N	\N
1	5	1	2	A2	0	\N	\N
1	5	1	3	A3	0	\N	\N
1	5	1	4	A4	0	\N	\N
1	5	1	5	A5	0	\N	\N
1	5	1	6	A6	0	\N	\N
1	5	1	7	A7	0	\N	\N
1	5	1	8	A8	0	\N	\N
1	5	1	9	A9	0	\N	\N
1	5	1	10	A10	0	\N	\N
1	5	1	11	A11	0	\N	\N
1	5	1	12	A12	0	\N	\N
1	5	1	13	A13	0	\N	\N
1	5	1	14	A14	0	\N	\N
1	5	1	15	A15	0	\N	\N
1	5	1	16	A16	0	\N	\N
1	5	1	17	A17	0	\N	\N
1	5	1	18	A18	0	\N	\N
1	5	1	19	A19	0	\N	\N
1	5	1	20	A20	0	\N	\N
1	5	2	1	B1	0	\N	\N
1	5	2	2	B2	0	\N	\N
1	5	2	3	B3	0	\N	\N
1	5	2	4	B4	0	\N	\N
1	5	2	5	B5	0	\N	\N
1	5	2	6	B6	0	\N	\N
1	5	2	7	B7	0	\N	\N
1	5	2	8	B8	0	\N	\N
1	5	2	9	B9	0	\N	\N
1	5	2	10	B10	0	\N	\N
1	5	2	11	B11	0	\N	\N
1	5	2	12	B12	0	\N	\N
1	5	2	13	B13	0	\N	\N
1	5	2	14	B14	0	\N	\N
1	5	2	15	B15	0	\N	\N
1	5	2	16	B16	0	\N	\N
1	5	2	17	B17	0	\N	\N
1	5	2	18	B18	0	\N	\N
1	5	2	19	B19	0	\N	\N
1	5	2	20	B20	0	\N	\N
2	1	1	1	A1	0	\N	\N
2	1	1	2	A2	0	\N	\N
2	1	1	3	A3	0	\N	\N
2	1	1	4	A4	0	\N	\N
2	1	1	5	A5	0	\N	\N
2	1	1	6	A6	0	\N	\N
2	1	1	7	A7	0	\N	\N
2	1	1	8	A8	0	\N	\N
2	1	1	9	A9	0	\N	\N
2	1	1	10	A10	0	\N	\N
2	1	1	11	A11	0	\N	\N
2	1	1	12	A12	0	\N	\N
2	1	1	13	A13	0	\N	\N
2	1	1	14	A14	0	\N	\N
2	1	1	15	A15	0	\N	\N
2	1	1	16	A16	0	\N	\N
2	1	1	17	A17	0	\N	\N
2	1	1	18	A18	0	\N	\N
2	1	1	19	A19	0	\N	\N
2	1	1	20	A20	0	\N	\N
2	1	2	1	B1	0	\N	\N
2	1	2	2	B2	0	\N	\N
2	1	2	3	B3	0	\N	\N
2	1	2	4	B4	0	\N	\N
2	1	2	5	B5	0	\N	\N
2	1	2	6	B6	0	\N	\N
2	1	2	7	B7	0	\N	\N
2	1	2	8	B8	0	\N	\N
2	1	2	9	B9	0	\N	\N
2	1	2	10	B10	0	\N	\N
2	1	2	11	B11	0	\N	\N
2	1	2	12	B12	0	\N	\N
2	1	2	13	B13	0	\N	\N
2	1	2	14	B14	0	\N	\N
2	1	2	15	B15	0	\N	\N
2	1	2	16	B16	0	\N	\N
2	1	2	17	B17	0	\N	\N
2	1	2	18	B18	0	\N	\N
2	1	2	19	B19	0	\N	\N
2	1	2	20	B20	0	\N	\N
2	2	1	1	A1	0	\N	\N
2	2	1	2	A2	0	\N	\N
2	2	1	3	A3	0	\N	\N
2	2	1	4	A4	0	\N	\N
2	2	1	5	A5	0	\N	\N
2	2	1	6	A6	0	\N	\N
2	2	1	7	A7	0	\N	\N
2	2	1	8	A8	0	\N	\N
2	2	1	9	A9	0	\N	\N
2	2	1	10	A10	0	\N	\N
2	2	1	11	A11	0	\N	\N
2	2	1	12	A12	0	\N	\N
2	2	1	13	A13	0	\N	\N
2	2	1	14	A14	0	\N	\N
2	2	1	15	A15	0	\N	\N
2	2	1	16	A16	0	\N	\N
2	2	1	17	A17	0	\N	\N
2	2	1	18	A18	0	\N	\N
2	2	1	19	A19	0	\N	\N
2	2	1	20	A20	0	\N	\N
2	2	2	1	B1	0	\N	\N
2	2	2	2	B2	0	\N	\N
2	2	2	3	B3	0	\N	\N
2	2	2	4	B4	0	\N	\N
2	2	2	5	B5	0	\N	\N
2	2	2	6	B6	0	\N	\N
2	2	2	7	B7	0	\N	\N
2	2	2	8	B8	0	\N	\N
2	2	2	9	B9	0	\N	\N
2	2	2	10	B10	0	\N	\N
2	2	2	11	B11	0	\N	\N
2	2	2	12	B12	0	\N	\N
2	2	2	13	B13	0	\N	\N
2	2	2	14	B14	0	\N	\N
2	2	2	15	B15	0	\N	\N
2	2	2	16	B16	0	\N	\N
2	2	2	17	B17	0	\N	\N
2	2	2	18	B18	0	\N	\N
2	2	2	19	B19	0	\N	\N
2	2	2	20	B20	0	\N	\N
2	3	1	1	A1	0	\N	\N
2	3	1	2	A2	0	\N	\N
2	3	1	3	A3	0	\N	\N
2	3	1	4	A4	0	\N	\N
2	3	1	5	A5	0	\N	\N
2	3	1	6	A6	0	\N	\N
2	3	1	7	A7	0	\N	\N
2	3	1	8	A8	0	\N	\N
2	3	1	9	A9	0	\N	\N
2	3	1	10	A10	0	\N	\N
2	3	1	11	A11	0	\N	\N
2	3	1	12	A12	0	\N	\N
2	3	1	13	A13	0	\N	\N
2	3	1	14	A14	0	\N	\N
2	3	1	15	A15	0	\N	\N
2	3	1	16	A16	0	\N	\N
2	3	1	17	A17	0	\N	\N
2	3	1	18	A18	0	\N	\N
2	3	1	19	A19	0	\N	\N
2	3	1	20	A20	0	\N	\N
2	3	2	1	B1	0	\N	\N
2	3	2	2	B2	0	\N	\N
2	3	2	3	B3	0	\N	\N
2	3	2	4	B4	0	\N	\N
2	3	2	5	B5	0	\N	\N
2	3	2	6	B6	0	\N	\N
2	3	2	7	B7	0	\N	\N
2	3	2	8	B8	0	\N	\N
2	3	2	9	B9	0	\N	\N
2	3	2	10	B10	0	\N	\N
2	3	2	11	B11	0	\N	\N
2	3	2	12	B12	0	\N	\N
2	3	2	13	B13	0	\N	\N
2	3	2	14	B14	0	\N	\N
2	3	2	15	B15	0	\N	\N
2	3	2	16	B16	0	\N	\N
2	3	2	17	B17	0	\N	\N
2	3	2	18	B18	0	\N	\N
2	3	2	19	B19	0	\N	\N
2	3	2	20	B20	0	\N	\N
2	4	1	1	A1	0	\N	\N
2	4	1	2	A2	0	\N	\N
2	4	1	3	A3	0	\N	\N
2	4	1	4	A4	0	\N	\N
2	4	1	5	A5	0	\N	\N
2	4	1	6	A6	0	\N	\N
2	4	1	7	A7	0	\N	\N
2	4	1	8	A8	0	\N	\N
2	4	1	9	A9	0	\N	\N
2	4	1	10	A10	0	\N	\N
2	4	1	11	A11	0	\N	\N
2	4	1	12	A12	0	\N	\N
2	4	1	13	A13	0	\N	\N
2	4	1	14	A14	0	\N	\N
2	4	1	15	A15	0	\N	\N
2	4	1	16	A16	0	\N	\N
2	4	1	17	A17	0	\N	\N
2	4	1	18	A18	0	\N	\N
2	4	1	19	A19	0	\N	\N
2	4	1	20	A20	0	\N	\N
2	4	2	1	B1	0	\N	\N
2	4	2	2	B2	0	\N	\N
2	4	2	3	B3	0	\N	\N
2	4	2	4	B4	0	\N	\N
2	4	2	5	B5	0	\N	\N
2	4	2	6	B6	0	\N	\N
2	4	2	7	B7	0	\N	\N
2	4	2	8	B8	0	\N	\N
2	4	2	9	B9	0	\N	\N
2	4	2	10	B10	0	\N	\N
2	4	2	11	B11	0	\N	\N
2	4	2	12	B12	0	\N	\N
2	4	2	13	B13	0	\N	\N
2	4	2	14	B14	0	\N	\N
2	4	2	15	B15	0	\N	\N
2	4	2	16	B16	0	\N	\N
2	4	2	17	B17	0	\N	\N
2	4	2	18	B18	0	\N	\N
2	4	2	19	B19	0	\N	\N
2	4	2	20	B20	0	\N	\N
2	5	1	1	A1	0	\N	\N
2	5	1	2	A2	0	\N	\N
2	5	1	3	A3	0	\N	\N
2	5	1	4	A4	0	\N	\N
2	5	1	5	A5	0	\N	\N
2	5	1	6	A6	0	\N	\N
2	5	1	7	A7	0	\N	\N
2	5	1	8	A8	0	\N	\N
2	5	1	9	A9	0	\N	\N
2	5	1	10	A10	0	\N	\N
2	5	1	11	A11	0	\N	\N
2	5	1	12	A12	0	\N	\N
2	5	1	13	A13	0	\N	\N
2	5	1	14	A14	0	\N	\N
2	5	1	15	A15	0	\N	\N
2	5	1	16	A16	0	\N	\N
2	5	1	17	A17	0	\N	\N
2	5	1	18	A18	0	\N	\N
2	5	1	19	A19	0	\N	\N
2	5	1	20	A20	0	\N	\N
2	5	2	1	B1	0	\N	\N
2	5	2	2	B2	0	\N	\N
2	5	2	3	B3	0	\N	\N
2	5	2	4	B4	0	\N	\N
2	5	2	5	B5	0	\N	\N
2	5	2	6	B6	0	\N	\N
2	5	2	7	B7	0	\N	\N
2	5	2	8	B8	0	\N	\N
2	5	2	9	B9	0	\N	\N
2	5	2	10	B10	0	\N	\N
2	5	2	11	B11	0	\N	\N
2	5	2	12	B12	0	\N	\N
2	5	2	13	B13	0	\N	\N
2	5	2	14	B14	0	\N	\N
2	5	2	15	B15	0	\N	\N
2	5	2	16	B16	0	\N	\N
2	5	2	17	B17	0	\N	\N
2	5	2	18	B18	0	\N	\N
2	5	2	19	B19	0	\N	\N
2	5	2	20	B20	0	\N	\N
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (user_id, user_name, user_email, user_password, user_phone_no, user_address) FROM stdin;
1	Alice Sharma	alice.sharma@example.com	secret123	9876543210	123 MG Road, Delhi
2	Bob Gupta	bob.gupta@example.org	pa55word	9123456789	Flat 5B, Indira Nagar, Lucknow
3	Chitra Rao	chitra.rao@domain.co	qwertyui	9988776655	22 Green Park, Bangalore
4	Deepak Singh	deepak.singh@xyz.net	letmein1	9011223344	9 Rose Villa, Pune
5	Elena Iyer	elena.iyer@abc.in	passw0rd	9456123780	Apartment 12, Chennai
6	Farhan Akhtar	farhan.akhtar@mail.com	mysecure	9900112233	Villa No.7, Jaipur
7	Gita Patil	gita.patil@site.org	hello1234	9765432101	Block C, Kolkata
8	Harish Kumar	harish.kumar@web.com	admin456	9876501234	Sector 15, Gurgaon
9	Isha Mehta	isha.mehta@mail.co	sunshine	9123004567	Plot 8, Noida
10	Jayant Rai	jayant.rai@alpha.com	iloveSQL	9800114455	House 101, Hyderabad
\.


--
-- Name: users_user_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_user_id_seq', 12, true);


--
-- Name: floors floors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.floors
    ADD CONSTRAINT floors_pkey PRIMARY KEY (parkinglot_id, floor_id);


--
-- Name: parkinglots_details parking_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parkinglots_details
    ADD CONSTRAINT parking_data_pkey PRIMARY KEY (parkinglot_id);


--
-- Name: parking_sessions parking_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parking_sessions
    ADD CONSTRAINT parking_sessions_pkey PRIMARY KEY (ticket_id);


--
-- Name: rows rows_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rows
    ADD CONSTRAINT rows_pkey PRIMARY KEY (parkinglot_id, floor_id, row_id);


--
-- Name: slots slots_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slots
    ADD CONSTRAINT slots_pkey PRIMARY KEY (parkinglot_id, floor_id, row_id, slot_id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: users users_user_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_user_email_key UNIQUE (user_email);


--
-- Name: users users_user_phone_no_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_user_phone_no_key UNIQUE (user_phone_no);


--
-- Name: floors floors_parkinglot_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.floors
    ADD CONSTRAINT floors_parkinglot_id_fkey FOREIGN KEY (parkinglot_id) REFERENCES public.parkinglots_details(parkinglot_id);


--
-- Name: parking_sessions parking_sessions_parkinglot_id_floor_id_row_id_slot_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parking_sessions
    ADD CONSTRAINT parking_sessions_parkinglot_id_floor_id_row_id_slot_id_fkey FOREIGN KEY (parkinglot_id, floor_id, row_id, slot_id) REFERENCES public.slots(parkinglot_id, floor_id, row_id, slot_id);


--
-- Name: parking_sessions parking_sessions_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.parking_sessions
    ADD CONSTRAINT parking_sessions_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id);


--
-- Name: rows rows_parkinglot_id_floor_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rows
    ADD CONSTRAINT rows_parkinglot_id_floor_id_fkey FOREIGN KEY (parkinglot_id, floor_id) REFERENCES public.floors(parkinglot_id, floor_id);


--
-- Name: slots slots_parkinglot_id_floor_id_row_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.slots
    ADD CONSTRAINT slots_parkinglot_id_floor_id_row_id_fkey FOREIGN KEY (parkinglot_id, floor_id, row_id) REFERENCES public.rows(parkinglot_id, floor_id, row_id);


--
-- PostgreSQL database dump complete
--

