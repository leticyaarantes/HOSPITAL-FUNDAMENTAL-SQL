-- ######################################################
-- 1. PREPARAÇÃO DE DADOS PARA GARANTIR OS TESTES
-- ######################################################

-- 1.1. Inclusão de um médico com "Gabriel" no nome (para teste 10)
INSERT INTO medico (crm_medico, nome, cpf) VALUES
('CRM/SP 900001', 'Dr. Gabriel Martins', '00000000001');

-- 1.2. Inclusão de um paciente menor de 18 anos (para teste 7)
-- Paciente "Joãozinho" (Nascido em 2015-01-01). Em 2020 (data da consulta) ele teria 5 anos.
INSERT INTO paciente (id_paciente, nome, data_nascimento, cpf) VALUES
(16, 'P. Joãozinho Lima', '2015-01-01', '60060060060');

-- 1.3. Inclusão de uma consulta para o Joãozinho com especialidade não-pediatria (Ortopedia - ID 6)
-- Consulta em 2020 para testar o critério de idade.
INSERT INTO consulta (id_consulta, crm_medico, id_paciente, id_especialidade, data_hora, valor_consulta) VALUES
(21, 'CRM/SP 123461', 16, 6, '2020-10-10 13:00:00', 300.00);

-- 1.4. Inclusão de consulta sem convênio de menor valor (para teste 4)
-- Valor de 50.00
INSERT INTO consulta (id_consulta, crm_medico, id_paciente, id_especialidade, data_hora, valor_consulta) VALUES
(22, 'CRM/SP 123457', 6, 2, '2018-02-01 09:00:00', 50.00);


-- ######################################################
-- 2. CONSULTAS SOLICITADAS (RELATÓRIOS)
-- ######################################################

-- Consulta 1: Todos os dados e o valor médio das consultas do ano de 2020 e das que foram feitas sob convênio.
-- NOTA: O critério "sob convênio" é inferido pela existência de registro na tabela paciente_convenio
SELECT
    C.*,
    (SELECT AVG(C2.valor_consulta)
     FROM consulta C2
     JOIN paciente_convenio PC ON C2.id_paciente = PC.id_paciente
     WHERE YEAR(C2.data_hora) = 2020) AS valor_medio_consultas_2020_convenio
FROM consulta C
JOIN paciente_convenio PC ON C.id_paciente = PC.id_paciente
WHERE YEAR(C.data_hora) = 2020;


-- Consulta 2: Todos os dados das internações que tiveram data de alta maior que a data prevista para a alta.
SELECT
    I.*,
    P.nome AS nome_paciente
FROM internacao I
JOIN paciente P ON I.id_paciente = P.id_paciente
WHERE I.data_saida_efetiva IS NOT NULL
  AND I.data_saida_efetiva > I.data_saida_prevista;


-- Consulta 3: Receituário completo da primeira consulta registrada com receituário associado.
-- A primeira consulta com receituário é a de ID 11 (na nossa base povoada).
SELECT
    C.id_consulta,
    C.data_hora AS Data_Consulta,
    M.nome AS Medicamento,
    IR.quantidade AS Qtd_Prescrita,
    IR.instrucoes AS Modo_Uso
FROM consulta C
JOIN receituario R ON C.id_consulta = R.id_consulta
JOIN item_receituario IR ON R.id_receituario = IR.id_receituario
JOIN medicamento M ON IR.id_medicamento = M.id_medicamento
ORDER BY C.data_hora ASC
LIMIT 1;


-- Consulta 4: Todos os dados da consulta de maior valor e também da de menor valor 
-- (ambas as consultas não foram realizadas sob convênio).
-- NOTA: Como não há um campo "id_convenio" na tabela consulta, filtramos pacientes SEM convênio.

-- Consulta de MAIOR valor (Sem Convênio)
(SELECT 'Maior Valor' AS Tipo_Consulta, C.*
FROM consulta C
LEFT JOIN paciente_convenio PC ON C.id_paciente = PC.id_paciente
WHERE PC.id_convenio IS NULL -- Paciente SEM convênio
ORDER BY C.valor_consulta DESC
LIMIT 1)
UNION ALL
-- Consulta de MENOR valor (Sem Convênio)
(SELECT 'Menor Valor' AS Tipo_Consulta, C.*
FROM consulta C
LEFT JOIN paciente_convenio PC ON C.id_paciente = PC.id_paciente
WHERE PC.id_convenio IS NULL -- Paciente SEM convênio
ORDER BY C.valor_consulta ASC
LIMIT 1);


-- Consulta 5: Todos os dados das internações em seus respectivos quartos, calculando o total da internação
-- a partir do valor de diária do quarto e o número de dias entre a entrada e a alta.
SELECT
    I.id_internacao,
    P.nome AS Paciente,
    I.data_entrada,
    I.data_saida_efetiva,
    TQ.descricao AS Tipo_Quarto,
    TQ.valor_diaria,
    DATEDIFF(I.data_saida_efetiva, I.data_entrada) AS Dias_Internados,
    (DATEDIFF(I.data_saida_efetiva, I.data_entrada) * TQ.valor_diaria) AS Custo_Total_Diarias
FROM internacao I
JOIN quarto Q ON I.numero_quarto = Q.numero_quarto
JOIN tipo_quarto TQ ON Q.id_tipo = TQ.id_tipo
WHERE I.data_saida_efetiva IS NOT NULL; -- Apenas internações finalizadas


-- Consulta 6: Data, procedimento e número de quarto de internações em quartos do tipo “apartamento”.
SELECT
    I.data_entrada,
    I.descricao_procedimentos AS Procedimento,
    I.numero_quarto
FROM internacao I
JOIN quarto Q ON I.numero_quarto = Q.numero_quarto
JOIN tipo_quarto TQ ON Q.id_tipo = TQ.id_tipo
WHERE TQ.descricao = 'Apartamento';


-- Consulta 7: Nome do paciente, data da consulta e especialidade de todas as consultas em que os pacientes
-- eram menores de 18 anos na data da consulta e cuja especialidade não seja “pediatria”, 
-- ordenando por data de realização da consulta.
SELECT
    P.nome AS Paciente,
    C.data_hora AS Data_Consulta,
    E.nome_especialidade AS Especialidade
FROM consulta C
JOIN paciente P ON C.id_paciente = P.id_paciente
JOIN especialidade E ON C.id_especialidade = E.id_especialidade
WHERE
    -- Verifica se o paciente era menor de 18 anos na data da consulta
    TIMESTAMPDIFF(YEAR, P.data_nascimento, DATE(C.data_hora)) < 18
    -- Verifica se a especialidade não é Pediatria (ID 1 na nossa base)
    AND E.id_especialidade <> 1
ORDER BY C.data_hora ASC;


-- Consulta 8: Nome do paciente, nome do médico, data da internação e procedimentos das internações 
-- realizadas por médicos da especialidade “gastroenterologia”, que tenham acontecido em “enfermaria”.
SELECT
    P.nome AS Paciente,
    M.nome AS Medico_Responsavel,
    I.data_entrada,
    I.descricao_procedimentos AS Procedimentos
FROM internacao I
JOIN paciente P ON I.id_paciente = P.id_paciente
JOIN medico M ON I.crm_medico = M.crm_medico
JOIN medico_especialidade ME ON M.crm_medico = ME.crm_medico
JOIN especialidade E ON ME.id_especialidade = E.id_especialidade
JOIN quarto Q ON I.numero_quarto = Q.numero_quarto
JOIN tipo_quarto TQ ON Q.id_tipo = TQ.id_tipo
WHERE
    E.nome_especialidade = 'Gastrenterologia'
    AND TQ.descricao = 'Enfermaria'
GROUP BY I.id_internacao; -- Agrupa por internação para evitar duplicidade de médico-especialidade


-- Consulta 9: Os nomes dos médicos, seus CRMs e a quantidade de consultas que cada um realizou.
SELECT
    M.nome AS Medico,
    M.crm_medico AS CRM,
    COUNT(C.id_consulta) AS Total_Consultas_Realizadas
FROM medico M
LEFT JOIN consulta C ON M.crm_medico = C.crm_medico
GROUP BY M.crm_medico, M.nome
ORDER BY Total_Consultas_Realizadas DESC, M.nome;


-- Consulta 10: Todos os médicos que tenham "Gabriel" no nome.
SELECT
    crm_medico,
    nome,
    em_atividade
FROM medico
WHERE nome LIKE '%Gabriel%';


-- Consulta 11: Os nomes, CREs e número de internações de enfermeiros que participaram de mais de uma internação.
SELECT
    E.nome AS Enfermeiro,
    E.cre_enfermeiro AS CRE,
    COUNT(II.id_internacao) AS Total_Internacoes
FROM enfermeiro E
JOIN internacao_infermeiro II ON E.cre_enfermeiro = II.cre_enfermeiro
GROUP BY E.cre_enfermeiro, E.nome
HAVING Total_Internacoes > 1
ORDER BY Total_Internacoes DESC, E.nome;