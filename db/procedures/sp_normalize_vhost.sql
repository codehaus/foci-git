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

-- Looks up the subnet_id for each subnet in raw_lines
CREATE OR REPLACE FUNCTION sp_normalize_vhost() RETURNS void AS $$
BEGIN
    -- Clear existing values - typically they will be NULL anyway
    UPDATE RAW_LINES
    SET VHOST_ID = NULL
    WHERE VHOST_ID IS NOT NULL;

    -- Update all existing subnets
    UPDATE RAW_LINES
    SET VHOST_ID = V.ID
    FROM VHOSTS V
    WHERE RAW_LINES.HOST = V.HOST;

    -- Create the missing subnets
    INSERT INTO VHOSTS (HOST)
    SELECT DISTINCT 
      HOST
    FROM RAW_LINES WHERE VHOST_ID IS NULL;

    -- Now update the missing ones
    UPDATE RAW_LINES
    SET VHOST_ID = V.ID
    FROM VHOSTS V
    WHERE RAW_LINES.HOST = V.HOST
      AND RAW_LINES.VHOST_ID IS NULL;
    
    RETURN;
END;
$$ LANGUAGE plpgsql;