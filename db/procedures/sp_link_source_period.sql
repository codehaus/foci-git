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
DROP TABLE TMP_SOURCE_PERIODS;

-- We don't worry about indexes because we're only likely to have 1 or 2 records in the table at any one point
CREATE TABLE TMP_SOURCE_PERIODS (
  SOURCE_ID INTEGER NOT NULL,
  PERIOD_ID INTEGER NOT NULL,
  LINE_COUNT INTEGER NOT NULL
);


-- Looks up the period_id for each datetime in raw_lines
CREATE OR REPLACE FUNCTION sp_link_source_period() RETURNS void AS $$
BEGIN
    TRUNCATE TABLE TMP_SOURCE_PERIODS;
    
    RAISE NOTICE 'Calculating new SOURCE_PERIODS totals';
    
    INSERT INTO TMP_SOURCE_PERIODS (SOURCE_ID, PERIOD_ID, LINE_COUNT)
    SELECT SOURCE_ID, PERIOD_ID, COUNT(*) FROM RAW_LINES
    GROUP BY SOURCE_ID, PERIOD_ID;
    
    RAISE NOTICE 'Creating new SOURCE_PERIODS entries';

    INSERT INTO SOURCE_PERIODS (SOURCE_ID, PERIOD_ID, LINE_COUNT)
    SELECT SOURCE_ID, PERIOD_ID, 0 FROM TMP_SOURCE_PERIODS TSP
    WHERE NOT EXISTS (SELECT * FROM SOURCE_PERIODS SP WHERE SP.SOURCE_ID = TSP.SOURCE_ID AND SP.PERIOD_ID = TSP.PERIOD_ID);

    RAISE NOTICE 'Updating SOURCE_PERIODS totals';
    -- Now coalesce the line counts in
    UPDATE SOURCE_PERIODS SP
    SET 
      LINE_COUNT = SP.LINE_COUNT + TSP.LINE_COUNT
    FROM TMP_SOURCE_PERIODS TSP
    WHERE SP.SOURCE_ID = TSP.SOURCE_ID
    AND SP.PERIOD_ID = TSP.PERIOD_ID;
    
    RETURN;
END;
$$ LANGUAGE plpgsql;