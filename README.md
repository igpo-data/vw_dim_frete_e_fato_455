#A view parte da tabela principal:
##-> dim_frete d
Define os fretes (Ctrcs) 
Contém dados cadastrais e operacionais. 

##-> LEFT JOIN ft_455 f
  ON f.sk_dim_frete = d.sk_dim_frete 
###📌 Função:
Trazer valores financeiros do frete
###📦 Principais dados:
valor da mercadoria
valor do frete
ICMS
pedágio
TDE
volumes
comissões

#### OBS1: a fato ft_455 há tanto PK quanto FK, sendo 
  PK (sk_ft_455): Identificar cada linha da fato de forma única sem duplicidade 
  FK (sk_dim_frete): ligar a fato com a dimensão dim_frete
  -> Não usar sk_dim_frete como PK, pois o mesmo frete pode ter varias linhas 

#### OBS2: a fato ft_455 há decomposição no valor do frete: 
  PK (sk_ft_455): Identificar cada linha da fato de forma única sem duplicidade 
  FK (sk_dim_frete): ligar a fato com a dimensão dim_frete
  -> Não usar sk_dim_frete como PK, pois o mesmo frete pode ter varias linhas 







<img width="1536" height="1024" alt="image" src="https://github.com/user-attachments/assets/0793aa1d-47d8-4483-a3a6-6e29825f404c" />
