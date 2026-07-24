-- ============================================================
-- Setup completo de la base de datos Zazzacrifice
-- Genera el esquema 'zazzacrifice' con tablas, triggers, vistas y datos de prueba.
-- Cargar con un cliente que soporte DELIMITER (mysql CLI, TablePlus, DBeaver, MySQL Workbench).
-- Ej:  mysql -h <host> -P <port> -u <user> -p < WEB/Backend_api/db_setup.sql
-- ============================================================

-- ---------- 1) TABLAS ----------
DROP SCHEMA IF EXISTS zazzacrifice;
CREATE SCHEMA zazzacrifice;
USE zazzacrifice;


CREATE TABLE users (
user_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT UNIQUE,
username VARCHAR(30) NOT NULL UNIQUE,
password VARCHAR(30) NOT NULL,
created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE game_sessions (
game_session_id  INT UNSIGNED PRIMARY KEY AUTO_INCREMENT UNIQUE,
user_id INT UNSIGNED NOT NULL,
time_on_seconds INT UNSIGNED NOT NULL DEFAULT 0,
finished BIT NOT NULL DEFAULT 0,
created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
FOREIGN KEY (user_id) REFERENCES users(user_id) ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
 

CREATE TABLE stats (
stat_id TINYINT UNSIGNED PRIMARY KEY AUTO_INCREMENT UNIQUE,
name VARCHAR(10) NOT NULL UNIQUE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE classes (
class_id TINYINT UNSIGNED PRIMARY KEY AUTO_INCREMENT UNIQUE,
name VARCHAR(20) NOT NULL UNIQUE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;




CREATE TABLE scenes (
scene_id TINYINT UNSIGNED PRIMARY KEY AUTO_INCREMENT UNIQUE,
name VARCHAR(30)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE players (
player_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT UNIQUE NOT NULL,
game_session_id INT UNSIGNED NOT NULL ,
money INT UNSIGNED NOT NULL DEFAULT 0,
class_id TINYINT UNSIGNED NOT NULL ,
FOREIGN KEY (game_session_id) REFERENCES game_sessions(game_session_id) ON UPDATE CASCADE,
FOREIGN KEY (class_id) REFERENCES classes(class_id) ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE checkpoints (
checkpoint_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT UNIQUE,
player_id INT UNSIGNED NOT NULL,
scene_id TINYINT UNSIGNED NOT NULL DEFAULT 1,
x_position FLOAT NOT NULL DEFAULT -10.4,
y_position FLOAT NOT NULL DEFAULT  1.5,
created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
FOREIGN KEY (player_id) REFERENCES players(player_id) ON UPDATE CASCADE,
FOREIGN KEY (scene_id) REFERENCES scenes(scene_id) ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;




CREATE TABLE stats_players (
stat_player_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT UNIQUE,
player_id INT UNSIGNED NOT NULL,
stat_id TINYINT UNSIGNED  NOT NULL ,
value SMALLINT UNSIGNED NOT NULL,
created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
FOREIGN KEY (player_id) REFERENCES players(player_id) ON UPDATE CASCADE,
FOREIGN KEY (stat_id) REFERENCES stats(stat_id) ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



CREATE TABLE attacks (
attack_id smallint unsigned PRIMARY KEY AUTO_INCREMENT UNIQUE,
name varchar(30) UNIQUE,
description varchar(150)
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE players_attacks (
player_attack_id int unsigned PRIMARY KEY AUTO_INCREMENT UNIQUE,
player_id int unsigned not null,
attack_id smallint unsigned not null,
created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
FOREIGN KEY (attack_id) REFERENCES attacks(attack_id)ON UPDATE CASCADE,
FOREIGN KEY (player_id) REFERENCES players(player_id) ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


CREATE TABLE battles(
battle_id int unsigned PRIMARY KEY AUTO_INCREMENT UNIQUE,
player_id  INT UNSIGNED NOT NULL,
enemy VARCHAR(40) NOT NULL,
total_damage_made INT UNSIGNED DEFAULT 0 NOT NULL,
total_damage_received INT UNSIGNED DEFAULT 0 NOT NULL,
coin_received INT UNSIGNED DEFAULT 0 NOT NULL,
battle_result BIT,
attacks_missed INT UNSIGNED DEFAULT 0 NOT NULL,
critical_attacks INT UNSIGNED DEFAULT 0 NOT NULL,
created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
FOREIGN KEY (player_id) REFERENCES players(player_id)ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



CREATE TABLE battles_attacks(
battle_attack_id int unsigned PRIMARY KEY AUTO_INCREMENT UNIQUE,
battle_id INT UNSIGNED NOT NULL,
attack_id SMALLINT UNSIGNED NOT NULL,
times_used SMALLINT UNSIGNED NOT NULL, 
FOREIGN KEY (battle_id) REFERENCES battles(battle_id)ON UPDATE CASCADE,
FOREIGN KEY (attack_id) REFERENCES attacks(attack_id)ON UPDATE CASCADE
)ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
-- ---------- 2) TRIGGERS ----------
DELIMITER //
CREATE TRIGGER insert_default_checkpoint AFTER INSERT ON players
FOR EACH ROW
BEGIN
  INSERT INTO checkpoints (player_id) VALUES (NEW.player_id);
END;
 //
DELIMITER ;

DELIMITER //
CREATE TRIGGER insert_default_attacks AFTER INSERT ON players
FOR EACH ROW
BEGIN
  INSERT INTO players_attacks (player_id, attack_id) 
	VALUES 
		(NEW.player_id, 1),
    (NEW.player_id, 5),
    (NEW.player_id, 6)
						;
END;
 //
DELIMITER ;

-- ---------- 3) VISTAS ----------
USE zazzacrifice;

CREATE VIEW sessions_summary AS
SELECT u.user_id as user_id, c.name as class_name, p.money FROM users u
INNER JOIN game_sessions gs ON u.user_id = gs.user_id
INNER JOIN players p ON p.game_session_id = gs.game_session_id
INNER JOIN classes c ON c.class_id = p.class_id;

CREATE VIEW class_percentage AS 
SELECT c.name, COUNT(*) * 100.0 / (SELECT COUNT(*) FROM players) AS percentage
FROM players
INNER JOIN classes c
USING (class_id)
GROUP BY class_id;

CREATE VIEW damage_made_vs_received AS
SELECT player_id, total_damage_made, total_damage_received FROM battles
order by player_id, battle_id;

CREATE VIEW enemy_win_rate AS
SELECT enemy, battle_result, COUNT(*) AS count  
FROM battles 
GROUP BY enemy, battle_result order by enemy, battle_result;


CREATE VIEW attack_uses AS
SELECT sum(times_used)as times, attacks.name as attack  FROM battles_attacks
INNER JOIN attacks
USING (attack_id)
group by attack_id;


CREATE VIEW criticals_vs_missed AS
SELECT 
    SUM(IF(battle_result=1, critical_attacks, 0)) as critical_attacks_won,
    SUM(IF(battle_result=1, attacks_missed, 0)) as attacks_missed_won,
    SUM(IF(battle_result=0, critical_attacks, 0)) as critical_attacks_lost,
    SUM(IF(battle_result=0, attacks_missed, 0)) as attacks_missed_lost
FROM battles


-- ---------- 4) DATOS DE PRUEBA ----------
USE zazzacrifice;

#Tablas Users 
INSERT INTO users (username, password) VALUE ('Ian', 'zazza');
INSERT INTO users (username, password) VALUE ('Fran', 'shaggy');
INSERT INTO users (username, password) VALUE ('Sunday', 'berries');
INSERT INTO users (username, password) VALUE ('Tuch', 'Master');
INSERT INTO users (username, password) VALUE ('Tena', 'calistena');
INSERT INTO users (username, password) VALUE ('Rafa', 'blanga');




#Tablas estadisticas 
INSERT INTO stats (name) values ('DEF'); #id 1 
INSERT INTO stats (name) values ('ATK') ; #id 2 
INSERT INTO stats (name) values ('AGL'); #id 3 
INSERT INTO stats (name) values ('LCK') ; #id 4 
INSERT INTO stats (name) values ('CHAR') ; #id 5 
INSERT INTO stats (name) values ('ACC') ; #id 6
INSERT INTO stats (name) values ('Max_HP') ; #id 7
INSERT INTO stats (name) values ('Current_HP') ; #id 8
INSERT INTO stats (name) values ('Max_MP') ; #id 9
INSERT INTO stats (name) values ('Current_MP') ; #id 10

#Tablas Clases 
INSERT INTO classes (name) value ('Light');
INSERT INTO classes (name) value ('Medium');
INSERT INTO classes (name) value ('Heavy');



#Tablas Scenes
INSERT INTO scenes (name) VALUES 
('The Forest'),
('The Tower');


#Tablas Ataques
INSERT INTO attacks (name, description) VALUES  
('Melee Attack', 'A swift and precise attack'),
('Fire', 'A fiery spell that deals continious damage'),
('Lightning', 'A powerful bolt of lightning that doubles all stats'),
('Ice', 'A icy spell that freeces the enemys attack turn'),
('Heal', 'A restorative spell to heal damage'),
('Recharg', 'A restorative spell to recharge mana points');



#Tablas Game session 
INSERT INTO game_sessions (user_id, time_on_seconds, finished)
VALUES
(1, 3600, 1),
(2, 1800, 0),
(3, 5400, 1),
(4, 7200, 1),
(5, 7200,0),
(2, 7200, 0),
(2, 7200, 0),
(3, 7200, 0),
(5, 9000, 1);




#Tabla players
INSERT INTO players (game_session_id, money,  class_id)
VALUES 
  (1,  1000, 1),
  (2,  500, 1),
  (3,  200, 2),
  (4,  800, 2),
  (5,  300, 3),
  (6,  600, 3),
  (7,  400, 1),
  (8,  900, 2),
  (9,  700, 3);
  
  #Tabla checkpoint 
INSERT INTO checkpoints (player_id, scene_id, x_position, y_position) 
VALUES 
  (1, 1, 100, 200),
  (2, 2, 50, 300),
  (3, 2, 200, 150),
  (4, 1, 300, 50),
  (5, 2, 150, 250),
  (6, 1, 75, 175),
  (7, 1, 200, 300),
  (8, 2, 100, 100),
  (9, 2, 250, 200);






#Tabla stats players
INSERT INTO stats_players (player_id, stat_id, value) VALUES
(1, 1, 75), (1, 2, 149), (1, 3, 43), (1, 4, 112), (1, 5, 198), (1, 6, 7), (1, 7, 32),
(2, 1, 85), (2, 2, 23), (2, 3, 167), (2, 4, 56), (2, 5, 92), (2, 6, 132), (2, 7, 18),
(3, 1, 129), (3, 2, 76), (3, 3, 89), (3, 4, 1), (3, 5, 52), (3, 6, 187), (3, 7, 150),
(4, 1, 26), (4, 2, 82), (4, 3, 135), (4, 4, 116), (4, 5, 67), (4, 6, 40), (4, 7, 97),
(5, 1, 121), (5, 2, 165), (5, 3, 19), (5, 4, 53), (5, 5, 8), (5, 6, 162), (5, 7, 142),
(6, 1, 52), (6, 2, 29), (6, 3, 86), (6, 4, 44), (6, 5, 127), (6, 6, 183), (6, 7, 91),
(7, 1, 168), (7, 2, 38), (7, 3, 117), (7, 4, 9), (7, 5, 50), (7, 6, 3), (7, 7, 165),
(8, 1, 74), (8, 2, 150), (8, 3, 112), (8, 4, 43), (8, 5, 198), (8, 6, 7), (8, 7, 31),
(9, 1, 142), (9, 2, 19), (9, 3, 165), (9, 4, 87), (9, 5, 123), (9, 6, 37), (9, 7, 193);



#Tabla Players attack 
INSERT INTO players_attacks (player_id, attack_id) VALUES
(1, 1),
(1, 4),
(1, 6),
(2, 1),
(2, 3),
(2, 5),
(2, 6),
(3, 1),
(3, 6),
(3, 3),
(4, 2),
(4, 6),
(4, 1),
(5, 3),
(5, 2),
(5, 6),
(5, 4),
(6, 4),
(6, 6),
(6, 2),
(7, 5),
(7, 3),
(7, 2),
(8, 1),
(8, 3),
(8, 2),
(8, 4),
(9, 2),
(9, 5),
(9, 1),
(9, 3);

#Tablas Battle 
INSERT INTO battles (player_id, enemy, total_damage_made, total_damage_received, coin_received, battle_result, attacks_missed, critical_attacks) VALUES
(1, 'Dabull', 120, 60, 15, 1, 10, 40),
(1, 'Fire Lord', 200, 80, 25, 1, 2, 6),
(1, 'Thunder Lord', 180, 90, 20, 0, 3, 1),
(1, 'AMLO', 500, 250, 100, 0, 10, 8),
(2, 'Dabull', 80, 40, 10, 1, 2, 1),
(2, 'Ice Lord', 250, 120, 35, 1, 5, 4),
(2, 'Thunder Lord', 150, 70, 15, 0, 4, 2),
(3, 'Dabull', 60, 30, 8, 1, 1, 1),
(3, 'Ice Lord', 180, 90, 20, 1, 3, 3),
(3, 'Thunder Lord', 200, 100, 25, 0, 6, 2),
(3, 'AMLO', 600, 300, 120, 0, 8, 10),
(4, 'Dabull', 40, 20, 5, 1, 3, 0),
(4, 'Ice Lord', 150, 70, 18, 1, 4, 2),
(5, 'Dabull', 200, 100, 25, 1, 0, 5),
(5, 'Ice Lord', 80, 40, 10, 0, 2, 1),
(5, 'Thunder Lord', 300, 150, 50, 1, 4, 5),
(6, 'Dabull', 100, 50, 12, 1, 1, 3),
(6, 'Ice Lord', 300, 150, 45, 1, 3, 6),
(6, 'Thunder Lord', 250, 120, 30, 0, 5, 3),
(6, 'AMLO', 700, 350, 150, 0, 12, 12),
(7, 'Dabull', 120, 60, 15, 0, 4, 2),
(7, 'Ice Lord', 100, 50, 12, 1, 2, 2),
(7, 'Thunder Lord', 180, 90, 22, 1, 3, 1),
(7, 'AMLO', 800, 400, 200, 0, 15, 15),
(8, 'Dabull', 50, 25, 6, 1, 2, 0),
(8, 'Ice Lord', 200, 100, 28, 1, 5, 3),
(8, 'Thunder Lord', 150, 70, 18, 0, 4, 2),
(9, 'Dabull', 70, 35, 9, 0, 1, 1),
(9, 'Ice Lord', 150, 150, 40, 1, 6, 2),
(9, 'Fire Lord', 190, 50, 15, 0, 2, 0),
(9, 'Thunder Lord', 250, 250, 70, 1, 12, 5),
(9, 'Slime', 350, 100, 30, 1, 4, 1),
(9, 'AMLO', 420, 200, 60, 1, 7, 2);


#Tabla Battles_attack
INSERT INTO battles_attacks (battle_id, attack_id, times_used) VALUES
(1, 1, 3),
(1, 2, 2),
(1, 3, 1),
(2, 2, 4),
(2, 4, 1),
(3, 1, 2),
(3, 5, 3),
(4, 3, 5),
(4, 6, 2),
(5, 1, 1),
(5, 4, 4),
(5, 5, 3);
