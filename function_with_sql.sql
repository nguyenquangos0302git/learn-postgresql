-- function with sql (query language function)
CREATE OR REPLACE FUNCTION fn_sum(p1 INTEGER, p2 INTEGER) 
RETURNS INTEGER
AS
'
	SELECT p1 + p2;
' LANGUAGE SQL;

SELECT fn_sum(1, 2);

-- dollar quoting
CREATE OR REPLACE FUNCTION fn_sum_with_dollar_quoting_1(p1 INTEGER, p2 INTEGER)
RETURNS INTEGER
AS 
$$
	SELECT p1 + p2;
$$ LANGUAGE SQL;

CREATE OR REPLACE FUNCTION fn_sum_with_dollar_quoting_2(p1 INTEGER, p2 INTEGER)
RETURNS INTEGER
AS 
$body$
	SELECT p1 + p2;
$body$ LANGUAGE SQL;

SELECT fn_sum_with_dollar_quoting_1(1, 2);
SELECT fn_sum_with_dollar_quoting_2(1, 2);

-- returns void (no value)

