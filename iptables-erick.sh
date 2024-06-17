#! /bin/sh

# Autor: Erick Andrade
# Site: erickandrade.com.br
# Descrição: Script baseado em estudos de cursos e artigos na internet. O Firewall IPTABLES está com regras básicas de segurança, para uso em servidores simples. Para mais informações sobre regras, consulte a documentação oficial.

#---------------------- Configuracoes Gerais ----------------------

echo -e "---INICIANDO AS CONFIGURAÇÕES GERAIS DO IPTABLES---\n"
echo -e "Se o Iptables/Terminal travar ou aparecer uma mensagem de erro em alguma linha, verifique as alterações feitas no script, pois pode ter ocorrido algum erro grave.\n"
echo -e "....\n"

#Comandos para zerar completamente o iptables - limpando as regras de cada tabela
echo "1 - Resetando o IPtables, limpando as regras de todas as tabelas..."
iptables -F -t nat
iptables -F -t filter
iptables -F -t mangle

#Mudando as Politicas de todas as CHAINS (fluxos) da tabela Filter
echo "2 - Mudando as Politicas de todas as CHAINS"
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

#Regra de entrada e saida pela interface de loopback
echo "3 - Criando a regra de entrada pela interface de loopback"
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

#---------------------- Rede Local <-> Internet ----------------------

#Habilitar Acesso via SSH da Rede Local para o Firewall
echo "4 - Aceitando Conexao SSH apenas do seu IP"
iptables -A INPUT -p tcp --dport 22 -i ens18 -s SEU-IP -j ACCEPT 
iptables -A OUTPUT -p tcp --sport 22 -o ens18 -d SEU-IP -j ACCEPT 

#Registrando em LOG todas as solicitações de conexao SSH
echo "4.1 - Criando regra para registrar solicitacao de SSH de IP NAO PERMITIDO"
iptables -A INPUT -p tcp --dport 22 -j LOG --log-prefix "SOLIC SSH IP NAO PERMITIDO "
iptables -A OUTPUT -p tcp --sport 22 -j LOG --log-prefix "RESP SSH IP NAO PERMITIDO "

#---------------------- Firewall -> Internet ----------------------

#Permitindo a saida de Ping do Firewall
echo "5 - Permitindo o Ping do Firewall para a Internet"
iptables -A OUTPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A INPUT -p icmp --icmp-type echo-reply -j ACCEPT

#Permitindo saida de Consulta DNS
echo "6 - Permitindo a consulta de DNS do Firewall para Internet"
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --sport 53 -j ACCEPT

#Permitir a saida para web via HTTPS/443
echo "7 - Permitindo a saida HTTPS do Firewall para Internet"
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp --sport 443 -j ACCEPT

#Permitir a saida para web via HTTP/80
echo -e "8 - Permitindo a saida HTTP do Firewall para Internet\n" 
iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --sport 80 -j ACCEPT

#---------------------- Firewall <-> Rede Local ----------------------

echo -e "....\n"
echo -e "CONFIGURAÇÕES DO FIREWALL FINALIZADAS COM SUCESSO\n"
echo -e "EXIBINDO TODAS AS REGRAS QUE FORAM CRIADAS E/OU ATUALIZADAS\n"

iptables -nvL --line-numbers

#---------------------- Final do Firewall ----------------------
