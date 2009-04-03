--------------------------------------------------------------------------------
--  Copyright 2007-2008 Codehaus Foundation
--
--  Licensed under the Apache License, Version 2.0 (the "License");
--  you may not use this file except in compliance with the License.
--  You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
--  Unless required by applicable law or agreed to in writing, software
--  distributed under the License is distributed on an "AS IS" BASIS,
--  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--  See the License for the specific language governing permissions and
--  limitations under the License.
--------------------------------------------------------------------------------

DROP TABLE TMP_SUBNET_TOTALS;

CREATE TABLE TMP_SUBNET_TOTALS
(
  VHOST_ID               INTEGER,
  PERIOD_ID              INTEGER,
  SUBNET                 CIDR,
  RESPONSE_COUNT         BIGINT,
  RESPONSE_BYTES         BIGINT,
  RESPONSE_BYTES_SQUARE  BIGINT
);

CREATE INDEX TMP_SUBNET_TOTALS_SUBNET_PERIOD_VHOST ON TMP_SUBNET_TOTALS(SUBNET, PERIOD_ID, VHOST_ID);
CREATE INDEX TMP_SUBNET_TOTALS_PERIOD_VHOST_SUBNET ON TMP_SUBNET_TOTALS(PERIOD_ID, VHOST_ID, SUBNET);


CREATE OR REPLACE FUNCTION sp_aggregate_subnet_total() RETURNS void AS $$
BEGIN
    TRUNCATE TABLE TMP_SUBNET_TOTALS;
    
    INSERT INTO TMP_SUBNET_TOTALS (VHOST_ID, PERIOD_ID, SUBNET, RESPONSE_COUNT, RESPONSE_BYTES, RESPONSE_BYTES_SQUARE)
    SELECT 
      VHOST_ID,
      PERIOD_ID,
      SUBNET,
      COUNT(BYTECOUNT),
      SUM(BYTECOUNT),
      SUM(CAST(BYTECOUNT AS BIGINT) * CAST(BYTECOUNT AS BIGINT))
    FROM
      RAW_LINES
    WHERE
          METHOD = 'GET'
      AND SUBNET IS NOT NULL
    GROUP BY
      VHOST_ID,
      PERIOD_ID,
      SUBNET;
      
    -- Put any missing lines in
    INSERT INTO SUBNET_TOTALS (VHOST_ID, PERIOD_ID, SUBNET, RESPONSE_COUNT, RESPONSE_BYTES, RESPONSE_BYTES_SQUARE)
    SELECT
      VHOST_ID, PERIOD_ID, SUBNET, 0, 0, 0
    FROM
      TMP_SUBNET_TOTALS TST
    WHERE NOT EXISTS (
        SELECT * 
        FROM SUBNET_TOTALS ST
        WHERE ST.VHOST_ID = TST.VHOST_ID
          AND ST.PERIOD_ID = TST.PERIOD_ID
          AND ST.SUBNET = TST.SUBNET
    );
    
    -- Now coalesce the new values in
    UPDATE SUBNET_TOTALS
    SET 
      RESPONSE_COUNT = SUBNET_TOTALS.RESPONSE_COUNT + TST.RESPONSE_COUNT,
      RESPONSE_BYTES = SUBNET_TOTALS.RESPONSE_BYTES + TST.RESPONSE_BYTES,
      RESPONSE_BYTES_SQUARE = SUBNET_TOTALS.RESPONSE_BYTES_SQUARE + TST.RESPONSE_BYTES_SQUARE
    FROM TMP_SUBNET_TOTALS TST
    WHERE SUBNET_TOTALS.VHOST_ID = TST.VHOST_ID
    AND SUBNET_TOTALS.PERIOD_ID = TST.PERIOD_ID
    AND SUBNET_TOTALS.SUBNET = TST.SUBNET;
END;
$$ LANGUAGE plpgsql;