# 3. Faça uma análise da base escolhida para responder alguma pergunta de
# interesse (veja o tópico "Bases de dados").

# 4. A comunicação dos resultados deve ser feita no README.Rmd do seu
# repositório. O README.Rmd é um arquivo R Markdown localizado na raiz do seu
# repositório. Se ele não existir, rode o comando usethis::use_readme_rmd()
# para criá-lo.

# - Análise crítica: entendimento da base e do problema em estudo.
# - Organização: clareza na comunicação dos resultados e acesso aos arquivos
# utilizados na análise.
# - Técnica: conhecimento do conteúdo visto nesse curso.
# - Criatividade: abordagem escolhida para a análise e a comunicação dos
# resultados.


# ** COVID-19 **

# Descrição: número de casos e óbitos diários por COVID no Brasil por
# município.

# Principais variáveis:

# - Número de casos e óbitos diários por COVID
# - Município, estado e população do município
# - Data
# - Latitude e longitude de cada município (centróide)

# Principais características
# - Séries temporais
# - Dados geográficos
# - Oportunidade para construção de mapas

# Sugestões de análises
# - Visualizar as séries de casos e óbitos por município
# - Prever o número de óbitos no próximo mês

# _____________________________________________________________
# ** Secretaria de Segurança Pública (SSP) de São Paulo **

# Descrição: número de ocorrências mensais de diversos crimes de 2002 a 2020
# (abril) no nível delegacia para todo o Estado de São Paulo.

# Principais variáveis:
#
# - Número de ocorrências mensais (furtos, roubos, homicídios etc)
# - Delegacia onde a ocorrência foi registrada
# - Município e região do estado da delegacia
# - Mês e ano

# Principais características

# - Séries temporais
# - Dados geográficos
# - Oportunidade para construção de mapas

# Sugestões de análises

# - Visualizar as séries de criminalidade
# - Avaliar se os níveis de criminalidade mudaram durante a quarentena

________________________________________________________________________________________________________________________
# ** Companhia Ambiental do Estado de São Paulo (CETESB) **
#
#   Descrição: concentração horária de alguns poluentes em algumas estações
# de monitoramento na Região Metropolitana de São Paulo de jan/2017 a mai/2020.

# Principais variáveis:

# - Concentração horária de CO, NO, NO2, O3 e MP10
# - Data e hora da medição
# - Estação de monitoramento
# - Latitude e longitude das estações de monitoramento

# Principais características

# - Séries temporais
# - Oportunidade para construção de mapas
# - Oportunidade para vários tipos de sumarização (dado que as medidas são
# horárias)
#
# Sugestões de análises
#
# - Visualizar cada uma das séries de poluentes
# - Avaliar se os níveis de poluição mudaram durante a quarentena
