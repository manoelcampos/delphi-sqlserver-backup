# Delphi SQL Server Backup [![GPL licensed](https://img.shields.io/badge/license-GPL-blue.svg)](http://www.gnu.org/licenses/gpl-3.0)

Aplicação de Backup/Restore de Bancos de Dados SQL Server, desenvolvida em Delphi XE 1.
Ela utilizando os componentes ADO e comandos [DDL](https://technet.microsoft.com/en-us/library/ff848799(v=sql.110).aspx) específicos do SQL Server
para realizar o backup e restore de bancos de dados.

A aplicação carrega as configurações de conexão e geração de backup de um arquivo [Conexao.ini](Conexao.ini)
que esteja na pasta do executável (gerado na sub-pasta `Bin`) ou na pasta superior.
A aplicação pode ser executada via linha de comando, para permitir a automatização do backup/restore.
Quando executada normalmente, um botão na interface mostra os parâmetros disponíveis.
Desta forma, é possível incluir a aplicação como uma tarefa no Agendador de Tarefas do Windows.
O arquivo [agendar-backup.bat](agendar-backup.bat) mostra um exemplo de comando para fazer isso.

Utilizando o comando exemplificado, pode-se, por exemplo, utilizar o [Inno Setup](http://www.jrsoftware.org/isinfo.php) 
para instalar uma determinada aplicação que use um banco de dados SQL Server e então executar
a linha de comando mostrada no bat para agendar o backup.

# Componentes Utilizados

- [Biblioteca JVCL 3.4](http://jvcl.delphi-jedi.org)
- Componentes ADO (pré-instalados no Delphi)