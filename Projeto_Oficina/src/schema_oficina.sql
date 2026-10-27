CREATE TABLE Cliente (
    idCliente INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    cpf VARCHAR(14) UNIQUE NOT NULL,
    endereco VARCHAR(255)
);

CREATE TABLE Veiculo (
    placa VARCHAR(10) PRIMARY KEY,
    modelo VARCHAR(50) NOT NULL,
    marca VARCHAR(50) NOT NULL,
    ano INT NOT NULL,
    idCliente INT,
    FOREIGN KEY (idCliente) REFERENCES Cliente(idCliente) ON DELETE CASCADE
);

CREATE TABLE Mecanico (
    idMecanico INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100) NOT NULL,
    especialidade VARCHAR(50) NOT NULL
);

CREATE TABLE Peca (
    idPeca INT PRIMARY KEY AUTO_INCREMENT,
    descricao VARCHAR(100) NOT NULL,
    quantidadeEstoque INT NOT NULL DEFAULT 0,
    precoUnitario DECIMAL(10,2) NOT NULL
);

CREATE TABLE Servico (
    idServico INT PRIMARY KEY AUTO_INCREMENT,
    descricao VARCHAR(100) NOT NULL,
    valorPadrao DECIMAL(10,2) NOT NULL
);

CREATE TABLE OrdemServico (
    numeroOS INT PRIMARY KEY AUTO_INCREMENT,
    dataAbertura DATETIME DEFAULT CURRENT_TIMESTAMP,
    dataConclusao DATETIME,
    status ENUM('ABERTA', 'EM_ANALISE', 'AGUARDANDO_PECAS', 'EM_EXECUCAO', 'PRONTO', 'FINALIZADA') DEFAULT 'ABERTA',
    valorTotal DECIMAL(10,2) DEFAULT 0.00,
    placaVeiculo VARCHAR(10),
    idMecanico INT,
    FOREIGN KEY (placaVeiculo) REFERENCES Veiculo(placa),
    FOREIGN KEY (idMecanico) REFERENCES Mecanico(idMecanico)
);


CREATE TABLE ItemOS_Peca (
    numeroOS INT,
    idPeca INT,
    quantidade INT NOT NULL,
    precoCobrado DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (numeroOS, idPeca),
    FOREIGN KEY (numeroOS) REFERENCES OrdemServico(numeroOS) ON DELETE CASCADE,
    FOREIGN KEY (idPeca) REFERENCES Peca(idPeca)
);

CREATE TABLE ItemOS_Servico (
    numeroOS INT,
    idServico INT,
    valorCobrado DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (numeroOS, idServico),
    FOREIGN KEY (numeroOS) REFERENCES OrdemServico(numeroOS) ON DELETE CASCADE,
    FOREIGN KEY (idServico) REFERENCES Servico(idServico)
);