from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
from enum import Enum

app = FastAPI(title="API AutoManage - Oficina Mecânica")

class StatusOS(str, Enum):
    ABERTA = "ABERTA"
    EM_ANALISE = "EM_ANALISE"
    AGUARDANDO_PECAS = "AGUARDANDO_PECAS"
    EM_EXECUCAO = "EM_EXECUCAO"
    PRONTO = "PRONTO"
    FINALIZADA = "FINALIZADA"

class Cliente(BaseModel):
    nome: str
    telefone: str
    cpf: str

class Veiculo(BaseModel):
    placa: str
    modelo: str
    marca: str
    ano: int
    cpf_cliente: str

class OrdemServicoBase(BaseModel):
    placa_veiculo: str
    id_mecanico: int
    observacoes_iniciais: Optional[str] = None

class AtualizacaoStatus(BaseModel):
    novo_status: StatusOS


db_clientes = []
db_veiculos = []
db_os = {}
contador_os = 1


@app.post("/clientes/", tags=["Clientes"])
def cadastrar_cliente(cliente: Cliente):
    db_clientes.append(cliente.dict())
    return {"mensagem": "Cliente registado com sucesso", "cliente": cliente}

@app.post("/veiculos/", tags=["Veículos"])
def cadastrar_veiculo(veiculo: Veiculo):
    db_veiculos.append(veiculo.dict())
    return {"mensagem": "Veículo registado com sucesso", "veiculo": veiculo}

@app.post("/os/", tags=["Ordens de Serviço"])
def abrir_ordem_servico(os: OrdemServicoBase):
    global contador_os
    nova_os = {
        "numero_os": contador_os,
        "placa_veiculo": os.placa_veiculo,
        "id_mecanico": os.id_mecanico,
        "data_abertura": datetime.now().isoformat(),
        "status": StatusOS.ABERTA,
        "valor_total": 0.0
    }
    db_os[contador_os] = nova_os
    contador_os += 1
    return {"mensagem": "Ordem de Serviço aberta.", "os": nova_os}

@app.put("/os/{numero_os}/status", tags=["Ordens de Serviço"])
def atualizar_status_os(numero_os: int, atualizacao: AtualizacaoStatus):
    if numero_os not in db_os:
        raise HTTPException(status_code=404, detail="Ordem de Serviço não encontrada.")
    
    os_atual = db_os[numero_os]
    os_atual["status"] = atualizacao.novo_status
    
    if atualizacao.novo_status in [StatusOS.PRONTO, StatusOS.FINALIZADA]:
        os_atual["data_conclusao"] = datetime.now().isoformat()
        
    return {"mensagem": f"Status alterado para {atualizacao.novo_status.value}", "os": os_atual}

@app.get("/os/{numero_os}", tags=["Ordens de Serviço"])
def consultar_os(numero_os: int):
    if numero_os not in db_os:
        raise HTTPException(status_code=404, detail="Ordem de Serviço não encontrada.")
    return db_os[numero_os]