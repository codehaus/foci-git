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

-- Looks up the path_id for each path in raw_lines
CREATE OR REPLACE FUNCTION sp_normalize_path() RETURNS void AS $$
BEGIN
    SET SORT_MEM = '1GB'; -- Improves join performance

    --BEGIN TRANSACTION;;
    LOCK TABLE RAW_LINES IN EXCLUSIVE MODE NOWAIT;


    RAISE NOTICE 'Clearing PATH_ID';
    -- Clear existing path - typically they will be NULL anyway
    UPDATE RAW_LINES
    SET PATH_ID = NULL
    WHERE PATH_ID IS NOT NULL;
    
    RAISE NOTICE 'Clearing paths for non path checking hosts';

    -- Note: VHosts must have already been done for this to work properly
    UPDATE RAW_LINES RL
    SET PATH_NORMALIZED = ''
    FROM VHOSTS VH
    WHERE RL.VHOST_ID = VH.ID
      AND VH.AGGREGATE_PATHS <> TRUE;

    RAISE NOTICE 'Clearing paths for unsuccessful requests';

    -- Don't track requests that aren't successful (other modules will track 404s etc separately)
    UPDATE RAW_LINES
    SET PATH_NORMALIZED = ''
    WHERE STATUS NOT BETWEEN 200 AND 399
      AND PATH_NORMALIZED IS NULL;

    RAISE NOTICE 'Copying normalized paths';
    
    -- Copy across the value for all others
    UPDATE RAW_LINES
    SET PATH_NORMALIZED = LOWER(PATH)
    WHERE PATH_NORMALIZED IS NULL;
    
    RAISE NOTICE 'Looking up paths';

    -- Update blanks
    UPDATE RAW_LINES RL
       SET PATH_ID = P.ID
      FROM PATHS P
     WHERE RL.PATH_NORMALIZED = P.PATH
       AND RL.PATH_NORMALIZED = ''
       AND P.PATH = '';

    -- Update all existing paths
    UPDATE RAW_LINES RL
       SET PATH_ID = P.ID
      FROM PATHS P
     WHERE RL.PATH_NORMALIZED = P.PATH
       AND RL.PATH_NORMALIZED <> '';
    
    -- UPDATE RAW_LINES RL
    -- SET PATH_ID = (SELECT P.ID FROM PATHS P WHERE RL.PATH_NORMALIZED = P.PATH)
    
    RAISE NOTICE 'Creating missing paths';
    -- Create the missing paths
    INSERT INTO PATHS (PATH)
    SELECT PATH_NORMALIZED
    FROM RAW_LINES 
    WHERE PATH_ID IS NULL 
      AND STATUS BETWEEN 200 AND 399
      AND PATH_NORMALIZED IS NOT NULL
    GROUP BY PATH_NORMALIZED;

    RAISE NOTICE 'Lookup up paths (phase 2)';
    
    -- Now update the missing ones
    UPDATE RAW_LINES RL
    SET PATH_ID = P.ID
    FROM PATHS P
    WHERE RL.PATH_NORMALIZED = P.PATH
      AND RL.PATH_ID IS NULL;
    
    COMMIT TRANSACTION;

    RAISE NOTICE 'Complete';
    
    RETURN;
END;
$$ LANGUAGE plpgsql;
