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
			echo "Para executar o script é necessário instalar as dependências mostradas acima."--
			read -e -p $'Deseja instalá-las? [s/n]' opt
				if [[ $opt = 's' ]] || [[ $opt = 'S' ]]; then
					apt install -y dialog nmon
					./osmany.sh
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

	## Informações a serem utilizadas pelo Gerenciamento de Memória
	function basic() {

	mkdir -p /tmp/thresholds

	touch /tmp/thresholds/tdis
	echo "70" > /tmp/thresholds/tdis
	tdispadrao=$(cat /tmp/thresholds/tdis)

	touch /tmp/thresholds/tmem
	echo "70" > /tmp/thresholds/tmem
	tmempadrao=$(cat /tmp/thresholds/tmem)

	touch /tmp/thresholds/tcpu
	echo "70" > /tmp/thresholds/tcpu
	tcpupadrao=$(cat /tmp/thresholds/tcpu) 

	main
	}

	function disaux() { 

	## Informações padrão para o disco

	disuso=$(df | grep /dev/sda | awk 'NR==1 {print $5}' | tr -d '%')

	}		

	function memaux() {

	## Informações padrão para a memória

	memtotal=$(free | awk 'NR==2 {print $2}')
	memtotal=$(($memtotal * 1024))
	memfree=$(free | awk 'NR==2 {print $4}')
	memfree=$(($memfree * 1024))
	memused=$(($memtotal - $memfree))
	memfinal=$(($memused * 100 / $memtotal))

	}

	function cpuaux() {

	## Informações padrão para a CPU

	cpuidle=$(vmstat | awk 'NR==3 {print $15}')
	cpuuso=$((100 - $cpuidle))

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
		3 'Gerenciador de CPU'			\
		4 'Monitorar Sistema'			\
		5 'Sair.')

	## Invoca a opção selecionada do usuário.

	case $opt in 
		1) disaux ; gerdis ;;
		2) memaux ; germem ;;
		3) cpuaux ; gercpu ;;
		4) monsis ;;
		5) leave ;;
		*) leave ;;
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
	
	## Alarme de uso de disco

	if [[ $disuso -gt $tdispadrao ]]; then
		dialog										\
			--title 'ATENÇÃO'							\
			--msgbox "USO DO DISCO ACIMA DO RECOMENDADO PELO ADMINISTRADOR!
				\n\n EM USO = $disuso% \n RECOMENDADO = $tdispadrao%\n\n"	\
			0 0
	fi

	## Mensagem de apresentação.

	## Menu de Root
	
	if [[ $userid -eq 0 ]]; then

		opt=$(dialog							\
			--stdout						\
			--title 'Bem vindo ao Gerenciador de Disco do OSM!'	\
			--menu 'Escolha a opção desejada:'			\
			0 0 0							\
			1 'Informações sobre espaço em disco'			\
			2 'Informações sobre partições'				\
			3 'Definir thresholds de uso do disco'			\
			4 'Voltar'						\
			5 'Sair')
	
		case $opt in
			1) subgerdis1 ;;
			2) subgerdis2 ;;
			3) subgerdis3 ;;
			4) main ;;
			5) leave ;;
			*) main ;;
		esac

	else
		## Menu usuário comum

		opt=$(dialog							\
			--stdout						\
			--title 'Bem vindo ao Gerenciador de Disco do OSM!'	\
			--menu 'Escolha a opção desejada:'			\
			0 0 0							\
			1 'Informações sobre espaço em disco'			\
			2 'Voltar'						\
			3 'Sair')
	
		case $opt in
			1) subgerdis1 ;;
			2) main ;;
			3) leave ;;
			*) main ;;
		esac

	fi
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

	## Subfunção 3 (Gerenciamento de Disco): definir thresholds para disco

	function subgerdis3() {

	opt=$(dialog								\
		--stdout							\
		--title 'THRESHOLD DISCO'					\
		--menu 'Escolha o novo valor de threshold para o disco:'	\
		0 0 0								\
		0 '50%'								\
		1 '55%'								\
		2 '60%'								\
		3 '65%'								\
		4 '70%'	 							\
		5 '75%'								\
		6 '80%'								\
		7 '85%'								\
		8 '90%'								\
		9 '95%')

	a=0
	while [[ $a -lt 10 ]]; do
		if [[ $opt -eq $a ]]; then
			tdispadrao=$((50+$a*5))
			let a=10
		else
			let a=a+1
		fi
	done

	dialog --msgbox 'Valor de threshold atualizado!' 0 0 

	gerdis

	}
	###  Função de gerenciamento de memória  #### 

	function germem() {

	## Alarme de uso de memória

	if [[ $memfinal -gt $tmempadrao ]]; then
		dialog										\
			--title 'ATENÇÃO'							\
			--msgbox "USO DE RAM ACIMA DO RECOMENDADO PELO ADMINISTRADOR!
				\n\n EM USO = $memfinal% \n RECOMENDADO = $tmempadrao%\n\n"	\
			0 0
	fi

	## Mensagem de apresentação.
	
	## Menu root

	if [[ $userid -eq 0 ]]; then
		opt=$(dialog							\
			--stdout						\
			--title 'Bem vindo ao Gerenciador de Memória do OSM!'	\
			--menu 'Escolha a opção desejada:'			\
			0 0 0							\
			1 'Informações sobre a memória'				\
			2 'Definir threshold de uso'				\
			3 'Voltar'						\
			4 'Sair')
		
			case $opt in
				1) subgermem1 ;;
				2) subgermem2 ;;
				3) main ;;
				4) leave ;;
				*) main ;;
			esac
	else
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
				*) main ;;
			esac

	fi
	}

	## Subfunção 1 (Gerenciamento de Memória): informações sobre memória livre

	function subgermem1() {

	export NMON=m
	nmon

	germem

	}

	## Subfunção 2 (Gerenciamento de Memória): definir threshold para alarmes

	function subgermem2() {
	
	opt=$(dialog								\
		--stdout							\
		--title 'THRESHOLD MEMÒRIA'					\
		--menu 'Escolha o novo valor de threshold para a memória:'	\
		0 0 0								\
		0 '50%'								\
		1 '55%'								\
		2 '60%'								\
		3 '65%'								\
		4 '70%'	 							\
		5 '75%'								\
		6 '80%'								\
		7 '85%'								\
		8 '90%'								\
		9 '95%')

	a=0
	while [[ $a -lt 10 ]]; do
		if [[ $opt -eq $a ]]; then
			tmempadrao=$((50+$a*5))
			let a=10
		else
			let a=a+1
		fi
	done

	dialog --msgbox 'Valor de threshold atualizado!' 0 0 

	germem

	}

	###  Função de gerenciamento de processos  #### 

	function gercpu(){

	## Alarme de uso de cpu

	if [[ $cpuuso -gt $tcpupadrao ]]; then
		dialog										\
			--title 'ATENÇÃO'							\
			--msgbox "USO DO DISCO ACIMA DO RECOMENDADO PELO ADMINISTRADOR!
				\n\n EM USO = $cpuuso% \n RECOMENDADO = $tcpupadrao%\n\n"	\
			0 0
	fi

	## Mensagem de apresentação.

	## Menu root

	if [[ $userid -eq 0 ]]; then
		opt=$(dialog							\
			--stdout						\
			--title 'Bem vindo ao Gerenciador de CPU do OSM!'	\
			--menu 'Escolha a opção desejada:'			\
			0 0 0							\
			1 'Informações sobre os processos em tempo real'	\
			2 'Snapshot sobre os processos atuais'			\
			3 'Encerrar algum processo'				\
			4 'Definir threshold de uso da cpu'			\
			5 'Voltar'						\
			6 'Sair')
		
		case $opt in
			1) subgercpu1 ;;
			2) subgercpu2 ;;
			3) subgercpu3 ;;
			4) subgercpu4 ;;
			5) main ;;
			6) leave ;;
			*) main ;;
		esac
	else
		opt=$(dialog							\
			--stdout						\
			--title 'Bem vindo ao Gerenciador de CPU do OSM!'	\
			--menu 'Escolha a opção desejada:'			\
			0 0 0							\
			1 'Informações sobre os processos em tempo real'	\
			2 'Snapshot sobre os processos atuais'			\
			3 'Encerrar algum processo'				\
			4 'Voltar'						\
			5 'Sair')
		
		case $opt in
			1) subgercpu1 ;;
			2) subgercpu2 ;;
			3) subgercpu3 ;;
			4) main ;;
			5) leave ;;
			*) main ;;
		esac
	fi
	}

	## Subfunção 1 (Gerenciamento de Processos): informações sobre processos em tempo real

	function subgercpu1() {

	if [[ $userid -eq 0 ]]; then
	       top	
       	else
	       top -u $USER
	fi

	gercpu

	}

	## Subfunção 2 (Gerenciamento de Processos): snapshot sobre o uso da memória em tempo real

	function subgercpu2() {

	if [[ $userid -eq 0 ]]; then
		ps aux | more
	else
		ps -U $USER -u $USER u | more
	fi

	gercpu

	}

	## Subfunção 3 (Gerenciamento de Processos): encerrar algum processo

	function subgercpu3() {

	dialog										\
		--title 'IMPORTANTE'							\
		--yesno '\nPara encerrar um processo é necessário saber seu PID.	
			\n\nCaso não saiba o PID do processo que deseja encerrar	
			\né possível buscá-lo pelo nome.
			\n\nDeseja procurar seu PID pelo nome?\n\n'			\
       		0 0

	## Procura o processo do usuário

	if [[ $? -eq 0 ]]; then
		
		propro1

	else

		propro2
	fi

	}

	function propro1() {
	
		procname=$(dialog							\
				--stdout						\
				--title 'PID'						\
				--inputbox 'Digite o nome do processo a ser procurado:'	\
				0 0)

		if [[ $? -eq 1 ]]; then
			gercpu
		fi

		exipro1
	}

	function propro2() {
		procpid=$(dialog							\
				--stdout						\
				--title 'PID'						\
				--inputbox 'Digite o PID do processo a ser encerrado:'	\
				0 0)

		if [[ $? -eq 1 ]]; then
			gercpu
		fi

		exipro2
	}

	function exipro1(){
		a=0
		while [[ $a -eq 0 ]]; do

			## Verifica se o processo exite. Rp = root pid. Rpk = root pid kill.

			## Se for root
			if [[ $userid -eq 0 ]]; then
	
	
				ps aux | awk '{print $2}' > /tmp/rp
				pidnum=$(ps aux | grep $procname | awk 'NR==1 {print $2}')

				if `cat /tmp/rp | grep -q -w $pidnum` ; then
					ps aux | grep $procname > /tmp/pe
				else
					nonexist=1
				fi

			else
			## Se for usuário comum

				ps aux -U $USER -u $USER u | awk '{print $2}' > /tmp/up
				pidnum=$(ps aux -U $USER -u $USER u | grep $procname | awk 'NR==1 {print $2}')

				if `cat /tmp/up | grep -q -w $pidnum` ; then
					ps aux -U $USER -u $USER u | grep $procname > /tmp/peu
				else
					nonexist=1
				fi

			fi

			if [[ $nonexist -eq 1 ]]; then
				dialog --title 'IMPORTANTE' --yesno 'Processo não encontrado! \n\n Tentar novamente?' 0 0
				if [[ $? -eq 0 ]]; then
					propro1
				else
					gercpu
				fi
			else
				killpro
			fi
		done
	}
	function exipro2 () {

	a=0
	while [[ $a -eq 0 ]]; do

		## Verifica se o processo exite. Rp = root pid. Rpk = root pid kill.

		## Se for root
		if [[ $userid -eq 0 ]]; then
	
	
			ps aux | awk '{print $2}' > /tmp/rp
			pidnum=$(ps aux | grep $procpid | awk 'NR==1 {print $2}')

			if `cat /tmp/rp | grep -q -w $pidnum` ; then
				ps aux | grep $procpid > /tmp/pe
			else
				nonexist=1
			fi

		else
			## Se for usuário comum

			ps aux -U $USER -u $USER u | awk '{print $2}' > /tmp/up
			pidnum=$(ps aux -U $USER -u $USER u | grep $procpid | awk 'NR==1 {print $2}')

			if `cat /tmp/up | grep -q -w $pidnum` ; then
				ps aux -U $USER -u $USER u | grep $procpid > /tmp/peu
			else
				nonexist=1
			fi

		fi

		if [[ $nonexist -eq 1 ]]; then
			dialog --title 'IMPORTANTE' --yesno 'Processo não encontrado! \n\n Tentar novamente?' 0 0
			if [[ $? -eq 0 ]]; then
				propro2
			else
				gercpu
			fi
		else
			killpro
		fi
	done
	
	}
	function killpro() {	

		## Se for root
		if [[ $userid -eq 0 ]]; then


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
						--msgbox "Processo '$procname' de pid '$pidnum' foi encerrado."	\
						5 60
				else
					gercpu
				fi

		else
			## Se for outro usuário
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
						--msgbox "Processo '$procname' de pid '$pidnum' encerrado."	\
						5 60
				else
					gercpu
				fi

		fi

	## Pergunta ao usuário se quer voltar ou sair.

	gercpu

	}

	## Subfunção 4 (Gerenciamento de Processos): definir thresholds de uso da cpu

	function subgercpu4() {

	opt=$(dialog								\
		--stdout							\
		--title 'THRESHOLD CPU'						\
		--menu 'Escolha o novo valor de threshold para a cpu:'		\
		0 0 0								\
		0 '50%'								\
		1 '55%'								\
		2 '60%'								\
		3 '65%'								\
		4 '70%'	 							\
		5 '75%'								\
		6 '80%'								\
		7 '85%'								\
		8 '90%'								\
		9 '95%')

	a=0
	while [[ $a -lt 10 ]]; do
		if [[ $opt -eq $a ]]; then
			tcpupadrao=$((50+$a*5))
			let a=10
		else
			let a=a+1
		fi
	done

	dialog --msgbox 'Valor de threshold atualizado!' 0 0 

	gercpu

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
			t	'Processos' off					\
			v	'Voltar' off					\
			s	'Sair' off)

	## Concatena as opções do usuário e executa o nmon.

	if [[ $opt == 'v' ]]; then main; fi

	if [[ $opt == 's' ]]; then leave; fi

	if [[ -n $opt ]]; then
		export NMON="$opt"
		nmon
	fi	

	main
}
basic
