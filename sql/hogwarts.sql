-- =====================================================================
-- Atividade Prática: Escola de Magia de Hogwarts
-- Disciplina: Manipulação de Dados / Banco de Dados II (ADS242N01)
-- Professor: Aguinaldo Neto
--
-- Aluno: 
-- Matrícula:
--
-- Escreva cada resposta logo abaixo do comentário da questão.
-- Comandos que a atividade pede para FALHAR devem ficar comentados,
-- seguidos do código/mensagem de erro e da sua explicação.
-- =====================================================================

SET SQL_SAFE_UPDATES = 0;

-- =====================================================================
-- 1. PREPARACAO DO AMBIENTE (DDL)
-- =====================================================================
DROP DATABASE IF EXISTS hogwarts;
CREATE DATABASE hogwarts;
USE hogwarts;

-- Tabela casa
CREATE TABLE casa (
    id_casa INT AUTO_INCREMENT PRIMARY KEY,
    nome_casa VARCHAR(30) NOT NULL UNIQUE,
    fundador VARCHAR(60),
    pontos INT DEFAULT 0
);

-- Tabela professor
CREATE TABLE professor (
    id_prof INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    salario DECIMAL(10,2),
    data_contratacao DATE,
    id_casa INT NULL,
    CONSTRAINT chk_professor_salario CHECK (salario > 0),
    CONSTRAINT fk_professor_casa FOREIGN KEY (id_casa)
        REFERENCES casa(id_casa)
);

-- Tabela disciplina
CREATE TABLE disciplina (
    id_disc INT AUTO_INCREMENT PRIMARY KEY,
    nome_disc VARCHAR(60) NOT NULL UNIQUE,
    ano_minimo INT,
    id_prof INT NULL,
    CONSTRAINT chk_disciplina_ano CHECK (ano_minimo BETWEEN 1 AND 7),
    CONSTRAINT fk_disciplina_professor FOREIGN KEY (id_prof)
        REFERENCES professor(id_prof)
);

-- Tabela aluno
CREATE TABLE aluno (
    id_aluno INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    ano_escolar INT,
    id_casa INT NULL,
    saldo_galeoes DECIMAL(10,2) DEFAULT 0,
    CONSTRAINT chk_aluno_ano CHECK (ano_escolar BETWEEN 1 AND 7),
    CONSTRAINT chk_aluno_saldo CHECK (saldo_galeoes >= 0),
    CONSTRAINT fk_aluno_casa FOREIGN KEY (id_casa)
        REFERENCES casa(id_casa)
);

-- Tabela matricula
CREATE TABLE matricula (
    id_aluno INT,
    id_disc INT,
    nota DECIMAL(4,2),
    PRIMARY KEY (id_aluno, id_disc),
    CONSTRAINT chk_matricula_nota CHECK (nota BETWEEN 0 AND 10),
    CONSTRAINT fk_matricula_aluno FOREIGN KEY (id_aluno)
        REFERENCES aluno(id_aluno),
    CONSTRAINT fk_matricula_disciplina FOREIGN KEY (id_disc)
        REFERENCES disciplina(id_disc)
);

-- Tabela registro_pontos
CREATE TABLE registro_pontos (
    id_registro INT AUTO_INCREMENT PRIMARY KEY,
    id_aluno INT NOT NULL,
    id_prof INT NOT NULL,
    pontos INT NOT NULL,
    motivo VARCHAR(150),
    data_registro DATE NOT NULL,
    CONSTRAINT fk_registro_aluno FOREIGN KEY (id_aluno)
        REFERENCES aluno(id_aluno),
    CONSTRAINT fk_registro_professor FOREIGN KEY (id_prof)
        REFERENCES professor(id_prof)
);

-- Tabela produto
CREATE TABLE produto (
    id_produto INT AUTO_INCREMENT PRIMARY KEY,
    nome_produto VARCHAR(100) NOT NULL,
    loja VARCHAR(50) NOT NULL,
    preco DECIMAL(10,2),
    estoque INT DEFAULT 0,
    CONSTRAINT chk_produto_preco CHECK (preco > 0),
    CONSTRAINT chk_produto_estoque CHECK (estoque >= 0)
);

-- Tabela compra
CREATE TABLE compra (
    id_compra INT AUTO_INCREMENT PRIMARY KEY,
    id_aluno INT,
    id_produto INT,
    quantidade INT,
    valor_total DECIMAL(10,2),
    data_compra DATE NOT NULL,
    CONSTRAINT chk_compra_quantidade CHECK (quantidade > 0),
    CONSTRAINT fk_compra_aluno FOREIGN KEY (id_aluno)
        REFERENCES aluno(id_aluno),
    CONSTRAINT fk_compra_produto FOREIGN KEY (id_produto)
        REFERENCES produto(id_produto)
);

-- Tabela log_auditoria
CREATE TABLE log_auditoria (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    tabela VARCHAR(30),
    operacao VARCHAR(10),
    descricao VARCHAR(255),
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Pergunta para pensar: por que matricula usa chave primaria composta?
-- Resposta: porque a matricula representa a associacao entre um aluno e uma
-- disciplina. A combinacao id_aluno + id_disc identifica unicamente cada
-- matricula e impede que o mesmo aluno seja matriculado duas vezes na mesma
-- disciplina. Se existisse apenas id_matricula AUTO_INCREMENT, seria possivel
-- inserir repetidamente o mesmo par aluno/disciplina, a menos que tambem
-- fosse criada uma restricao UNIQUE(id_aluno, id_disc).

-- =====================================================================
-- 1.1 CARGA INICIAL DE DADOS (DML)
-- =====================================================================

-- INSERT casa
INSERT INTO casa (nome_casa, fundador) VALUES
('Grifinoria', 'Godric Gryffindor'),       -- 1
('Sonserina', 'Salazar Slytherin'),        -- 2
('Corvinal', 'Rowena Ravenclaw'),          -- 3
('Lufa-Lufa', 'Helga Hufflepuff');         -- 4

-- INSERT professor
INSERT INTO professor (nome, salario, data_contratacao, id_casa) VALUES
('Minerva McGonagall', 9500.00, '1956-12-01', 1), -- 1
('Severo Snape', 8800.00, '1981-09-01', 2),       -- 2
('Filio Flitwick', 8200.00, '1974-09-01', 3),     -- 3
('Pomona Sprout', 7900.00, '1972-09-01', 4),     -- 4
('Rubeo Hagrid', 4500.00, '1993-09-01', NULL),   -- 5
('Remo Lupin', 6200.00, '1993-09-01', NULL),     -- 6
('Sibila Trelawney', 5100.00, '1980-09-01', NULL), -- 7
('Gilderoy Lockhart', 7000.00, '1992-09-01', NULL), -- 8
('Horacio Slughorn', 8000.00, '1996-09-01', NULL); -- 9

-- INSERT disciplina
INSERT INTO disciplina (nome_disc, ano_minimo, id_prof) VALUES
('Transfiguracao', 1, 1),                         -- 1
('Pocoes', 1, 2),                                 -- 2
('Feiticos', 1, 3),                               -- 3
('Herbologia', 1, 4),                             -- 4
('Trato das Criaturas Magicas', 3, 5),             -- 5
('Defesa Contra as Artes das Trevas', 1, 6),       -- 6
('Adivinhacao', 3, 7),                            -- 7
('Estudo dos Trouxas', 3, NULL),                  -- 8
('Runas Antigas', 3, NULL);                       -- 9

-- INSERT aluno
INSERT INTO aluno (nome, ano_escolar, id_casa, saldo_galeoes) VALUES
('Harry Potter', 5, 1, 120.00),          -- 1
('Hermione Granger', 5, 1, 85.00),       -- 2
('Rony Weasley', 5, 1, 12.00),           -- 3
('Neville Longbottom', 5, 1, 30.00),     -- 4
('Draco Malfoy', 5, 2, 500.00),          -- 5
('Pansy Parkinson', 5, 2, 150.00),       -- 6
('Vicente Crabbe', 5, 2, 40.00),         -- 7
('Luna Lovegood', 4, 3, 45.00),          -- 8
('Cho Chang', 6, 3, 200.00),             -- 9
('Padma Patil', 5, 3, 60.00),            -- 10
('Cedrico Diggory', 7, 4, 180.00),       -- 11
('Ana Abbott', 5, 4, 25.00),             -- 12
('Ernesto Macmillan', 5, 4, 70.00),      -- 13
('Teddy Lupin', 1, NULL, 0.00);          -- 14

-- INSERT matricula
INSERT INTO matricula (id_aluno, id_disc, nota) VALUES
(1,1,7.5),(1,2,5.0),(1,6,9.8),(1,5,8.0),
(2,1,10.0),(2,2,9.5),(2,3,10.0),(2,5,9.0),(2,9,9.5),
(3,1,6.0),(3,2,4.5),(3,7,5.5),
(4,2,3.0),(4,4,10.0),(4,6,7.0),
(5,2,9.0),(5,1,7.0),(5,5,4.0),
(6,2,7.5),(6,7,6.5),
(7,2,3.5),(7,6,2.0),
(8,5,8.5),(8,3,8.0),(8,4,9.0),
(9,3,8.5),(9,6,7.5),
(10,3,9.0),(10,7,6.0),
(11,4,8.5),(11,6,9.0),(11,1,8.0),
(12,4,8.0),
(13,4,7.0),(13,3,7.5);

-- INSERT produto
INSERT INTO produto (nome_produto, loja, preco, estoque) VALUES
('Varinha de Azevinho', 'Olivaras', 7.00, 10),                    -- 1
('Vassoura Nimbus 2001', 'Artigos de Quadribol', 300.00, 3),      -- 2
('Sapo de Chocolate', 'Dedosdemel', 2.00, 200),                  -- 3
('Feijõezinhos de Todos os Sabores', 'Dedosdemel', 1.50, 150),   -- 4
('Livro Monstruoso dos Monstros', 'Floreios e Borrões', 12.00, 20), -- 5
('Caldeirão de Estanho', 'Caldeirões Potage', 9.00, 0),           -- 6
('Kit de Logros', 'Gemialidades Weasley', 25.00, 40),             -- 7
('Pena de Repetição Rápida', 'Escribbulus', 15.00, 5);            -- 8

-- Confira: contagem inicial de cada tabela
SELECT 'casa' AS tabela, COUNT(*) AS quantidade FROM casa
UNION ALL SELECT 'professor', COUNT(*) FROM professor
UNION ALL SELECT 'disciplina', COUNT(*) FROM disciplina
UNION ALL SELECT 'aluno', COUNT(*) FROM aluno
UNION ALL SELECT 'matricula', COUNT(*) FROM matricula
UNION ALL SELECT 'produto', COUNT(*) FROM produto
UNION ALL SELECT 'registro_pontos', COUNT(*) FROM registro_pontos
UNION ALL SELECT 'compra', COUNT(*) FROM compra
UNION ALL SELECT 'log_auditoria', COUNT(*) FROM log_auditoria;

-- =====================================================================
-- 2. MANUTENCAO POS-CARGA (ALTER E UPDATE)
-- =====================================================================

-- 2.1. Alteracoes de estrutura (ALTER TABLE)
-- Questao 1
ALTER TABLE aluno ADD COLUMN email VARCHAR(100);

-- Questao 2
ALTER TABLE matricula ADD COLUMN situacao VARCHAR(20) DEFAULT 'Cursando';

-- Questao 3
ALTER TABLE produto ADD COLUMN ativo CHAR(1) DEFAULT 'S';

-- Questao 4
ALTER TABLE casa MODIFY COLUMN fundador VARCHAR(100);

-- Questao 5
ALTER TABLE professor RENAME COLUMN data_contratacao TO data_admissao;

-- Conferencia das alteracoes
DESC aluno;
DESC matricula;
DESC produto;
DESC casa;
DESC professor;

-- 2.2. Atualizacoes de dados (UPDATE)

-- Questao 6: gerar e-mails a partir dos nomes
UPDATE aluno
SET email = LOWER(CONCAT(REPLACE(nome, ' ', '.'), '@hogwarts.edu'));

-- Questao 7: impedir e-mails repetidos
ALTER TABLE aluno
ADD CONSTRAINT uq_aluno_email UNIQUE (email);

-- Questao 8: bonus de 0.5 na disciplina ministrada por Lupin, limitado a 10
UPDATE matricula
SET nota = LEAST(nota + 0.5, 10)
WHERE id_disc IN (
    SELECT id_disc
    FROM disciplina
    WHERE id_prof = (
        SELECT id_prof FROM professor WHERE nome = 'Remo Lupin'
    )
);

-- Questao 9: atualizar situacao de todas as matriculas
UPDATE matricula
SET situacao = CASE
    WHEN nota >= 6 THEN 'Aprovado'
    ELSE 'Reprovado'
END;

-- Questao 10: reajuste de 10% para diretores admitidos antes de 1980
UPDATE professor
SET salario = salario * 1.10
WHERE id_casa IS NOT NULL
  AND data_admissao < '1980-01-01';

-- Questao 11: produtos sem estoque ficam inativos
UPDATE produto
SET ativo = 'N'
WHERE estoque = 0;

-- Questao 12: promocao de 20% na loja Dedosdemel
UPDATE produto
SET preco = preco * 0.80
WHERE loja = 'Dedosdemel';

-- Conferencias das questoes 8 a 12
SELECT a.nome, d.nome_disc, m.nota
FROM matricula m
JOIN aluno a ON a.id_aluno = m.id_aluno
JOIN disciplina d ON d.id_disc = m.id_disc
WHERE a.nome = 'Harry Potter'
  AND d.nome_disc = 'Defesa Contra as Artes das Trevas';

SELECT situacao, COUNT(*) AS quantidade
FROM matricula
GROUP BY situacao;

SELECT nome, salario FROM professor WHERE nome = 'Minerva McGonagall';
SELECT nome_produto, preco FROM produto WHERE nome_produto = 'Sapo de Chocolate';
-- =====================================================================
-- 3. REMOCAO DE DADOS (DELETE) E TESTES DE RESTRICOES
-- =====================================================================

-- Questao 13: teste de FK - este DELETE deve falhar porque Sonserina
-- esta referenciada por professor e aluno. Execute separadamente para
-- observar o erro; mantido comentado para o script continuar.
-- DELETE FROM casa WHERE nome_casa = 'Sonserina';
-- Explicacao: erro 1451 (Cannot delete or update a parent row):
-- existem registros dependentes que referenciam essa casa.

-- Questao 14: teste de CHECK - deve falhar, pois o ano 8 esta fora de 1 a 7.
-- INSERT INTO aluno (nome, ano_escolar, id_casa, saldo_galeoes, email)
-- VALUES ('Dobby', 8, 1, 0.00, 'dobby@hogwarts.edu');
-- Explicacao: violacao da constraint chk_aluno_ano.

-- Questao 15: teste de UNIQUE - deve falhar porque o e-mail ja pertence
-- a Harry Potter.
-- INSERT INTO aluno (nome, ano_escolar, id_casa, saldo_galeoes, email)
-- VALUES ('Harry Potter (Polissuco)', 5, 1, 0.00, 'harry.potter@hogwarts.edu');
-- Explicacao: erro 1062, valor duplicado na constraint uq_aluno_email.

-- Questao 16: teste de integridade - deve falhar porque Snape ministra Pocoes
-- e possui registros relacionados quando os dados forem inseridos na secao 4.
-- Neste ponto, a FK de disciplina ja impede a exclusao.
-- DELETE FROM professor WHERE nome = 'Severo Snape';
-- Explicacao: erro 1451, pois disciplina.id_prof referencia Severo Snape.

-- Questao 17: Lockhart pode ser excluido porque nao e referenciado por
-- nenhuma disciplina nem por registros de pontos.
DELETE FROM professor WHERE nome = 'Gilderoy Lockhart';

-- Questao 18: excluir primeiro matriculas de Vicente Crabbe e depois o aluno
SET SQL_SAFE_UPDATES = 0;
DELETE FROM matricula
WHERE id_aluno IN (SELECT id_aluno FROM aluno WHERE nome = 'Vicente Crabbe');

DELETE FROM aluno WHERE nome = 'Vicente Crabbe';

-- Questao 19: excluir disciplinas sem matriculas
DELETE FROM disciplina
WHERE id_disc NOT IN (SELECT id_disc FROM matricula);

-- Conferencia apos a secao 3
SELECT COUNT(*) AS total_professores FROM professor; -- esperado: 8
SELECT COUNT(*) AS total_alunos FROM aluno;            -- esperado: 13
SELECT COUNT(*) AS total_disciplinas FROM disciplina; -- esperado: 8
SELECT COUNT(*) AS total_matriculas FROM matricula;   -- esperado: 33

-- =====================================================================
-- 4. TRIGGERS: AS REGRAS QUE SE CUMPREM SOZINHAS
-- =====================================================================

-- Questao 20: atualizar os pontos da casa do aluno apos inserir registro
DELIMITER $$
CREATE TRIGGER trg_pontos_casa
AFTER INSERT ON registro_pontos
FOR EACH ROW
BEGIN
    UPDATE casa c
    JOIN aluno a ON a.id_casa = c.id_casa
    SET c.pontos = c.pontos + NEW.pontos
    WHERE a.id_aluno = NEW.id_aluno;
END$$
DELIMITER ;

-- Questao 21: validar estoque e saldo antes de inserir compra
DELIMITER $$
CREATE TRIGGER trg_valida_compra
BEFORE INSERT ON compra
FOR EACH ROW
BEGIN
    DECLARE v_preco DECIMAL(10,2);
    DECLARE v_estoque INT;
    DECLARE v_saldo DECIMAL(10,2);

    SELECT preco, estoque
      INTO v_preco, v_estoque
    FROM produto
    WHERE id_produto = NEW.id_produto;

    SELECT saldo_galeoes
      INTO v_saldo
    FROM aluno
    WHERE id_aluno = NEW.id_aluno;

    IF v_estoque < NEW.quantidade THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Estoque insuficiente no Beco Diagonal';
    END IF;

    IF v_saldo < (v_preco * NEW.quantidade) THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Galeões insuficientes no cofre do aluno';
    END IF;

    SET NEW.valor_total = v_preco * NEW.quantidade;
END$$
DELIMITER ;

-- Questao 22: baixar estoque e saldo depois da compra
DELIMITER $$
CREATE TRIGGER trg_baixa_compra
AFTER INSERT ON compra
FOR EACH ROW
BEGIN
    UPDATE produto
    SET estoque = estoque - NEW.quantidade
    WHERE id_produto = NEW.id_produto;

    UPDATE aluno
    SET saldo_galeoes = saldo_galeoes - NEW.valor_total
    WHERE id_aluno = NEW.id_aluno;
END$$
DELIMITER ;

-- Questao 23: recalcular situacao sempre que a nota mudar
DELIMITER $$
CREATE TRIGGER trg_situacao_nota
BEFORE UPDATE ON matricula
FOR EACH ROW
BEGIN
    SET NEW.situacao = CASE
        WHEN NEW.nota >= 6 THEN 'Aprovado'
        ELSE 'Reprovado'
    END;
END$$
DELIMITER ;

-- Questao 24: auditar alteracao de salario
DELIMITER $$
CREATE TRIGGER trg_audita_salario
AFTER UPDATE ON professor
FOR EACH ROW
BEGIN
    IF OLD.salario <> NEW.salario THEN
        INSERT INTO log_auditoria (tabela, operacao, descricao)
        VALUES (
            'professor',
            'UPDATE',
            CONCAT(OLD.nome, ': salario de ',
                   FORMAT(OLD.salario, 2), ' para ',
                   FORMAT(NEW.salario, 2))
        );
    END IF;
END$$
DELIMITER ;

-- Pergunta para pensar: por que a validacao da compra precisa ser BEFORE
-- e a baixa do estoque precisa ser AFTER?
-- Resposta: BEFORE permite verificar estoque e saldo e preencher valor_total
-- antes de gravar. Se uma regra falhar, o INSERT e bloqueado sem alterar os
-- dados. AFTER executa a baixa somente depois que a compra foi inserida com
-- sucesso, evitando descontar estoque ou saldo em uma compra recusada.

-- =====================================================================
-- 4.1. TESTANDO OS TRIGGERS
-- =====================================================================

-- Questao 25: INSERT registro_pontos
INSERT INTO registro_pontos
(id_aluno, id_prof, pontos, motivo, data_registro) VALUES
(2,3,20,'Feitico de levitacao perfeito','2026-09-10'),
(1,2,-10,'Atraso na aula de Pocoes','2026-09-12'),
(5,2,15,'Pocao do Morto-Vivo impecavel','2026-09-12'),
(8,5,10,'Cuidou de um testralio ferido','2026-09-20'),
(11,4,25,'Ajudou os alunos do 1o ano','2026-09-25'),
(4,4,30,'Identificou uma Mimbulus mimbletonia','2026-10-02'),
(6,1,-20,'Fora da cama apos o toque de recolher','2026-10-05'),
(1,6,50,'Conjurou um Patrono corporeo','2026-10-15'),
(9,3,15,'Duelo exemplar no Clube de Duelos','2026-10-18'),
(5,1,-30,'Duelo proibido no corredor','2026-10-31'),
(10,7,5,'Interpretacao da bola de cristal','2026-11-03'),
(13,4,10,'Colheita de mandragoras','2026-11-05'),
(3,9,10,'Identificou um bezoar','2026-11-06'),
(8,3,20,'Resposta brilhante sobre o Diadema','2026-11-08'),
(6,2,25,'Antidoto para venenos comuns','2026-11-09'),
(5,9,40,'Melhor pocao do Clube do Slugue','2026-11-09');

-- INSERT compra: valor_total sera calculado pelo trigger
INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra) VALUES
(5,2,1,'2026-09-01'),
(2,5,2,'2026-09-02'),
(1,3,10,'2026-09-03'),
(3,4,5,'2026-09-03'),
(9,8,1,'2026-09-15'),
(8,5,1,'2026-09-20'),
(11,1,1,'2026-10-01'),
(6,3,20,'2026-10-10'),
(1,7,2,'2026-10-20'),
(13,4,10,'2026-11-02');

-- Teste: Rony tenta comprar Nimbus 2001. Deve falhar por saldo insuficiente.
-- Execute separadamente para observar a mensagem:
-- INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra)
-- VALUES (3, 2, 1, '2026-11-10');
-- Resultado esperado: 'Galeoes insuficientes no cofre do aluno'.

-- Teste: Hermione tenta comprar Caldeirao sem estoque. Deve falhar.
-- INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra)
-- VALUES (2, 6, 1, '2026-11-10');
-- Resultado esperado: 'Estoque insuficiente no Beco Diagonal'.

-- Rony fez recuperacao de Pocoes: situacao sera recalculada pelo trigger
UPDATE matricula
SET nota = 6.5
WHERE id_aluno = 3
  AND id_disc = (SELECT id_disc FROM disciplina WHERE nome_disc = 'Pocoes');

SELECT a.nome, d.nome_disc, m.nota, m.situacao
FROM matricula m
JOIN aluno a ON a.id_aluno = m.id_aluno
JOIN disciplina d ON d.id_disc = m.id_disc
WHERE a.nome = 'Rony Weasley' AND d.nome_disc = 'Pocoes';

-- Atualizar salario de Hagrid: gera um registro de auditoria
UPDATE professor SET salario = 5000.00 WHERE nome = 'Rubeo Hagrid';

-- Atualizar somente a data: nao gera auditoria, pois salario nao mudou
UPDATE professor
SET data_admissao = '1993-08-15'
WHERE nome = 'Rubeo Hagrid';

SELECT * FROM log_auditoria;

-- Conferencias dos triggers
SELECT nome_casa, pontos FROM casa ORDER BY pontos DESC;
SELECT nome, saldo_galeoes FROM aluno WHERE nome IN ('Draco Malfoy','Harry Potter');
SELECT nome_produto, estoque FROM produto
WHERE nome_produto IN ('Vassoura Nimbus 2001','Sapo de Chocolate');
SELECT SUM(valor_total) AS total_compras FROM compra;
SELECT COUNT(*) AS total_logs FROM log_auditoria;

-- =====================================================================
-- 5. CONTROLE DE TRANSACOES (TCL): O BANCO GRINGOTES
-- =====================================================================

-- Questao 26: transferencia de Draco para Pansy
START TRANSACTION;
UPDATE aluno SET saldo_galeoes = saldo_galeoes - 50
WHERE nome = 'Draco Malfoy';
UPDATE aluno SET saldo_galeoes = saldo_galeoes + 50
WHERE nome = 'Pansy Parkinson';
COMMIT;

SELECT nome, saldo_galeoes
FROM aluno WHERE nome IN ('Draco Malfoy','Pansy Parkinson');

-- Questao 27: zerar pontos e desfazer
START TRANSACTION;
UPDATE casa SET pontos = 0;
SELECT nome_casa, pontos FROM casa;
ROLLBACK;
SELECT nome_casa, pontos FROM casa;

-- Questao 28: compra dentro de transacao e rollback
START TRANSACTION;
INSERT INTO compra (id_aluno, id_produto, quantidade, data_compra)
VALUES (1, 1, 1, '2026-11-10');
SELECT nome, saldo_galeoes FROM aluno WHERE id_aluno = 1;
SELECT nome_produto, estoque FROM produto WHERE id_produto = 1;
ROLLBACK;
SELECT nome, saldo_galeoes FROM aluno WHERE id_aluno = 1;
SELECT nome_produto, estoque FROM produto WHERE id_produto = 1;

-- Resposta: como as tabelas usam InnoDB, o INSERT e as alteracoes feitas
-- pelo trigger pertencem a mesma transacao. O ROLLBACK desfaz a compra,
-- a reducao do estoque e o desconto no saldo.

-- Questao 29: SAVEPOINT
START TRANSACTION;

INSERT INTO registro_pontos
(id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (12, 4, 15, 'Cuidou das estufas no feriado', '2026-11-10');

SAVEPOINT sp_pontos_legitimos;

INSERT INTO registro_pontos
(id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (6, 2, 100, 'Favoritismo descarado', '2026-11-10');

ROLLBACK TO SAVEPOINT sp_pontos_legitimos;
COMMIT;

-- Questao 30: autocommit e DDL
SELECT @@autocommit;
-- Resposta: valor 1 significa que cada instrucao e confirmada automaticamente
-- quando executada fora de uma transacao explicita. Com autocommit = 0,
-- as alteracoes precisam ser confirmadas com COMMIT ou desfeitas com ROLLBACK.
-- CREATE TABLE e outros comandos DDL provocam commit implicito no MySQL;
-- portanto, uma transacao aberta pode ser confirmada antes da execucao do DDL.

-- Conferencia da secao 5
SELECT nome_casa, pontos FROM casa ORDER BY pontos DESC;
SELECT COUNT(*) AS total_registros FROM registro_pontos;

-- =====================================================================
-- 6. DESAFIOS DE CONSULTA (SQL AVANCADO)
-- Executar apos as secoes 2 a 5
-- =====================================================================

-- 6.1 Faixa salarial (BETWEEN)
SELECT p.nome, p.salario
FROM professor p
WHERE p.salario BETWEEN 6000.00 AND 9000.00
ORDER BY p.salario DESC;

-- 6.2 Anos selecionados (IN)
SELECT a.nome, a.ano_escolar
FROM aluno a
WHERE a.ano_escolar IN (1,4,6,7)
ORDER BY a.ano_escolar;

-- 6.3 Busca por padrao (LIKE com _)
SELECT a.nome
FROM aluno a
WHERE a.nome LIKE '_a%';

-- 6.4 Disciplina orfa (IS NULL)
SELECT d.nome_disc
FROM disciplina d
WHERE d.id_prof IS NULL;

-- 6.5 Fora da faixa (NOT BETWEEN)
SELECT p.nome_produto, p.preco
FROM produto p
WHERE p.preco NOT BETWEEN 5 AND 20
ORDER BY p.preco;

-- 6.6 Lojas do Beco Diagonal (DISTINCT)
SELECT DISTINCT p.loja
FROM produto p
ORDER BY p.loja;

-- 6.7 Quem e de qual casa (INNER JOIN)
SELECT a.nome AS aluno, c.nome_casa AS casa
FROM aluno a
INNER JOIN casa c ON c.id_casa = a.id_casa
ORDER BY c.nome_casa, a.nome;
-- Esperado: 12 alunos. Teddy nao possui casa (id_casa NULL), por isso
-- nao aparece no INNER JOIN.

-- 6.8 Todos os alunos (LEFT JOIN)
SELECT a.nome AS aluno,
       COALESCE(c.nome_casa, 'Aguardando o Chapeu Seletor') AS casa
FROM aluno a
LEFT JOIN casa c ON c.id_casa = a.id_casa
ORDER BY a.nome;

-- 6.9 Professor sem turma (RIGHT JOIN)
SELECT p.nome AS professor
FROM disciplina d
RIGHT JOIN professor p ON p.id_prof = d.id_prof
WHERE d.id_disc IS NULL;

-- 6.10 Boletim da Grifinoria (JOIN com 5 tabelas)
SELECT a.nome AS aluno,
       c.nome_casa AS casa,
       d.nome_disc AS disciplina,
       COALESCE(p.nome, 'Sem professor') AS professor,
       m.nota,
       m.situacao
FROM aluno a
JOIN casa c ON c.id_casa = a.id_casa
JOIN matricula m ON m.id_aluno = a.id_aluno
JOIN disciplina d ON d.id_disc = m.id_disc
LEFT JOIN professor p ON p.id_prof = d.id_prof
WHERE c.nome_casa = 'Grifinoria'
ORDER BY a.nome, d.nome_disc;

-- 6.11 Extrato do Beco Diagonal (JOIN com 3 tabelas)
SELECT co.id_compra AS numero_compra,
       a.nome AS aluno,
       pr.nome_produto AS produto,
       pr.loja,
       co.quantidade,
       co.valor_total,
       co.data_compra
FROM compra co
JOIN aluno a ON a.id_aluno = co.id_aluno
JOIN produto pr ON pr.id_produto = co.id_produto
ORDER BY co.data_compra;

-- 6.12 Desempenho por disciplina
SELECT d.nome_disc AS disciplina,
       COUNT(m.id_aluno) AS quantidade_alunos,
       ROUND(AVG(m.nota), 2) AS media,
       MAX(m.nota) AS maior_nota,
       MIN(m.nota) AS menor_nota
FROM disciplina d
JOIN matricula m ON m.id_disc = d.id_disc
GROUP BY d.id_disc, d.nome_disc
HAVING AVG(m.nota) >= 7
ORDER BY media DESC;

-- 6.13 Livro-razao da Taca
SELECT c.nome_casa,
       COUNT(r.id_registro) AS quantidade_registros,
       SUM(CASE WHEN r.pontos > 0 THEN r.pontos ELSE 0 END) AS pontos_ganhos,
       SUM(CASE WHEN r.pontos < 0 THEN r.pontos ELSE 0 END) AS pontos_perdidos,
       COALESCE(SUM(r.pontos), 0) AS saldo_pontos
FROM casa c
LEFT JOIN aluno a ON a.id_casa = c.id_casa
LEFT JOIN registro_pontos r ON r.id_aluno = a.id_aluno
GROUP BY c.id_casa, c.nome_casa
ORDER BY c.nome_casa;

-- 6.14 Faturamento por loja
SELECT pr.loja,
       COUNT(co.id_compra) AS quantidade_compras,
       SUM(co.valor_total) AS faturamento
FROM produto pr
JOIN compra co ON co.id_produto = pr.id_produto
GROUP BY pr.loja
HAVING SUM(co.valor_total) > 20
ORDER BY faturamento DESC;

-- 6.15 Pontos por mes
SELECT MONTH(r.data_registro) AS mes,
       COUNT(*) AS quantidade_registros,
       SUM(r.pontos) AS total_pontos
FROM registro_pontos r
GROUP BY MONTH(r.data_registro)
ORDER BY mes;

-- 6.16 Professores mais ativos
SELECT p.nome,
       COUNT(r.id_registro) AS quantidade_registros,
       SUM(r.pontos) AS total_concedido
FROM professor p
JOIN registro_pontos r ON r.id_prof = p.id_prof
GROUP BY p.id_prof, p.nome
HAVING COUNT(r.id_registro) >= 2
ORDER BY total_concedido DESC;

-- 6.17 Clientes da Dedosdemel (IN, sem JOIN)
SELECT a.nome
FROM aluno a
WHERE a.id_aluno IN (
    SELECT co.id_aluno
    FROM compra co
    WHERE co.id_produto IN (
        SELECT pr.id_produto
        FROM produto pr
        WHERE pr.loja = 'Dedosdemel'
    )
);

-- 6.18 Encalhados (NOT IN)
SELECT pr.nome_produto, pr.estoque
FROM produto pr
WHERE pr.id_produto NOT IN (
    SELECT co.id_produto FROM compra co
);

-- 6.19 Cofres cheios (subconsulta escalar)
SELECT a.nome, a.saldo_galeoes
FROM aluno a
WHERE a.saldo_galeoes > (
    SELECT AVG(a2.saldo_galeoes) FROM aluno a2
);

-- 6.20 Acima de todos (ALL)
SELECT p.nome, p.salario
FROM professor p
WHERE p.salario > ALL (
    SELECT p2.salario
    FROM professor p2
    WHERE p2.id_casa IS NULL
);

-- 6.21 Mais rico que algum sonserino (ANY)
SELECT a.nome, a.saldo_galeoes
FROM aluno a
WHERE (a.id_casa IS NULL OR a.id_casa <> 2)
  AND a.saldo_galeoes > ANY (
      SELECT a2.saldo_galeoes
      FROM aluno a2
      WHERE a2.id_casa = 2
  );
-- Resposta: > ANY significa maior que pelo menos um valor da subconsulta.
-- Portanto, equivale a ser maior que o menor valor retornado, e nao o maior.

-- 6.22 Casas com nota maxima (EXISTS)
SELECT c.nome_casa
FROM casa c
WHERE EXISTS (
    SELECT 1
    FROM aluno a
    JOIN matricula m ON m.id_aluno = a.id_aluno
    WHERE a.id_casa = c.id_casa
      AND m.nota = 10
);

-- 6.23 Nunca foram ao Beco (NOT EXISTS)
SELECT a.nome
FROM aluno a
WHERE NOT EXISTS (
    SELECT 1
    FROM compra co
    WHERE co.id_aluno = a.id_aluno
);

-- 6.24 Media das medias (subconsulta no FROM)
SELECT c.nome_casa,
       ROUND(AVG(media_aluno.media_individual), 2) AS media_da_casa
FROM casa c
JOIN aluno a ON a.id_casa = c.id_casa
JOIN (
    SELECT m.id_aluno, AVG(m.nota) AS media_individual
    FROM matricula m
    GROUP BY m.id_aluno
) AS media_aluno ON media_aluno.id_aluno = a.id_aluno
GROUP BY c.id_casa, c.nome_casa
ORDER BY media_da_casa DESC;

-- 6.25 Diretorio de Hogwarts (UNION ALL)
SELECT nome, vinculo
FROM (
    SELECT a.nome AS nome, 'Aluno' AS vinculo FROM aluno a
    UNION ALL
    SELECT p.nome AS nome, 'Professor' AS vinculo FROM professor p
) AS diretorio
ORDER BY nome;

-- 6.26 UNION x UNION ALL
-- UNION ALL mantem repeticoes
SELECT a.nome
FROM aluno a
WHERE a.id_aluno IN (SELECT co.id_aluno FROM compra co)
UNION ALL
SELECT a.nome
FROM aluno a
WHERE a.id_aluno IN (SELECT r.id_aluno FROM registro_pontos r);

-- UNION remove nomes duplicados
SELECT a.nome
FROM aluno a
WHERE a.id_aluno IN (SELECT co.id_aluno FROM compra co)
UNION
SELECT a.nome
FROM aluno a
WHERE a.id_aluno IN (SELECT r.id_aluno FROM registro_pontos r);

-- Para contar o resultado de cada operacao:
SELECT COUNT(*) AS linhas_union_all
FROM (
    SELECT co.id_aluno AS id_aluno FROM compra co
    UNION ALL
    SELECT r.id_aluno FROM registro_pontos r
) AS resultado_union_all;

SELECT COUNT(*) AS linhas_union
FROM (
    SELECT co.id_aluno AS id_aluno FROM compra co
    UNION
    SELECT r.id_aluno FROM registro_pontos r
) AS resultado_union;

-- Resposta: UNION ALL conserva todas as ocorrencias; UNION elimina duplicatas.

-- 6.27 Painel do Diretor
SELECT 'Total de pontos distribuidos' AS indicador,
       CAST(COALESCE(SUM(pontos),0) AS CHAR) AS valor
FROM registro_pontos
UNION ALL
SELECT 'Total de galeoes gastos na loja',
       CAST(COALESCE(SUM(valor_total),0) AS CHAR)
FROM compra
UNION ALL
SELECT 'Folha salarial dos professores',
       CAST(COALESCE(SUM(salario),0) AS CHAR)
FROM professor
UNION ALL
SELECT 'Total de galeoes nos cofres dos alunos',
       CAST(COALESCE(SUM(saldo_galeoes),0) AS CHAR)
FROM aluno;

-- =====================================================================
-- 7. VIEWS: OS QUADROS DE AVISOS DE HOGWARTS
-- =====================================================================

-- Questao 31: placar das casas
CREATE OR REPLACE VIEW vw_placar_casas AS
SELECT nome_casa, pontos
FROM casa
ORDER BY pontos DESC;

-- Questao 32: boletim de todas as matriculas
CREATE OR REPLACE VIEW vw_boletim AS
SELECT a.nome AS aluno,
       COALESCE(c.nome_casa, 'Sem casa') AS casa,
       d.nome_disc AS disciplina,
       COALESCE(p.nome, 'Sem professor') AS professor,
       m.nota,
       m.situacao
FROM matricula m
JOIN aluno a ON a.id_aluno = m.id_aluno
LEFT JOIN casa c ON c.id_casa = a.id_casa
JOIN disciplina d ON d.id_disc = m.id_disc
LEFT JOIN professor p ON p.id_prof = d.id_prof;

-- Questao 33: extrato da loja
CREATE OR REPLACE VIEW vw_extrato_loja AS
SELECT a.nome AS aluno,
       pr.nome_produto AS produto,
       pr.loja,
       co.quantidade,
       co.valor_total,
       co.data_compra
FROM compra co
JOIN aluno a ON a.id_aluno = co.id_aluno
JOIN produto pr ON pr.id_produto = co.id_produto;

-- Questao 34: alunos destaque
CREATE OR REPLACE VIEW vw_alunos_destaque AS
SELECT a.nome AS aluno,
       c.nome_casa AS casa,
       ROUND(AVG(m.nota), 2) AS media
FROM aluno a
JOIN casa c ON c.id_casa = a.id_casa
JOIN matricula m ON m.id_aluno = a.id_aluno
GROUP BY a.id_aluno, a.nome, c.nome_casa
HAVING AVG(m.nota) >= 8;

-- Questao 35: quadro de professores
CREATE OR REPLACE VIEW vw_quadro_professores AS
SELECT p.nome AS professor,
       COALESCE(c.nome_casa, 'Nao e diretor') AS casa_que_dirige,
       (SELECT COUNT(*)
        FROM disciplina d
        WHERE d.id_prof = p.id_prof) AS quantidade_disciplinas,
       COALESCE((SELECT SUM(r.pontos)
                 FROM registro_pontos r
                 WHERE r.id_prof = p.id_prof), 0) AS total_pontos_concedidos
FROM professor p
LEFT JOIN casa c ON c.id_casa = p.id_casa;

-- Questao 36: consultas usando as views

-- a) Consultar o placar
SELECT * FROM vw_placar_casas ORDER BY pontos DESC;

-- b) Boletim apenas dos alunos da Corvinal
SELECT * FROM vw_boletim WHERE casa = 'Corvinal';

-- c) Total faturado por loja
SELECT loja, SUM(valor_total) AS total_faturado
FROM vw_extrato_loja
GROUP BY loja
ORDER BY total_faturado DESC;

-- d) Alunos destaque
SELECT * FROM vw_alunos_destaque ORDER BY media DESC;

-- e) Quadro de professores
SELECT * FROM vw_quadro_professores
ORDER BY total_pontos_concedidos DESC;

-- Questao 37: view e dinamica; inserir pontos para Cedrico
INSERT INTO registro_pontos
(id_aluno, id_prof, pontos, motivo, data_registro)
VALUES (11, 1, 20, 'Venceu a primeira tarefa do Torneio', '2026-11-10');

SELECT * FROM vw_placar_casas ORDER BY pontos DESC;
-- Resposta: a pontuacao da Lufa-Lufa aumenta em 20 pontos. A view consulta
-- os dados atuais das tabelas; nao e uma copia estatica dos resultados.

-- Questao 38: incluir fundador no placar
CREATE OR REPLACE VIEW vw_placar_casas AS
SELECT nome_casa, fundador, pontos
FROM casa
ORDER BY pontos DESC;

SELECT * FROM vw_placar_casas;


-- =====================================================================
-- 8. CONTROLE DE ACESSO (DCL): QUEM PODE VER O QUE
-- =====================================================================

-- Questao 39: criar usuarios
CREATE USER IF NOT EXISTS 'filch'@'localhost'
IDENTIFIED BY 'MadameNorra#1';

CREATE USER IF NOT EXISTS 'mcgonagall'@'localhost'
IDENTIFIED BY 'Animago#Gato1';

CREATE USER IF NOT EXISTS 'dumbledore'@'localhost'
IDENTIFIED BY 'Fenix#Fawkes1';

-- Questao 40: Filch pode consultar somente a view do placar
GRANT SELECT ON hogwarts.vw_placar_casas TO 'filch'@'localhost';

-- Questao 41: permissoes de McGonagall
GRANT SELECT, INSERT ON hogwarts.registro_pontos
TO 'mcgonagall'@'localhost';

GRANT SELECT ON hogwarts.aluno
TO 'mcgonagall'@'localhost';

GRANT SELECT ON hogwarts.vw_boletim
TO 'mcgonagall'@'localhost';

-- Questao 42: Dumbledore recebe todos os privilegios e pode repassa-los
GRANT ALL PRIVILEGES ON hogwarts.*
TO 'dumbledore'@'localhost'
WITH GRANT OPTION;

-- Questao 43: conferir permissoes
SHOW GRANTS FOR 'filch'@'localhost';
SHOW GRANTS FOR 'mcgonagall'@'localhost';

-- Questao 44: testes devem ser executados conectando como filch
-- SELECT * FROM hogwarts.vw_placar_casas;
-- Deve funcionar.
-- SELECT * FROM hogwarts.aluno;
-- Deve falhar com erro 1142 (SELECT command denied), pois Filch nao recebeu
-- permissao de SELECT na tabela aluno.

-- Questao 45: testes conectando como mcgonagall
-- a) Registrar 10 pontos para Hermione, pela professora McGonagall
-- Executar conectado como mcgonagall:
-- USE hogwarts;
-- INSERT INTO registro_pontos
-- (id_aluno, id_prof, pontos, motivo, data_registro)
-- VALUES (2, 1, 10, 'Ajudou um colega em Transfiguracao', '2026-11-10');
-- b) Este UPDATE deve ser negado por falta de permissao:
-- UPDATE casa SET pontos = 1000 WHERE id_casa = 1;
-- Resposta: o primeiro comando aciona o trigger. O trigger executa com os
-- privilegios do DEFINER (usuario que o criou), portanto consegue atualizar
-- casa mesmo que mcgonagall nao tenha permissao direta de UPDATE nessa tabela.

-- Questao 46: revogar INSERT de McGonagall
REVOKE INSERT ON hogwarts.registro_pontos
FROM 'mcgonagall'@'localhost';

SHOW GRANTS FOR 'mcgonagall'@'localhost';

-- Questao 47: papel monitor
CREATE ROLE IF NOT EXISTS 'monitor';

GRANT SELECT ON hogwarts.vw_boletim TO 'monitor';
GRANT SELECT ON hogwarts.vw_placar_casas TO 'monitor';

CREATE USER IF NOT EXISTS 'percy'@'localhost'
IDENTIFIED BY 'Monitor#Chefe1';

GRANT 'monitor' TO 'percy'@'localhost';
SET DEFAULT ROLE 'monitor' TO 'percy'@'localhost';

-- Resposta: roles facilitam a administracao. As permissoes sao concedidas
-- ao papel uma unica vez e depois atribuidas aos usuarios que exercem a
-- mesma funcao, evitando repetir GRANT para cada monitor.

-- Questao 48: remover usuarios e papel criados
DROP USER IF EXISTS 'filch'@'localhost';
DROP USER IF EXISTS 'mcgonagall'@'localhost';
DROP USER IF EXISTS 'dumbledore'@'localhost';
DROP USER IF EXISTS 'percy'@'localhost';
DROP ROLE IF EXISTS 'monitor';

-- =====================================================================
-- FIM DA ATIVIDADE
-- Observacao: as questoes que provocam erros intencionais estao comentadas.
-- Execute-as individualmente para registrar o codigo e a mensagem do MySQL.
-- Para as questoes 44 e 45, abra conexoes separadas com os usuarios indicados.
-- =====================================================================

