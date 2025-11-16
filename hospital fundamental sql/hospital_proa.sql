-- O "CREATE TYPE" foi removido.

CREATE TABLE medico (
	id INT PRIMARY KEY AUTO_INCREMENT, -- MUDANÇA: de SERIAL para INT AUTO_INCREMENT
	crm VARCHAR(15) NOT NULL UNIQUE,
	nome VARCHAR(255) NOT NULL,
	tipo ENUM ('generalista', 'residente', 'especialista') NOT NULL -- MUDANÇA: O ENUM é definido aqui
);

CREATE TABLE especialidade (
	id INT PRIMARY KEY AUTO_INCREMENT, -- MUDANÇA
	nome VARCHAR(255) NOT NULL
);

CREATE TABLE medico_especialidade (
	id_medico INT NOT NULL,
	id_especialidade INT NOT NULL,
	CONSTRAINT pk_medico_especialidade PRIMARY KEY (id_medico, id_especialidade),
	CONSTRAINT fk_me_medico FOREIGN KEY (id_medico) REFERENCES medico(id),
	CONSTRAINT fk_me_especialidade FOREIGN KEY (id_especialidade) REFERENCES especialidade(id)
);

CREATE TABLE paciente (
	id INT PRIMARY KEY AUTO_INCREMENT, -- MUDANÇA
	nome VARCHAR(255) NOT NULL,
	cpf VARCHAR(11) NOT NULL UNIQUE,
	rg VARCHAR(10) NOT NULL UNIQUE,
	data_nascimento DATE NOT NULL,
	email VARCHAR(255) NOT NULL,
	-- ATRIBUTOS DE ENDERECO
	rua VARCHAR(255) NOT NULL,
	numero INT NOT NULL,
	complemento VARCHAR(255),
	estado CHAR(2) NOT NULL,
	cidade VARCHAR(255) NOT NULL
);

CREATE TABLE telefone_paciente (
	id_paciente INT NOT NULL,
	numero_telefone VARCHAR(15) NOT NULL,
	CONSTRAINT pk_tp_telefone PRIMARY KEY (id_paciente, numero_telefone),
	CONSTRAINT fk_tp_paciente FOREIGN KEY (id_paciente) REFERENCES paciente(id)
);

CREATE TABLE convenio (
	id INT PRIMARY KEY AUTO_INCREMENT, -- MUDANÇA
	cnpj VARCHAR(15) NOT NULL UNIQUE,
	nome VARCHAR(255) NOT NULL
);

CREATE TABLE paciente_convenio (
	id_paciente INT NOT NULL,
	id_convenio INT NOT NULL,
	tempo_carencia INT NOT NULL,
	CONSTRAINT pk_paciente_convenio PRIMARY KEY(id_paciente, id_convenio),
	CONSTRAINT fk_pc_paciente FOREIGN KEY(id_paciente) REFERENCES paciente (id),
	CONSTRAINT fk_pc_convenio FOREIGN KEY(id_convenio) REFERENCES convenio (id)
);


CREATE TABLE consulta (
	id_consulta INT PRIMARY KEY AUTO_INCREMENT, -- MUDANÇA
	id_paciente INT NOT NULL,
	id_medico INT NOT NULL,
	valor_consulta NUMERIC(10,2),
	hora_realizacao TIME NOT NULL,
	data_realizacao DATE NOT NULL,
	CONSTRAINT fk_c_paciente FOREIGN KEY (id_paciente) REFERENCES paciente(id),
	CONSTRAINT fk_c_medico FOREIGN KEY (id_medico) REFERENCES medico(id)
);


-- PARTE 2


CREATE TABLE tipo_quarto (
	id INT PRIMARY KEY AUTO_INCREMENT, -- MUDANÇA
	descricao VARCHAR(50) NOT NULL,
	valor_diaria NUMERIC(8,2) NOT NULL
);

CREATE TABLE quarto (
	id INT PRIMARY KEY AUTO_INCREMENT, -- MUDANÇA
	tipo_quarto INT NOT NULL,
	numero INT NOT NULL,
	FOREIGN KEY (tipo_quarto) REFERENCES tipo_quarto (id)
);

CREATE TABLE internacao (
	id INT PRIMARY KEY AUTO_INCREMENT, -- MUDANÇA
	id_paciente INT NOT NULL,
	id_medico INT NOT NULL,
	id_quarto INT NOT NULL,
	procedimento VARCHAR(255) NOT NULL,
	data_entrada DATE NOT NULL,
	data_prev_alta DATE NOT NULL,
	data_alta DATE,
	CONSTRAINT fk_i_paciente FOREIGN KEY (id_paciente) REFERENCES paciente (id),
	CONSTRAINT fk_i_medico FOREIGN KEY (id_medico) REFERENCES medico (id),
	CONSTRAINT fk_i_quarto FOREIGN KEY (id_quarto) REFERENCES quarto (id)
);

CREATE TABLE enfermeiro (
	id INT PRIMARY KEY AUTO_INCREMENT, -- MUDANÇA
	cpf VARCHAR(11) NOT NULL UNIQUE,
	cre VARCHAR(12) NOT NULL UNIQUE,
	nome VARCHAR(100) NOT NULL
);

CREATE TABLE internacao_enfermeiro (
	id_enfermeiro INT NOT NULL,
	id_internacao INT NOT NULL,
	CONSTRAINT pk_internacao_enfermeiro PRIMARY KEY(id_enfermeiro, id_internacao),
	CONSTRAINT fk_ie_enfermeiro FOREIGN KEY (id_enfermeiro) REFERENCES enfermeiro(id),
	CONSTRAINT fk_ie_internacao FOREIGN KEY (id_internacao) REFERENCES internacao(id)
);