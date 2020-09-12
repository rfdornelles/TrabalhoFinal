
<!-- README.md is generated from README.Rmd. Please edit that file -->

# CRIME E COVID: uma relação viral? \[1\]

## APRESENTAÇÃO

O presente trabalho visa realizar uma singela análise sobre os índices
de criminalidade no Estado de São Paulo e compará-los aos números da
pandemia causada pela COVID-19.

Pretendemos verificar as consequências da pandemia (dentre eles, a breve
quarentena que se verificou no estado) e levantar algumas reflexões
sobre os impactos da violência. Dentre as perguntas que se pretende
refletir (mas sem a pretensão de oferecer respostas):

1.  *Qual é, em linhas gerais, a **tendência de evolução** da incidência
    criminal em SP? Os crimes têm, ao longo das últimas décadas
    **diminuído** ou **aumentado**?*

2.  *É possível visualizar **tendências** nas diferentes regiões da
    cidade*?

3.  *Como foi o comportamento dessas tendências **durante os meses em
    que a quarentena** em SP foi mais intensa*? *Houve **padrão** nos
    distintos tipos de crime e nas distintas regiões*?

4.  S*e houve comportamento fora do padrão ou **inesperado**, quais
    poderiam ser as razões*?

Ao final, queremos instigar a seguinte provocação na leitora e no
leitor: as projeções e sonhos que temos para um “novo normal” não
deveriam ter em mente, também, a “pandemia” de violência em nosso
Estado?

## DADOS UTILIZADOS

Vamos analisar as bases :

  - `COVID`, contendo [dados coletados e tratados pela equipe da
    Curso-R](https://www.youtube.com/watch?v=ja2AbTFN4yk&ab_channel=Curso-R)
    a partir de webscrap do [site do Ministério da
    Saúde](http://covid.saude.gov.br). Os dados estão atualizados
    15/06/2020;
  - `SSP`, oriundos da mesma Curso-R, com dados extraídos da [Secretaria
    de Segurança Pública de São
    Paulo](http://www.ssp.sp.gov.br/transparenciassp/Consulta.aspx). Os
    dados são de janeiro de 2002 até abril de 2020.

## METODOLOGIA

Ambas as bases, embora pré-processadas e em formato *tidy*, receberam
tratamento a fim de torná-las comparáveis entre si. O detalhamento dos
passos fica mais evidente nos comentários nos arquivos nas pastas `/R` e
`/data-raw`, porém a seguir trazemos os aspectos mais significativos.

### *Tratamento dos dados da COVID*

Os dados foram restritos ao estado de **São Paulo** e foram removidas
variáveis como a quantidade de novos casos, casos recuperados, etc, uma
vez que o foco da análise se deu sobre dois indicadores:

  - **Incidência de casos**: ou seja, a quantidade de casos confirmados
    por 100 mil habitantes

  - **Mortalidade** (ou incidência de mortes): a quantidade de óbitos
    confirmados por 100 mil habitantes

|                                                                                                                               Variáveis originais                                                                                                                                |         Variáveis finais          |
| :------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: | :-------------------------------: |
| regiao, estado, municipio, coduf, codmun, codRegiaoSaude, nomeRegiaoSaude, data, semanaEpi, populacaoTCU2019, casosAcumulado, casosNovos, obitosAcumulado, obitosNovos, Recuperadosnovos, emAcompanhamentoNovos, eh\_capital, obitosAcumulado\_log2, obitosNovos\_log2, lat, lon | regiao, mes, variavel, quantidade |

*Tab 1. Variáveis da base de dados COVID antes e depois do tratamento*

### *Tratamento dos dados da SSP*

A base originalmente continha variáveis em sub-espécies dos crimes
cometidos, separando por exemplo homicídios de homicídios culposos. Para
melhor aproveitamento dos dados, considerando os bens jurídicos
inerentes a cada tipo penal, as hipóteses originais foram dividas em
quatro grupos:

  - **Crimes Violentos Letais Intencionais (CVLI)**: reunindo homicídios
    dolosos, latrocínio (também chamado de roubo seguido de morte) e
    lesão corporal seguida de morte. Para fins desse estudo, se incluiu
    nesse grupo também os homicídios tentados (que, por definição, são
    intencionais), ainda que o óbito não tenha necessariamente ocorrido.

  - **Crimes contra o patrimônio**: Reunindo roubos (exceto se
    resultantes em óbito) e furtos (de qualquer tipo).

  - **Outros crimes contra a pessoa**: Reunindo estupros (em todas as
    modalidades) e lesões corporais. Sabe-se que ambos possuem grande
    diferença quanto aos contextos criminológicos em que ocorrem, porém
    apenas e exclusivamente para fins metodológicos fez sentido
    agrupá-los aquo.

  - **Acidentes penalmente relevantes:** Agrupou-se os crimes de
    trânsito (inclusive as modalidades dolosas), lesões corporais
    culposas e homicídios culposos. Da mesma forma que no caso anterior,
    a proposta é unicamente didática, tendo em mente que todos os crimes
    aqui descritos possuem um aspecto subjetivamente não-intencional,
    mesmo nos casos de dolo eventual.

|                                                                                                                                                                                                                                                               Variáveis originais                                                                                                                                                                                                                                                                |                  Variáveis finais                   |
| :----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------: | :-------------------------------------------------: |
| mes, ano, delegacia\_nome, municipio\_nome, regiao\_nome, estupro, estupro\_total, estupro\_vulneravel, furto\_outros, furto\_veiculos, hom\_culposo\_acidente\_transito, hom\_culposo\_outros, hom\_doloso, hom\_doloso\_acidente\_transito, hom\_tentativa, latrocinio, lesao\_corp\_culposa\_acidente\_transito, lesao\_corp\_culposa\_outras, lesao\_corp\_dolosa, lesao\_corp\_seg\_morte, roubo\_banco, roubo\_carga, roubo\_outros, roubo\_total, roubo\_veiculo, vit\_hom\_doloso, vit\_hom\_doloso\_acidente\_transito, vit\_latrocinio | ano, regiao, tipo\_crime, quantidade, qnt\_relativa |

*Tab 2. Variáveis da base SSP antes e após tratamento*

### Convergência dos dados

A fim de que se pudesse tornar os dados estudados comparáveis em algumas
medidas, adotou-se os seguintes padrões:

  - Os dados de **população**, oriundos das projeções do Tribunal de
    Contas da União (TCU) para 2019, foram aproveitados para ambas as
    bases. Elas vieram originalmente na base `COVID` e foi daptada para
    a base `SSP`.

  - Como as bases possuiam recortes temporais distintos, os dados de
    segurança da `SSP`foram *projetados até o final do an*o,
    considerando as tendências até abril/2020.

  - As **regiões** da Segurança Pública (base `SSP`) foram aproveitadas
    também para os dados da pandemia (base `COVID`). Assim, os dados
    foram apresentados considerando as mesmas 12 regiões.

|  Regiões Utilizadas   |
| :-------------------: |
|       Araçatuba       |
|         Bauru         |
|       Campinas        |
|        Capital        |
|   Grande São Paulo    |
|      Piracicaba       |
|  Presidente Prudente  |
|    Ribeirão Preto     |
|        Santos         |
| São José do Rio Preto |
|  São José dos Campos  |
|       Sorocaba        |

![](README_files/figure-gfm/regioes-1.png)<!-- -->

## ESTADO DE SÃO PAULO E A COVID-19

### Situação da COVID no Brasil

Como é sabido, o Brasil chegou rapidamente aos países com mais casos no
mundo. Ao contrário do que se disse, esse número não se deu unicamente
em razão da grandeza de sua população.

### SP como epicentro nacional

Por outro lado, o Estado de São Paulo foi por muito tempo o “epicentro”
da pandemia no país. Além de sua alta população, possivelmente houve
influência da sua alta urbanização dentre muitos outros fatores.

### Bla bla bla

## O CRIME E O ESTADO DE SÃO PAULO

### Tendências

São Paulo, crimes, bla bla bla Tendência de queda por diversos fatores

### Criminalidade durante a pandemia

#### Quarentena

Durou em especial nos primeiros meses

Qual impacto teve nos índices?

#### Perguntas importantes

Houve diminuição ou aumento dos crimes?

Houve diminuição das ocorrências de crimes contra o patrimônio?

Lesões corporais e estupros - como foram? pessoas em casa

Acidentes de carro - diminuição da circulação, fechamento dos bares,
lojas de conveniência, etc

Mas e os CVLI? Qual o impacto? Esses tendem a ter menos subnotificação

Levantar o ponto da letalidade policial

#### Regiões que tiveram aumento

Explicações para isso

## Incidências de crime

Temos regiões com mais crime que covid?

Temos uma pandemia de violência?

## Notas

1.  A ideia do nome veio de uma excelente matéria da [Revista
    piauí](https://piaui.folha.uol.com.br/crime-e-covid-no-rio/)
