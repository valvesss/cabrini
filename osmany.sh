#!/bin/bash

## Descobre se é root

	if [[ $EUID -eq 0 ]]; then
		userid=0
	else
		userid=1
	fi

function leave(){
	clear
	echo "Good-Bye... "
	exit
}

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
	2 'Gerenciador de Memória'		\
	3 'Gerenciador de Processos'		\
	4 'Créditos'				\
	5 'Sair.')

## Invoca a opção selecionada do usuário.

	case $opt in 
		1) gerdis ;;
		2) germem ;;
		3) gerpro ;;
		4) creditos ;;
		5) leave ;; 
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
		4) leave ;;
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
		3) leave ;;
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
		5) leave ;;
		*) echo "Opção inválida, tente novamente." ; sleep 2 ; gerpro ;;
	esac
}

## Subfunção 1 (Gerenciamento de Processos): informações sobre processos em tempo real
	function subgerpro1() {

## Comando que exibe processos em tempo real. Se for root, verá todos os processos, caso não seja, verá apenas os seus.

	if [[ $userid -eq 0 ]]; then
	       top	
       	else
	       top -u $USER
	fi

## Pergunta ao usuário se quer voltar ou sair.

	goback

	}

## Subfunção 2 (Gerenciamento de Processos): snapshot sobre o uso da memória em tempo real

	function subgerpro2() {

## Comando que exibe snapshot dos processos atuais. Se o usuário for root, verá todos os processos, caso não seja, apenas verá os seus.

	if [[ $userid -eq 0 ]]; then
		ps aux | more
	else
		ps -U $USER -u $USER u | more
	fi

## Pergunta ao usuário se quer voltar ou sair.

	goback

	}

## Subfunção 3 (Gerenciamento de Processos): encerrar algum processo

	function subgerpro3() {

	dialog 								\
		--title 'IMPORTANTE'					\
		--yesno '\nPara encerrar um processo é necessário saber seu PID.
		\n\nDeseja procurar o processo?\n\n'			\
		0 0
	
	if [[ $? -eq 0 ]]; then
	
		a=0;
		while [ $a == 0 ]; do
	
			## Procura o processo do usuário
	
			proc=$(dialog								\
				--stdout						\
				--title 'PID'						\
				--inputbox 'Digite o nome do processo a ser procurado:'	\
				0 0)
		

			## Se for root
			if [[ $userid -eq 0 ]]; then

				## Verifica se o processo exite
				ps aux | awk '{print $2}' > /tmp/pidstokillroot
				pidname=$( ps aux | grep -w $proc | awk 'NR==1 {print $2}')
				if `cat /tmp/pidstokillroot | grep -w $pidname` ; then

					dialog									\
						--title 'NOME DO PROCESSO'					\
						--yesno "Seu processo é esse?\n\n `ps aux | grep $proc`"	\
						0 0
	
					if [[ $? -eq 0 ]]; then
						let a=a+1
						ps aux | grep $proc | awk '{print $2}' > /tmp/pidstokill
					fi
				else
					exist=1
				fi

			else
				## Se for outro usuário
				dialog									\
					--title 'NOME DO PROCESSO'					\
					--yesno "Seu processo é esse?\n\n `ps aux -U $USER -u $USER u | grep $proc`"	\
					0 0
	
					if [[ $? -eq 0 ]]; then
						let a=a+1
						ps aux | grep $proc | awk '{print $2}' > /tmp/pidstokill
					fi
			fi

			if [[ $exit -eq 1 ]]; then
				dialog --title 'IMPORTANTE' --yesno 'Processo não encontrado\n\n Tentar novamente?' 0 0
				if [[ $? -eq 1 ]]; then
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
