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

-- SELECT sp_aggregate_path_total();
DROP TABLE TMP_PATH_TOTALS;

CREATE TABLE TMP_PATH_TOTALS
(
  VHOST_ID               INTEGER,
  PERIOD_ID              INTEGER,
  PATH_ID                INTEGER NULL,
  RESPONSE_COUNT         BIGINT,
  RESPONSE_BYTES         BIGINT,
  RESPONSE_BYTES_SQUARE  BIGINT,
  RESPONSE_TIME          BIGINT,
  RESPONSE_TIME_SQUARE   BIGINT
);

CREATE UNIQUE INDEX TPT_VHOST_PERIOD_PATH ON TMP_PATH_TOTALS(PATH_ID, VHOST_ID, PERIOD_ID);



CREATE OR REPLACE FUNCTION sp_aggregate_path_total() RETURNS void AS $$
BEGIN
    RAISE NOTICE 'Clearing temp table';
    
    TRUNCATE TABLE TMP_PATH_TOTALS;
    
    RAISE NOTICE 'Group totals for this batch';
    
    INSERT INTO TMP_PATH_TOTALS 
    (
      PATH_ID, VHOST_ID, PERIOD_ID, 
      RESPONSE_COUNT, 
      RESPONSE_BYTES, RESPONSE_BYTES_SQUARE, 
      RESPONSE_TIME, RESPONSE_TIME_SQUARE
    )
    SELECT 
      PATH_ID,
      VHOST_ID,
      PERIOD_ID,
      COUNT(DURATION),
      SUM(BYTECOUNT),
      SUM(CAST(BYTECOUNT AS BIGINT) * CAST(BYTECOUNT AS BIGINT)),
      SUM(DURATION),
      SUM(DURATION * DURATION)
    FROM
      RAW_LINES
    WHERE
      METHOD = 'GET'
    GROUP BY
      PATH_ID, -- Most selective column first
      VHOST_ID,
      PERIOD_ID;
      
    RAISE NOTICE 'Finding missing entries in main table for this batch';
      
    -- Put any missing lines in (alternative syntaxes were considered, but this is 10x faster!)
    INSERT INTO PATH_TOTALS 
    (
    VHOST_ID, PERIOD_ID, PATH_ID, 
    RESPONSE_COUNT, 
    RESPONSE_BYTES, RESPONSE_BYTES_SQUARE, 
    RESPONSE_TIME, RESPONSE_TIME_SQUARE
    )
    SELECT
    TPT.VHOST_ID, TPT.PERIOD_ID, TPT.PATH_ID, 0, 0, 0, 0, 0
    FROM TMP_PATH_TOTALS TPT 
    LEFT OUTER JOIN PATH_TOTALS PT ON 
    (
            TPT.PATH_ID = PT.PATH_ID 
        AND TPT.VHOST_ID = PT.VHOST_ID
        AND TPT.PERIOD_ID = PT.PERIOD_ID
    )
    WHERE PT.ID IS NULL;
    
    RAISE NOTICE 'Coalescing values back into main table';
    
    -- Now coalesce the new values in
    UPDATE PATH_TOTALS PT
    SET 
      RESPONSE_COUNT = PT.RESPONSE_COUNT + TPT.RESPONSE_COUNT,
      RESPONSE_BYTES = PT.RESPONSE_BYTES + TPT.RESPONSE_BYTES,
      RESPONSE_BYTES_SQUARE = PT.RESPONSE_BYTES_SQUARE + TPT.RESPONSE_BYTES_SQUARE,
      RESPONSE_TIME = PT.RESPONSE_TIME + TPT.RESPONSE_TIME,
      RESPONSE_TIME_SQUARE = PT.RESPONSE_TIME_SQUARE + TPT.RESPONSE_TIME_SQUARE
    FROM TMP_PATH_TOTALS TPT
    WHERE PT.VHOST_ID = TPT.VHOST_ID
      AND PT.PERIOD_ID = TPT.PERIOD_ID
      AND PT.PATH_ID = TPT.PATH_ID;
END;
$$ LANGUAGE plpgsql;