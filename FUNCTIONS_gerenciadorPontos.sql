-- FUNCTIONS

SET GLOBAL log_bin_trust_function_creators = 1;
USE gerenciador_pontos;

DROP FUNCTION IF EXISTS fn_valida_email;
DELIMITER $$
	CREATE FUNCTION `fn_valida_email` (email VARCHAR(100)) RETURNS TINYINT
    BEGIN
		DECLARE retorno_email TINYINT DEFAULT 0;
        IF (email REGEXP '(^[a-z0-9._%-]+@[a-z0-9.-]+\.[a-z]{2,4}$)')
			THEN SET retorno_email  = 1;
        END IF;
        RETURN return_email;
    END$$
DELIMITER ;

-- EVENTO/TEMPORADA NÃO PODE TER A DATA INICIAL MAIOR QUE A FINAL
DROP FUNCTION IF EXISTS fn_valida_espaco_tempo;
DELIMITER $$
	CREATE FUNCTION `fn_valida_espaco_tempo` (started_at TIMESTAMP, ended_at TIMESTAMP) RETURNS TINYINT
    BEGIN
		DECLARE return_date TINYINT DEFAULT 1;
        IF (ended_at >= started_at)
			THEN SET return_date  = 0;
        END IF;
        RETURN return_date;
    END$$
DELIMITER ;

-- UM MEMBRO NÂO PODE ESTAR PRESENTE EM DOIS EVENTOS SIMULTANEOS ( QUE AS DATA DE SOBREPONHAM)
DROP FUNCTION IF EXISTS fn_presenca_unica_evento;
DELIMITER $$
	CREATE FUNCTION `fn_presenca_unica_evento` (old_envent_started_at TIMESTAMP, old_event_ended_at TIMESTAMP, new_envent_started_at TIMESTAMP, new_event_ended_at TIMESTAMP) RETURNS TINYINT
    BEGIN
		DECLARE return_event_member TINYINT DEFAULT 0;
        --  new event    |             |
        --  old event    |          |
        
        --  new event      |             |
        --  old event    |          |
        IF ( new_envent_started_at <= old_envent_ended_at ) THEN
			IF( new_envent_started_at >= old_envent_started_at) THEN
				SET return_event_member = 0;
            END IF;
        END IF;
		--  new event    |         |
        --  old event      |          |
        
        --  new event      |         |
        --  old event                |          |
        IF ( new_event_ended_at <= old_envent_ended_at ) THEN
			IF( new_event_ended_at >= old_envent_started_at) THEN
				SET return_event_member = 0;
            END IF;
        END IF;
        --  new event          |     |
        --  old event        |          |
        
        --  new event      |          |
        --  old event      |          |
        IF ( (new_envent_started_at <= old_event_ended_at) AND (new_event_ended_at >= old_envent_started_at) ) THEN
				SET return_event_member = 0;
        END IF;
        --  new event      |              |
        --  old event        |          |
        IF ( new_envent_started_at <= old_envent_started_at ) THEN
			IF( new_event_ended_at >= old_event_ended_at) THEN
				SET return_event_member = 0;
            END IF;
        END IF;
        
        RETURN return_event_member;
    END$$
DELIMITER ;