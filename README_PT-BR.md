# Following Stocks

-------
<p align="center">
    <a href="#o-projeto">O Projeto</a> &bull;
    <a href="#pre-requisitos">Pré-requisitos</a> &bull;
    <a href="#functionalities">Funcionalidades</a> &bull;
    <a href="#used-APIs">APIs Utilizadas</a> &bull;
    <a href="#restrictions">Restrições</a> &bull;
    <a href="#license">Licença</a> &bull;
    <a href="#autor">Autor</a>
    
</p>

-------

O Projeto
Following Stocks é um aplicativo que permite, de forma simplificada, consultar cotações e seguir papéis (ações, moedas e futuros) negociados pelas diversas bolsas de valores espalhadas pelo mundo.

# Pré-requisitos
IOS 11.3+

# Desenvolvimento
O app foi desenvolvido em Swift 4, utilizando Xcode 9.4.1

# Funcionalidades
## Search
No Search View, é possível localizar papéis pelo nome do papel, companhia ou símbolo (sigla de identificação do papel nas bolsas de valor)

> ![](SearchView320px.gif)

## Following
Na aba Following são apresentados os papéis marcados pelo usuário para serem seguidos.

> ![](FollowingView320px.gif)

## Portfolio
Na aba Portfolio, o usuário visualiza sua carteira de ações. A partir desta aba, também é possível adicionar novos papés ao portifólio.

> ![](PortfolioView320px.gif)

## Detail
Na view Detail, o usuário pode conferir dados mais detalhados da cotação do papel.
Dentro de Detail, o usuário tem a opção de:
 - adicionar ou remover o papel do portifólio;
 - marcar ou desmarcar o papel como "seguindo".
 
> ![](DetailView320px.gif)

# APIs Utilizadas
O Following Stocks utiliza duas APIs como base, que possibilitam o usuário consultar ações de diversas bolsas ao redor do mundo, são elas:
 - [Alpha Vantage](https://www.alphavantage.co/) - Permite consultar a cotação do papel em tempo real;
 - [Yahoo Finance Auto Complete](https://stackoverflow.com/questions/52390536/javascript-jquery-get-request-is-not-getting-data-or-returning-any-error) - Usado no auto completamento das buscas por papéis das bolsas de valores, a partir do nome da companhia ou do símbolos do papel. Obs: Não encontrei documentação desta API, mas fui 'peneirando' no [stackoverflow](https://stackoverflow.com/) até chegar a usabilidade utilizado no Following Stocks.

# Restrições
Por se tratar de um projeto acadêmico e demonstrativo, o Following Stocks não teve verba injetada no projeto e desta forma utilizou a versão gratuita da API da Alpha Vantage que, permite realizar apenas 5 consultas de cotação por minuto ou 500 consultas por dia. Com isso o Following Stocks foi modelado da seguinte maneira:

- O usuário pode seguir até 5 papéis;
- O usuário pode adicionar até 5 papéis no portifólio;
- A cada 1 minuto, o Follokwing Stocks atualiza a cotação do papel que está mais tempo desatualizado;
- As consultas de cotação, além das automáticas, só são realizadas ao entrar na visualizão de detalhes;
- Caso o usuário realize mais de 4 consultas no intervalo de 1 minuto, e a API perceber um excesso de consulta, uma mensagem é mostrada para que o usuário aguarde alguns instantes para realizar a próxima consulta.

# Licença
Este projeto está licenciado baseado na licença GLP v3 - Veja o arquivo License.md para mais detalhes

# Autor
 * Bruno Wagner
 https://github.com/brunowagner/
