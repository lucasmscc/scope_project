#!/usr/bin/env bash
# Executa os casos de teste (*.f3) e compara com a linha "// esperado: ..." de cada um.
#
# Uso:
#   testes/rodar.sh                    # todos os .f3 desta pasta
#   testes/rodar.sh testes/f1_re.f3    # so os arquivos indicados
#   SEM_BUILD=1 testes/rodar.sh        # nao roda "mvn compile" antes
#
# Valores esperados (apos "// esperado: "):
#   <texto>          resultado impresso pelo interpretador (apos "resultado = " ou "resultado=")
#   erro-sintaxe     ParseException / TokenMgrError
#   erro-tipo        checaTipo falhou (ErroTipoException ou retorno false)
#   erro-variavel    VariavelNaoDeclaradaException na checagem
#   erro-execucao    excecao durante a execucao
#
# Sai com codigo 1 se algum caso falhar.

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RAIZ="$(dirname "$DIR")"
CLASSES="$RAIZ/target/classes"
PREFIXO='Funcional 3 PLP Parser Version 0\.0\.1:'

if [ -z "$SEM_BUILD" ]; then
	(cd "$RAIZ" && mvn -q compile) || { echo "mvn compile falhou; nada foi executado." >&2; exit 2; }
fi

if [ "$#" -gt 0 ]; then
	arquivos=("$@")
else
	arquivos=("$DIR"/*.f3)
fi

classifica() {
	local saida="$1" res
	res=$(printf '%s\n' "$saida" | grep -a -m1 -E "^$PREFIXO +resultado ?= ?" | sed -E "s/^$PREFIXO +resultado ?= ?//")
	if printf '%s\n' "$saida" | grep -a -q -E "^$PREFIXO +resultado ?= ?"; then
		printf '%s' "$res"
	elif printf '%s\n' "$saida" | grep -a -q 'Encountered errors during execution'; then
		printf 'erro-execucao'
	elif printf '%s\n' "$saida" | grep -a -q -E 'ParseException|TokenMgrError'; then
		printf 'erro-sintaxe'
	elif printf '%s\n' "$saida" | grep -a -q 'VariavelNaoDeclaradaException'; then
		printf 'erro-variavel'
	elif printf '%s\n' "$saida" | grep -a -q 'Encountered errors during parse'; then
		printf 'erro-tipo'
	else
		printf 'saida-inesperada'
	fi
}

passou=0
falhou=0
for f in "${arquivos[@]}"; do
	nome="$(basename "$f" .f3)"
	esperado=$(head -n1 "$f" | tr -d '\r' | sed -nE 's|^// esperado: ?(.*)$|\1|p')
	if [ -z "$esperado" ]; then
		echo "FALHA  $nome: primeira linha nao e '// esperado: ...'"
		falhou=$((falhou + 1))
		continue
	fi
	saida=$(timeout 30 java -cp "$CLASSES" lf3.plp.functional3.parser.Func3Parser "$f" 2>&1 </dev/null)
	[ "$?" -eq 124 ] && obtido='timeout' || obtido=$(classifica "$saida")
	if [ "$obtido" = "$esperado" ]; then
		echo "ok     $nome"
		passou=$((passou + 1))
	else
		echo "FALHA  $nome: esperado [$esperado], obtido [$obtido]"
		falhou=$((falhou + 1))
	fi
done

echo "---"
echo "$passou ok, $falhou falha(s)"
[ "$falhou" -eq 0 ]
