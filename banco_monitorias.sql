
-- pk é primary key, fk é foreign key, uq é unique e ck é check
CREATE TABLE professor (
    matricula_prof BIGINT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    CONSTRAINT pk_professor PRIMARY KEY (matricula_prof),
    CONSTRAINT uq_professor_email UNIQUE (email),
    CONSTRAINT ck_professor_matricula CHECK (matricula_prof BETWEEN 100000000000 AND 999999999999)
);

CREATE TABLE disciplina (
    cod_disciplina VARCHAR(10) NOT NULL,
    nome VARCHAR(100) NOT NULL,
    carga_horaria SMALLINT NOT NULL,
    CONSTRAINT pk_disciplina PRIMARY KEY (cod_disciplina),
    CONSTRAINT ck_carga_horaria CHECK (carga_horaria > 0)
);

CREATE TABLE aluno (
    matricula_aluno BIGINT NOT NULL,
    nome VARCHAR(100) NOT NULL,
    curso VARCHAR(60) NOT NULL,
    email VARCHAR(100) NOT NULL,
    CONSTRAINT pk_aluno PRIMARY KEY (matricula_aluno),
    CONSTRAINT uq_aluno_email UNIQUE (email),
    CONSTRAINT ck_aluno_matricula CHECK (matricula_aluno BETWEEN 100000000000 AND 999999999999)
);

CREATE TABLE monitor (
    matricula_aluno BIGINT NOT NULL,
    cod_disciplina VARCHAR(10) NOT NULL,
    tipo VARCHAR(10) NOT NULL,   
    CONSTRAINT pk_monitor PRIMARY KEY  (matricula_aluno),
    CONSTRAINT fk_monitor_aluno FOREIGN KEY  (matricula_aluno) REFERENCES aluno (matricula_aluno),
    CONSTRAINT fk_monitor_disciplina FOREIGN KEY (cod_disciplina) REFERENCES disciplina (cod_disciplina),
    CONSTRAINT ck_monitor_matricula CHECK (matricula_aluno BETWEEN 100000000000 AND 999999999999),
    CONSTRAINT ck_monitor_tipo CHECK (tipo IN ('Bolsista', 'Voluntario'))
);

CREATE TABLE sessao (
    id_sessao SERIAL NOT NULL,
    matricula_monitor BIGINT NOT NULL,
    local VARCHAR(100) NOT NULL,
    modalidade VARCHAR(10) NOT NULL,
    data DATE NOT NULL, 
    horario TIME NOT NULL,
    CONSTRAINT pk_sessao PRIMARY KEY (id_sessao),
    CONSTRAINT fk_sessao_monitor FOREIGN KEY  (matricula_monitor) REFERENCES monitor (matricula_aluno),
    CONSTRAINT ck_modalidade CHECK (modalidade IN ('Presencial', 'Remota'))
);

CREATE TABLE coordenador ( -- mudei o nome da tabela de coordena para coordenador
    matricula_prof BIGINT NOT NULL,
    cod_disciplina VARCHAR(10) NOT NULL,
    coordena BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT pk_coordena PRIMARY KEY (matricula_prof, cod_disciplina),
    CONSTRAINT fk_coordena_professor FOREIGN KEY (matricula_prof) REFERENCES professor (matricula_prof),
    CONSTRAINT fk_coordena_disciplina FOREIGN KEY (cod_disciplina) REFERENCES disciplina (cod_disciplina)
);


-- no MÁXIMO um coordenador por disciplina
CREATE UNIQUE INDEX uq_coordenador_por_disciplina
    ON coordenador (cod_disciplina)
    WHERE coordena;

-- presenca = true, ausente = false e não registrado = null
CREATE TABLE se_inscreve (
    matricula_aluno BIGINT NOT NULL,
    id_sessao INT NOT NULL,
    presenca BOOLEAN,
    CONSTRAINT pk_se_inscreve PRIMARY KEY (matricula_aluno, id_sessao),
    CONSTRAINT fk_inscricao_aluno FOREIGN KEY (matricula_aluno) REFERENCES aluno (matricula_aluno),
    CONSTRAINT fk_inscricao_sessao FOREIGN KEY (id_sessao) REFERENCES sessao (id_sessao)
);


--	CARGA DE DADOS:
INSERT INTO professor
    (matricula_prof, nome, email)
VALUES
    (100161238231, 'Ana Souza', 'ana@example.com'),
    (100274450185, 'Bruno Lima', 'bruno@example.com'),
    (100327912518, 'Fernanda Alves', 'fernanda@example.com');

INSERT INTO disciplina
    (cod_disciplina, nome, carga_horaria)
VALUES
    ('IME101', 'Banco de Dados', 60),
    ('IME102', 'Programação', 80),
    ('IME103', 'Redes de Computadores', 60);

INSERT INTO aluno
    (matricula_aluno, nome, curso, email)
VALUES
    (200110032802, 'Carla Santos', 'Sistemas de Informação', 'carla@example.com'),
    (200243134418, 'Diego Silva', 'Sistemas de Informação', 'diego@example.com'),
    (200392248526, 'Elisa Costa', 'Ciência da Computação', 'elisa@example.com'),
    (200414941837, 'Felipe Rocha', 'Ciência da Computação', 'felipe@example.com'),
    (200559781921, 'Gabriela Lima', 'Sistemas de Informação', 'gabriela@example.com'),
    (200680236152, 'Henrique Souza', 'Ciência da Computação', 'henrique@example.com');

INSERT INTO monitor (matricula_aluno, cod_disciplina, tipo)
VALUES
    (200110032802, 'IME101', 'Bolsista'),
    (200243134418, 'IME101', 'Voluntario'),
    (200392248526, 'IME102', 'Bolsista');

INSERT INTO coordenador (matricula_prof, cod_disciplina, coordena)
VALUES
    (100161238231, 'IME101', TRUE),
    (100274450185, 'IME101', FALSE),
    (100327912518, 'IME102', TRUE),
    (100161238231, 'IME102', FALSE),
    (100327912518, 'IME103', TRUE);

-- o id_sessao é serial, então não é colocado no insert
-- os ids são gerados na ordem das linhas
INSERT INTO sessao (matricula_monitor, local, modalidade, data, horario)
VALUES
    (200110032802, 'Laboratório 1', 'Presencial', '2026-10-01', '14:00:00'),   -- id: 1 - monitor: carla 
    (200110032802, 'Sala virtual', 'Remota', '2026-10-02', '16:00:00'),        -- id: 2 - monitor: carla   
    (200392248526, 'Laboratório 2', 'Presencial', '2026-10-07', '10:00:00'),   -- id 3 - monitoa: elisa
    (200392248526, 'Sala virtual', 'Remota', '2026-10-08', '15:00:00');        -- id: 4 - monitora elisa

-- nenhum monitor deve se inscrever na prória sessao
INSERT INTO se_inscreve (matricula_aluno, id_sessao, presenca)
VALUES
   (200414941837, 1, TRUE),     -- Felipe  -> sessão 1
    (200559781921, 1, FALSE),   -- Gabriela-> sessão 1
    (200392248526, 1, TRUE),    -- Elisa   -> sessão 1
    (200414941837, 2, TRUE),    -- Felipe  -> sessão 2
    (200392248526, 2, FALSE),   -- Elisa   -> sessão 2
    (200110032802, 3, NULL),    -- Carla   -> sessão 3
    (200559781921, 3, NULL);    -- Gabriela-> sessão 3


-- CONSULTAS:

-- CONSULTA 1
-- Lista os alunos do curso de Ciência da Computação em ordem alfabética
SELECT nome, curso, email
FROM aluno
WHERE curso = 'Ciência da Computação'
ORDER BY nome;

-- CONSULTA 2
-- Mostra cada sessão de monitoria com o nome do monitor e a disciplina que ele atua
-- Além de local, modalidade, data e horário da monitoria

SELECT sessao.id_sessao,
       aluno.nome,
       disciplina.nome,
       sessao.local, sessao.modalidade, sessao.data, sessao.horario
FROM sessao
JOIN monitor ON monitor.matricula_aluno = sessao.matricula_monitor
JOIN aluno ON aluno.matricula_aluno   = monitor.matricula_aluno
JOIN disciplina ON disciplina.cod_disciplina = monitor.cod_disciplina
ORDER BY sessao.id_sessao;
 
-- CONSULTA 3
-- Conta quantos alunos estão inscritos em cada sessão
-- todas as sessões sem inscritos vão aparecer com 0
SELECT sessao.id_sessao,
       sessao.data,
       COUNT(se_inscreve.matricula_aluno)
FROM sessao
LEFT JOIN se_inscreve ON se_inscreve.id_sessao = sessao.id_sessao
GROUP BY sessao.id_sessao, sessao.data
ORDER BY sessao.id_sessao;

-- CONSULTA 4
-- Lista os alunos com mais de uma presença confirmada nas monitorias
SELECT aluno.nome,
       COUNT(*)
FROM se_inscreve
JOIN aluno ON aluno.matricula_aluno = se_inscreve.matricula_aluno
WHERE se_inscreve.presenca = TRUE
GROUP BY aluno.matricula_aluno, aluno.nome
HAVING COUNT(*) > 1;

-- Inscrições antes das alterações
SELECT * FROM se_inscreve ORDER BY id_sessao, matricula_aluno;


-- VALIDAÇÕES COM CHAVE ESTRANGEIRA:

-- O comando gera erro pois viola a chave estrangeira
-- Ele tenta inscrever o aluno Henrique na sessão 13, que não existe na tabela sessao
-- A coluna se_inscreve.id_sessao é fk de sessao.id_sessao
-- Logo, o banco recusa a inscrição em uma sessão que não existe
-- MENSAGEM DE ERRO: ERROR:  insert or update on table "se_inscreve" violates foreign key constraint "fk_inscricao_sessao" DETAIL:  Key (id_sessao)=(13) is not present in table "sessao"

INSERT INTO se_inscreve (matricula_aluno, id_sessao, presenca)
VALUES (200680236152, 13, NULL); 
 
-- O comando funciona corretamente com a chave estrangeira
-- Inscreve o aluno Henrique na sessão 4, que existe
-- As chaves estrangeiras são aceitas, então a inscrição é aceita
-- A presença fica como NULL, porquê a sessão ainda não aconteceu
INSERT INTO se_inscreve (matricula_aluno, id_sessao, presenca)
VALUES (200680236152, 4, NULL); 

-- UPDATE E DELETE:

-- UPDATE: registra a presença de Carla na sessão 3 que estava NULL (não registrada) e vira TRUE (presente)
UPDATE se_inscreve
SET presenca = TRUE
WHERE matricula_aluno = 200110032802 AND id_sessao = 3;
 
-- DELETE: remove a inscrição de Elisa na sessão 2
-- Elisa continua cadastrada como aluna e a sessão 2 continua existindo
DELETE FROM se_inscreve
WHERE matricula_aluno = 200392248526 AND id_sessao = 2;
 
-- Inscrições depois das alterações
SELECT * FROM se_inscreve ORDER BY id_sessao, matricula_aluno;

