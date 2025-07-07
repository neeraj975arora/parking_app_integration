CREATE TABLE "ParkingLotDetails" (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    address character varying(255) NOT NULL,
    zip_code character varying(10) NOT NULL,
    city character varying(50) NOT NULL,
    state character varying(50) NOT NULL,
    country character varying(50) NOT NULL,
    phone_number character varying(15) NOT NULL,
    opening_time time without time zone,
    closing_time time without time zone,
    total_floors integer,
    total_rows integer,
    total_slots integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "Users" (
    id integer NOT NULL,
    first_name character varying(50),
    last_name character varying(50),
    username character varying(50) NOT NULL,
    email character varying(100) NOT NULL,
    password character varying(255) NOT NULL,
    role character varying(20) DEFAULT 'user'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "Floor" (
    id integer NOT NULL,
    parking_lot_id integer,
    floor_number integer,
    total_rows integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "Row" (
    id integer NOT NULL,
    floor_id integer,
    row_name character varying(50),
    total_slots integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE "Slot" (
    id integer NOT NULL,
    row_id integer,
    slot_number character varying(50),
    status character varying(20) DEFAULT 'free'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE ONLY "Floor"
    ADD CONSTRAINT "Floor_pkey" PRIMARY KEY (id);

ALTER TABLE ONLY "ParkingLotDetails"
    ADD CONSTRAINT "ParkingLotDetails_pkey" PRIMARY KEY (id);

ALTER TABLE ONLY "Row"
    ADD CONSTRAINT "Row_pkey" PRIMARY KEY (id);

ALTER TABLE ONLY "Slot"
    ADD CONSTRAINT "Slot_pkey" PRIMARY KEY (id);

ALTER TABLE ONLY "Users"
    ADD CONSTRAINT "Users_pkey" PRIMARY KEY (id);

ALTER TABLE ONLY "Floor"
    ADD CONSTRAINT "Floor_parking_lot_id_fkey" FOREIGN KEY (parking_lot_id) REFERENCES "ParkingLotDetails"(id);

ALTER TABLE ONLY "Row"
    ADD CONSTRAINT "Row_floor_id_fkey" FOREIGN KEY (floor_id) REFERENCES "Floor"(id);

ALTER TABLE ONLY "Slot"
    ADD CONSTRAINT "Slot_row_id_fkey" FOREIGN KEY (row_id) REFERENCES "Row"(id);