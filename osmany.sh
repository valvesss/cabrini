#!/bin/bash

MAIN() {

## Limpa a tela 

	clear

## Mensagem de apresentação do script.

opt=$(dialog					\
	--stdout				\
	--title 'Gerenciador de Sistema OSM'	\
	--menu 'Escolha a opção desejada:'	\
	0 0 0					\
	1 'Gerenciador de Disco'		\
	2 'Gerenciiador de Memória'		\
	3 'Gerenciador de Processos'		\
	4 'Créditos'				\
	5 'Sair.')

## Invoca a opção selecionada do usuário.

	case $opt in 
		1) gerdis ;;
		2) germem ;;
		3) gerpro ;;
		4) creditos ;;
		5) exit ;; 
	esac

}

## Função para facilitar retorno ao menu principal
function goback(){


	dialog --stdout --yesno 'Deseja retornar ao menu inicial?' 0 0

	if [ $? = 0 ]; then
		MAIN
	else
		clear
		exit
	fi
}

###  Função de gerenciamento de disco  ###
function gerdis() {

## Mensagem de apresentação.

opt=$(dialog							\
	--stdout						\
	--title 'Bem vindo ao Gerenciador de Disco do OSM!'	\
	--menu 'Escolha a opção desejada:'			\
	0 0 0							\
	1 'Informações sobre espaço em disco'			\
	2 'Informações sobre partições'				\
	3 'Voltar'						\
	4 'Sair')
	
	case $opt in
		1) subgerdis1 ;;
		2) subgerdis2 ;;
		3) MAIN ;;
		4) exit ;;
	esac
}
## Subfunção 1 (Gerenciamento de Disco): informações sobre espaço em disco
	function subgerdis1() {

	df -hT > /tmp/disco.txt
	dialog --title 'Informações sobre espaço em disco' --textbox /tmp/disco.txt 0 0 \

	goback

	}

## Subfunção 2 (Gerenciamento de Disco): informações sobre partições

	function subgerdis2() {

	fdisk -l > /tmp/disco1.txt
	dialog --title 'Informações sobre as partições' --textbox /tmp/disco1.txt 0 0\

	goback

	}

###  Função de gerenciamento de memória  #### 
function germem(){

## Mensagem de apresentação.

opt=$(dialog							\
	--stdout						\
	--title 'Bem vindo ao Gerenciador de Memória do OSM!'	\
	--menu 'Escolha a opção desejada:'			\
	0 0 0							\
	1 'Informações sobre a memória'				\
	2 'Voltar'						\
	3 'Sair')
	
	case $opt in
		1) subgermem1 ;;
		2) MAIN ;;
		3) exit ;;
	esac
}

## Subfunção 1 (Gerenciamento de Memória): informações sobre memória livre
	function subgermem1() {

	export NMON=m
	nmon

	goback

	}

###  Função de gerenciamento de processos  #### 
function gerpro(){

## Mensagem de apresentação.

opt=$(dialog							\
	--stdout						\
	--title 'Bem vindo ao Gerenciador de Processos do OSM!'	\
	--menu 'Escolha a opção desejada:'			\
	0 0 0							\
	1 'Informações sobre os processos em tempo real'	\
	2 'Snapshot sobre os processos atuais'			\
	3 'Encerrar algum processo'				\
	4 'Voltar'						\
	5 'Sair')
	
	case $opt in
		1) subgerpro1 ;;
		2) subgerpro2 ;;
		3) subgerpro3 ;;
		4) MAIN ;;
		5) echo "Saindo..." ; exit ;;
		*) echo "Opção inválida, tente novamente." ; sleep 2 ; gerpro ;;
	esac
}

## Subfunção 1 (Gerenciamento de Processos): informações sobre processos em tempo real
	function subgerpro1() {
	echo
	echo "Você escolheu 'Informações sobre processos em tempo real': " 
	echo

## Comando

	top

## Pergunta ao usuário se quer voltar ou sair.

	goback

	}

## Subfunção 2 (Gerenciamento de Processos): snapshot sobre o uso da memória em tempo real

	function subgerpro2() {
	echo
	echo "Você escolheu 'Snapshot dos processos atuais': "
	echo

## Comando

	ps aux | more

## Pergunta ao usuário se quer voltar ou sair.

	goback

	}

## Subfunção 3 (Gerenciamento de Processos): encerrar algum processos

	function subgerpro3() {

	echo
	echo "Você escolheu 'Encerrar algum processo': "
	echo
	read -e -p $'Deseja procurar o processo? [s/n]: ' opt
	
	if [ $opt == 's' ]; then
	
		a=0;
		while [ $a == 0 ]; do
	
			## Procura o processo do usuário
	
			if [ $opt == 's' ]; then
				read -e -p $'Digite o nome do processo a ser procurado: ' proc
			fi
		
			## Procura o PID do processo do usuário

			if top | grep $proc ; then

				pidkill=$(top | grep $proc | cut -d ' ' -f7)

				## Apresenta o número do processo encontrado.

				echo "O número do seu processo é $pidkill."

			else
				read -e -p $'Processo não encontrado... \x0aDeseja tentar novamente? [s/n]: ' opt
					if [ $opt == 'n' ]; then
						let a=a+1

					
					fi
			fi

	done

	fi


	## Comando para encerrar processo 

	echo 
	read -e -p $'Digite o PID do processo a ser encerrado: ' pidnum
	kill $pidnum 2>/dev/null
	echo "Processo $pidnum encerrado."

## Pergunta ao usuário se quer voltar ou sair.

	goback

	}
function creditos() {

dialog 						\
	--title 'Integrantes'			\ 
	--msgbox 'Jhonny Papa Pukas Valves' 	\
	0 0

goback

}
MAIN
