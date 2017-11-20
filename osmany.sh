#!/bin/bash

## Verifica se possui as dependências necessárias

	a=0
	b=0
	while [[ $a -eq 0 ]]; do
		clear
		if ! hash dialog &>/dev/null; then
			echo "Dialog não instalado...."
			b=1
		fi

		if ! hash nmon &>/dev/null; then
			echo "Nmon não instalado..."
			b=1
		fi

		if [[ $b -eq 1 ]]; then
			echo "Para executar o script é necessário instalar as dependências mostradas acima."
			read -e -p $'Deseja instalá-las? [s/n]' opt
				if [[ $opt = 's' ]] || [[ $opt = 'S' ]]; then
					apt install -y dialog nmon
				fi
			exit
		fi

		let a=a+1
	done

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

function main() {

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
	4 'Monitorar Sistema'			\
	5 'Sair.')

## Invoca a opção selecionada do usuário.

	case $opt in 
		1) gerdis ;;
		2) germem ;;
		3) gerpro ;;
		4) monsis ;;
		5) leave ;;
	esac

}

## Função para facilitar retorno ao menu principal
function goback(){


	dialog --stdout --yesno 'Deseja retornar ao menu inicial?' 0 0

	if [ $? = 0 ]; then
		main
	else
		clear
		exit
	fi
}

##### Gerenciar sistema #####

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
		3) main ;;
		4) leave ;;
	esac
}
## Subfunção 1 (Gerenciamento de Disco): informações sobre espaço em disco
	function subgerdis1() {

	df -hT > /tmp/disco.txt
	dialog --title 'Informações sobre espaço em disco' --textbox /tmp/disco.txt 0 0 \

	gerdis

	}

## Subfunção 2 (Gerenciamento de Disco): informações sobre partições

	function subgerdis2() {

	fdisk -l > /tmp/disco1.txt
	dialog --title 'Informações sobre as partições' --textbox /tmp/disco1.txt 0 0\

	gerdis

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
		2) main ;;
		3) leave ;;
	esac
}

## Subfunção 1 (Gerenciamento de Memória): informações sobre memória livre
	function subgermem1() {

	export NMON=m
	nmon

	germem

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
		4) main ;;
		5) leave ;;
		*) main ;;
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

	gerpro

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

	gerpro

	}

## Subfunção 3 (Gerenciamento de Processos): encerrar algum processo

	function subgerpro3() {

	dialog 								\
		--title 'IMPORTANTE'					\
		--yesno '\nPara encerrar um processo é necessário saber seu PID.
		\n\nDeseja procurar o processo a ser encerrado?\n\n'			\
		0 0
	
	if [[ $? -eq 0 ]]; then
	
		a=0;
		while [ $a == 0 ]; do
	
			## Procura o processo do usuário
	
			proc=$(dialog							\
				--stdout						\
				--title 'PID'						\
				--inputbox 'Digite o nome do processo a ser procurado:'	\
				0 0)

			## Se for root
			if [[ $userid -eq 0 ]]; then

				## Verifica se o processo exite. Rp = root pid. Rpk = root pid kill.
				ps aux | awk '{print $2}' > /tmp/rp
				pidnum=$(ps aux | grep $proc | awk 'NR==1 {print $2}')
				if `cat /tmp/rp | grep -q -w $pidnum` ; then
					ps aux | grep $proc > /tmp/pe
					dialog											\
						--stdout									\
						--title 'NOME DO PROCESSO'							\
						--yesno "Deseja encerrar esse processo?\n\n `cat /tmp/pe | awk 'NR==1'`"	\
						8 110
	
					if [[ $? -eq 0 ]]; then
						let a=a+1
						kill $pidnum &>/dev/null
						dialog 									\
							--stdout							\
							--title 'FEITO'							\
							--msgbox "Processo '$proc' de pid '$pidnum' foi encerrado."	\
							5 60
					else
						gerpro
					fi
				else
					exist=1	
				fi

			else
				## Se for outro usuário
				ps aux -U $USER -u $USER u | awk '{print $2}' > /tmp/up
				pidnum=$(ps aux -U $USER -u $USER u | grep $proc | awk 'NR==1 {print $2}')
				if `cat /tmp/up | grep -q -w $pidnum` ; then
					ps aux | grep $proc > /tmp/peu

				dialog									\
					--title 'NOME DO PROCESSO'					\
					--yesno "Seu processo é esse?\n\n `cat /tmp/peu | awk 'NR==1'`"	\
					8 110
	

					if [[ $? -eq 0 ]]; then
						let a=a+1
						kill $pidnum &>/dev/null
						dialog 								\
							--stdout						\
							--title 'FEITO'						\
							--msgbox "Processo $proc de pid $pidnum encerrado."	\
							5 60
					fi
				else
					exist=1
				fi
			fi

			if [[ $exist -eq 1 ]]; then
				dialog --title 'IMPORTANTE' --yesno 'Processo não encontrado! \n\n Tentar novamente?' 0 0
				if [[ $? -eq 1 ]]; then
					let a=a+1
				fi
			fi
		done

	else

		## Comando para encerrar processo

		pidnum=$(dialog								\
				--stdout						\
				--title 'NUMERO PID'					\
				--inputbox 'Digite o PID do processo a ser encerrado:'	\
				0 0)

		kill $pidnum 2>/dev/null
	
		dialog --title 'FEITO' --msgbox "Processo $pidnum encerrado." 5 60

	fi
## Pergunta ao usuário se quer voltar ou sair.

	gerpro

	}

##### Monitorar sistema #####

function monsis() {

	## Apresenta opções de monitoramento ao usuário.
	opt=$(dialog								\
		--stdout						\
		--title 'MONITORAR SISTEMA'				\
		--checklist 'Digite as opções a serem monitoradas:'	\
		0 0 0							\
		c	'CPU'	off					\
		d	'Disco'	off					\
		m	'Memória'	off				\
		n	'Rede'	off					\
		t	'Processos' off)

	## Concatena as opções do usuário e executa o nmon.
	
	if [[ -n $opt ]]; then
		export NMON="$opt"
		nmon
	fi	

	main
}
main
