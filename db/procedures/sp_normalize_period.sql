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

-- Looks up the period_id for each datetime in raw_lines
CREATE OR REPLACE FUNCTION sp_normalize_period() RETURNS void AS $$
DECLARE
  PERIOD_DURATION CONSTANT INTEGER := 86400;
BEGIN
    -- Clear existing values - typically they will be NULL anyway
    RAISE NOTICE 'Clear period_id';
    UPDATE RAW_LINES
    SET PERIOD_ID = NULL
    WHERE PERIOD_ID IS NOT NULL;

    RAISE NOTICE 'Set period_id (pass 1)';
    -- Update existing periods
    UPDATE RAW_LINES RL
    SET PERIOD_ID = P.ID
    FROM PERIODS P
    WHERE RL.DATETIME >= P.START AND RL.DATETIME <= P.FINISH;

    RAISE NOTICE 'Create missing periods';
    -- Create missing periods
    INSERT INTO PERIODS (NAME, START, FINISH, DURATION)
    SELECT DISTINCT
      CAST(CAST(DATETIME AS DATE) AS VARCHAR),
      CAST(DATETIME AS DATE),
      CAST(DATETIME AS DATE) + INTERVAL '1 DAY' - INTERVAL '1 MILLISECOND',
      PERIOD_DURATION
    FROM
      RAW_LINES
    WHERE 
      PERIOD_ID IS NULL;

    RAISE NOTICE 'Set period_id (pass 2)';
    -- Update all missed periods
    UPDATE RAW_LINES RL
    SET PERIOD_ID = P.ID
    FROM PERIODS P
    WHERE RL.DATETIME BETWEEN P.START AND P.FINISH
    AND RL.PERIOD_ID IS NULL;

    RAISE NOTICE 'Complete';
    RETURN;
END;
$$ LANGUAGE plpgsql;