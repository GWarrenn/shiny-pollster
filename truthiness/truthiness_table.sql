-- Description: Creating SQL tables to store truthiness data
-- Author: August Warren
-- Run: 

CREATE TABLE truthiness (

	date date, 
	name character varying(50),
	ruling character varying(100),
	party character varying(25),
	url character varying(200),
	subject character varying(50),
	statement_text character varying(250),

	constraint truthiness_pkey primary key (date,name,ruling,party,subject)

);

