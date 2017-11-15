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
		3) echo "3" ;;
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
	function subgerdis1() {
	echo
	echo "Você escolheu 'Informações sobre memória livre': " 
	echo

## Comando

	free

## Pergunta ao usuário se quer voltar ou sair.

	goback

	}

## Subfunção 2 (Gerenciamento de Memória): informações sobre uso da memória

	function subgerdis2() {
	echo
	echo "Você escolheu 'Informações sobre uso da memória': "
	echo

## Comando

	fdisk -l

## Pergunta ao usuário se quer voltar ou sair.

	goback

	}


MAIN
