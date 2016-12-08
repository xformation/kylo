SET SQL_MODE='ALLOW_INVALID_DATES';
use thinkbig;
delimiter //

create procedure alter_job_execution_dt()

begin


IF NOT EXISTS(SELECT table_name
            FROM INFORMATION_SCHEMA.COLUMNS
           WHERE table_schema = 'thinkbig'
             AND table_name = 'BATCH_JOB_EXECUTION' and column_name = 'START_YEAR') then
/**
Add the new columns
 */
ALTER TABLE BATCH_JOB_EXECUTION
ADD COLUMN `START_TIME_MILLIS` BIGINT NULL COMMENT '' AFTER `JOB_CONFIGURATION_LOCATION`,
ADD COLUMN `END_TIME_MILLIS` BIGINT NULL COMMENT '' AFTER `START_TIME_MILLIS`,
ADD COLUMN `CREATE_TIME_MILLIS` BIGINT NULL COMMENT '' AFTER `END_TIME_MILLIS`,
ADD COLUMN `LAST_UPDATED_MILLIS` BIGINT NULL COMMENT '' AFTER `CREATE_TIME_MILLIS`,
ADD COLUMN `START_YEAR` INT NULL COMMENT '' AFTER `LAST_UPDATED`,
ADD COLUMN `START_MONTH` INT NULL COMMENT '' AFTER `START_YEAR`,
ADD COLUMN `START_DAY` INT NULL COMMENT '' AFTER `START_MONTH`,
ADD COLUMN `END_YEAR` INT NULL COMMENT '' AFTER `START_DAY`,
ADD COLUMN `END_MONTH` INT NULL COMMENT '' AFTER `END_YEAR`,
ADD COLUMN `END_DAY` INT NULL COMMENT '' AFTER `END_MONTH`;


/**
only update if the type of START_TIME is a datetime
**/
UPDATE BATCH_JOB_EXECUTION
SET START_TIME_MILLIS = (UNIX_TIMESTAMP(START_TIME)*1000),
END_TIME_MILLIS = (UNIX_TIMESTAMP(END_TIME)*1000),
CREATE_TIME_MILLIS = (UNIX_TIMESTAMP(CREATE_TIME)*1000),
LAST_UPDATED_MILLIS = (UNIX_TIMESTAMP(LAST_UPDATED)*1000),
START_YEAR = YEAR(START_TIME),
START_MONTH = MONTH(START_TIME),
START_DAY = DAY(START_TIME),
END_YEAR = YEAR(END_TIME),
END_MONTH = MONTH(END_TIME),
END_DAY = DAY(END_TIME);


/**
Store off the previous datetime values for future reference if needed
 */
ALTER TABLE BATCH_JOB_EXECUTION
CHANGE COLUMN `CREATE_TIME` `CREATE_TIME_X` DATETIME NULL COMMENT '' ,
CHANGE COLUMN `START_TIME` `START_TIME_X` DATETIME NULL DEFAULT NULL COMMENT '' ,
CHANGE COLUMN `END_TIME` `END_TIME_X` DATETIME NULL DEFAULT NULL COMMENT '' ,
CHANGE COLUMN `LAST_UPDATED` `LAST_UPDATED_X` DATETIME NULL DEFAULT NULL COMMENT '' ;

/**
Move the _MILLIS to the correct column
 */
ALTER TABLE `thinkbig`.`BATCH_JOB_EXECUTION`
CHANGE COLUMN `CREATE_TIME_MILLIS` `CREATE_TIME` BIGINT NOT NULL COMMENT '' ,
CHANGE COLUMN `START_TIME_MILLIS` `START_TIME` BIGINT NULL DEFAULT NULL COMMENT '' ,
CHANGE COLUMN `END_TIME_MILLIS` `END_TIME` BIGINT NULL DEFAULT NULL COMMENT '' ,
CHANGE COLUMN `LAST_UPDATED_MILLIS` `LAST_UPDATED` BIGINT NULL DEFAULT NULL COMMENT '' ;


END IF;


IF NOT EXISTS(SELECT table_name
            FROM INFORMATION_SCHEMA.COLUMNS
           WHERE table_schema = 'thinkbig'
             AND table_name = 'BATCH_STEP_EXECUTION' and column_name = 'START_TIME' and LOWER(data_type) = 'bigint') then

ALTER TABLE BATCH_STEP_EXECUTION
ADD COLUMN `START_TIME_MILLIS` BIGINT NULL COMMENT '' AFTER `LAST_UPDATED`,
ADD COLUMN `END_TIME_MILLIS` BIGINT NULL COMMENT '' AFTER `START_TIME_MILLIS`,
ADD COLUMN `LAST_UPDATED_MILLIS` BIGINT NULL COMMENT '' AFTER `END_TIME_MILLIS`;

/**
only update if the type of START_TIME is a datetime
**/
UPDATE BATCH_STEP_EXECUTION
SET START_TIME_MILLIS = (UNIX_TIMESTAMP(START_TIME)*1000),
END_TIME_MILLIS = (UNIX_TIMESTAMP(END_TIME)*1000),
LAST_UPDATED_MILLIS = (UNIX_TIMESTAMP(LAST_UPDATED)*1000);

ALTER TABLE BATCH_STEP_EXECUTION
CHANGE COLUMN `START_TIME` `START_TIME_X` DATETIME NULL DEFAULT NULL COMMENT '' ,
CHANGE COLUMN `END_TIME` `END_TIME_X` DATETIME NULL DEFAULT NULL COMMENT '' ,
CHANGE COLUMN `LAST_UPDATED` `LAST_UPDATED_X` DATETIME NULL DEFAULT NULL COMMENT '' ;

ALTER TABLE BATCH_STEP_EXECUTION
CHANGE COLUMN `START_TIME_MILLIS` `START_TIME` BIGINT NULL DEFAULT NULL COMMENT '' ,
CHANGE COLUMN `END_TIME_MILLIS` `END_TIME` BIGINT NULL DEFAULT NULL COMMENT '' ,
CHANGE COLUMN `LAST_UPDATED_MILLIS` `LAST_UPDATED` BIGINT NULL DEFAULT NULL COMMENT '' ;


END IF;




END//

-- Execute the procedure
call alter_job_execution_dt();

-- Drop the procedure
drop procedure alter_job_execution_dt;



