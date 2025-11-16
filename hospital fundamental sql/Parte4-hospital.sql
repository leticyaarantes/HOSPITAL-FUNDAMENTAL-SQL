-- Adiciona a coluna 'em_atividade' na tabela 'medico'
ALTER TABLE medico
ADD COLUMN em_atividade BOOLEAN NOT NULL DEFAULT TRUE;

-- Atualiza Dr. Daniel Souza (CRM/SP 123459) para inativo
UPDATE medico
SET em_atividade = FALSE
WHERE crm_medico = 'CRM/SP 123459';

-- Atualiza Dr. Isabel Rocha (CRM/SP 123464) para inativo
UPDATE medico
SET em_atividade = FALSE
WHERE crm_medico = 'CRM/SP 123464';

-- Confere o resultado da alteração:
SELECT crm_medico, nome, em_atividade
FROM medico
ORDER BY em_atividade DESC, nome;

-- Identifica as consultas mais antigas (IDs 1 a 10)
SET @consultas_antigas = (SELECT GROUP_CONCAT(id_consulta) FROM consulta ORDER BY data_hora ASC LIMIT 10);

-- 1.1. EXCLUIR ITENS DE RECEITUÁRIO relacionados a essas consultas (se houver)
DELETE FROM item_receituario
WHERE id_receituario IN (
    SELECT id_receituario
    FROM receituario
    WHERE id_consulta IN (@consultas_antigas)
);

-- 1.2. EXCLUIR RECEITUÁRIOS relacionados a essas consultas (se houver)
DELETE FROM receituario
WHERE id_consulta IN (@consultas_antigas);

-- 1.3. EXCLUIR AS CONSULTAS mais antigas
DELETE FROM consulta
WHERE id_consulta IN (@consultas_antigas);

-- Verificação (Deve retornar 10 consultas)
SELECT COUNT(*) FROM consulta;

-- Identifica as 5 internações mais recentes (IDs 3, 4, 5, 6, 7, se olharmos as datas, mas usaremos a ordenação)
SET @internacoes_recentes = (SELECT GROUP_CONCAT(id_internacao) FROM internacao ORDER BY data_entrada DESC LIMIT 5);

-- 2.1. EXCLUIR RELACIONAMENTO COM ENFERMEIROS (tabela internacao_infermeiro)
DELETE FROM internacao_infermeiro
WHERE id_internacao IN (@internacoes_recentes);

-- 2.2. EXCLUIR AS INTERNAÇÕES mais recentes
DELETE FROM internacao
WHERE id_internacao IN (@internacoes_recentes);

-- Verificação (Deve retornar 2 internações)
SELECT COUNT(*) FROM internacao;