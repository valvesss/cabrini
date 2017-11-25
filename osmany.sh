#!/bin/bash

## Verifica se possui as dependências necessárias

a=0
b=0
while [[ $a -eq 0 ]]; do

	#clear

	if ! hash dialog &>/dev/null; then

		echo "Dialog não instalado...."
		b=1
		pn1='dialog'

	fi

	if ! hash nmon &>/dev/null; then

		echo "Nmon não instalado..."
		b=1
		pn2=nmon
	fi

	if [[ $b -eq 1 ]]; then

		echo "Para executar o script é necessário instalar as dependências mostradas acima."--
		read -e -p $'Deseja instalá-las? [s/n]' opt

		if [[ $opt = 's' ]] || [[ $opt = 'S' ]]; then

			if [[ $EUID -eq 0 ]]; then

				apt install -y dialog nmon
				./osmany.sh
			else
				if ! sudo apt install -y dialog nmon &>/dev/null ; then
					
					echo "Usuário não possui direitos administrativos."
					echo "Entre como root e digite 'apt -y install $pn1 $pn2'"

				else

					sudo apt install -y dialog nmon 

				fi
			fi
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

## Comando de saída padrão 

function leave(){

clear
echo "Good-Bye... "
exit

}

## Informações a serem utilizadas pelo Gerenciamento de Memória
function basic() {

## Cria pastas para definição dos thresholds
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

## Informações padrão para o disco

function disaux() { 

disuso=$(df | grep /dev/sda | awk 'NR==1 {print $5}' | tr -d '%')

}		

## Informações padrão para a memória

function memaux() {

memtotal=$(free | awk 'NR==2 {print $2}')
memtotal=$(($memtotal * 1024))
memfree=$(free | awk 'NR==2 {print $4}')
memfree=$(($memfree * 1024))
memused=$(($memtotal - $memfree))
memfinal=$(($memused * 100 / $memtotal))

}

## Informações padrão para a CPU

function cpuaux() {

cpuidle=$(vmstat | awk 'NR==3 {print $15}')
cpuuso=$((100 - $cpuidle))

}

## Função principal do programa

function main() {

## Limpa a tela 

clear

## Mensagem de apresentação do script.

	opt=$(dialog				\
	--stdout				\
	--title 'Gerenciador de Sistema OSM'	\
	--menu 'Escolha a opção desejada:'	\
	0 0 0					\
	1 'Gerenciador de Disco.'		\
	2 'Gerenciador de Memória.'		\
	3 'Gerenciador de CPU.'			\
	4 'Monitorar Sistema.'			\
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

if [[ $? = 0 ]]; then

	main
else

clear

exit

fi
}

################## Gerenciar sistema ##############################

##########  Função de gerenciamento de disco  ##########
function gerdis() {

## Alarme de uso de disco

if [[ $disuso -gt $tdispadrao ]]; then

	dialog								\
	--title 'ATENÇÃO'						\
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

fdisk -l | head -n 1 > /tmp/aux1
fdisk -l | tail -n 6 > /tmp/aux2
cat /tmp/aux* >	/tmp/disco1.txt
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

if [[ $? -eq 1 ]]; then

	gerdis
fi

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

######################  Função de gerenciamento de memória  #########################3

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

free -h > farq
dialog --title 'INFORMAÇÕES SOBRE MEMÓRIA' --textbox farq 0 0
rm -rf farq
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

if [[ $? -eq 1 ]]; then

	germem
fi

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

#####################  Função de gerenciamento de processos  ####################### 

function gercpu(){

## Alarme de uso de cpu

if [[ $cpuuso -gt $tcpupadrao ]]; then

	dialog										\
	--title 'ATENÇÃO'							\
	--msgbox "USO DE CPU ACIMA DO RECOMENDADO PELO ADMINISTRADOR!
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
	5 'Alterar prioridade de processos'			\
	6 'Iniciar processo com prioridade definida'		\
	7 'Voltar'						\
	8 'Sair')

	case $opt in

	1) subgercpu1 ;;
	2) subgercpu2 ;;
	3) subgercpu3 ;;
	4) subgercpu4 ;;
	5) subgercpu5 ;;
	6) subgercpu6 ;;
	7) main ;;
	8) leave ;;
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

	ps aux | sort -k 3 -r | tr -s " "  | cut -d ' ' -f1,2,11 | column -t > /tmp/subg2
	dialog 						\
	--title 'SNAPSHOT' 				\
	--textbox /tmp/subg2				\
	0 0

else

	ps -U $USER -u $USER u | sort -k 3 -r | tr -s " "  | cut -d ' ' -f1,2,11 | column -t > /tmp/subg2
	dialog 						\
	--title 'SNAPSHOT' 				\
	--textbox /tmp/subg2				\
	0 0

fi

gercpu

}

## Subfunção 3 (Gerenciamento de Processos): encerrar algum processo

function subgercpu3() {

	dialog									\
	--stdout								\
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

else

	exipro1

fi
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
nonexist=0
while [[ $a -eq 0 ]]; do

## Verifica se o processo exite. Rp = root pid. Rpk = root pid kill.

## Se for root
	if [[ $userid -eq 0 ]]; then

		if `ps aux | awk '{print $11}' | grep -q $procname` ; then

			ps aux | grep $procname > /tmp/pe
			pidnum1=$(ps aux | grep $procname | awk 'NR==1 {print $2}')
			pidnum2=$(ps aux | grep $procname | awk 'NR==2 {print $2}')

		else

			nonexist=1

		fi

	else

## Se for usuário comum
		if `ps aux -U $USER -u $USER u | awk '{print $11}' | grep -q $procname` ; then

			ps aux -U $USER -u $USER u | grep $procname > /tmp/peu
			pidnum1=$(ps aux -U $USER -u $USER u | grep $procname | awk 'NR==1 {print $2}')
			pidnum2=$(ps aux -U $USER -u $USER u | grep $procname | awk 'NR==2 {print $2}')

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
nonexist=0
while [[ $a -eq 0 ]]; do

## Verifica se o processo existe. Rp = root pid. Rpk = root pid kill.

## Se for root
	if [[ $userid -eq 0 ]]; then


		if `ps aux | awk '{print $2}' | grep -q $procpid` ; then

			pidnum1=$(ps aux | grep $procpid | awk 'NR==1 {print $2}')
			ps aux | grep $procpid > /tmp/pe

		else

			nonexist=1

		fi

	else
## Se for usuário comum

		if `ps aux -U $USER -u $USER u | awk '{print $2}' | grep $procpid` ; then

			pidnum1=$(ps aux -U $USER -u $USER u | grep $procpid | awk 'NR==1 {print $2}')
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

		procname=$(ps aux | grep -q -w $procpid | awk '{print $11}')
		killpro
	fi

done

}

function killpro() {	

## Se for root

if [[ $userid -eq 0 ]]; then

	dialog										\
	--stdout									\
	--title 'NOME DO PROCESSO'							\
	--yesno "Deseja encerrar esse processo?\n\n `cat /tmp/pe | awk 'NR==1'`"	\
	8 110

	if [[ $? -eq 0 ]]; then

		let a=a+1

		## Encerra processo
		kill $pidnum1 &>/dev/null
		kill $pidnum2 &>/dev/null
		dialog 									\
		--stdout							\
		--title 'FEITO'							\
		--msgbox "Processo de pid '$pidnum1' foi encerrado."	\
		5 60

	else

		subgercpu3
	fi

else

## Se for outro usuário

	dialog											\
	--title 'NOME DO PROCESSO'							\
	--yesno "Deseja encerrar esse processo??\n\n `cat /tmp/peu | awk 'NR==1'`"	\
	8 110

	if [[ $? -eq 0 ]]; then

		let a=a+1

		## Encerra processo
		kill $pidnum1 &>/dev/null
		kill $pidnum2 &>/dev/null
		dialog 								\
		--stdout						\
		--title 'FEITO'						\
		--msgbox "Processo de pid '$pidnum1' encerrado."	\
		5 60

	else

		gercpu	
	fi

fi

## Retorna ao menu de cpu

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

if [[ $? -eq 1 ]]; then

	gercpu

fi

## Redefine variável de threshold de cpu padrão

a=0
while [[ $a -lt 10 ]]; do

	if [[ $opt -eq $a ]]; then

		tcpupadrao=$((50+$a*5))
		let a=10

	else

		let a=a+1

	fi
done

## Mensagem de atualização de threshold
dialog --msgbox 'Valor de threshold atualizado!' 0 0 

## Retorna ao menu de cpu
gercpu

}

## Subfunção 5 (Gerenciamento de Processos): alterar prioridade de processos

function subgercpu5() {

## Questiona o PID do processo e a nova prioridade dele

	pidnum=$(dialog									\
	--stdout								\
	--inputbox 'Digite o PID do Processo' 0 0				\
	)

if [[ $? -eq 1 ]]; then


	gercpu
fi

## Verifica se processo existe 

## Se for root

nonexist=0
if [[ $userid -eq 0 ]]; then

	if ! `ps aux | awk '{print $2}' | grep -q -w $pidnum` ; then
	nonexist=1

	fi

else

## Se for usuário comum

	if ! `ps aux -U $USER -u $USER u | awk '{print $2}' | grep -q -w $pidnum` ; then

	nonexist=1

	fi
fi

## Caso processo não exista, retorna erro

if [[ $nonexist -eq 1 ]]; then

	dialog --title 'IMPORTANTE' --yesno 'Processo não encontrado! \n\n Tentar novamente?' 0 0

	if [[ $? -eq 0 ]]; then

		subgercpu5

	else
		gercpu

	fi
else

	altpri

fi

}


function altpri() {

	altnum=$(dialog								\
	--stdout								\
	--title 'PRIORIDADES'							\
	--radiolist '\nEscolha a nova prioridade do processo.
	\n\nObs: Quanto menor o número, maior será a prioridade.'		\
	0 0 0									\
	+19 'Menos Relevante' off 						\
	+18 '.' off								\
	+17 '.' off								\
	+16 '.' off								\
	+15 '.' off								\
	+14 '.' off								\
	+13 '.' off								\
	+12 '.' off								\
	+11 '.' off								\
	+10 '.' off			 					\
	+09 '.' off								\
	+08 '.' off								\
	+07 '.' off								\
	+06 '.' off								\
	+05 '.' off								\
	+04 '.' off								\
	+03 '.' off								\
	+02 '.' off								\
	+01 '.' off								\
	+00 'Médio Relevante' off						\
	-01 '.' off								\
	-02 '.' off								\
	-03 '.' off								\
	-04 '.' off								\
	-05 '.' off								\
	-06 '.' off								\
	-07 '.' off								\
	-08 '.' off								\
	-09 '.' off								\
	-10 '.' off								\
	-11 '.' off								\
	-12 '.' off								\
	-13 '.' off								\
	-14 '.' off								\
	-15 '.' off								\
	-16 '.' off								\
	-17 '.' off								\
	-18 '.' off								\
	-19 '.' off								\
	-20 'Mais Relevante' off)

## Validação caso nada seja selecionado

if [[ ! -n $altnum ]] ; then

	dialog --stdout --title 'ATENÇÃO' --msgbox 'Nenhuma opção selecionada, tente novamente.' 0 0
	altpri

fi

## Validação aceitar/cancelar
if [[ $? -eq 1 ]]; then

	subgercpu5

fi


## Altera prioridade do processo
renice $altnum $pidnum 1> /tmp/renout

## Mensagem de sucesso
dialog --title 'SUCESSO' --textbox /tmp/renout 0 0 \

## Retorna ao menu de cpu
gercpu

}

## Subfunção 6 (Gerenciamento de Processos): iniciar processo com prioridade específica

function subgercpu6() {

## Pergunta o nome do processo

	procname=$(dialog						\
	--stdout							\
	--inputbox 'Digite o nome do processo que quer iniciar:' 0 0	\
	)

## Validação cancelar/entrar
if [[ $? -eq 1 ]]; then

	gercpu

fi

## Validação se programa existe
if ! `dpkg --get-selections | grep -q $procname` ; then

	dialog --title 'IMPORTANTE' --yesno 'Processo não encontrado! \n\n Tentar novamente?' 0 0

	if [[ $? -eq 0 ]]; then

		subgercpu6

	else

	gercpu

	fi
fi

sgc6alt

}


function sgc6alt() {

## Pergunta qual prioridade deve ser colocada a esse processo

	altnum=$(dialog								\
	--stdout								\
	--title 'PRIORIDADES'							\
	--radiolist '\nEscolha prioridade que processo irá iniciar.
	\n\nObs: Quanto menor o número, maior será a prioridade.'		\
	0 0 0									\
	+19 'Menos Relevante' off 						\
	+18 '.' off								\
	+17 '.' off								\
	+16 '.' off								\
	+15 '.' off								\
	+14 '.' off								\
	+13 '.' off								\
	+12 '.' off								\
	+11 '.' off								\
	+10 '.' off			 					\
	+09 '.' off								\
	+08 '.' off								\
	+07 '.' off								\
	+06 '.' off								\
	+05 '.' off								\
	+04 '.' off								\
	+03 '.' off								\
	+02 '.' off								\
	+01 '.' off								\
	+00 'Médio Relevante' off						\
	-01 '.' off								\
	-02 '.' off								\
	-03 '.' off								\
	-04 '.' off								\
	-05 '.' off								\
	-06 '.' off								\
	-07 '.' off								\
	-08 '.' off								\
	-09 '.' off								\
	-10 '.' off								\
	-11 '.' off								\
	-12 '.' off								\
	-13 '.' off								\
	-14 '.' off								\
	-15 '.' off								\
	-16 '.' off								\
	-17 '.' off								\
	-18 '.' off								\
	-19 '.' off								\
	-20 'Mais Relevante' off)

## Validação caso nada seja selecionado
if [[ ! -n $altnum ]] ; then

	dialog --stdout --title 'ATENÇÃO' --msgbox 'Nenhuma opção selecionada, tente novamente.' 0 0
	sgc6alt

fi

## Validação aceitar/cancelar

if [[ $? -eq 1 ]]; then

	subgercpu6

fi

## Filtra resposta por + ou -

value=$(echo $altnum | grep -q + && echo + || echo -)
nnum=$(echo $altnum | sed 's/[^0-9]//g')

if [[ $value == '+' ]]; then

	value=-

else

	value=--
fi

## Inicia programa com prioridade pré-definida
nice $value$nnum $procname &

## Mensagem de sucesso
dialog --stdout --title 'SUCESSO' --msgbox 'Processo iniciado com sucesso' 0 0

## Retorna ao menu de cpu
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
