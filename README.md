# vw_dim_frete_e_fato_455 :
  ## -> dim_frete d
Define os fretes (Ctrcs) 
Contém dados cadastrais e operacionais. 

  ## -> LEFT JOIN ft_455 f
  ON f.sk_dim_frete = d.sk_dim_frete 
  
  ### 📌 Função:
  Trazer valores financeiros do frete
  ### 📦 Principais:
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
vlr_frete: valor total do frete.  
Frete Valor: parte do frete baseada no valor da mercadoria.  
Frete Peso: parte baseada no peso.  

#### OBS3: valor de frete filtrado sempre com recarga de D-90 dias pois substituição de um CTRC pode ser alterada para ocorrência 83 e 87.

 

 
  <img width="1536" height="1024" alt="111" src="https://github.com/user-attachments/assets/387293c4-dc75-45a1-a8b9-f7c90678e454" />





