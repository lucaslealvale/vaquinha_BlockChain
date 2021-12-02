# Codigo baseado nas aulas de Ativos digitais por Raul Ikeda e referencias 
#da propria documentacao do vyper, disponivel em https://vyper.readthedocs.io


#Variaveis globais vaquinha:
dono: address # endereço do dono da vaquinha
meta: uint256 # meta a ser atingida na vaquinha
acumulado: uint256 # montante acumulado
validade: uint256 # data do encerramento da vaquinha
end: bool
complete: bool

struct doador:
    carteira: address # endereco da carteira do doador
    valor: uint256 # valor doado

# Dicionário que indica se determinado usuário doou algum valor
doadores: public(HashMap[address, doador])



# Função que roda quando é feito o deploy do contrato
@external
def __init__(meta:uint256, validade:uint256):
    self.dono = msg.sender
    self.meta = meta
    self.acumulado = 0
    self.validade = block.timestamp + validade # funcionalidade do timestamp retirada da documentacao do vyper link nas primeiras linhas
    self.end = False
    self.complete = False
# Função que encerra a vaquinha, caso quem tenha a executado seja o dono. O qual recebe o valor
@external
def finish():
    # Testa se é o dono do contrato
    assert msg.sender == self.dono, "dono verificado"

    assert block.timestamp > self.validade , "time error"
    self.end = True

    assert self.acumulado >= self.meta, "meta atingida"
    self.complete = True

    # Sinaliza e saca o dinheiro do contrato
    send(msg.sender, self.balance)

# A donate permite doacoes caso o prazo da vaquinha nao tenha encerrado
@external # Habilita para interação externa (função chamável)
@payable # Habilita o recebimento de valores pela função
def donate():

    assert self.end == False

    assert block.timestamp < self.validade , "time error"

    assert msg.value > 0, "enviando menos que zero"

    self.doadores[msg.sender] =  doador({carteira: msg.sender, valor: msg.value})
    self.acumulado += msg.value

# A refound devolve o valor ao doador caso, a vaquinha nao tenha se encerrado
@external
def refound():

    assert self.end == True, "vaquinha nao finalizada"

    assert not self.complete, "valor ja sacado pelo dono da vaquinha, refound invalido"
    
    send(msg.sender, self.doadores[msg.sender].valor)
