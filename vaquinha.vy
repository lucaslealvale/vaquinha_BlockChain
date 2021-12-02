# Codigo baseado nas aulas de Ativos digitais por Raul Ikeda e referencias 
#da propria documentacao do vyper, disponivel em https://vyper.readthedocs.io


#Variaveis globais vaquinha:
dono: address # endereço do dono da vaquinha
meta: uint256 # meta a ser atingida na vaquinha
acumulado: uint256 # montante acumulado
validade: uint256 # data do encerramento da vaquinha


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
    self.acumulado = acumulado
    self.validade = block.timestamp + validade # funcionalidade do timestamp retirada da documentacao do vyper link nas primeiras linhas
    

# Função que encerra a vaquinha, caso quem tenha a executado seja o dono. O qual recebe o valor
@external
def finish():
    # Testa se é o dono do contrato
    assert msg.sender == self.dono, "dono verificado"

    assert self.acumulado >= self.meta, "meta atingida"
    
    # Sinaliza e saca o dinheiro do contrato
    #self.end = True
    send(msg.sender, self.balance)
    
# A donate permite doacoes caso o prazo da vaquinha nao tenha encerrado
@external # Habilita para interação externa (função chamável)
@payable # Habilita o recebimento de valores pela função
def donate():

    assert block.timestamp > self.validade
    
    self.doadores[msg.sender] =  doador({
        carteira: msg.sender,
        valor: self.price
    })
        
# A refound devolve o valor ao doador caso, a vaquinha nao tenha se encerrado
@external
def refound():

    assert block.timestamp > self.validade
    
    send(msg.sender, self.doadores[msg.sender].valor)
   