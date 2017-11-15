#!/bin/bash

MAIN() {

## Limpa a tela 

	clear

## Mensagem de apresentação do script.

	echo "Bem vindo ao Gerenciador de Sistema OSM!"
	echo

## Apresenta as opções ao usuário.

	echo " 1. Gerenciador de Disco "
	echo " 2. Gerenciiador de Memória "
	echo " 3. Gerenciador de Processos "
	echo " 4. Sair. "
	echo

## Lê a opção do usuário.

	read -e -p $'Escolha a opção desejada: ' opt 

## Invoca a opção selecionada do usuário.

	case $opt in 
		1) gerdis ;;
		2) germem ;;
		3) gerpro ;;
		4) echo "Saindo..." ; exit ;; 
		*) echo "Opção inválida, tente novamente." ; sleep 2 ; MAIN ;;
	esac

}

## Função para facilitar retorno ao menu principal
function goback(){

	echo
	read -e -p $'Deseja retornar ao menu inicial? [s/n]: ' opt

	if [ $opt == 's' ]; then
		MAIN
	elif [ $opt == 'n' ]; then
		exit
        else
 		echo "Opção inválida, tente novamente."
		goback
	fi
}

###  Função de gerenciamento de disco  ###
function gerdis() {

## Mensagem de apresentação.

	clear

	echo "Bem vindo ao Gerenciador de Disco do OSM!"
	echo
	echo " 1. Informações sobre espaço em disco "
	echo " 2. Informações sobre partições"
	echo " 3. Voltar"
	echo " 4. Sair"
	echo
	
	read -e -p $'Escolha a opção desejada: ' opt
	
	case $opt in
		1) subgerdis1 ;;
		2) subgerdis2 ;;
		3) MAIN ;;
		4) echo "Saindo..." ; exit ;;
		*) echo "Opção inválida, tente novamente." ; sleep 2 ; gerdis ;;
	esac
}
## Subfunção 1 (Gerenciamento de Disco): informações sobre espaço em disco
	function subgerdis1() {
	echo
	echo "Você escolheu 'Informações sobre espaço em disco': " 
	echo

## Comando

	df -hT

## Pergunta ao usuário se quer voltar ou sair.

	goback

	}

## Subfunção 2 (Gerenciamento de Disco): informações sobre partições

	function subgerdis2() {
	echo
	echo "Você escolheu 'Informações sobre partições': "
	echo

## Comando

	fdisk -l

## Pergunta ao usuário se quer voltar ou sair.

	goback

	}

###  Função de gerenciamento de memória  #### 
function germem(){

## Mensagem de apresentação.

	clear

	echo "Bem vindo ao Gerenciador de Memória do OSM!"
	echo
	echo " 1. Informações sobre memória livre "
	echo " 2. Informações sobre uso da memória"
	echo " 3. Voltar"
	echo " 4. Sair"
	echo
	
	read -e -p $'Escolha a opção desejada: ' opt
	
	case $opt in
		1) subgermem1 ;;
		2) subgermem2 ;;
		3) MAIN ;;
		4) echo "Saindo..." ; exit ;;
		*) echo "Opção inválida, tente novamente." ; sleep 2 ; gerdis ;;
	esac
}

## Subfunção 1 (Gerenciamento de Memória): informações sobre memória livre
	function subgermem1() {
	echo
	echo "Você escolheu 'Informações sobre memória livre': " 
	echo

## Comando

	free

## Pergunta ao usuário se quer voltar ou sair.

	goback

	}

## Subfunção 2 (Gerenciamento de Memória): informações sobre uso da memória

	function subgermem2() {
	echo
	echo "Você escolheu 'Informações sobre uso da memória': "
	echo

## Comando

	fdisk -l

## Pergunta ao usuário se quer voltar ou sair.

	goback

	}

###  Função de gerenciamento de processos  #### 
function gerpro(){

## Mensagem de apresentação.

	clear

	echo "Bem vindo ao Gerenciador de Memória do OSM!"
	echo
	echo " 1. Informações sobre os processos em tempo real"
	echo " 2. Snapshot sobre os processos atuais"
	echo " 3. Encerrar algum processo"
	echo " 4. Voltar"
	echo " 5. Sair"
	echo
	
	read -e -p $'Escolha a opção desejada: ' opt
	
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
		read -e -p $'Digite o nome do processo a ser procurado: ' proc
	fi


## Comando

	echo "Nenhum programa ainda."

## Pergunta ao usuário se quer voltar ou sair.

	goback

	}

MAIN
