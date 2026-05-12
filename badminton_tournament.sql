-- =====================================================
-- REGIONAL BADMINTON TOURNAMENT MANAGEMENT SYSTEM
-- =====================================================

CREATE DATABASE badminton_tournament;

USE badminton_tournament;

-- =====================================================
-- PLAYERS TABLE
-- =====================================================

CREATE TABLE players (
    player_id INT PRIMARY KEY AUTO_INCREMENT,
    player_name VARCHAR(100) NOT NULL,
    age INT,
    gender VARCHAR(10),
    state_name VARCHAR(50),
    ranking_points INT DEFAULT 0
);

-- =====================================================
-- TOURNAMENTS TABLE
-- =====================================================

CREATE TABLE tournaments (
    tournament_id INT PRIMARY KEY AUTO_INCREMENT,
    tournament_name VARCHAR(100),
    city VARCHAR(50),
    start_date DATE,
    end_date DATE
);

-- =====================================================
-- MATCHES TABLE
-- =====================================================

CREATE TABLE matches (
    match_id INT PRIMARY KEY AUTO_INCREMENT,
    tournament_id INT,
    player1_id INT,
    player2_id INT,
    winner_id INT,
    round_name VARCHAR(50),
    score VARCHAR(50),

    FOREIGN KEY (tournament_id)
    REFERENCES tournaments(tournament_id),

    FOREIGN KEY (player1_id)
    REFERENCES players(player_id),

    FOREIGN KEY (player2_id)
    REFERENCES players(player_id),

    FOREIGN KEY (winner_id)
    REFERENCES players(player_id)
);

-- =====================================================
-- SPONSORS TABLE
-- =====================================================

CREATE TABLE sponsors (
    sponsor_id INT PRIMARY KEY AUTO_INCREMENT,
    sponsor_name VARCHAR(100),
    sponsorship_amount DECIMAL(10,2)
);

-- =====================================================
-- TOURNAMENT SPONSORS TABLE
-- =====================================================

CREATE TABLE tournament_sponsors (
    id INT PRIMARY KEY AUTO_INCREMENT,
    tournament_id INT,
    sponsor_id INT,

    FOREIGN KEY (tournament_id)
    REFERENCES tournaments(tournament_id),

    FOREIGN KEY (sponsor_id)
    REFERENCES sponsors(sponsor_id)
);

-- =====================================================
-- SAMPLE PLAYERS
-- =====================================================

INSERT INTO players
(player_name, age, gender, state_name, ranking_points)
VALUES
('Rahul Choudhary', 20, 'Male', 'Rajasthan', 1200),
('Aman Verma', 21, 'Male', 'Delhi', 1100),
('Priya Singh', 19, 'Female', 'Haryana', 1400),
('Neha Jain', 22, 'Female', 'Rajasthan', 1500),
('Karan Gupta', 20, 'Male', 'Punjab', 1000);

-- =====================================================
-- SAMPLE TOURNAMENTS
-- =====================================================

INSERT INTO tournaments
(tournament_name, city, start_date, end_date)
VALUES
('North Zone Championship', 'Jaipur', '2026-06-10', '2026-06-15'),
('State Badminton Cup', 'Delhi', '2026-07-01', '2026-07-05');

-- =====================================================
-- SAMPLE MATCHES
-- =====================================================

INSERT INTO matches
(tournament_id, player1_id, player2_id, winner_id, round_name, score)
VALUES
(1, 1, 2, 1, 'Quarter Final', '21-18, 21-15'),

(1, 3, 4, 4, 'Quarter Final', '18-21, 21-19, 19-21'),

(1, 1, 4, 4, 'Final', '20-22, 19-21');

-- =====================================================
-- SAMPLE SPONSORS
-- =====================================================

INSERT INTO sponsors
(sponsor_name, sponsorship_amount)
VALUES
('Yonex India', 500000),
('Li-Ning Sports', 300000);

-- =====================================================
-- TOURNAMENT SPONSOR RELATION
-- =====================================================

INSERT INTO tournament_sponsors
(tournament_id, sponsor_id)
VALUES
(1,1),
(1,2);

-- =====================================================
-- IMPORTANT QUERIES
-- =====================================================

-- DISPLAY ALL PLAYERS

SELECT * FROM players;

-- DISPLAY ALL MATCHES

SELECT * FROM matches;

-- PLAYER WINNERS WITH MATCH DETAILS

SELECT
p.player_name AS winner,
m.round_name,
m.score
FROM matches m
JOIN players p
ON m.winner_id = p.player_id;

-- TOP RANKED PLAYERS

SELECT
player_name,
ranking_points
FROM players
ORDER BY ranking_points DESC;

-- TOURNAMENT WINNERS

SELECT
t.tournament_name,
p.player_name AS winner
FROM matches m
JOIN tournaments t
ON m.tournament_id = t.tournament_id
JOIN players p
ON m.winner_id = p.player_id
WHERE m.round_name = 'Final';

-- COUNT MATCHES PLAYED BY EACH PLAYER

SELECT
p.player_name,
COUNT(*) AS matches_played
FROM matches m
JOIN players p
ON p.player_id = m.player1_id
OR p.player_id = m.player2_id
GROUP BY p.player_name;

-- =====================================================
-- VIEW
-- =====================================================

CREATE VIEW top_players AS
SELECT
player_name,
ranking_points
FROM players
WHERE ranking_points > 1100;

-- USE VIEW

SELECT * FROM top_players;

-- =====================================================
-- STORED PROCEDURE
-- =====================================================

DELIMITER //

CREATE PROCEDURE GetPlayerMatches(IN pid INT)
BEGIN
    SELECT
    p1.player_name AS player1,
    p2.player_name AS player2,
    m.score,
    m.round_name
    FROM matches m
    JOIN players p1
    ON m.player1_id = p1.player_id
    JOIN players p2
    ON m.player2_id = p2.player_id
    WHERE m.player1_id = pid
    OR m.player2_id = pid;
END //

DELIMITER ;

-- EXECUTE PROCEDURE

CALL GetPlayerMatches(1);

-- =====================================================
-- TRIGGER
-- =====================================================

DELIMITER //

CREATE TRIGGER prevent_negative_points
BEFORE INSERT ON players
FOR EACH ROW
BEGIN

    IF NEW.ranking_points < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Ranking points cannot be negative';

    END IF;

END //

DELIMITER ;

-- =====================================================
-- INDEX
-- =====================================================

CREATE INDEX idx_player_name
ON players(player_name);

-- =====================================================
-- ANALYTICS QUERY
-- =====================================================

SELECT
state_name,
AVG(ranking_points) AS average_points
FROM players
GROUP BY state_name;

-- =====================================================
-- END OF PROJECT
-- =====================================================
