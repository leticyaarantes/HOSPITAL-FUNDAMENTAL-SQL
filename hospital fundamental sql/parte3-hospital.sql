-- #################################################################
-- 1. ESTRUTURA DO BANCO DE DADOS (DDL)
-- #################################################################

-- TABELAS DE DADOS ESSENCIAIS (POVOAMENTO OBRIGATÓRIO)
CREATE TABLE Especialidade (
    EspecialidadeID SERIAL PRIMARY KEY,
    Nome VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE Convenio (
    ConvenioID SERIAL PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL UNIQUE,
    Valor DECIMAL(10, 2) NOT NULL
);

CREATE TABLE Tipo_Quarto (
    TipoQuartoID SERIAL PRIMARY KEY,
    Descricao VARCHAR(50) NOT NULL UNIQUE,
    ValorDiaria DECIMAL(10, 2) NOT NULL
);

-- ENTIDADES PRINCIPAIS
CREATE TABLE Medico (
    MedicoID SERIAL PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL,
    CRM VARCHAR(15) NOT NULL UNIQUE,
    Telefone VARCHAR(15)
);

CREATE TABLE Enfermeiro (
    EnfermeiroID SERIAL PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL,
    COREN VARCHAR(15) NOT NULL UNIQUE
);

CREATE TABLE Paciente (
    PacienteID SERIAL PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL,
    CPF VARCHAR(14) NOT NULL UNIQUE,
    DataNascimento DATE,
    ConvenioID INT,
    FOREIGN KEY (ConvenioID) REFERENCES Convenio(ConvenioID)
);

CREATE TABLE Quarto (
    QuartoID SERIAL PRIMARY KEY,
    Numero VARCHAR(10) NOT NULL UNIQUE,
    TipoQuartoID INT NOT NULL,
    FOREIGN KEY (TipoQuartoID) REFERENCES Tipo_Quarto(TipoQuartoID)
);

-- ENTIDADE DE RELACIONAMENTO (M:M): Medico <-> Especialidade
CREATE TABLE Medico_Especialidade (
    MedicoID INT NOT NULL,
    EspecialidadeID INT NOT NULL,
    PRIMARY KEY (MedicoID, EspecialidadeID),
    FOREIGN KEY (MedicoID) REFERENCES Medico(MedicoID),
    FOREIGN KEY (EspecialidadeID) REFERENCES Especialidade(EspecialidadeID)
);

-- CONSULTAS
CREATE TABLE Consulta (
    ConsultaID SERIAL PRIMARY KEY,
    PacienteID INT NOT NULL,
    MedicoID INT NOT NULL,
    ConvenioID INT, -- Associado ao convênio para cálculo de valor
    DataConsulta TIMESTAMP NOT NULL,
    Valor DECIMAL(10, 2) NOT NULL,
    Diagnostico TEXT,
    FOREIGN KEY (PacienteID) REFERENCES Paciente(PacienteID),
    FOREIGN KEY (MedicoID) REFERENCES Medico(MedicoID),
    FOREIGN KEY (ConvenioID) REFERENCES Convenio(ConvenioID)
);

-- RECEITUÁRIO (RELACIONAMENTO 1:N com Consulta)
CREATE TABLE Receituario (
    ReceituarioID SERIAL PRIMARY KEY,
    ConsultaID INT NOT NULL UNIQUE,
    Descricao TEXT,
    FOREIGN KEY (ConsultaID) REFERENCES Consulta(ConsultaID)
);

-- MEDICAMENTO (RELACIONAMENTO 1:N com Receituario)
CREATE TABLE Medicamento (
    MedicamentoID SERIAL PRIMARY KEY,
    ReceituarioID INT NOT NULL,
    Nome VARCHAR(100) NOT NULL,
    Dosagem VARCHAR(50),
    FOREIGN KEY (ReceituarioID) REFERENCES Receituario(ReceituarioID)
);

-- INTERNAÇÃO
CREATE TABLE Internacao (
    InternacaoID SERIAL PRIMARY KEY,
    PacienteID INT NOT NULL,
    MedicoID INT NOT NULL, -- Chave Estrangeira Médico (solicitante)
    QuartoID INT NOT NULL,
    DataEntrada TIMESTAMP NOT NULL,
    DataSaida TIMESTAMP,
    ValorTotal DECIMAL(10, 2),
    Procedimento TEXT,
    FOREIGN KEY (PacienteID) REFERENCES Paciente(PacienteID),
    FOREIGN KEY (MedicoID) REFERENCES Medico(MedicoID),
    FOREIGN KEY (QuartoID) REFERENCES Quarto(QuartoID)
);

-- ENTIDADE DE RELACIONAMENTO (M:M): Internacao <-> Enfermeiro
CREATE TABLE Internacao_Enfermeiro (
    InternacaoID INT NOT NULL,
    EnfermeiroID INT NOT NULL,
    PRIMARY KEY (InternacaoID, EnfermeiroID),
    FOREIGN KEY (InternacaoID) REFERENCES Internacao(InternacaoID),
    FOREIGN KEY (EnfermeiroID) REFERENCES Enfermeiro(EnfermeiroID)
);

-- #################################################################
-- 2. POPULAÇÃO DE DADOS ESSENCIAIS
-- #################################################################

-- Tipos de Quarto (Al menos três tipos con valores diferentes)
INSERT INTO Tipo_Quarto (Descricao, ValorDiaria) VALUES
('Apartamento', 450.00),
('Quarto Duplo', 300.00),
('Enfermaria', 150.00),
('Semi-privativo', 220.00);

-- Convênios Médicos (Al menos cuatro)
INSERT INTO Convenio (Nome, Valor) VALUES
('Particular', 0.00),
('SulAmérica Saúde', 80.00),
('Unimed Nacional', 75.00),
('Amil Fácil', 60.00);

-- Especialidades (Al menos siete especialidades)
INSERT INTO Especialidade (Nome) VALUES
('Clínica Geral'),
('Pediatria'),
('Gastrenterologia'),
('Dermatologia'),
('Cardiologia'),
('Neurologia'),
('Ortopedia'),
('Infectologia'),
('Ginecologia');

-- Quarto (Al menos tres quartos cadastrados)
INSERT INTO Quarto (Numero, TipoQuartoID) VALUES
('101A', 1), -- Apartamento
('205D', 2), -- Quarto Duplo
('301E', 3), -- Enfermaria
('102A', 1); -- Apartamento

-- #################################################################
-- 3. POPULAÇÃO DE DADOS PRINCIPAIS (DML)
-- #################################################################

-- Médicos (Al menos diez médicos)
INSERT INTO Medico (Nome, CRM, Telefone) VALUES
('Dr. Roberto Silva', 'CRM/SP 12345', '11987654321'),      -- 1
('Dra. Ana Costa', 'CRM/SP 54321', '11987654322'),        -- 2
('Dr. Carlos Mendes', 'CRM/SP 98765', '11987654323'),    -- 3
('Dra. Beatriz Lopes', 'CRM/SP 11223', '11987654324'),   -- 4
('Dr. Fernando Pires', 'CRM/RJ 22334', '21987654325'),    -- 5
('Dra. Laura Souza', 'CRM/SP 33445', '11987654326'),      -- 6
('Dr. Paulo Ramos', 'CRM/MG 44556', '31987654327'),       -- 7
('Dra. Camila Nogueira', 'CRM/RJ 55667', '21987654328'), -- 8
('Dr. Daniel Lima', 'CRM/SP 66778', '11987654329'),      -- 9
('Dra. Erika Farias', 'CRM/DF 77889', '61987654330');     -- 10

-- Relacionamento Médico <-> Especialidade
-- Dr. Roberto Silva (1): Clínica Geral (1), Cardiologia (5)
-- Dra. Ana Costa (2): Pediatria (2)
-- Dr. Carlos Mendes (3): Gastrenterologia (3)
-- Dra. Beatriz Lopes (4): Dermatologia (4)
-- Dr. Fernando Pires (5): Cardiologia (5), Ortopedia (7)
-- Dra. Laura Souza (6): Neurologia (6)
-- Dr. Paulo Ramos (7): Ortopedia (7)
-- Dra. Camila Nogueira (8): Infectologia (8)
-- Dr. Daniel Lima (9): Ginecologia (9), Clínica Geral (1)
-- Dra. Erika Farias (10): Pediatria (2)

INSERT INTO Medico_Especialidade (MedicoID, EspecialidadeID) VALUES
(1, 1), (1, 5), (2, 2), (3, 3), (4, 4), (5, 5), (5, 7),
(6, 6), (7, 7), (8, 8), (9, 9), (9, 10);


-- Enfermeiros (Al menos diez profesionales)
INSERT INTO Enfermeiro (Nome, COREN) VALUES
('Enf. Maria Oliveira', 'COREN/SP 1001'), -- 1
('Enf. João Pereira', 'COREN/SP 1002'),   -- 2
('Enf. Sofia Santos', 'COREN/RJ 1003'),   -- 3
('Enf. Lucas Ferreira', 'COREN/SP 1004'), -- 4
('Enf. Diana Gomes', 'COREN/MG 1005'),    -- 5
('Enf. Felipe Rocha', 'COREN/SP 1006'),   -- 6
('Enf. Helena Alves', 'COREN/SP 1007'),   -- 7
('Enf. Gustavo Mendes', 'COREN/DF 1008'),  -- 8
('Enf. Isabella Lima', 'COREN/RJ 1009'),  -- 9
('Enf. Victor Ribeiro', 'COREN/SP 1010'); -- 10

-- Pacientes (Al menos quince pacientes)
INSERT INTO Paciente (Nome, CPF, DataNascimento, ConvenioID) VALUES
('Mariana Lima', '111.111.111-11', '1990-05-15', 2), -- 1 (SulAmérica) - Consulta/Internação
('João Silva', '222.222.222-22', '1985-10-20', 3),   -- 2 (Unimed) - Consulta/Internação
('Pedro Souza', '333.333.333-33', '2010-03-01', 2),  -- 3 (SulAmérica) - Consulta
('Carla Reis', '444.444.444-44', '1975-12-05', 4),   -- 4 (Amil) - Consulta/Internação
('Alexandre Costa', '555.555.555-55', '1960-01-30', 1), -- 5 (Particular) - Consulta/Internação
('Fernanda Alves', '666.666.666-66', '1995-07-25', 3), -- 6 (Unimed) - Consulta
('Ricardo Moura', '777.777.777-77', '1980-04-10', 4), -- 7 (Amil) - Consulta/Internação
('Juliana Santos', '888.888.888-88', '2005-09-18', 2),-- 8 (SulAmérica) - Consulta
('Gustavo Dias', '999.999.999-99', '1970-11-28', 1), -- 9 (Particular) - Consulta
('Patricia Lima', '000.000.000-00', '1992-02-02', 3),-- 10 (Unimed) - Consulta
('Rafaela Gomes', '101.101.101-01', '2000-08-14', 4), -- 11 (Amil) - Consulta
('Sergio Braga', '121.121.121-21', '1988-06-03', 1),  -- 12 (Particular) - Consulta
('Tânia Viana', '131.131.131-31', '1977-01-19', 2),   -- 13 (SulAmérica) - Consulta
('Victor Melo', '141.141.141-41', '1965-04-29', 3),   -- 14 (Unimed) - Consulta
('Wanda Xavier', '151.151.151-51', '1998-11-11', 4);  -- 15 (Amil) - Consulta

-- Consultas (Al menos 20 consultas)
-- As consultas 1, 3, 5, 7, 9, 11, 13, 15, 17, 19 terão Receituário com 2+ medicamentos
INSERT INTO Consulta (PacienteID, MedicoID, ConvenioID, DataConsulta, Valor, Diagnostico) VALUES
-- 1. Receituário Múltiplo (5 -> PARTICULAR)
(5, 3, 1, '2015-02-10 10:00:00', 350.00, 'Gastrite Crônica'),
-- 2. Simples
(2, 2, 3, '2015-05-20 14:30:00', 75.00, 'Gripe sazonal'),
-- 3. Receituário Múltiplo (1 -> SulAmérica)
(1, 4, 2, '2016-01-15 09:00:00', 80.00, 'Dermatite atópica'),
-- 4. Simples
(3, 2, 2, '2016-03-22 11:00:00', 80.00, 'Rotina Pediatria'),
-- 5. Receituário Múltiplo (5 -> PARTICULAR)
(5, 5, 1, '2017-08-05 16:00:00', 400.00, 'Dor no joelho e artrose'),
-- 6. Simples
(6, 1, 3, '2017-11-11 08:30:00', 75.00, 'Check-up anual'),
-- 7. Receituário Múltiplo (4 -> Amil)
(4, 6, 4, '2018-02-28 13:00:00', 60.00, 'Cefaleia tensional'),
-- 8. Simples (7 -> Amil)
(7, 3, 4, '2018-05-18 10:30:00', 60.00, 'Dificuldade de digestão'),
-- 9. Receituário Múltiplo
(8, 2, 2, '2019-01-01 15:00:00', 80.00, 'Amigdalite Bacteriana'),
-- 10. Simples
(9, 1, 1, '2019-06-03 09:30:00', 300.00, 'Risco Cardiovascular'),
-- 11. Receituário Múltiplo (12 -> PARTICULAR)
(12, 6, 1, '2019-11-20 14:00:00', 350.00, 'Nevralgia do trigêmeo'),
-- 12. Simples
(10, 3, 3, '2020-01-10 11:30:00', 75.00, 'Colite leve'),
-- 13. Receituário Múltiplo (2 -> Unimed)
(2, 5, 3, '2020-04-05 10:00:00', 75.00, 'Avaliação Cardíaca'),
-- 14. Simples
(11, 4, 4, '2020-07-07 15:30:00', 60.00, 'Acne persistente'),
-- 15. Receituário Múltiplo (7 -> Amil)
(7, 6, 4, '2020-10-14 12:00:00', 60.00, 'Tontura e labirintite'),
-- 16. Simples (9 -> PARTICULAR)
(9, 9, 1, '2021-01-25 16:30:00', 350.00, 'Rotina ginecológica'),
-- 17. Receituário Múltiplo (14 -> Unimed)
(14, 5, 3, '2021-05-02 08:00:00', 75.00, 'Dor Crônica no joelho'),
-- 18. Simples
(15, 1, 4, '2021-09-19 14:00:00', 60.00, 'Avaliação Clínica'),
-- 19. Receituário Múltiplo (13 -> SulAmérica)
(13, 8, 2, '2021-11-30 11:00:00', 80.00, 'Febre prolongada'),
-- 20. Simples
(1, 10, 2, '2022-01-01 09:00:00', 80.00, 'Check-up do filho');

-- Receituários (10 com múltiplos medicamentos)
INSERT INTO Receituario (ConsultaID, Descricao) VALUES
(1, 'Tratamento de 6 semanas para H. pylori.'),
(3, 'Cremes e comprimidos para surto alérgico.'),
(5, 'Medicação para dor e inflamação articular crônica.'),
(7, 'Analgésicos específicos para enxaquecas e relaxante muscular.'),
(9, 'Antibiótico de amplo espectro para infecção de garganta.'),
(11, 'Medicação controlada para dor neuropática.'),
(13, 'Remédio para pressão e anticoagulante.'),
(15, 'Medicação para controle de vertigem e náuseas.'),
(17, 'Analgésico potente e suplemento para cartilagem.'),
(19, 'Antipirético e antibiótico de uso restrito.');

-- Medicamentos (Al menos 2 medicamentos por receituário)
INSERT INTO Medicamento (ReceituarioID, Nome, Dosagem) VALUES
(1, 'Omeprazol', '20mg'), (1, 'Amoxicilina', '500mg'),
(3, 'Creme de Hidrocortisona', '0.5%'), (3, 'Cetirizina', '10mg'),
(5, 'Celecoxib', '200mg'), (5, 'Tramadol', '50mg'),
(7, 'Sumatriptano', '50mg'), (7, 'Diazepam', '5mg'),
(9, 'Azitromicina', '500mg'), (9, 'Paracetamol', '750mg'),
(11, 'Gabapentina', '300mg'), (11, 'Codeína', '30mg'),
(13, 'Losartana', '50mg'), (13, 'Rivaroxabana', '10mg'),
(15, 'Cinarizina', '25mg'), (15, 'Dimenidrinato', '50mg'),
(17, 'Diclofenaco', '100mg'), (17, 'Condroitina', '500mg'),
(19, 'Novalgina', '1g'), (19, 'Ceftriaxona', '1g');


-- Internações (Al menos siete internações, 2 pacientes com múltiplas internações)
INSERT INTO Internacao (PacienteID, MedicoID, QuartoID, DataEntrada, DataSaida, ValorTotal, Procedimento) VALUES
-- 1. Paciente 1: Mariana Lima (1) - 1ª Internação
(1, 1, 1, '2015-09-01 18:00:00', '2015-09-04 10:00:00', 1350.00, 'Avaliação Cardiológica e Angiografia'),
-- 2. Paciente 2: João Silva (2) - 1ª Internação
(2, 5, 2, '2016-12-10 12:00:00', '2016-12-15 17:00:00', 1500.00, 'Cirurgia de Apendicite'),
-- 3. Paciente 4: Carla Reis (4) - 1ª Internação
(4, 6, 3, '2017-04-20 09:00:00', '2017-04-22 14:00:00', 450.00, 'Investigação Neurológica (P. punção)'),
-- 4. Paciente 5: Alexandre Costa (5) - 1ª Internação
(5, 7, 4, '2018-10-01 14:00:00', '2018-10-06 11:00:00', 2250.00, 'Fratura de fêmur e colocação de pino'),
-- 5. Paciente 1: Mariana Lima (1) - 2ª Internação (paciente com múltiplas internações)
(1, 1, 1, '2019-03-15 07:00:00', '2019-03-17 18:00:00', 900.00, 'Reajuste Medicamentoso Pós-Alta'),
-- 6. Paciente 7: Ricardo Moura (7) - 1ª Internação
(7, 3, 2, '2020-08-08 10:00:00', '2020-08-10 10:00:00', 600.00, 'Colonoscopia e Biópsia'),
-- 7. Paciente 2: João Silva (2) - 2ª Internação (paciente com múltiplas internações)
(2, 8, 3, '2021-06-25 19:00:00', '2021-06-28 15:00:00', 450.00, 'Infecção Pós-Cirúrgica');

-- Relacionamento Internacao <-> Enfermeiro (Al menos 2 enfermeiros por internação)
INSERT INTO Internacao_Enfermeiro (InternacaoID, EnfermeiroID) VALUES
(1, 1), (1, 2), -- Int 1
(2, 3), (2, 4), -- Int 2
(3, 5), (3, 6), -- Int 3
(4, 7), (4, 8), -- Int 4
(5, 9), (5, 10), -- Int 5
(6, 1), (6, 3), -- Int 6
(7, 2), (7, 5); -- Int 7
