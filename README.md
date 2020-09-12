
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Crime e Covid\[1\]: uma relação viral?

## Apresentação

O presente trabalho visa realizar uma singela análise sobre os índices
de criminalidade no Estado de São Paulo e compará-los aos números da
pandemia causada pela COVID-19.

Pretendemos verificar as consequências da pandemia (dentre eles, a breve
quarentena que se verificou no estado) e levantar algumas reflexões
sobre os impactos da violência. Dentre as perguntas que se pretende
refletir (mas sem a pretensão de oferecer respostas):

1.  Qual é, em linhas gerais, a tendência de evolução da incidência
    criminal em SP? Os crimes têm, ao longo das últimas décadas
    diminuído ou aumentado?
2.  É possível visualizar tendências nas diferentes regiões da cidade?
3.  Como foi o comportamento dessas tendências durante os meses em que a
    quarentena em SP foram mais intensas? Houve padrão nos distintos
    tipos de crime e nas distintas regiões?
4.  Se houve comportamento fora do padrão ou inesperado, quais poderiam
    ser as razões?

Ao final, queremos instigar a seguinte provocação na leitora e no
leitor: as projeções e sonhos que temos para um “novo normal” não
deveriam ter em mente, também, a “pandemia” de violência em nosso
Estado?

## Dados utilizados

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

## Metodologia

### 

``` r
summary(cars)
#> Warning in prettyNum(.Internal(format(x, trim, digits, nsmall, width, 3L, : NAs
#> introduced by coercion to integer range
#> Warning in format.default(names(sms)): NAs introduced by coercion to integer
#> range
#> Warning in paste0(lbs, ":", sms, " "): NAs introduced by coercion to integer
#> range
#> Warning in prettyNum(.Internal(format(x, trim, digits, nsmall, width, 3L, : NAs
#> introduced by coercion to integer range
#> Warning in format.default(names(sms)): NAs introduced by coercion to integer
#> range
#> Warning in paste0(lbs, ":", sms, " "): NAs introduced by coercion to integer
#> range
#> Warning in paste(character(max(lw, na.rm = TRUE) + 2L), collapse = " "): NAs
#> introduced by coercion to integer range
#> Warning in paste0(substring(blanks, 1, pad), nm): NAs introduced by coercion to
#> integer range
#> Warning in format.default(unclass(x), digits = digits, justify = justify): NAs
#> introduced by coercion to integer range
#> Warning in print.default(xx, quote = quote, right = right, ...): NAs introduced
#> by coercion to integer range
#>      speed           dist       
#>  Min.   : 4.0   Min.   :  2.00  
#>  1st Qu.:12.0   1st Qu.: 26.00  
#>  Median :15.0   Median : 36.00  
#>  Mean   :15.4   Mean   : 42.98  
#>  3rd Qu.:19.0   3rd Qu.: 56.00  
#>  Max.   :25.0   Max.   :120.00
#> Warning in print.default(xx, quote = quote, right = right, ...): NAs introduced
#> by coercion to integer range
```

You’ll still need to render `README.Rmd` regularly, to keep `README.md`
up-to-date.

You can also embed plots, for example:

    #> Warning in deparse(x[[1L]]): NAs introduced by coercion to integer range
    #> Warning in deparse(expr, width.cutoff, ...): NAs introduced by coercion to
    #> integer range
    #> Warning in paste(deparse(expr, width.cutoff, ...), collapse = collapse): NAs
    #> introduced by coercion to integer range
    #> Warning in deparse(x[[1L]]): NAs introduced by coercion to integer range
    #> Warning in deparse(expr, width.cutoff, ...): NAs introduced by coercion to
    #> integer range
    #> Warning in paste(deparse(expr, width.cutoff, ...), collapse = collapse): NAs
    #> introduced by coercion to integer range
    #> Warning in paste(x[c("major", "minor")], collapse = "."): NAs introduced by
    #> coercion to integer range
    #> Warning in axis(side = side, at = at, labels = labels, ...): NAs introduced by
    #> coercion to integer range
    
    #> Warning in axis(side = side, at = at, labels = labels, ...): NAs introduced by
    #> coercion to integer range

![](README_files/figure-gfm/pressure-1.png)<!-- -->

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub\!

1.  A ideia do nome veio de uma excelente matéria da [Revista
    piauí](https://piaui.folha.uol.com.br/crime-e-covid-no-rio/)
